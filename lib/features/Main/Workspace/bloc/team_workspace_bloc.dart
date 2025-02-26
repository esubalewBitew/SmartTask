import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../domain/entities/workspace_entity.dart';
import '../domain/repositories/workspace_repository.dart';

// Events
abstract class TeamWorkspaceEvent extends Equatable {
  const TeamWorkspaceEvent();

  @override
  List<Object?> get props => [];
}

class LoadWorkspaces extends TeamWorkspaceEvent {}

class CreateWorkspace extends TeamWorkspaceEvent {
  final String name;
  final String description;

  const CreateWorkspace({required this.name, required this.description});

  @override
  List<Object?> get props => [name, description];
}

class JoinWorkspace extends TeamWorkspaceEvent {
  final String workspaceId;

  const JoinWorkspace({required this.workspaceId});

  @override
  List<Object?> get props => [workspaceId];
}

// States
abstract class TeamWorkspaceState extends Equatable {
  const TeamWorkspaceState();

  @override
  List<Object?> get props => [];
}

class TeamWorkspaceInitial extends TeamWorkspaceState {}

class TeamWorkspaceLoading extends TeamWorkspaceState {}

class TeamWorkspaceLoaded extends TeamWorkspaceState {
  final List<WorkspaceEntity> workspaces;

  const TeamWorkspaceLoaded({required this.workspaces});

  @override
  List<Object?> get props => [workspaces];
}

class TeamWorkspaceError extends TeamWorkspaceState {
  final String message;

  const TeamWorkspaceError({required this.message});

  @override
  List<Object?> get props => [message];
}

// Bloc
class TeamWorkspaceBloc extends Bloc<TeamWorkspaceEvent, TeamWorkspaceState> {
  final WorkspaceRepository repository;

  TeamWorkspaceBloc({required this.repository})
      : super(TeamWorkspaceInitial()) {
    on<LoadWorkspaces>(_onLoadWorkspaces);
    on<CreateWorkspace>(_onCreateWorkspace);
    on<JoinWorkspace>(_onJoinWorkspace);
  }

  Future<void> _onLoadWorkspaces(
    LoadWorkspaces event,
    Emitter<TeamWorkspaceState> emit,
  ) async {
    emit(TeamWorkspaceLoading());
    try {
      final workspaces = await repository.getWorkspaces();
      emit(TeamWorkspaceLoaded(workspaces: workspaces));
    } catch (e) {
      emit(TeamWorkspaceError(message: e.toString()));
    }
  }

  Future<void> _onCreateWorkspace(
    CreateWorkspace event,
    Emitter<TeamWorkspaceState> emit,
  ) async {
    emit(TeamWorkspaceLoading());
    try {
      await repository.createWorkspace(
        name: event.name,
        description: event.description,
      );
      final workspaces = await repository.getWorkspaces();
      emit(TeamWorkspaceLoaded(workspaces: workspaces));
    } catch (e) {
      emit(TeamWorkspaceError(message: e.toString()));
    }
  }

  Future<void> _onJoinWorkspace(
    JoinWorkspace event,
    Emitter<TeamWorkspaceState> emit,
  ) async {
    emit(TeamWorkspaceLoading());
    try {
      await repository.joinWorkspace(event.workspaceId);
      final workspaces = await repository.getWorkspaces();
      emit(TeamWorkspaceLoaded(workspaces: workspaces));
    } catch (e) {
      emit(TeamWorkspaceError(message: e.toString()));
    }
  }
}
