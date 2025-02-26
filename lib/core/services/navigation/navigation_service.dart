import 'package:smarttask/core/services/router_name.dart';
import 'package:flutter/material.dart';
import 'package:smarttask/core/constants/storage_keys.dart';
import 'package:smarttask/core/services/storage/hive_box_manager.dart';
import 'package:smarttask/features/auth/data/datasources/auth_local_datasource.dart';

class NavigationService {
  bool _hasPinVerification = false;
  final HiveBoxManager _hiveBoxManager;
  final AuthLocalDataSource _authLocalDataSource;
  // final DeviceCheckRepository _deviceCheckRepository;

  NavigationService({
    required HiveBoxManager hiveBoxManager,
    required AuthLocalDataSource authLocalDataSource,
  })  : _hiveBoxManager = hiveBoxManager,
        _authLocalDataSource = authLocalDataSource {
    _initPinVerification();
  }

  Future<void> _initPinVerification() async {
    _hasPinVerification =
        await _hiveBoxManager.getValue<bool>(StorageKeys.pinVerification) ??
            false;
  }

  Future<void> setPinVerification(bool value) async {
    _hasPinVerification = value;
    await _hiveBoxManager.setValue(StorageKeys.pinVerification, value);
    debugPrint('PIN verification state updated: $_hasPinVerification');
  }

  Future<String?> handleRedirect(String location) async {
    try {
      debugPrint('Handling redirect for location: $location');

      // Check device association
      // final deviceCheckResponse = await _deviceCheckRepository.checkDevice();
      // if (deviceCheckResponse.success && deviceCheckResponse.data != null) {
      //   final isDeviceAssociated = deviceCheckResponse.data!.email != null ||
      //       deviceCheckResponse.data!.phoneNumber != null;

      //   if (isDeviceAssociated) {
      //     final token = await _authLocalDataSource.getAuthToken();
      //     final userData = await _authLocalDataSource.getCachedUserData();
      //     final hasValidAuth = token != null && userData != null;

      //     // If not authenticated or no PIN verification, redirect to token login
      //     if (!hasValidAuth || !_hasPinVerification) {
      //       debugPrint('Redirecting to token login: Missing auth or PIN');

      //       if (location == AppRouteName.profileInfo ||
      //           location == AppRouteName.verifyEmail ||
      //           location == AppRouteName.verifyOtp ||
      //           location == AppRouteName.createPin) {
      //         debugPrint('Allowing direct access to auth route: $location');
      //         return null;
      //       }
      //       return AppRouteName.tokenDeviceLogin;
      //     }

      //     // Allow access to protected routes after authentication
      //     if (location.startsWith('/main')) {
      //       debugPrint('Access granted to protected route');
      //       return null;
      //     }

      //     // Redirect other routes to home
      //     debugPrint('Redirecting to home route');
      //     return AppRouteName.mainPage;
      //   }
      // }

      // Handle first-time users
      final box = _hiveBoxManager.mainBox;
      final isFirstTimer =
          box.get(StorageKeys.firstTimer, defaultValue: true) as bool;

      if (isFirstTimer) {
        return AppRouteName.onboarding;
      }

      return AppRouteName.signIn;
    } catch (e) {
      debugPrint('Navigation error: $e');
      return AppRouteName.signIn;
    }
  }
}
