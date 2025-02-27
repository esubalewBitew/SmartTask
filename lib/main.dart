import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:smarttask/core/di/injection_container.dart' as di;
import 'package:smarttask/core/services/route.dart';
import 'package:smarttask/features/Main/Home/presentation/bloc/home_bloc.dart';
import 'package:smarttask/features/Main/Tasks/presentation/bloc/task_bloc.dart';
import 'package:smarttask/features/Main/Workspace/presentation/bloc/workspace_bloc.dart';
import 'package:smarttask/core/theme/theme_cubit.dart';
import 'package:smarttask/core/theme/theme_manager.dart';
import 'package:smarttask/core/services/notification_service.dart';
import 'firebase_options.dart';

// Handle background messages
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  print('Handling a background message: ${message.messageId}');
}

void main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();

    // Initialize Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // Set up background message handler
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Initialize notification service
    print('Initializing notification service...');
    final notificationService = NotificationService();
    await notificationService.initialize().then((_) {
      print('Notification service initialized successfully');
    }).catchError((error) {
      print('Error initializing notification service: $error');
    });

    // Initialize dependency injection
    await di.init();

    // Get SharedPreferences instance
    final prefs = await SharedPreferences.getInstance();

    runApp(MyApp(prefs: prefs));
  } catch (e) {
    print('Error initializing app: $e');
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
                  //await main();
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
