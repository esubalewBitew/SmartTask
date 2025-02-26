import '../../domain/entities/task_list_entity.dart';
import '../../domain/repositories/tasks_repository.dart';
import '../datasources/tasks_remote_data_source.dart';

class TasksRepositoryImpl implements TasksRepository {
  final TasksRemoteDataSource remoteDataSource;

  TasksRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<TaskListEntity>> getTasks() async {
    return await remoteDataSource.getTasks();
  }

  @override
  Future<TaskListEntity> createTask(TaskListEntity task) async {
    return await remoteDataSource.createTask(task);
  }

  @override
  Future<void> updateTask(TaskListEntity task) async {
    await remoteDataSource.updateTask(task);
  }

  @override
  Future<void> deleteTask(String taskId) async {
    await remoteDataSource.deleteTask(taskId);
  }

  @override
  Future<void> toggleTaskStatus(String taskId) async {
    await remoteDataSource.toggleTaskStatus(taskId);
  }

  @override
  Future<List<TaskListEntity>> filterTasks({
    String? category,
    String? priority,
    bool? isCompleted,
  }) async {
    return await remoteDataSource.filterTasks(
      category: category,
      priority: priority,
      isCompleted: isCompleted,
    );
  }
}
