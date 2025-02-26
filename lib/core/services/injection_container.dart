import 'package:smarttask/core/services/api_service.dart';
import 'package:smarttask/features/Auth/data/datasources/auth_remote_data_source.dart';
import 'package:smarttask/features/Main/Home/presentation/bloc/home_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:local_auth/local_auth.dart';
import 'package:path_provider/path_provider.dart';
import 'package:smarttask/core/api/config/api_config.dart';
import 'package:smarttask/core/network/api_client.dart';
import 'package:smarttask/core/services/storage/hive_box_manager.dart';
import 'package:smarttask/core/services/device/device_service.dart';

part 'injection_container.main.dart';

final sl = GetIt.instance;

Future<void> init() async {
  final appDocumentDir = await getApplicationDocumentsDirectory();
  await Hive.initFlutter(appDocumentDir.path);

  final hiveManager = HiveBoxManager();
  await hiveManager.init();

  sl.registerLazySingleton(() => hiveManager);

  _registerCoreDependencies();
  await _onBoardingInit();
  //await initAuth();
  await _initCreateOrder();

  // Home Feature
  //sl.registerFactory(() => HomeBloc(repository: sl()));
  //sl.registerFactory(() => LoadRequestBloc(repository: sl()));

  sl.registerFactory(() => ApiClient());
  sl.registerFactory(() => ApiService(apiClient: sl()));
  // sl.registerLazySingleton<LoadDetailRepository>(
  //   () => LoadDetailRepositoryImpl(remoteDataSource: sl()),
  // );
  // sl.registerLazySingleton<LoadDetailRemoteDataSource>(
  //   () => LoadDetailRemoteDataSourceImpl(apiService: sl()),
  // );
  // sl.registerLazySingleton<HomeRepository>(
  //   () => HomeRepositoryImpl(remoteDataSource: sl()),
  // );
  // sl.registerLazySingleton<HomeRemoteDataSource>(
  //   () => HomeRemoteDataSourceImpl(apiClient: sl()),
  // );

  // // Driver Order Feature
  // sl.registerLazySingleton<DriverOrderRepository>(
  //   () => DriverOrderRepository(apiClient: sl()),
  // );

  // sl.registerFactory(
  //   () => DriverOrderBloc(repository: sl()),
  // );

  // ... rest of your registrations ...
}

Future<void> _initCreateOrder() async {
  // sl
  //   ..registerLazySingleton<CreateOrderRemoteDataSource>(
  //     () => CreateOrderRemoteDataSourceImpl(
  //       apiClient: sl(),
  //     ),
  //   )
  //   ..registerLazySingleton<CreateOrderRepository>(
  //     () => CreateOrderRepositoryImpl(sl<CreateOrderRemoteDataSource>()),
  //   )
  //   ..registerFactory(
  //     () => CreateOrderBloc(
  //       repository: sl(),
  //     ),
  //   );
}

void _registerCoreDependencies() {
  sl
    ..registerLazySingleton(LocalAuthentication.new)
    ..registerLazySingleton(
      () => ApiConfig(localDataSource: sl()),
    )
    ..registerLazySingleton(() => sl<ApiConfig>().client)
    ..registerLazySingleton(
      () => DeviceService(hiveManager: sl()),
    );
}

Future<void> _onBoardingInit() async {
  // sl
  //   ..registerFactory(
  //     () => OnBoardingCubit(
  //       cacheFirstTimer: sl(),
  //       checkIfUserFirstTimer: sl(),
  //     ),
  //   )
  //   ..registerLazySingleton(() => CacheFirstTimer(sl()))
  //   ..registerLazySingleton(() => CheckIfUserFirstTimer(sl()))
  //   ..registerLazySingleton<OnBoardingRepo>(() => OnBoardingRepoImpl(sl()))
  //   ..registerLazySingleton<OnBoardingLocalDataSource>(
  //     () => OnBoardingLocalDataSourceImpl(hiveManager: sl()),
  //   );
}

// Future<void> initAuth() async {
//   sl
//     ..registerLazySingleton<AuthRemoteDataSource>(
//       () => AuthRemoteDataSourceImpl(
//         apiClient: sl(),
//         localDataSource: sl(),
//         deviceService: sl(),
//       ),
//     )
//     // ..registerLazySingleton<ApiClient>(ApiClient.new)
//     ..registerLazySingleton<AuthLocalDataSource>(
//       () => SecureAuthLocalDataSourceImpl(
//         authBox: sl<HiveBoxManager>().authBox,
//         localAuth: sl(),
//       ),
//     )
//     ..registerLazySingleton<AuthRepository>(
//       () => AuthRepositoryImpl(
//         remoteDataSource: sl(),
//         localDataSource: sl(),
//       ),
//     )
//     ..registerLazySingleton(() => SignInWithEmail(sl()))
//     ..registerLazySingleton(() => SignInWithPhone(sl()))
//     ..registerLazySingleton(() => VerifyOtp(sl()))
//     ..registerLazySingleton(() => VerifyEmail(sl()))
//     ..registerLazySingleton(() => ResendOtp(sl()))
//     ..registerLazySingleton(() => ResendEmailVerification(sl()))
//     ..registerLazySingleton(() => SignUp(sl()))
//     ..registerLazySingleton(() => CreatePin(sl()))
//     ..registerLazySingleton(() => LoginWithPin(sl()))
//     ..registerLazySingleton(() => ForgotPin(sl()))
//     ..registerLazySingleton(() => ForgotPinWithPhone(sl()))
//     ..registerLazySingleton(() => ResetPin(sl()))
//     ..registerLazySingleton(() => UnlinkDevice(sl()))
//     ..registerLazySingleton(() => Logout(sl()))
//     ..registerFactory(
//       () => AuthBloc(
//         signInWithEmail: sl(),
//         signInWithPhone: sl(),
//         verifyOtp: sl(),
//         verifyEmail: sl(),
//         resendOtp: sl(),
//         resendEmailVerification: sl(),
//         signUp: sl(),
//         createPin: sl(),
//         loginWithPin: sl(),
//         forgotPin: sl(),
//         forgotPinWithPhone: sl(),
//         resetPin: sl(),
//         unlinkDevice: sl(),
//         logout: sl(),
//         localDataSource: sl(),
//       ),
//     );
// }
