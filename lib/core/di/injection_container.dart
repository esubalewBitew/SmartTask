import 'package:get_it/get_it.dart';
import 'package:path_provider/path_provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smarttask/core/network/api_interception.dart';
import 'package:smarttask/features/Auth/data/datasources/auth_local_datasource.dart';
import 'package:smarttask/features/Auth/data/datasources/auth_local_datasource_impl.dart';
import 'package:smarttask/features/Auth/data/datasources/auth_remote_data_source.dart';
import 'package:smarttask/features/Auth/data/repositories/auth_repository_impl.dart';
import 'package:smarttask/features/Auth/domain/repositories/auth_repository.dart';
import 'package:smarttask/features/Auth/presentation/bloc/auth_bloc.dart';
import 'package:smarttask/features/Main/Home/data/datasources/home_remote_data_source.dart';
import 'package:smarttask/features/Main/Home/data/repositories/home_repository_impl.dart';
import 'package:smarttask/features/Main/Home/domain/repositories/home_repository.dart';
import 'package:smarttask/features/Main/Home/presentation/bloc/home_bloc.dart';
import 'package:smarttask/features/Main/Analytics/data/datasources/analytics_remote_data_source.dart';
import 'package:smarttask/features/Main/Analytics/data/repositories/analytics_repository_impl.dart';
import 'package:smarttask/features/Main/Analytics/domain/repositories/analytics_repository.dart';
import 'package:smarttask/features/Main/Analytics/presentation/bloc/analytics_bloc.dart';
import 'package:smarttask/features/Main/Tasks/data/datasources/task_local_data_source.dart';
import 'package:smarttask/features/Main/Tasks/data/datasources/task_remote_data_source.dart';
import 'package:smarttask/features/Main/Tasks/data/repositories/task_repository_impl.dart';
import 'package:smarttask/features/Main/Tasks/domain/repositories/task_repository.dart';
import 'package:smarttask/features/Main/Tasks/presentation/bloc/task_bloc.dart';
import 'package:smarttask/features/Main/Workspace/data/repositories/workspace_repository_impl.dart';
import 'package:smarttask/features/Main/Workspace/domain/repositories/workspace_repository.dart';
import 'package:smarttask/features/Main/Workspace/presentation/bloc/workspace_bloc.dart';
import 'package:smarttask/core/network/network_info.dart';
import 'package:smarttask/core/theme/theme_cubit.dart';
import 'package:dio/dio.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // Initialize Hive
  final appDocumentDir = await getApplicationDocumentsDirectory();
  await Hive.initFlutter(appDocumentDir.path);
  await Hive.openBox<dynamic>('settingsBox');

  // External
  final taskBox = await Hive.openBox<Map>('tasks');
  sl.registerLazySingleton(() => taskBox);
  sl.registerLazySingleton(() => FirebaseFirestore.instance);
  sl.registerLazySingleton(() => FirebaseAuth.instance);
  sl.registerLazySingleton(() => Connectivity());
  sl.registerLazySingleton(() => Dio());
  sl.registerLazySingleton(() => ApiInterceptor());
  sl.registerLazySingleton(() => SharedPreferences.getInstance());

  // Core
  sl.registerLazySingleton<NetworkInfo>(
    () => NetworkInfoImpl(sl()),
  );

  // Theme
  sl.registerLazySingleton(() async => ThemeCubit(await sl()));

  // Features - Auth
  sl.registerFactory(() => AuthBloc(authRepository: sl()));
  sl.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(sl()));
  sl.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(hiveManager: sl()),
  );
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(dio: sl()),
  );

  // Features - Home
  sl.registerFactory(() => HomeBloc(homeRepository: sl()));
  sl.registerLazySingleton<HomeRepository>(() => HomeRepositoryImpl(sl()));
  sl.registerLazySingleton<HomeRemoteDataSource>(
      () => HomeRemoteDataSourceImpl());

  // Features - Analytics
  sl.registerFactory(() => AnalyticsBloc(analyticsRepository: sl()));
  sl.registerLazySingleton<AnalyticsRepository>(
      () => AnalyticsRepositoryImpl(sl()));
  sl.registerLazySingleton<AnalyticsRemoteDataSource>(
      () => AnalyticsRemoteDataSourceImpl());

  // Features - Tasks
  sl.registerFactory(() => TaskBloc());
  sl.registerLazySingleton<TaskRepository>(
    () => TaskRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
      networkInfo: sl(),
    ),
  );
  sl.registerLazySingleton<TaskRemoteDataSource>(
    () => TaskRemoteDataSourceImpl(
      firestore: sl(),
      auth: sl(),
    ),
  );
  sl.registerLazySingleton<TaskLocalDataSource>(
    () => TaskLocalDataSourceImpl(taskBox: sl()),
  );

  // Features - Workspace
  sl.registerFactory(() => WorkspaceBloc(repository: sl()));
  sl.registerLazySingleton<WorkspaceRepository>(
    () => WorkspaceRepositoryImpl(
      firestore: sl(),
      auth: sl(),
    ),
  );
}
