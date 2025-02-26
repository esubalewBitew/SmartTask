import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:go_router/go_router.dart';
import 'package:smarttask/core/common/widgets/custom_button.dart';
import 'package:smarttask/core/services/router_name.dart';

class SSOScreen extends StatefulWidget {
  const SSOScreen({Key? key}) : super(key: key);

  @override
  State<SSOScreen> createState() => _SSOScreenState();
}

class _SSOScreenState extends State<SSOScreen> {
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _signInWithGoogle() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Initialize Google Sign-In
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return;

      // Get auth details from request
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Create credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in with Firebase
      await FirebaseAuth.instance.signInWithCredential(credential);

      if (mounted) {
        context.go('/${AppRouteName.home}');
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to sign in with Google';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _signInWithApple() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      final oAuthCredential = OAuthProvider('apple.com').credential(
        idToken: credential.identityToken,
        accessToken: credential.authorizationCode,
      );

      await FirebaseAuth.instance.signInWithCredential(oAuthCredential);

      if (mounted) {
        context.go('/${AppRouteName.home}');
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to sign in with Apple';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Future<void> _signInWithMicrosoft() async {
  //   setState(() {
  //     _isLoading = true;
  //     _errorMessage = null;
  //   });

  //   try {
  //     final microsoftAuth = FlutterMicrosoftAuth(
  //       clientId: 'YOUR_MICROSOFT_CLIENT_ID',
  //       redirectUri: 'YOUR_REDIRECT_URI',
  //       scope: 'openid profile email',
  //     );

  //     final result = await microsoftAuth.signIn();
  //     if (result != null) {
  //       final OAuthCredential credential =
  //           OAuthProvider('microsoft.com').credential(
  //         accessToken: result.accessToken,
  //       );

  //       await FirebaseAuth.instance.signInWithCredential(credential);

  //       if (mounted) {
  //         context.go('/${AppRouteName.home}');
  //       }
  //     }
  //   } catch (e) {
  //     setState(() {
  //       _errorMessage = 'Failed to sign in with Microsoft';
  //     });
  //   } finally {
  //     if (mounted) {
  //       setState(() {
  //         _isLoading = false;
  //       });
  //     }
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: theme.colorScheme.onBackground,
          ),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Sign in with',
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onBackground,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Text(
                    _errorMessage!,
                    style: TextStyle(
                      color: theme.colorScheme.error,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              CustomButton(
                text: 'Continue with Google',
                onPressed: _isLoading ? null : _signInWithGoogle,
                showLoadingIndicator: _isLoading,
                options: CustomButtonOptions(
                  width: double.infinity,
                  height: 56,
                  color: Colors.white,
                  textStyle: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              const SizedBox(height: 16),
              // CustomButton(
              //   text: 'Continue with Microsoft',
              //   onPressed: _isLoading ? null : _signInWithMicrosoft,
              //   showLoadingIndicator: _isLoading,
              //   options: CustomButtonOptions(
              //     width: double.infinity,
              //     height: 56,
              //     color: Colors.white,
              //     textStyle: GoogleFonts.poppins(
              //       fontSize: 16,
              //       fontWeight: FontWeight.w600,
              //       color: Colors.black87,
              //     ),
              //     borderRadius: BorderRadius.circular(16),
              //     border: Border.all(color: Colors.grey[300]!),
              //     icon: Image.asset(
              //       'assets/images/microsoft_logo.png',
              //       height: 24,
              //     ),
              //   ),
              // ),
              if (Theme.of(context).platform == TargetPlatform.iOS) ...[
                const SizedBox(height: 16),
                CustomButton(
                  text: 'Continue with Apple',
                  onPressed: _isLoading ? null : _signInWithApple,
                  showLoadingIndicator: _isLoading,
                  options: CustomButtonOptions(
                    width: double.infinity,
                    height: 56,
                    color: Colors.black,
                    textStyle: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
