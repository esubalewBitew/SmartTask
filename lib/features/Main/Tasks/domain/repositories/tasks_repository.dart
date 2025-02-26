import '../entities/task_list_entity.dart';

abstract class TasksRepository {
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
