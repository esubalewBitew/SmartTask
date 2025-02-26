import 'package:hive_flutter/hive_flutter.dart';
import 'package:smarttask/core/errors/exceptions.dart';
import 'package:smarttask/features/Auth/data/datasources/auth_local_datasource.dart';
import 'package:smarttask/features/Auth/data/models/user_dto.dart';

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final Box<dynamic> hiveManager;

  AuthLocalDataSourceImpl({required this.hiveManager});

  @override
  Future<void> cacheUserData(LocalUserDTO user) async {
    await hiveManager.put('user_data', user.toJson());
  }

  @override
  Future<LocalUserDTO?> getCachedUserData() async {
    final userData = await hiveManager.get('user_data');
    if (userData == null) return null;
    return LocalUserDTO.fromJson(Map<String, dynamic>.from(userData));
  }

  @override
  Future<void> clearUserData() async {
    await hiveManager.delete('user_data');
  }

  @override
  Future<void> saveAuthToken(String token) async {
    await hiveManager.put('auth_token', token);
  }

  @override
  Future<String?> getAuthToken() async {
    return hiveManager.get('auth_token')?.toString();
  }

  @override
  Future<void> clearAuthToken() async {
    await hiveManager.delete('auth_token');
  }

  @override
  Future<bool> authenticateWithBiometrics() async {
    return false; // Implement actual biometric auth later
  }

  @override
  Future<void> savePin(String pin) async {
    await hiveManager.put('pin', pin);
  }

  @override
  Future<bool> verifyPin(String pin) async {
    final savedPin = await hiveManager.get('pin');
    return pin == savedPin;
  }

  @override
  Future<void> clearPin() async {
    await hiveManager.delete('pin');
  }
}
