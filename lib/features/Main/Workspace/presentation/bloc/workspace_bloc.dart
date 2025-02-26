import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/workspace_entity.dart';
import '../../domain/repositories/workspace_repository.dart';

// Events
abstract class WorkspaceEvent extends Equatable {
  const WorkspaceEvent();

  @override
  List<Object?> get props => [];
}

class LoadWorkspaces extends WorkspaceEvent {}

class CreateWorkspace extends WorkspaceEvent {
  final String name;
  final String description;

  const CreateWorkspace({
    required this.name,
    required this.description,
  });

  @override
  List<Object?> get props => [name, description];
}

class JoinWorkspace extends WorkspaceEvent {
  final String workspaceId;

  const JoinWorkspace(this.workspaceId);

  @override
  List<Object?> get props => [workspaceId];
}

class LeaveWorkspace extends WorkspaceEvent {
  final String workspaceId;

  const LeaveWorkspace(this.workspaceId);

  @override
  List<Object?> get props => [workspaceId];
}

class DeleteWorkspace extends WorkspaceEvent {
  final String workspaceId;

  const DeleteWorkspace(this.workspaceId);

  @override
  List<Object?> get props => [workspaceId];
}

class UpdateWorkspace extends WorkspaceEvent {
  final WorkspaceEntity workspace;

  const UpdateWorkspace(this.workspace);

  @override
  List<Object?> get props => [workspace];
}

class InviteMember extends WorkspaceEvent {
  final String workspaceId;
  final String email;

  const InviteMember({
    required this.workspaceId,
    required this.email,
  });

  @override
  List<Object?> get props => [workspaceId, email];
}

class RemoveMember extends WorkspaceEvent {
  final String workspaceId;
  final String memberId;

  const RemoveMember({
    required this.workspaceId,
    required this.memberId,
  });

  @override
  List<Object?> get props => [workspaceId, memberId];
}

// States
abstract class WorkspaceState extends Equatable {
  const WorkspaceState();

  @override
  List<Object?> get props => [];
}

class WorkspaceInitial extends WorkspaceState {}

class WorkspaceLoading extends WorkspaceState {}

class WorkspaceLoaded extends WorkspaceState {
  final List<WorkspaceEntity> workspaces;

  const WorkspaceLoaded(this.workspaces);

  @override
  List<Object?> get props => [workspaces];
}

class WorkspaceError extends WorkspaceState {
  final String message;

  const WorkspaceError(this.message);

  @override
  List<Object?> get props => [message];
}

// Bloc
class WorkspaceBloc extends Bloc<WorkspaceEvent, WorkspaceState> {
  final WorkspaceRepository _repository;

  WorkspaceBloc(this._repository) : super(WorkspaceInitial()) {
    on<LoadWorkspaces>(_onLoadWorkspaces);
    on<CreateWorkspace>(_onCreateWorkspace);
    on<JoinWorkspace>(_onJoinWorkspace);
    on<LeaveWorkspace>(_onLeaveWorkspace);
    on<DeleteWorkspace>(_onDeleteWorkspace);
    on<UpdateWorkspace>(_onUpdateWorkspace);
    on<InviteMember>(_onInviteMember);
    on<RemoveMember>(_onRemoveMember);
  }

  Future<void> _onLoadWorkspaces(
    LoadWorkspaces event,
    Emitter<WorkspaceState> emit,
  ) async {
    try {
      emit(WorkspaceLoading());
      final workspaces = await _repository.getWorkspaces();
      emit(WorkspaceLoaded(workspaces));
    } catch (e) {
      emit(WorkspaceError(e.toString()));
    }
  }

  Future<void> _onCreateWorkspace(
    CreateWorkspace event,
    Emitter<WorkspaceState> emit,
  ) async {
    try {
      emit(WorkspaceLoading());
      await _repository.createWorkspace(
        name: event.name,
        description: event.description,
      );
      final workspaces = await _repository.getWorkspaces();
      emit(WorkspaceLoaded(workspaces));
    } catch (e) {
      emit(WorkspaceError(e.toString()));
    }
  }

  Future<void> _onJoinWorkspace(
    JoinWorkspace event,
    Emitter<WorkspaceState> emit,
  ) async {
    try {
      emit(WorkspaceLoading());
      await _repository.joinWorkspace(event.workspaceId);
      final workspaces = await _repository.getWorkspaces();
      emit(WorkspaceLoaded(workspaces));
    } catch (e) {
      emit(WorkspaceError(e.toString()));
    }
  }

  Future<void> _onLeaveWorkspace(
    LeaveWorkspace event,
    Emitter<WorkspaceState> emit,
  ) async {
    try {
      emit(WorkspaceLoading());
      await _repository.leaveWorkspace(event.workspaceId);
      final workspaces = await _repository.getWorkspaces();
      emit(WorkspaceLoaded(workspaces));
    } catch (e) {
      emit(WorkspaceError(e.toString()));
    }
  }

  Future<void> _onDeleteWorkspace(
    DeleteWorkspace event,
    Emitter<WorkspaceState> emit,
  ) async {
    try {
      emit(WorkspaceLoading());
      await _repository.deleteWorkspace(event.workspaceId);
      final workspaces = await _repository.getWorkspaces();
      emit(WorkspaceLoaded(workspaces));
    } catch (e) {
      emit(WorkspaceError(e.toString()));
    }
  }

  Future<void> _onUpdateWorkspace(
    UpdateWorkspace event,
    Emitter<WorkspaceState> emit,
  ) async {
    try {
      emit(WorkspaceLoading());
      await _repository.updateWorkspace(event.workspace);
      final workspaces = await _repository.getWorkspaces();
      emit(WorkspaceLoaded(workspaces));
    } catch (e) {
      emit(WorkspaceError(e.toString()));
    }
  }

  Future<void> _onInviteMember(
    InviteMember event,
    Emitter<WorkspaceState> emit,
  ) async {
    try {
      emit(WorkspaceLoading());
      // TODO: Implement invite member functionality in repository
      final workspaces = await _repository.getWorkspaces();
      emit(WorkspaceLoaded(workspaces));
    } catch (e) {
      emit(WorkspaceError(e.toString()));
    }
  }

  Future<void> _onRemoveMember(
    RemoveMember event,
    Emitter<WorkspaceState> emit,
  ) async {
    try {
      emit(WorkspaceLoading());
      // TODO: Implement remove member functionality in repository
      final workspaces = await _repository.getWorkspaces();
      emit(WorkspaceLoaded(workspaces));
    } catch (e) {
      emit(WorkspaceError(e.toString()));
    }
  }
}
