//

// Common Imports

import 'package:smarttask/core/common/pages/error_screen.dart' as common;
import 'package:smarttask/core/common/presentation/pages/main_page.dart';

import 'package:smarttask/core/services/router_name.dart';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:smarttask/features/Auth/presentation/views/forgot_screen.dart';
import 'package:smarttask/features/Auth/presentation/views/login_screen.dart';
import 'package:smarttask/features/Auth/presentation/views/registration_screen.dart';
import 'package:smarttask/core/services/auth_guard.dart';
import 'package:smarttask/features/Auth/presentation/view/login_page.dart';
import 'package:smarttask/features/Auth/presentation/view/register_page.dart';
import 'package:smarttask/features/Main/Home/presentation/view/home_page.dart';
import 'package:smarttask/features/Main/Tasks/presentation/view/tasks_page.dart';
import 'package:smarttask/features/Main/Profile/presentation/view/profile_page.dart';
import 'package:smarttask/features/Auth/presentation/views/sso_screen.dart';
import 'package:smarttask/features/Auth/presentation/views/two_factor_auth_screen.dart';
import 'package:smarttask/features/Calendar/presentation/views/calendar_page.dart';
import 'package:smarttask/features/Error/presentation/views/error_screen.dart';
import 'package:smarttask/features/Main/Workspace/presentation/view/workspace_list_screen.dart';
import 'package:smarttask/features/Main/Workspace/presentation/view/workspace_detail_screen.dart';
import 'package:smarttask/features/Main/Workspace/domain/entities/workspace_entity.dart';
import 'package:smarttask/features/Settings/presentation/views/notification_preferences_screen.dart';

part 'route.main.dart';

final goRouter = GoRouter(
  initialLocation: '/',
  redirect: (context, state) => AuthGuard.redirectToLogin(state),
  errorBuilder: (context, state) => const ErrorScreen(),
  routes: [
    // Auth Routes
    GoRoute(
      path: '/auth',
      name: AppRouteName.auth,
      builder: (context, state) => const LoginPage(),
      routes: [
        GoRoute(
          path: 'login',
          name: AppRouteName.login,
          builder: (context, state) => const LoginPage(),
        ),
        GoRoute(
          path: 'register',
          name: AppRouteName.register,
          builder: (context, state) => const RegisterPage(),
        ),
        GoRoute(
          path: 'forgot-password',
          name: AppRouteName.forgotPassword,
          builder: (context, state) => const ForgotPasswordScreen(),
        ),
        GoRoute(
          path: 'sso',
          name: AppRouteName.sso,
          builder: (context, state) => const SSOScreen(),
        ),
        GoRoute(
          path: 'two-factor-setup',
          name: AppRouteName.twoFactorSetup,
          builder: (context, state) => const TwoFactorAuthScreen(isSetup: true),
        ),
        GoRoute(
          path: 'two-factor-verify',
          name: AppRouteName.twoFactorVerify,
          builder: (context, state) =>
              const TwoFactorAuthScreen(isSetup: false),
        ),
      ],
    ),

    // Main app shell with bottom navigation
    ShellRoute(
      builder: (context, state, child) => MainPage(),
      routes: [
        GoRoute(
          path: '/',
          name: AppRouteName.mainPage,
          builder: (context, state) => const HomePage(),
          routes: [
            GoRoute(
              path: 'home',
              name: AppRouteName.home,
              builder: (context, state) => const HomePage(),
            ),
            GoRoute(
              path: 'tasks',
              name: AppRouteName.tasks,
              builder: (context, state) => const TasksPage(),
            ),
            GoRoute(
              path: 'profile',
              name: AppRouteName.profile,
              builder: (context, state) => const ProfilePage(),
            ),
            GoRoute(
              path: 'calendar',
              name: AppRouteName.calendar,
              builder: (context, state) => const CalendarPage(),
            ),
            // Workspace Routes
            GoRoute(
              path: 'workspaces',
              name: AppRouteName.workspaces,
              builder: (context, state) => const WorkspaceListScreen(),
            ),
            GoRoute(
              path: 'workspaces/:id',
              name: AppRouteName.workspaceDetail,
              builder: (context, state) => WorkspaceDetailScreen(
                workspace: state.extra as WorkspaceEntity,
              ),
            ),
            // Settings routes
            GoRoute(
              path: 'settings/notifications',
              name: AppRouteName.notificationPreferences,
              builder: (context, state) =>
                  const NotificationPreferencesScreen(),
            ),
          ],
        ),
      ],
    ),
  ],
);

class AppRouter {
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case RouterName.main:
        return MaterialPageRoute(
          builder: (_) => const MainPage(),
        );
      default:
        return MaterialPageRoute(
          builder: (_) => const common.ErrorScreen(),
        );
    }
  }
}
