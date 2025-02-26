import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:smarttask/core/di/injection_container.dart' as di;
import 'package:smarttask/core/services/route.dart';
import 'package:smarttask/features/Main/Home/presentation/bloc/home_bloc.dart';
import 'package:smarttask/features/Main/Tasks/presentation/bloc/task_bloc.dart';
import 'package:smarttask/features/Main/Workspace/presentation/bloc/workspace_bloc.dart';
import 'package:smarttask/core/theme/theme_cubit.dart';
import 'package:smarttask/core/theme/theme_manager.dart';
import 'package:smarttask/core/services/notification_service.dart';
import 'firebase_options.dart';

Future<void> main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();

    // Initialize Firebase first
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // Configure reCAPTCHA
    await FirebaseAuth.instance.setSettings(
      appVerificationDisabledForTesting:
          true, // Temporarily disable for testing
      forceRecaptchaFlow: false,
    );

    // Initialize notification service
    await NotificationService().initialize();

    // Initialize other dependencies
    final prefs = await SharedPreferences.getInstance();
    await di.init();

    runApp(MyApp(prefs: prefs));
  } catch (e, stackTrace) {
    debugPrint('Error during initialization: $e');
    debugPrint('Stack trace: $stackTrace');
    // Show error UI instead of crashing
    runApp(const ErrorApp());
  }
}

class ErrorApp extends StatelessWidget {
  const ErrorApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              const Text(
                'Failed to initialize app',
                style: TextStyle(fontSize: 20),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () async {
                  // Retry initialization
                  await main();
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  final SharedPreferences prefs;

  const MyApp({Key? key, required this.prefs}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => di.sl<HomeBloc>()),
        BlocProvider(create: (context) => di.sl<TaskBloc>()),
        BlocProvider(create: (context) => di.sl<WorkspaceBloc>()),
        BlocProvider(create: (context) => ThemeCubit(prefs)),
      ],
      child: BlocBuilder<ThemeCubit, ThemeState>(
        builder: (context, themeState) {
          return MaterialApp.router(
            debugShowCheckedModeBanner: false,
            title: 'SmartTask',
            routerConfig: goRouter,
            theme: ThemeManager.lightTheme,
            darkTheme: ThemeManager.darkTheme,
            themeMode: themeState == ThemeState.dark
                ? ThemeMode.dark
                : ThemeMode.light,
          );
        },
      ),
    );
  }
}
