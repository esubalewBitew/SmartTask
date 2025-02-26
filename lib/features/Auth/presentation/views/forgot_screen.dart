import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smarttask/core/common/widgets/custom_button.dart';
import 'package:smarttask/core/common/widgets/custom_textfield.dart';
import 'package:smarttask/core/di/injection_container.dart';
import 'package:smarttask/core/services/router_name.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<AuthBloc>(),
      child: const _ForgotPasswordView(),
    );
  }
}

class _ForgotPasswordView extends StatefulWidget {
  const _ForgotPasswordView({Key? key}) : super(key: key);

  @override
  State<_ForgotPasswordView> createState() => _ForgotPasswordViewState();
}

class _ForgotPasswordViewState extends State<_ForgotPasswordView> {
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
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
      ),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (true) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Password reset link sent to your email'),
                backgroundColor: Colors.green,
              ),
            );
            context.go('${AppRouteName.login}');
          } else if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(theme),
                    const SizedBox(height: 40),
                    _buildEmailField(theme),
                    const SizedBox(height: 40),
                    _buildResetButton(context, state),
                    const SizedBox(height: 24),
                    _buildBackToLogin(theme),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Forgot Password?',
          style: GoogleFonts.poppins(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onBackground,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Enter your email address to receive a password reset link',
          style: GoogleFonts.poppins(
            fontSize: 16,
            color: theme.colorScheme.onBackground.withOpacity(0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildEmailField(ThemeData theme) {
    return CustomTextFormField(
      controller: _emailController,
      labelText: 'Email',
      hintText: 'Enter your email address',
      textInputType: TextInputType.emailAddress,
      prefixIcon: Icon(
        Icons.email_outlined,
        color: theme.colorScheme.primary,
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your email';
        }
        if (!value.contains('@') || !value.contains('.')) {
          return 'Please enter a valid email';
        }
        return null;
      },
    );
  }

  Widget _buildResetButton(BuildContext context, AuthState state) {
    return CustomButton(
      text: 'Reset Password',
      onPressed: state is AuthLoading
          ? null
          : () {
              if (_formKey.currentState?.validate() ?? false) {
                context.go('${AppRouteName.login}');
                // context.read<AuthBloc>().add(
                //       ForgotPasswordRequested(
                //         email: _emailController.text,
                //       ),
                //     );
              }
            },
      showLoadingIndicator: state is AuthLoading,
      options: CustomButtonOptions(
        width: double.infinity,
        height: 56,
        color: Theme.of(context).colorScheme.primary,
        textStyle: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
    );
  }

  Widget _buildBackToLogin(ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Remember your password? ',
          style: GoogleFonts.poppins(
            color: theme.colorScheme.onBackground.withOpacity(0.7),
          ),
        ),
        TextButton(
          onPressed: () => context.go('${AppRouteName.login}'),
          child: Text(
            'Login',
            style: GoogleFonts.poppins(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
