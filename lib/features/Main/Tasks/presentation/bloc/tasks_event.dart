import '../../domain/entities/task_list_entity.dart';

abstract class TasksEvent {}

class LoadTasks extends TasksEvent {}

class CreateTask extends TasksEvent {
  final TaskListEntity task;
  CreateTask(this.task);
}

class UpdateTask extends TasksEvent {
  final TaskListEntity task;
  UpdateTask(this.task);
}

class DeleteTask extends TasksEvent {
  final String taskId;
  DeleteTask(this.taskId);
}

class ToggleTaskStatus extends TasksEvent {
  final String taskId;
  ToggleTaskStatus(this.taskId);
}

class FilterTasks extends TasksEvent {
  final String? category;
  final String? priority;
  final bool? isCompleted;

  FilterTasks({
    this.category,
    this.priority,
    this.isCompleted,
  });
}
