part of 'route.dart';

final GoRouter router = GoRouter(
  initialLocation: '/${AppRouteName.login}',
  errorBuilder: (context, state) => const LoginScreen(),
  routes: [
    // Auth routes
    GoRoute(
      path: '/${AppRouteName.login}',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/${AppRouteName.register}',
      builder: (context, state) => const RegistrationScreen(),
    ),

    // Main app shell with bottom navigation
    ShellRoute(
      builder: (context, state, child) => MainPage(),
      routes: [
        GoRoute(
          path: '/${AppRouteName.mainPage}',
          builder: (context, state) => const MainPage(),
          routes: [
            GoRoute(
              path: 'home',
              builder: (context, state) => const HomePage(),
            ),
            GoRoute(
              path: 'tasks',
              builder: (context, state) => const TasksPage(),
            ),
            GoRoute(
              path: 'profile',
              builder: (context, state) => const ProfilePage(),
            ),
          ],
        ),
      ],
    ),

    // Other routes
    GoRoute(
      path: '/${AppRouteName.forgotPassword}',
      builder: (context, state) => const ForgotPasswordScreen(),
    ),
    GoRoute(
      path: '/${AppRouteName.calendar}',
      builder: (context, state) => const CalendarPage(),
    ),
    GoRoute(
      path: '/${AppRouteName.workspaces}',
      builder: (context, state) => const WorkspaceListScreen(),
    ),
    GoRoute(
      path: '/${AppRouteName.sso}',
      builder: (context, state) => const SSOScreen(),
    ),
    GoRoute(
      path: '/${AppRouteName.twoFactorSetup}',
      builder: (context, state) => const TwoFactorAuthScreen(isSetup: true),
    ),
    GoRoute(
      path: '/${AppRouteName.twoFactorVerify}',
      builder: (context, state) => const TwoFactorAuthScreen(isSetup: false),
    ),
  ],
);

Widget _pageBuilder(Widget page, GoRouterState state) {
  return page;
}
