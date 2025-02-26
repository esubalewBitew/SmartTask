import '../../domain/entities/task_entity.dart';

abstract class HomeState {}

class HomeInitial extends HomeState {}

class HomeLoading extends HomeState {}

class HomeLoaded extends HomeState {
  final List<TaskEntity> tasks;
  HomeLoaded(this.tasks);
}

class HomeError extends HomeState {
  final String message;
  HomeError(this.message);
}
