import '../models/task_model.dart';

abstract class HomeRemoteDataSource {
  Future<List<TaskModel>> getTasks();
  Future<void> createTask(TaskModel task);
  Future<void> updateTask(TaskModel task);
  Future<void> deleteTask(String taskId);
  Future<void> toggleTaskStatus(String taskId);
}

class HomeRemoteDataSourceImpl implements HomeRemoteDataSource {
  // Add your API client here

  @override
  Future<List<TaskModel>> getTasks() async {
    // Implement API call
    throw UnimplementedError();
  }

  @override
  Future<void> createTask(TaskModel task) async {
    // Implement API call
    throw UnimplementedError();
  }

  @override
  Future<void> updateTask(TaskModel task) async {
    // Implement API call
    throw UnimplementedError();
  }

  @override
  Future<void> deleteTask(String taskId) async {
    // Implement API call
    throw UnimplementedError();
  }

  @override
  Future<void> toggleTaskStatus(String taskId) async {
    // Implement API call
    throw UnimplementedError();
  }
}
