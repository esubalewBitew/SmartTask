import 'package:hive_flutter/hive_flutter.dart';
import 'package:local_auth/local_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:smarttask/core/errors/exceptions.dart';
import 'package:smarttask/features/Auth/data/models/user_dto.dart';

abstract class AuthLocalDataSource {
  Future<void> cacheUserData(LocalUserDTO user);
  Future<LocalUserDTO?> getCachedUserData();
  Future<void> clearUserData();

  Future<bool> authenticateWithBiometrics();
  Future<void> savePin(String pin);
  Future<bool> verifyPin(String pin);
  Future<void> clearPin();

  Future<void> saveAuthToken(String token);
  Future<String?> getAuthToken();
  Future<void> clearAuthToken();
}

class SecureAuthLocalDataSourceImpl implements AuthLocalDataSource {
  SecureAuthLocalDataSourceImpl({
    required Box<dynamic> authBox,
    required LocalAuthentication localAuth,
  })  : _authBox = authBox,
        _localAuth = localAuth;
  final Box<dynamic> _authBox;
  final LocalAuthentication _localAuth;

  static const String kUserKey = 'user_data';
  static const String kPinKey = 'pin';
  static const String kTokenKey = 'auth_token';

  @override
  Future<void> cacheUserData(LocalUserDTO user) async {
    debugPrint('\n=== CACHING USER DATA ===');
    try {
      await _authBox.put(kUserKey, user.toJson());
      debugPrint('✓ User data cached successfully');
      debugPrint('User Data Cached Response: ${user.toJson()}');
      debugPrint('User ID: ${user.id}');
      debugPrint('Email: ${user.email}');
      debugPrint('=== USER DATA CACHED ===\n');
    } catch (e) {
      throw CacheException(message: 'Failed to cache user data: $e');
    }
  }

  @override
  Future<LocalUserDTO?> getCachedUserData() async {
    try {
      final userData = await _authBox.get(kUserKey);
      if (userData == null) return null;

      if (userData is! Map) {
        throw const CacheException(
          message: 'Cached user data is not in the correct format',
        );
      }

      return LocalUserDTO.fromJson(
        Map<String, dynamic>.from(userData),
      );
    } catch (e) {
      throw CacheException(message: 'Failed to get cached user data: $e');
    }
  }

  @override
  Future<void> savePin(String pin) async {
    try {
      await _authBox.put(kPinKey, pin);
    } catch (e) {
      throw CacheException(message: 'Failed to save PIN: $e');
    }
  }

  @override
  Future<bool> verifyPin(String pin) async {
    try {
      final storedPin = await _authBox.get(kPinKey);
      if (storedPin == null) return false;
      return storedPin == pin;
    } catch (e) {
      throw CacheException(message: 'Failed to verify PIN: $e');
    }
  }

  @override
  Future<void> saveAuthToken(String token) async {
    debugPrint('\n=== SAVING AUTH TOKEN ===');
    try {
      await _authBox.put(kTokenKey, token);
      debugPrint('✓ Auth token saved successfully');
      debugPrint('=== AUTH TOKEN SAVED ===\n');
    } catch (e) {
      debugPrint('❌ Failed to save auth token: $e');
      throw CacheException(message: 'Failed to save auth token: $e');
    }
  }

  @override
  Future<String?> getAuthToken() async {
    debugPrint('\n=== GETTING AUTH TOKEN ===');
    try {
      final token = await _authBox.get(kTokenKey);
      debugPrint('Token exists: ${token != null}');
      debugPrint('=== GET AUTH TOKEN COMPLETED ===\n');
      return token?.toString();
    } catch (e) {
      debugPrint('❌ Failed to get auth token: $e');
      throw CacheException(message: 'Failed to get auth token: $e');
    }
  }

  @override
  Future<bool> authenticateWithBiometrics() async {
    try {
      final canCheckBiometrics = await _localAuth.canCheckBiometrics;
      if (!canCheckBiometrics) {
        throw const BiometricException(
          message: 'Biometric authentication not available',
        );
      }

      return await _localAuth.authenticate(
        localizedReason: 'Please authenticate to access your account',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );
    } catch (e) {
      throw BiometricException(message: e.toString());
    }
  }

  @override
  Future<void> clearUserData() async {
    try {
      await _authBox.delete(kUserKey);
    } catch (e) {
      throw CacheException(message: 'Failed to clear user data: $e');
    }
  }

  @override
  Future<void> clearPin() async {
    try {
      await _authBox.delete(kPinKey);
    } catch (e) {
      throw CacheException(message: 'Failed to clear PIN: $e');
    }
  }

  @override
  Future<void> clearAuthToken() async {
    try {
      await _authBox.delete(kTokenKey);
    } catch (e) {
      throw CacheException(message: 'Failed to clear auth token: $e');
    }
  }
}
