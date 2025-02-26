import '../../domain/entities/task_list_entity.dart';

abstract class TasksState {}

class TasksInitial extends TasksState {}

class TasksLoading extends TasksState {}

class TasksLoaded extends TasksState {
  final List<TaskListEntity> tasks;
  TasksLoaded(this.tasks);
}

class TaskError extends TasksState {
  final String message;
  TaskError(this.message);
}
