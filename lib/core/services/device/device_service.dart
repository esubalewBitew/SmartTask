import 'package:smarttask/core/services/storage/hive_box_manager.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

class DeviceService {
  static const _deviceIdKey = 'device_uuid';
  final HiveBoxManager _hiveManager;

  DeviceService({required HiveBoxManager hiveManager})
      : _hiveManager = hiveManager;

  Future<String> getDeviceId() async {
    try {
      String? deviceId = _hiveManager.mainBox.get(_deviceIdKey) as String?;

      if (deviceId != null) {
        debugPrint('Retrieved existing device ID: $deviceId');
        return deviceId;
      }

      deviceId = const Uuid().v4();
      await _hiveManager.mainBox.put(_deviceIdKey, deviceId);
      debugPrint('Generated new device ID: $deviceId');

      return deviceId;
    } catch (e) {
      debugPrint('❌ Error getting device ID: $e');
      rethrow;
    }
  }
}
