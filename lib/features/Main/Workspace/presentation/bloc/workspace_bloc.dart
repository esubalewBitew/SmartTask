import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/repositories/workspace_repository.dart';
import '../../domain/entities/workspace_entity.dart';

// Events
abstract class WorkspaceEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadWorkspaces extends WorkspaceEvent {}

class CreateWorkspace extends WorkspaceEvent {
  final String name;
  final String description;

  CreateWorkspace(this.name, this.description);

  @override
  List<Object?> get props => [name, description];
}

class UpdateWorkspace extends WorkspaceEvent {
  final WorkspaceEntity workspace;

  UpdateWorkspace(this.workspace);

  @override
  List<Object?> get props => [workspace];
}

class DeleteWorkspace extends WorkspaceEvent {
  final String workspaceId;

  DeleteWorkspace(this.workspaceId);

  @override
  List<Object?> get props => [workspaceId];
}

class UpdateUserActivity extends WorkspaceEvent {
  final String workspaceId;
  final String? taskId;

  UpdateUserActivity(this.workspaceId, this.taskId);

  @override
  List<Object?> get props => [workspaceId, taskId];
}

class AddMember extends WorkspaceEvent {
  final String workspaceId;
  final String memberEmail;

  AddMember(this.workspaceId, this.memberEmail);

  @override
  List<Object?> get props => [workspaceId, memberEmail];
}

class RemoveMember extends WorkspaceEvent {
  final String workspaceId;
  final String memberId;

  RemoveMember(this.workspaceId, this.memberId);

  @override
  List<Object?> get props => [workspaceId, memberId];
}

// States
abstract class WorkspaceState extends Equatable {
  @override
  List<Object?> get props => [];
}

class WorkspaceInitial extends WorkspaceState {}

class WorkspaceLoading extends WorkspaceState {}

class WorkspacesLoaded extends WorkspaceState {
  final List<WorkspaceEntity> workspaces;

  WorkspacesLoaded(this.workspaces);

  @override
  List<Object?> get props => [workspaces];
}

class WorkspaceError extends WorkspaceState {
  final String message;

  WorkspaceError(this.message);

  @override
  List<Object?> get props => [message];
}

// Bloc
class WorkspaceBloc extends Bloc<WorkspaceEvent, WorkspaceState> {
  final WorkspaceRepository _repository;

  WorkspaceBloc({required WorkspaceRepository repository})
      : _repository = repository,
        super(WorkspaceInitial()) {
    on<LoadWorkspaces>(_onLoadWorkspaces);
    on<CreateWorkspace>(_onCreateWorkspace);
    on<UpdateWorkspace>(_onUpdateWorkspace);
    on<DeleteWorkspace>(_onDeleteWorkspace);
    on<UpdateUserActivity>(_onUpdateUserActivity);
    on<AddMember>(_onAddMember);
    on<RemoveMember>(_onRemoveMember);
  }

  // Expose repository as a getter
  WorkspaceRepository get repository => _repository;

  void _onLoadWorkspaces(
      LoadWorkspaces event, Emitter<WorkspaceState> emit) async {
    print('Loading workspaces...'); // Debug print
    emit(WorkspaceLoading());
    try {
      final workspaces = await _repository.getWorkspaces();
      print('Received workspaces: ${workspaces.length}'); // Debug print
      emit(WorkspacesLoaded(workspaces));
    } catch (error) {
      print('Error loading workspaces: $error'); // Debug print
      emit(WorkspaceError(error.toString()));
    }
  }

  Future<void> _onCreateWorkspace(
      CreateWorkspace event, Emitter<WorkspaceState> emit) async {
    try {
      await _repository.createWorkspace(
        name: event.name,
        description: event.description,
      );
      final workspaces = await _repository.getWorkspaces();
      emit(WorkspacesLoaded(workspaces));
    } catch (e) {
      emit(WorkspaceError(e.toString()));
    }
  }

  Future<void> _onUpdateWorkspace(
      UpdateWorkspace event, Emitter<WorkspaceState> emit) async {
    try {
      await _repository.updateWorkspace(event.workspace);
      final workspaces = await _repository.getWorkspaces();
      emit(WorkspacesLoaded(workspaces));
    } catch (e) {
      emit(WorkspaceError(e.toString()));
    }
  }

  Future<void> _onDeleteWorkspace(
      DeleteWorkspace event, Emitter<WorkspaceState> emit) async {
    try {
      await _repository.deleteWorkspace(event.workspaceId);
      final workspaces = await _repository.getWorkspaces();
      emit(WorkspacesLoaded(workspaces));
    } catch (e) {
      emit(WorkspaceError(e.toString()));
    }
  }

  Future<void> _onUpdateUserActivity(
      UpdateUserActivity event, Emitter<WorkspaceState> emit) async {
    try {
      await _repository.updateUserActivity(
        event.workspaceId,
        event.taskId,
        'editing', // Default action
      );
    } catch (e) {
      emit(WorkspaceError(e.toString()));
    }
  }

  Future<void> _onAddMember(
      AddMember event, Emitter<WorkspaceState> emit) async {
    try {
      await _repository.inviteMember(event.workspaceId, event.memberEmail);
      final workspaces = await _repository.getWorkspaces();
      emit(WorkspacesLoaded(workspaces));
    } catch (e) {
      emit(WorkspaceError(e.toString()));
    }
  }

  Future<void> _onRemoveMember(
      RemoveMember event, Emitter<WorkspaceState> emit) async {
    try {
      await _repository.removeMember(event.workspaceId, event.memberId);
      final workspaces = await _repository.getWorkspaces();
      emit(WorkspacesLoaded(workspaces));
    } catch (e) {
      emit(WorkspaceError(e.toString()));
    }
  }

  @override
  Future<void> close() async {
    return super.close();
  }
}
