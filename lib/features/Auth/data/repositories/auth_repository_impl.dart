import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl(this.remoteDataSource);

  @override
  Future<void> signIn(String email, String password) async {
    return await remoteDataSource.login(email, password);
  }

  @override
  Future<void> signUp(String email, String password, String name) async {
    return await remoteDataSource.register({
      'email': email,
      'password': password,
      'name': name,
    });
  }

  @override
  Future<void> forgotPassword(String email) async {
    return await remoteDataSource.forgotPassword(email);
  }

  @override
  Future<void> signOut() async {
    return await remoteDataSource.signOut();
  }

  @override
  Future<void> signInWithGoogle() async {
    return await remoteDataSource.signInWithGoogle();
  }
}
