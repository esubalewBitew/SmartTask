import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/home_repository.dart';
import 'home_event.dart';
import 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final HomeRepository homeRepository;

  HomeBloc({required this.homeRepository}) : super(HomeInitial()) {
    on<LoadTasks>((event, emit) async {
      emit(HomeLoading());
      try {
        final tasks = await homeRepository.getTasks();
        emit(HomeLoaded(tasks));
      } catch (e) {
        emit(HomeError(e.toString()));
      }
    });

    on<CreateTask>((event, emit) async {
      emit(HomeLoading());
      try {
        await homeRepository.createTask(event.task);
        final tasks = await homeRepository.getTasks();
        emit(HomeLoaded(tasks));
      } catch (e) {
        emit(HomeError(e.toString()));
      }
    });

    on<UpdateTask>((event, emit) async {
      emit(HomeLoading());
      try {
        await homeRepository.updateTask(event.task);
        final tasks = await homeRepository.getTasks();
        emit(HomeLoaded(tasks));
      } catch (e) {
        emit(HomeError(e.toString()));
      }
    });

    on<DeleteTask>((event, emit) async {
      emit(HomeLoading());
      try {
        await homeRepository.deleteTask(event.taskId);
        final tasks = await homeRepository.getTasks();
        emit(HomeLoaded(tasks));
      } catch (e) {
        emit(HomeError(e.toString()));
      }
    });

    on<ToggleTaskStatus>((event, emit) async {
      emit(HomeLoading());
      try {
        await homeRepository.toggleTaskStatus(event.taskId);
        final tasks = await homeRepository.getTasks();
        emit(HomeLoaded(tasks));
      } catch (e) {
        emit(HomeError(e.toString()));
      }
    });
  }
}
