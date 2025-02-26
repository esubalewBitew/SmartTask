import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/tasks_repository.dart';
import 'tasks_event.dart';
import 'tasks_state.dart';

class TasksBloc extends Bloc<TasksEvent, TasksState> {
  final TasksRepository tasksRepository;

  TasksBloc({required this.tasksRepository}) : super(TasksInitial()) {
    on<LoadTasks>((event, emit) async {
      emit(TasksLoading());
      try {
        final tasks = await tasksRepository.getTasks();
        emit(TasksLoaded(tasks));
      } catch (e) {
        emit(TaskError(e.toString()));
      }
    });

    on<CreateTask>((event, emit) async {
      try {
        await tasksRepository.createTask(event.task);
        add(LoadTasks());
      } catch (e) {
        emit(TaskError(e.toString()));
      }
    });

    on<DeleteTask>((event, emit) async {
      try {
        await tasksRepository.deleteTask(event.taskId);
        add(LoadTasks());
      } catch (e) {
        emit(TaskError(e.toString()));
      }
    });

    on<ToggleTaskStatus>((event, emit) async {
      try {
        await tasksRepository.toggleTaskStatus(event.taskId);
        add(LoadTasks());
      } catch (e) {
        emit(TaskError(e.toString()));
      }
    });
  }
}
