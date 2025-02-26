import 'package:dartz/dartz.dart';
import 'package:smarttask/core/error/failures.dart';
import 'package:smarttask/core/network/network_info.dart';
import 'package:smarttask/features/Main/Tasks/data/datasources/task_local_data_source.dart';
import 'package:smarttask/features/Main/Tasks/data/datasources/task_remote_data_source.dart';
import 'package:smarttask/features/Main/Tasks/data/models/task_model.dart';
import 'package:smarttask/features/Main/Tasks/domain/entities/task_entity.dart';
import 'package:smarttask/features/Main/Tasks/domain/repositories/task_repository.dart';

class TaskRepositoryImpl implements TaskRepository {
  final TaskRemoteDataSource remoteDataSource;
  final TaskLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  TaskRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, List<TaskEntity>>> getTasks() async {
    try {
      if (await networkInfo.isConnected) {
        final remoteTasks = await remoteDataSource.getTasks();
        await localDataSource.saveTasks(remoteTasks);
        return Right(remoteTasks);
      } else {
        final localTasks = await localDataSource.getTasks();
        return Right(localTasks);
      }
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, TaskEntity>> getTask(String id) async {
    try {
      if (await networkInfo.isConnected) {
        final remoteTask = await remoteDataSource.getTask(id);
        await localDataSource.saveTask(remoteTask);
        return Right(remoteTask);
      } else {
        final localTask = await localDataSource.getTask(id);
        return Right(localTask);
      }
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, TaskEntity>> createTask(TaskEntity task) async {
    try {
      final taskModel = TaskModel.fromEntity(task);
      final localTask = await localDataSource.saveTask(taskModel);

      if (await networkInfo.isConnected) {
        final remoteTask = await remoteDataSource.createTask(taskModel);
        await localDataSource.saveTask(remoteTask);
        return Right(remoteTask);
      }

      return Right(localTask);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, TaskEntity>> updateTask(TaskEntity task) async {
    try {
      final taskModel = TaskModel.fromEntity(task);
      final localTask = await localDataSource.saveTask(taskModel);

      if (await networkInfo.isConnected) {
        final remoteTask = await remoteDataSource.updateTask(taskModel);
        await localDataSource.saveTask(remoteTask);
        return Right(remoteTask);
      }

      return Right(localTask);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteTask(String id) async {
    try {
      await localDataSource.deleteTask(id);

      if (await networkInfo.isConnected) {
        await remoteDataSource.deleteTask(id);
      }

      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> syncTasks() async {
    try {
      if (!await networkInfo.isConnected) {
        return Left(NetworkFailure('No internet connection'));
      }

      final unsyncedTasks = await localDataSource.getUnsyncedTasks();
      if (unsyncedTasks.isEmpty) {
        return const Right(null);
      }

      await remoteDataSource.syncTasks(unsyncedTasks);

      for (var task in unsyncedTasks) {
        await localDataSource.markTaskAsSynced(task.id);
      }

      return const Right(null);
    } catch (e) {
      return Left(SyncFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> hasUnsyncedTasks() async {
    try {
      final unsyncedTasks = await localDataSource.getUnsyncedTasks();
      return Right(unsyncedTasks.isNotEmpty);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> saveTasksLocally(List<TaskEntity> tasks) async {
    try {
      final taskModels =
          tasks.map((task) => TaskModel.fromEntity(task)).toList();
      await localDataSource.saveTasks(taskModels);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<TaskEntity>>> getLocalTasks() async {
    try {
      final tasks = await localDataSource.getTasks();
      return Right(tasks);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> clearLocalTasks() async {
    try {
      await localDataSource.clearTasks();
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }
}
