import 'package:hive_flutter/hive_flutter.dart';
import 'package:smarttask/core/constants/storage_keys.dart';
import 'package:smarttask/core/services/storage/secure_storage_service.dart';

class HiveBoxManager {
  static final HiveBoxManager _instance = HiveBoxManager._internal();
  factory HiveBoxManager() => _instance;

  final SecureStorageService _secureStorage = SecureStorageService();
  Box<dynamic>? _mainBox;
  Box<dynamic>? _authBox;

  HiveBoxManager._internal();

  Future<void> init() async {
    await Hive.initFlutter();
    await _initAuthBox();
    await _initMainBox();
  }

  Future<void> _initAuthBox() async {
    if (_authBox != null) return;
    _authBox = await _secureStorage.openSecureBox<dynamic>(StorageKeys.authBox);
  }

  Future<T?> getValue<T>(String key) async {
    await _initAuthBox();
    return _authBox?.get(key) as T?;
  }

  Future<void> setValue<T>(String key, T value) async {
    await _initAuthBox();
    await _authBox?.put(key, value);
  }

  Future<void> _initMainBox() async {
    if (_mainBox != null) return;
    _mainBox = await Hive.openBox<dynamic>(StorageKeys.mainBox);
  }

  Box<dynamic> get authBox {
    if (_authBox == null) {
      throw StateError('AuthBox not initialized. Call init() first.');
    }
    return _authBox!;
  }

  Box<dynamic> get mainBox {
    if (_mainBox == null) {
      throw StateError('MainBox not initialized. Call init() first.');
    }
    return _mainBox!;
  }

  Future<void> closeBoxes() async {
    await _authBox?.close();
    await _mainBox?.close();
    _authBox = null;
    _mainBox = null;
  }
}
