import '../../domain/entities/task_entity.dart';

abstract class HomeEvent {}

class LoadTasks extends HomeEvent {}

class CreateTask extends HomeEvent {
  final TaskEntity task;
  CreateTask(this.task);
}

class UpdateTask extends HomeEvent {
  final TaskEntity task;
  UpdateTask(this.task);
}

class DeleteTask extends HomeEvent {
  final String taskId;
  DeleteTask(this.taskId);
}

class ToggleTaskStatus extends HomeEvent {
  final String taskId;
  ToggleTaskStatus(this.taskId);
}
