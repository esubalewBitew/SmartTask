import '../entities/task_entity.dart';

abstract class HomeRepository {
  Future<List<TaskEntity>> getTasks();
  Future<void> createTask(TaskEntity task);
  Future<void> updateTask(TaskEntity task);
  Future<void> deleteTask(String taskId);
  Future<void> toggleTaskStatus(String taskId);
}
