import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:smarttask/features/Auth/data/services/auth_service.dart';

class AuthGuard {
  static AuthService? _authService;

  static Future<String?> redirectToLogin(GoRouterState state) async {
    _authService ??= await AuthService.getInstance();

    debugPrint('Current location: ${state.matchedLocation}');
    final isAuth = await _authService!.isAuthenticated();
    debugPrint('Is authenticated: $isAuth');
    final isLoginRoute = state.matchedLocation.startsWith('/auth/');
    debugPrint('Is login route: $isLoginRoute');

    // if (isAuth) {
    //   debugPrint('Redirecting to main page');
    //   return '/workspaces';
    // }

    if (!isAuth && !isLoginRoute) {
      debugPrint('Redirecting to login');
      return '/auth/login';
    }

    if (isAuth && isLoginRoute) {
      debugPrint('Redirecting to main page');
      return '/${state.matchedLocation}';
    }

    debugPrint('No redirection needed');
    return null;
  }

  static Future<void> logout() async {
    _authService ??= await AuthService.getInstance();
    await _authService!.logout();
  }

  static Future<String?> getToken() async {
    _authService ??= await AuthService.getInstance();
    return await _authService!.getCurrentToken();
  }
}
