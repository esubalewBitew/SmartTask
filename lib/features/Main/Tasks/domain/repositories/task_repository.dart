import 'package:dartz/dartz.dart';
import 'package:smarttask/core/error/failures.dart';
import 'package:smarttask/features/Main/Tasks/domain/entities/task_entity.dart';

abstract class TaskRepository {
  Future<Either<Failure, List<TaskEntity>>> getTasks();
  Future<Either<Failure, TaskEntity>> getTask(String id);
  Future<Either<Failure, TaskEntity>> createTask(TaskEntity task);
  Future<Either<Failure, TaskEntity>> updateTask(TaskEntity task);
  Future<Either<Failure, void>> deleteTask(String id);

  // Sync operations
  Future<Either<Failure, void>> syncTasks();
  Future<Either<Failure, bool>> hasUnsyncedTasks();

  // Local operations
  Future<Either<Failure, void>> saveTasksLocally(List<TaskEntity> tasks);
  Future<Either<Failure, List<TaskEntity>>> getLocalTasks();
  Future<Either<Failure, void>> clearLocalTasks();
}
