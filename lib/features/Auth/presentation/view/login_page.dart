import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:otp/otp.dart';
import 'package:smarttask/core/services/router_name.dart';
import 'package:smarttask/features/Auth/data/services/auth_service.dart';
import 'package:crypto/crypto.dart';
import 'package:convert/convert.dart';
import 'dart:convert';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _otpController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;
  late final AuthService _authService;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  bool _show2FAPrompt = false;
  String? _userEmail;

  @override
  void initState() {
    super.initState();
    _initializeAuthService();
  }

  Future<void> _initializeAuthService() async {
    _authService = await AuthService.getInstance();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _signInWithGoogle() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      // Trigger the Google Sign In flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        throw Exception('Google sign in aborted');
      }

      // Get authentication details
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Create Firebase credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase
      final userCredential = await _auth.signInWithCredential(credential);
      final user = userCredential.user;
      if (user == null) throw Exception('Failed to sign in with Google');

      // Check if 2FA is enabled for this user
      final docSnapshot =
          await _firestore.collection('users').doc(user.uid).get();
      final is2FAEnabled = docSnapshot.data()?['is2FAEnabled'] ?? false;

      if (is2FAEnabled) {
        setState(() {
          _show2FAPrompt = true;
          _userEmail = user.email;
        });
        return;
      }

      // Get the ID token
      final idToken = await user.getIdToken();
      if (idToken != null) {
        await _authService.saveAuthTokens(idToken, idToken);

        if (mounted) {
          context.goNamed(AppRouteName.mainPage);
        }
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to sign in with Google: ${e.toString()}';
      });
      debugPrint('Google sign in error: $e');
    } finally {
      if (mounted && !_show2FAPrompt) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<bool> _verify2FA(String code, String uid) async {
    try {
      final docSnapshot = await _firestore.collection('users').doc(uid).get();
      final data = docSnapshot.data();
      if (data == null) return false;

      // Check if it's a backup code
      final backupCodes = List<String>.from(data['backupCodes'] ?? []);
      final backupCodesUsed = List<bool>.from(data['backupCodesUsed'] ?? []);

      // Hash the provided code
      final bytes = utf8.encode(code);
      final hashedCode = sha256.convert(bytes).toString();

      // Check if it matches any unused backup code
      final backupCodeIndex = backupCodes.indexOf(hashedCode);
      if (backupCodeIndex != -1 && !backupCodesUsed[backupCodeIndex]) {
        // Mark the backup code as used
        backupCodesUsed[backupCodeIndex] = true;
        await _firestore.collection('users').doc(uid).update({
          'backupCodesUsed': backupCodesUsed,
        });
        return true;
      }

      // If not a backup code, verify TOTP
      final secretKey = data['totpSecret'];
      if (secretKey == null) return false;

      final currentOtp = OTP.generateTOTPCodeString(
        secretKey,
        DateTime.now().millisecondsSinceEpoch,
        algorithm: Algorithm.SHA1,
        isGoogle: true,
      );

      return code == currentOtp;
    } catch (e) {
      debugPrint('Error verifying 2FA: $e');
      return false;
    }
  }

  Future<void> _verify2FAAndProceed() async {
    if (_otpController.text.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter the verification code';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('No user found');

      final isValid = await _verify2FA(_otpController.text, user.uid);
      if (!isValid) {
        setState(() {
          _errorMessage = 'Invalid verification code';
          _isLoading = false;
        });
        return;
      }

      // Get the ID token after 2FA verification
      final idToken = await user.getIdToken();
      if (idToken != null) {
        await _authService.saveAuthTokens(idToken, idToken);

        if (mounted) {
          context.goNamed(AppRouteName.mainPage);
        }
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to verify code: ${e.toString()}';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Sign in with Firebase
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      final user = userCredential.user;
      if (user == null) throw Exception('No user found');

      // Check if 2FA is enabled
      final docSnapshot =
          await _firestore.collection('users').doc(user.uid).get();
      final is2FAEnabled = docSnapshot.data()?['is2FAEnabled'] ?? false;

      if (is2FAEnabled) {
        setState(() {
          _show2FAPrompt = true;
          _userEmail = user.email;
        });
        return;
      }

      // Get the ID token
      final idToken = await user.getIdToken();
      if (idToken != null) {
        await _authService.saveAuthTokens(idToken, idToken);

        if (mounted) {
          context.goNamed(AppRouteName.mainPage);
        }
      } else {
        throw Exception('Failed to get authentication token');
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        switch (e.code) {
          case 'user-not-found':
            _errorMessage = 'No user found with this email';
            break;
          case 'wrong-password':
            _errorMessage = 'Wrong password provided';
            break;
          case 'invalid-email':
            _errorMessage = 'Invalid email address';
            break;
          case 'user-disabled':
            _errorMessage = 'This account has been disabled';
            break;
          default:
            _errorMessage = e.message ?? 'An error occurred during login';
        }
      });
      debugPrint('Login error: ${e.code} - ${e.message}');
    } catch (e) {
      debugPrint('Unexpected login error: $e');
      setState(() {
        _errorMessage = 'An unexpected error occurred';
      });
    } finally {
      if (mounted && !_show2FAPrompt) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_show2FAPrompt) {
      return Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Two-Factor Authentication',
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Enter the verification code from your Google Authenticator app or use a backup code',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
                if (_userEmail != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    'for $_userEmail',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                TextField(
                  controller: _otpController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Enter Verification Code',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                if (_errorMessage != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    _errorMessage!,
                    style: GoogleFonts.poppins(
                      color: Colors.red[700],
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _isLoading ? null : _verify2FAAndProceed,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[600],
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Text(
                          'Verify',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 48),
                Text(
                  'Welcome Back',
                  style: GoogleFonts.poppins(
                    fontSize: 32,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Sign in to continue',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 32),
                if (_errorMessage != null)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red[50],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _errorMessage!,
                      style: GoogleFonts.poppins(
                        color: Colors.red[700],
                      ),
                    ),
                  ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    if (!value.contains('@')) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    if (value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _isLoading ? null : _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[600],
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Text(
                          'Sign In',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Divider(color: Colors.grey[300]),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'Or',
                        style: GoogleFonts.poppins(
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                    Expanded(
                      child: Divider(color: Colors.grey[300]),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: _isLoading ? null : _signInWithGoogle,
                  icon: Image.network(
                    'https://www.google.com/favicon.ico',
                    height: 24,
                  ),
                  label: Text(
                    'Continue with Google',
                    style: GoogleFonts.poppins(),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () => context.go('/auth/register'),
                  child: Text(
                    'Don\'t have an account? Register',
                    style: GoogleFonts.poppins(
                      color: Colors.blue[600],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
