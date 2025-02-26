import 'package:firebase_auth/firebase_auth.dart';
import 'package:smarttask/core/services/secure_storage_service.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:flutter/material.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late final SecureStorageService _storage;

  AuthService._();

  static Future<AuthService> getInstance() async {
    final service = AuthService._();
    service._storage = await SecureStorageService.getInstance();
    return service;
  }

  Future<bool> isAuthenticated() async {
    try {
      // First check Firebase auth state
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        debugPrint('No current user in Firebase');
        return false;
      }

      // Refresh the user to ensure we have the latest state
      await currentUser.reload();

      // Get fresh ID token
      final idToken = await currentUser.getIdToken(true);
      if (idToken == null) {
        debugPrint('No ID token available');
        return false;
      }

      // Save the fresh token
      await _storage.saveToken(idToken);
      debugPrint('User authenticated with Firebase: ${currentUser.uid}');
      return true;
    } catch (e) {
      debugPrint('Error checking authentication: $e');
      return false;
    }
  }

  Future<void> saveAuthTokens(String token, String refreshToken) async {
    await _storage.saveToken(token);
    await _storage.saveRefreshToken(refreshToken);
    debugPrint('Auth tokens saved successfully');
  }

  Future<void> logout() async {
    await _storage.clearTokens();
    await _auth.signOut();
    debugPrint('User logged out');
  }

  Future<String?> getCurrentToken() async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser != null) {
        return await currentUser.getIdToken(true);
      }
      return await _storage.getToken();
    } catch (e) {
      debugPrint('Error getting current token: $e');
      return null;
    }
  }
}
