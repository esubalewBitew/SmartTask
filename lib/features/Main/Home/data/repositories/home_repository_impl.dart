import '../../domain/entities/task_entity.dart';
import '../../domain/repositories/home_repository.dart';
import '../datasources/home_remote_data_source.dart';

class HomeRepositoryImpl implements HomeRepository {
  final HomeRemoteDataSource remoteDataSource;

  HomeRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<TaskEntity>> getTasks() async {
    return await remoteDataSource.getTasks();
  }

  @override
  Future<void> createTask(TaskEntity task) async {
    // Convert TaskEntity to TaskModel
    // await remoteDataSource.createTask(taskModel);
  }

  @override
  Future<void> updateTask(TaskEntity task) async {
    // Convert TaskEntity to TaskModel
    // await remoteDataSource.updateTask(taskModel);
  }

  @override
  Future<void> deleteTask(String taskId) async {
    await remoteDataSource.deleteTask(taskId);
  }

  @override
  Future<void> toggleTaskStatus(String taskId) async {
    await remoteDataSource.toggleTaskStatus(taskId);
  }
}
