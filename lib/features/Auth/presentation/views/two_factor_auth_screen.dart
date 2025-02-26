import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:smarttask/core/common/widgets/custom_button.dart';
import 'package:smarttask/core/common/widgets/custom_textfield.dart';
import 'package:smarttask/core/services/router_name.dart';
import 'package:smarttask/features/Auth/data/services/two_factor_auth_service.dart';

class TwoFactorAuthScreen extends StatefulWidget {
  final bool isSetup;
  const TwoFactorAuthScreen({Key? key, this.isSetup = true}) : super(key: key);

  @override
  State<TwoFactorAuthScreen> createState() => _TwoFactorAuthScreenState();
}

class _TwoFactorAuthScreenState extends State<TwoFactorAuthScreen> {
  final _otpController = TextEditingController();
  final _twoFactorService = TwoFactorAuthService();
  String? _secretKey;
  String? _qrData;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    if (widget.isSetup) {
      _generateSecretKey();
    }
  }

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  void _generateSecretKey() {
    _secretKey = _twoFactorService.generateSecretKey();
    _qrData = _twoFactorService.generateQrData(_secretKey!);
    setState(() {});
  }

  Future<void> _enableTwoFactor() async {
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
      final isValid =
          _twoFactorService.verifyOTP(_otpController.text, _secretKey!);
      if (!isValid) {
        setState(() {
          _errorMessage = 'Invalid verification code';
        });
        return;
      }

      await _twoFactorService.enableTwoFactor(_secretKey!);

      if (mounted) {
        context.go('/${AppRouteName.home}');
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to enable two-factor authentication';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _verifyTwoFactor() async {
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
      _secretKey = await _twoFactorService.getTwoFactorSecret();

      if (_secretKey == null) {
        throw Exception('Two-factor authentication not set up');
      }

      final isValid =
          _twoFactorService.verifyOTP(_otpController.text, _secretKey!);
      if (!isValid) {
        setState(() {
          _errorMessage = 'Invalid verification code';
        });
        return;
      }

      if (mounted) {
        context.go('/${AppRouteName.home}');
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to verify two-factor authentication';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

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
        title: Text(
          widget.isSetup ? 'Set Up Two-Factor Auth' : 'Two-Factor Verification',
          style: GoogleFonts.poppins(
            color: theme.colorScheme.onBackground,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (widget.isSetup) ...[
                Text(
                  'Scan this QR code with Google Authenticator',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: theme.colorScheme.onBackground,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                if (_qrData != null)
                  Center(
                    child: QrImageView(
                      data: _qrData!,
                      version: QrVersions.auto,
                      size: 200.0,
                      backgroundColor: Colors.white,
                    ),
                  ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        _secretKey ?? '',
                        style: GoogleFonts.robotoMono(
                          fontSize: 16,
                          color: theme.colorScheme.onBackground,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.copy),
                      onPressed: () {
                        if (_secretKey != null) {
                          Clipboard.setData(ClipboardData(text: _secretKey!));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Secret key copied to clipboard'),
                            ),
                          );
                        }
                      },
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 32),
              Text(
                widget.isSetup
                    ? 'Enter the 6-digit code from Google Authenticator'
                    : 'Enter verification code',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: theme.colorScheme.onBackground,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              CustomTextFormField(
                controller: _otpController,
                labelText: 'Verification Code',
                hintText: '000000',
                textInputType: TextInputType.number,
                maxLength: 6,
                textAlign: TextAlign.center,
                style: GoogleFonts.robotoMono(
                  fontSize: 24,
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Text(
                    _errorMessage!,
                    style: TextStyle(
                      color: theme.colorScheme.error,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              const SizedBox(height: 32),
              CustomButton(
                text: widget.isSetup ? 'Enable Two-Factor' : 'Verify',
                onPressed: _isLoading
                    ? null
                    : widget.isSetup
                        ? _enableTwoFactor
                        : _verifyTwoFactor,
                showLoadingIndicator: _isLoading,
                options: CustomButtonOptions(
                  width: double.infinity,
                  height: 56,
                  color: theme.colorScheme.primary,
                  textStyle: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
