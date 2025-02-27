import 'package:hive_flutter/hive_flutter.dart';
import 'dart:math';

class SecureStorageService {
  static const String _encryptionKeyBoxName = '_internal_keys';
  static const String _encryptionKeyKey = 'encryption_key';

  Future<Box<T>> openSecureBox<T>(String boxName) async {
    final encryptionKey = await _getOrCreateEncryptionKey();

    return await Hive.openBox<T>(
      boxName,
      encryptionCipher: HiveAesCipher(encryptionKey),
    );
  }

  Future<List<int>> _getOrCreateEncryptionKey() async {
    final keyBox = await Hive.openBox<String>(_encryptionKeyBoxName);

    String? storedKey = keyBox.get(_encryptionKeyKey);
    if (storedKey != null) {
      return storedKey.codeUnits;
    }

    final key = _generateSecureKey();
    final keyString = String.fromCharCodes(key);
    await keyBox.put(_encryptionKeyKey, keyString);

    return key;
  }

  List<int> _generateSecureKey() {
    final random = Random.secure();
    final key = List<int>.generate(32, (i) => random.nextInt(256));
    return key;
  }
}
