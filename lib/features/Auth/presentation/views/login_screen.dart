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

class LoginScreen extends StatelessWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<AuthBloc>(),
      child: const _LoginView(),
    );
  }
}

class _LoginView extends StatefulWidget {
  const _LoginView({Key? key}) : super(key: key);

  @override
  State<_LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<_LoginView> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthSuccess) {
            context.go('$AppRouteName.home');
          } else if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
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
                    const SizedBox(height: 40),
                    _buildHeader(theme),
                    const SizedBox(height: 40),
                    _buildLoginForm(theme, state),
                    const SizedBox(height: 24),
                    _buildForgotPassword(theme),
                    const SizedBox(height: 40),
                    _buildLoginButton(context, state),
                    const SizedBox(height: 24),
                    _buildRegisterLink(theme),
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
          'Welcome Back!',
          style: GoogleFonts.poppins(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onBackground,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Sign in to continue',
          style: GoogleFonts.poppins(
            fontSize: 16,
            color: theme.colorScheme.onBackground.withOpacity(0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildLoginForm(ThemeData theme, AuthState state) {
    return Column(
      children: [
        CustomTextFormField(
          controller: _emailController,
          labelText: 'Email',
          hintText: 'Enter your email',
          textInputType: TextInputType.emailAddress,
          prefixIcon:
              Icon(Icons.email_outlined, color: theme.colorScheme.primary),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your email';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        CustomTextFormField(
          controller: _passwordController,
          labelText: 'Password',
          hintText: 'Enter your password',
          isPassword: true,
          prefixIcon:
              Icon(Icons.lock_outline, color: theme.colorScheme.primary),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your password';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildForgotPassword(ThemeData theme) {
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton(
        onPressed: () => context.goNamed(AppRouteName.forgotPassword),
        child: Text(
          'Forgot Password?',
          style: GoogleFonts.poppins(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildLoginButton(BuildContext context, AuthState state) {
    return CustomButton(
      text: 'Login',
      onPressed: state is AuthLoading
          ? null
          : () {
              if (_formKey.currentState?.validate() ?? false) {
                context.goNamed(AppRouteName.mainPage);
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

  Widget _buildRegisterLink(ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Don\'t have an account? ',
          style: GoogleFonts.poppins(
            color: theme.colorScheme.onBackground.withOpacity(0.7),
          ),
        ),
        TextButton(
          onPressed: () => context.go('$AppRouteName.register'),
          child: Text(
            'Register',
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
