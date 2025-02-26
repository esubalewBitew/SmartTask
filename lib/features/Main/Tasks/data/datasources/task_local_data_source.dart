import 'package:hive/hive.dart';
import 'package:smarttask/features/Main/Tasks/data/models/task_model.dart';

abstract class TaskLocalDataSource {
  Future<List<TaskModel>> getTasks();
  Future<TaskModel> getTask(String id);
  Future<TaskModel> saveTask(TaskModel task);
  Future<void> deleteTask(String id);
  Future<void> saveTasks(List<TaskModel> tasks);
  Future<void> clearTasks();
  Future<List<TaskModel>> getUnsyncedTasks();
  Future<void> markTaskAsSynced(String id);
}

class TaskLocalDataSourceImpl implements TaskLocalDataSource {
  final Box<Map> taskBox;
  static const String boxName = 'tasks';

  TaskLocalDataSourceImpl({required this.taskBox});

  @override
  Future<List<TaskModel>> getTasks() async {
    final taskMaps = taskBox.values.toList();
    return taskMaps
        .map((map) => TaskModel.fromJson(Map<String, dynamic>.from(map)))
        .toList();
  }

  @override
  Future<TaskModel> getTask(String id) async {
    final taskMap = taskBox.get(id);
    if (taskMap == null) {
      throw Exception('Task not found');
    }
    return TaskModel.fromJson(Map<String, dynamic>.from(taskMap));
  }

  @override
  Future<TaskModel> saveTask(TaskModel task) async {
    await taskBox.put(task.id, task.toJson());
    return task;
  }

  @override
  Future<void> deleteTask(String id) async {
    await taskBox.delete(id);
  }

  @override
  Future<void> saveTasks(List<TaskModel> tasks) async {
    final Map<String, Map<String, dynamic>> taskMap = {
      for (var task in tasks) task.id: task.toJson()
    };
    await taskBox.putAll(taskMap);
  }

  @override
  Future<void> clearTasks() async {
    await taskBox.clear();
  }

  @override
  Future<List<TaskModel>> getUnsyncedTasks() async {
    final tasks = await getTasks();
    return tasks.where((task) => !task.isSynced).toList();
  }

  @override
  Future<void> markTaskAsSynced(String id) async {
    final task = await getTask(id);
    final updatedTask = TaskModel(
      id: task.id,
      title: task.title,
      description: task.description,
      createdAt: task.createdAt,
      updatedAt: task.updatedAt,
      dueDate: task.dueDate,
      isCompleted: task.isCompleted,
      userId: task.userId,
      isSynced: true,
      lastSyncedAt: DateTime.now(),
    );
    await saveTask(updatedTask);
  }
}
