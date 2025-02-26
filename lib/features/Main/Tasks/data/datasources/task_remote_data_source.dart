import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:smarttask/features/Main/Tasks/data/models/task_model.dart';

abstract class TaskRemoteDataSource {
  Future<List<TaskModel>> getTasks();
  Future<TaskModel> getTask(String id);
  Future<TaskModel> createTask(TaskModel task);
  Future<TaskModel> updateTask(TaskModel task);
  Future<void> deleteTask(String id);
  Future<void> syncTasks(List<TaskModel> tasks);
}

class TaskRemoteDataSourceImpl implements TaskRemoteDataSource {
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;

  TaskRemoteDataSourceImpl({
    required this.firestore,
    required this.auth,
  });

  String? get _userId => auth.currentUser?.uid;

  CollectionReference? get _tasksCollection {
    final userId = _userId;
    if (userId == null || userId.isEmpty) {
      return null;
    }
    return firestore.collection('users').doc(userId).collection('tasks');
  }

  @override
  Future<List<TaskModel>> getTasks() async {
    try {
      final collection = _tasksCollection;
      if (collection == null) {
        throw Exception('User not authenticated');
      }

      final querySnapshot = await collection.get();
      return querySnapshot.docs
          .map((doc) => TaskModel.fromJson({
                ...doc.data() as Map<String, dynamic>,
                'id': doc.id,
              }))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch tasks: $e');
    }
  }

  @override
  Future<TaskModel> getTask(String id) async {
    try {
      final collection = _tasksCollection;
      if (collection == null) {
        throw Exception('User not authenticated');
      }

      final docSnapshot = await collection.doc(id).get();
      if (!docSnapshot.exists) {
        throw Exception('Task not found');
      }
      return TaskModel.fromJson({
        ...docSnapshot.data() as Map<String, dynamic>,
        'id': docSnapshot.id,
      });
    } catch (e) {
      throw Exception('Failed to fetch task: $e');
    }
  }

  @override
  Future<TaskModel> createTask(TaskModel task) async {
    try {
      final collection = _tasksCollection;
      if (collection == null) {
        throw Exception('User not authenticated');
      }

      final docRef = await collection.add(task.toJson());
      return TaskModel.fromEntity(task.copyWith(id: docRef.id));
    } catch (e) {
      throw Exception('Failed to create task: $e');
    }
  }

  @override
  Future<TaskModel> updateTask(TaskModel task) async {
    try {
      final collection = _tasksCollection;
      if (collection == null) {
        throw Exception('User not authenticated');
      }

      await collection.doc(task.id).update(task.toJson());
      return task;
    } catch (e) {
      throw Exception('Failed to update task: $e');
    }
  }

  @override
  Future<void> deleteTask(String id) async {
    try {
      final collection = _tasksCollection;
      if (collection == null) {
        throw Exception('User not authenticated');
      }

      await collection.doc(id).delete();
    } catch (e) {
      throw Exception('Failed to delete task: $e');
    }
  }

  @override
  Future<void> syncTasks(List<TaskModel> tasks) async {
    try {
      final collection = _tasksCollection;
      if (collection == null) {
        throw Exception('User not authenticated');
      }

      final batch = firestore.batch();

      for (var task in tasks) {
        final docRef = collection.doc(task.id);
        batch.set(docRef, task.toJson(), SetOptions(merge: true));
      }

      await batch.commit();
    } catch (e) {
      throw Exception('Failed to sync tasks: $e');
    }
  }
}
