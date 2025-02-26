import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/repositories/workspace_repository.dart';
import '../models/workspace_model.dart';
import '../../domain/entities/workspace_entity.dart';

class WorkspaceRepositoryImpl implements WorkspaceRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  WorkspaceRepositoryImpl({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  @override
  Future<List<WorkspaceEntity>> getWorkspaces() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) throw Exception('User not authenticated');

    final querySnapshot = await _firestore
        .collection('workspaces')
        .where('memberIds', arrayContains: userId)
        .get();

    return querySnapshot.docs
        .map((doc) => WorkspaceModel.fromJson({
              'id': doc.id,
              ...doc.data(),
            }))
        .toList();
  }

  @override
  Future<WorkspaceEntity> createWorkspace({
    required String name,
    required String description,
  }) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) throw Exception('User not authenticated');

    final workspaceData = {
      'name': name,
      'description': description,
      'ownerId': userId,
      'memberIds': [userId],
      'createdAt': DateTime.now().toIso8601String(),
      'updatedAt': DateTime.now().toIso8601String(),
    };

    final docRef = await _firestore.collection('workspaces').add(workspaceData);
    final doc = await docRef.get();

    return WorkspaceModel.fromJson({
      'id': doc.id,
      ...doc.data()!,
    });
  }

  @override
  Future<void> joinWorkspace(String workspaceId) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) throw Exception('User not authenticated');

    await _firestore.collection('workspaces').doc(workspaceId).update({
      'memberIds': FieldValue.arrayUnion([userId]),
      'updatedAt': DateTime.now().toIso8601String(),
    });
  }

  @override
  Future<void> leaveWorkspace(String workspaceId) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) throw Exception('User not authenticated');

    final doc =
        await _firestore.collection('workspaces').doc(workspaceId).get();
    final workspace = WorkspaceModel.fromJson({
      'id': doc.id,
      ...doc.data()!,
    });

    if (workspace.ownerId == userId) {
      throw Exception('Workspace owner cannot leave the workspace');
    }

    await _firestore.collection('workspaces').doc(workspaceId).update({
      'memberIds': FieldValue.arrayRemove([userId]),
      'updatedAt': DateTime.now().toIso8601String(),
    });
  }

  @override
  Future<void> deleteWorkspace(String workspaceId) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) throw Exception('User not authenticated');

    final doc =
        await _firestore.collection('workspaces').doc(workspaceId).get();
    final workspace = WorkspaceModel.fromJson({
      'id': doc.id,
      ...doc.data()!,
    });

    if (workspace.ownerId != userId) {
      throw Exception('Only workspace owner can delete the workspace');
    }

    await _firestore.collection('workspaces').doc(workspaceId).delete();
  }

  @override
  Future<void> updateWorkspace(WorkspaceEntity workspace) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) throw Exception('User not authenticated');

    if (workspace.ownerId != userId) {
      throw Exception('Only workspace owner can update the workspace');
    }

    await _firestore.collection('workspaces').doc(workspace.id).update({
      'name': workspace.name,
      'description': workspace.description,
      'updatedAt': DateTime.now().toIso8601String(),
    });
  }

  @override
  Future<List<String>> getWorkspaceMembers(String workspaceId) async {
    final doc =
        await _firestore.collection('workspaces').doc(workspaceId).get();
    final workspace = WorkspaceModel.fromJson({
      'id': doc.id,
      ...doc.data()!,
    });
    return workspace.memberIds;
  }

  @override
  Future<void> inviteMember(String workspaceId, String email) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) throw Exception('User not authenticated');

    // Check if the current user is the workspace owner
    final isOwner = await isWorkspaceOwner(workspaceId);
    if (!isOwner) {
      throw Exception('Only workspace owner can invite members');
    }

    // Get the user ID from the email
    final userQuery = await _firestore
        .collection('users')
        .where('email', isEqualTo: email)
        .limit(1)
        .get();

    if (userQuery.docs.isEmpty) {
      throw Exception('User not found');
    }

    final invitedUserId = userQuery.docs.first.id;

    // Check if the user is already a member
    final workspace =
        await _firestore.collection('workspaces').doc(workspaceId).get();
    final memberIds = List<String>.from(workspace.data()?['memberIds'] ?? []);

    if (memberIds.contains(invitedUserId)) {
      throw Exception('User is already a member of this workspace');
    }

    // Add the user to the workspace
    await _firestore.collection('workspaces').doc(workspaceId).update({
      'memberIds': FieldValue.arrayUnion([invitedUserId]),
      'updatedAt': DateTime.now().toIso8601String(),
    });
  }

  @override
  Future<void> removeMember(String workspaceId, String memberId) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) throw Exception('User not authenticated');

    // Check if the current user is the workspace owner
    final isOwner = await isWorkspaceOwner(workspaceId);
    if (!isOwner) {
      throw Exception('Only workspace owner can remove members');
    }

    // Get the workspace
    final doc =
        await _firestore.collection('workspaces').doc(workspaceId).get();
    final workspace = WorkspaceModel.fromJson({
      'id': doc.id,
      ...doc.data()!,
    });

    // Cannot remove the owner
    if (memberId == workspace.ownerId) {
      throw Exception('Cannot remove the workspace owner');
    }

    // Remove the member
    await _firestore.collection('workspaces').doc(workspaceId).update({
      'memberIds': FieldValue.arrayRemove([memberId]),
      'updatedAt': DateTime.now().toIso8601String(),
    });
  }

  @override
  Future<bool> isWorkspaceOwner(String workspaceId) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) throw Exception('User not authenticated');

    final doc =
        await _firestore.collection('workspaces').doc(workspaceId).get();
    return doc.data()?['ownerId'] == userId;
  }

  @override
  Future<bool> isWorkspaceMember(String workspaceId) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) throw Exception('User not authenticated');

    final doc =
        await _firestore.collection('workspaces').doc(workspaceId).get();
    final memberIds = List<String>.from(doc.data()?['memberIds'] ?? []);
    return memberIds.contains(userId);
  }
}
