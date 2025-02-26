import '../models/task_list_model.dart';
import '../../domain/entities/task_list_entity.dart';

abstract class TasksRemoteDataSource {
  Future<List<TaskListEntity>> getTasks();
  Future<TaskListEntity> createTask(TaskListEntity task);
  Future<void> updateTask(TaskListEntity task);
  Future<void> deleteTask(String taskId);
  Future<void> toggleTaskStatus(String taskId);
  Future<List<TaskListEntity>> filterTasks({
    String? category,
    String? priority,
    bool? isCompleted,
  });
}

class TasksRemoteDataSourceImpl implements TasksRemoteDataSource {
  @override
  Future<List<TaskListEntity>> getTasks() async {
    // TODO: Implement API call
    return [];
  }

  @override
  Future<TaskListEntity> createTask(TaskListEntity task) async {
    // TODO: Implement API call
    return task;
  }

  @override
  Future<void> updateTask(TaskListEntity task) async {
    // TODO: Implement API call
  }

  @override
  Future<void> deleteTask(String taskId) async {
    // TODO: Implement API call
  }

  @override
  Future<void> toggleTaskStatus(String taskId) async {
    // TODO: Implement API call
  }

  @override
  Future<List<TaskListEntity>> filterTasks({
    String? category,
    String? priority,
    bool? isCompleted,
  }) async {
    // TODO: Implement API call
    return [];
  }
}
