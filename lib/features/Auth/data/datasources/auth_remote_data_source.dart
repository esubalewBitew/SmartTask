import 'package:dio/dio.dart';

abstract class AuthRemoteDataSource {
  Future<void> login(String email, String password);
  Future<void> register(Map<String, dynamic> userData);
  Future<void> forgotPassword(String email);
  Future<void> signOut();
  Future<void> signInWithGoogle();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Dio dio;

  AuthRemoteDataSourceImpl({required this.dio});

  @override
  Future<void> login(String email, String password) async {
    // Implement login
  }

  @override
  Future<void> register(Map<String, dynamic> userData) async {
    // Implement register
  }

  @override
  Future<void> forgotPassword(String email) async {
    // Implement forgot password
  }

  @override
  Future<void> signOut() async {
    // Implement API call
  }

  @override
  Future<void> signInWithGoogle() async {
    // Implement Google Sign-In
  }
}
