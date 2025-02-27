import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/repositories/workspace_repository.dart';
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
        .where('isArchived', isEqualTo: false)
        .get();

    return querySnapshot.docs
        .map((doc) => WorkspaceEntity.fromJson({
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

    final workspace = WorkspaceEntity(
      id: '',
      name: name,
      description: description,
      ownerId: userId,
      memberIds: [userId],
      createdAt: DateTime.now(),
      activeUsers: {},
    );

    final docRef = await _firestore
        .collection('workspaces')
        .add(workspace.toJson()..remove('id'));

    return workspace.copyWith(id: docRef.id);
  }

  @override
  Future<void> updateWorkspace(WorkspaceEntity workspace) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) throw Exception('User not authenticated');

    if (workspace.ownerId != userId) {
      throw Exception('Only workspace owner can update the workspace');
    }

    await _firestore
        .collection('workspaces')
        .doc(workspace.id)
        .update(workspace.toJson());
  }

  @override
  Future<void> deleteWorkspace(String workspaceId) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) throw Exception('User not authenticated');

    final doc =
        await _firestore.collection('workspaces').doc(workspaceId).get();
    if (!doc.exists) throw Exception('Workspace not found');

    final workspace = WorkspaceEntity.fromJson({
      'id': doc.id,
      ...doc.data()!,
    });

    if (workspace.ownerId != userId) {
      throw Exception('Only workspace owner can delete the workspace');
    }

    await _firestore.collection('workspaces').doc(workspaceId).delete();
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
    if (!doc.exists) throw Exception('Workspace not found');

    final workspace = WorkspaceEntity.fromJson({
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
  Future<List<String>> getWorkspaceMembers(String workspaceId) async {
    final doc =
        await _firestore.collection('workspaces').doc(workspaceId).get();
    if (!doc.exists) throw Exception('Workspace not found');

    final workspace = WorkspaceEntity.fromJson({
      'id': doc.id,
      ...doc.data()!,
    });
    return workspace.memberIds;
  }

  @override
  Future<void> inviteMember(String workspaceId, String email) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) throw Exception('User not authenticated');

    final isOwner = await isWorkspaceOwner(workspaceId);
    if (!isOwner) {
      throw Exception('Only workspace owner can invite members');
    }

    final userQuery = await _firestore
        .collection('users')
        .where('email', isEqualTo: email)
        .limit(1)
        .get();

    if (userQuery.docs.isEmpty) {
      throw Exception('User not found');
    }

    final invitedUserId = userQuery.docs.first.id;
    await _firestore.collection('workspaces').doc(workspaceId).update({
      'memberIds': FieldValue.arrayUnion([invitedUserId]),
      'updatedAt': DateTime.now().toIso8601String(),
    });
  }

  @override
  Future<void> removeMember(String workspaceId, String memberId) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) throw Exception('User not authenticated');

    final isOwner = await isWorkspaceOwner(workspaceId);
    if (!isOwner) {
      throw Exception('Only workspace owner can remove members');
    }

    final doc =
        await _firestore.collection('workspaces').doc(workspaceId).get();
    if (!doc.exists) throw Exception('Workspace not found');

    final workspace = WorkspaceEntity.fromJson({
      'id': doc.id,
      ...doc.data()!,
    });

    if (memberId == workspace.ownerId) {
      throw Exception('Cannot remove the workspace owner');
    }

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
    if (!doc.exists) throw Exception('Workspace not found');

    return doc.data()?['ownerId'] == userId;
  }

  @override
  Future<bool> isWorkspaceMember(String workspaceId) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) throw Exception('User not authenticated');

    final doc =
        await _firestore.collection('workspaces').doc(workspaceId).get();
    if (!doc.exists) throw Exception('Workspace not found');

    final memberIds = List<String>.from(doc.data()?['memberIds'] ?? []);
    return memberIds.contains(userId);
  }

  @override
  Future<void> updateUserActivity(
      String workspaceId, String? taskId, String action) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    final docRef = _firestore.collection('workspaces').doc(workspaceId);

    if (taskId != null) {
      await docRef.update({
        'activeUsers.$userId': {
          'taskId': taskId,
          'action': action,
          'timestamp': FieldValue.serverTimestamp(),
        },
      });
    } else {
      await docRef.update({
        'activeUsers.$userId': FieldValue.delete(),
      });
    }
  }

  @override
  Stream<Map<String, dynamic>> getActiveUsers(String workspaceId) {
    return _firestore.collection('workspaces').doc(workspaceId).snapshots().map(
        (doc) => (doc.data()?['activeUsers'] as Map<String, dynamic>?) ?? {});
  }
}
