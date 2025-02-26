import 'package:get_it/get_it.dart';
import '../data/datasources/home_remote_data_source.dart';
import '../data/repositories/home_repository_impl.dart';
import '../domain/repositories/home_repository.dart';
import '../presentation/bloc/home_bloc.dart';

final sl = GetIt.instance;

void initHomeDependencies() {
  // Bloc
  sl.registerFactory(() => HomeBloc(homeRepository: sl()));

  // Repository
  sl.registerLazySingleton<HomeRepository>(
    () => HomeRepositoryImpl(sl()),
  );

  // Data sources
  sl.registerLazySingleton<HomeRemoteDataSource>(
    () => HomeRemoteDataSourceImpl(),
  );
}
