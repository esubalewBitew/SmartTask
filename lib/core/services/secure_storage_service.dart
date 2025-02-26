import 'dart:convert';
import 'package:encrypt/encrypt.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SecureStorageService {
  static const _keyPrefix = 'encrypted_';
  static const _keyStorageKey = 'encryption_key';

  final FlutterSecureStorage _secureStorage;
  final SharedPreferences _prefs;
  late final Encrypter _encrypter;
  final IV _iv = IV.fromLength(16);

  SecureStorageService._(this._secureStorage, this._prefs);

  static Future<SecureStorageService> getInstance() async {
    final secureStorage = const FlutterSecureStorage();
    final prefs = await SharedPreferences.getInstance();
    final service = SecureStorageService._(secureStorage, prefs);
    await service._initializeEncryption();
    return service;
  }

  Future<void> _initializeEncryption() async {
    String? encryptionKey = await _secureStorage.read(key: _keyStorageKey);
    if (encryptionKey == null) {
      final key = Key.fromSecureRandom(32);
      encryptionKey = base64.encode(key.bytes);
      await _secureStorage.write(key: _keyStorageKey, value: encryptionKey);
    }
    final key = Key.fromBase64(encryptionKey);
    _encrypter = Encrypter(AES(key));
  }

  Future<void> secureWrite(String key, String value) async {
    final encrypted = _encrypter.encrypt(value, iv: _iv);
    await _prefs.setString('$_keyPrefix$key', encrypted.base64);
  }

  Future<String?> secureRead(String key) async {
    final encrypted = _prefs.getString('$_keyPrefix$key');
    if (encrypted == null) return null;

    try {
      final decrypted = _encrypter.decrypt64(encrypted, iv: _iv);
      return decrypted;
    } catch (e) {
      return null;
    }
  }

  Future<void> secureDelete(String key) async {
    await _prefs.remove('$_keyPrefix$key');
  }

  Future<void> secureClear() async {
    final keys = _prefs.getKeys().where((key) => key.startsWith(_keyPrefix));
    for (final key in keys) {
      await _prefs.remove(key);
    }
  }

  // JWT Token Management
  static const _tokenKey = 'jwt_token';
  static const _refreshTokenKey = 'refresh_token';

  Future<void> saveToken(String token) async {
    await secureWrite(_tokenKey, token);
  }

  Future<String?> getToken() async {
    return await secureRead(_tokenKey);
  }

  Future<void> saveRefreshToken(String token) async {
    await secureWrite(_refreshTokenKey, token);
  }

  Future<String?> getRefreshToken() async {
    return await secureRead(_refreshTokenKey);
  }

  Future<void> clearTokens() async {
    await secureDelete(_tokenKey);
    await secureDelete(_refreshTokenKey);
  }
}
