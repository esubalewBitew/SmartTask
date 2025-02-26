import 'package:hive_flutter/hive_flutter.dart';
import 'package:smarttask/features/Tasks/data/models/task_model.dart';
import 'package:smarttask/features/Auth/data/models/user_dto.dart';

class LocalStorage {
  static const String tasksBox = 'tasks';
  static const String userBox = 'user';
  static const String settingsBox = 'settings';

  static Future<void> init() async {
    await Hive.initFlutter();

    // Register adapters
    Hive.registerAdapter(TaskModelAdapter());
    Hive.registerAdapter(LocalUserDTOAdapter());

    // Open boxes
    await Hive.openBox<TaskModel>(tasksBox);
    await Hive.openBox<LocalUserDTO>(userBox);
    await Hive.openBox<dynamic>(settingsBox);
  }
}
