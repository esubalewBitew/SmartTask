import '../entities/workspace_entity.dart';

abstract class WorkspaceRepository {
  Future<List<WorkspaceEntity>> getWorkspaces();
  Future<WorkspaceEntity> createWorkspace({
    required String name,
    required String description,
  });
  Future<void> joinWorkspace(String workspaceId);
  Future<void> leaveWorkspace(String workspaceId);
  Future<void> deleteWorkspace(String workspaceId);
  Future<void> updateWorkspace(WorkspaceEntity workspace);
  Future<List<String>> getWorkspaceMembers(String workspaceId);
  Future<void> inviteMember(String workspaceId, String email);
  Future<void> removeMember(String workspaceId, String memberId);
  Future<bool> isWorkspaceOwner(String workspaceId);
  Future<bool> isWorkspaceMember(String workspaceId);

  // Activity tracking methods
  Future<void> updateUserActivity(
      String workspaceId, String? taskId, String action);
  Stream<Map<String, dynamic>> getActiveUsers(String workspaceId);
}
