import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../../domain/entities/task_entity.dart';

// Events
abstract class TaskEvent {}

class LoadTasks extends TaskEvent {}

class AddTask extends TaskEvent {
  final TaskEntity task;
  AddTask(this.task);
}

class DeleteTask extends TaskEvent {
  final String id;
  DeleteTask(this.id);
}

class UpdateTask extends TaskEvent {
  final TaskEntity task;
  UpdateTask(this.task);
}

class SyncTasks extends TaskEvent {}

// States
abstract class TaskState {}

class TaskInitial extends TaskState {}

class TaskLoading extends TaskState {}

class TasksLoaded extends TaskState {
  final List<TaskEntity> tasks;
  final bool hasUnsyncedTasks;
  TasksLoaded(this.tasks, {this.hasUnsyncedTasks = false});
}

class TaskError extends TaskState {
  final String message;
  TaskError(this.message);
}

class TaskBloc extends Bloc<TaskEvent, TaskState> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late final Box<Map> _taskBox;
  final Connectivity _connectivity = Connectivity();

  TaskBloc() : super(TaskInitial()) {
    _initHive();
    _setupConnectivityListener();
    on<LoadTasks>(_onLoadTasks);
    on<AddTask>(_onAddTask);
    on<DeleteTask>(_onDeleteTask);
    on<UpdateTask>(_onUpdateTask);
    on<SyncTasks>(_onSyncTasks);
  }

  Future<void> _initHive() async {
    _taskBox = await Hive.openBox<Map>('tasks');
  }

  void _setupConnectivityListener() {
    _connectivity.onConnectivityChanged.listen((result) {
      if (result != ConnectivityResult.none) {
        add(SyncTasks());
      }
    });
  }

  Future<void> _onLoadTasks(LoadTasks event, Emitter<TaskState> emit) async {
    try {
      emit(TaskLoading());
      final user = _auth.currentUser;
      if (user == null) {
        emit(TaskError('User not authenticated'));
        return;
      }

      // First load from local storage
      final localTasks = _loadLocalTasks(user.uid);
      emit(TasksLoaded(localTasks, hasUnsyncedTasks: _hasUnsyncedTasks()));

      // If online, fetch from Firestore and update local
      final connectivityResult = await _connectivity.checkConnectivity();
      if (connectivityResult != ConnectivityResult.none) {
        await _syncWithFirestore(user.uid, emit);
      }
    } catch (e) {
      debugPrint('Error loading tasks: $e');
      emit(TaskError(e.toString()));
    }
  }

  List<TaskEntity> _loadLocalTasks(String userId) {
    final tasks =
        _taskBox.values.where((task) => task['userId'] == userId).map((data) {
      return TaskEntity(
        id: data['id'],
        title: data['title'],
        description: data['description'],
        dueDate:
            data['dueDate'] != null ? DateTime.parse(data['dueDate']) : null,
        isCompleted: data['isCompleted'] ?? false,
        isSynced: data['isSynced'] ?? false,
        userId: data['userId'],
        createdAt: DateTime.parse(data['createdAt']),
      );
    }).toList();
    return tasks;
  }

  Future<void> _onAddTask(AddTask event, Emitter<TaskState> emit) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        emit(TaskError('User not authenticated'));
        return;
      }

      // Save to local storage first
      final taskMap = {
        'id': event.task.id,
        'title': event.task.title,
        'description': event.task.description,
        'dueDate': event.task.dueDate?.toIso8601String(),
        'isCompleted': event.task.isCompleted,
        'createdAt': event.task.createdAt.toIso8601String(),
        'userId': user.uid,
        'isSynced': false,
      };
      await _taskBox.put(event.task.id, taskMap);

      // Try to sync with Firestore if online
      final connectivityResult = await _connectivity.checkConnectivity();
      if (connectivityResult != ConnectivityResult.none) {
        await _syncTask(event.task, user.uid);
      }

      add(LoadTasks());
    } catch (e) {
      debugPrint('Error adding task: $e');
      emit(TaskError(e.toString()));
    }
  }

  Future<void> _syncTask(TaskEntity task, String userId) async {
    try {
      final tasksRef =
          _firestore.collection('users').doc(userId).collection('tasks');
      final taskData = {
        'title': task.title,
        'description': task.description,
        'dueDate':
            task.dueDate != null ? Timestamp.fromDate(task.dueDate!) : null,
        'isCompleted': task.isCompleted,
        'createdAt': Timestamp.fromDate(task.createdAt),
      };

      await tasksRef.doc(task.id).set(taskData);

      // Update local sync status
      final localTask = _taskBox.get(task.id);
      if (localTask != null) {
        localTask['isSynced'] = true;
        await _taskBox.put(task.id, localTask);
      }
    } catch (e) {
      debugPrint('Error syncing task: $e');
    }
  }

  bool _hasUnsyncedTasks() {
    return _taskBox.values.any((task) => !(task['isSynced'] ?? false));
  }

  Future<void> _syncWithFirestore(
      String userId, Emitter<TaskState> emit) async {
    try {
      final tasksRef =
          _firestore.collection('users').doc(userId).collection('tasks');
      final snapshot = await tasksRef.get();

      for (var doc in snapshot.docs) {
        final data = doc.data();
        DateTime? parseTimestamp(dynamic value) {
          if (value == null) return null;
          if (value is Timestamp) return value.toDate();
          if (value is String) return DateTime.tryParse(value);
          return null;
        }

        final taskMap = {
          'id': doc.id,
          'title': data['title'] ?? '',
          'description': data['description'],
          'dueDate': parseTimestamp(data['dueDate'])?.toIso8601String(),
          'isCompleted': data['isCompleted'] ?? false,
          'createdAt': parseTimestamp(data['createdAt'])?.toIso8601String() ??
              DateTime.now().toIso8601String(),
          'userId': userId,
          'isSynced': true,
        };
        await _taskBox.put(doc.id, taskMap);
      }

      final tasks = _loadLocalTasks(userId);
      emit(TasksLoaded(tasks, hasUnsyncedTasks: _hasUnsyncedTasks()));
    } catch (e) {
      debugPrint('Error syncing with Firestore: $e');
    }
  }

  Future<void> _onDeleteTask(DeleteTask event, Emitter<TaskState> emit) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        emit(TaskError('User not authenticated'));
        return;
      }

      // Delete from local storage
      await _taskBox.delete(event.id);

      // Try to delete from Firestore if online
      final connectivityResult = await _connectivity.checkConnectivity();
      if (connectivityResult != ConnectivityResult.none) {
        final tasksRef =
            _firestore.collection('users').doc(user.uid).collection('tasks');
        await tasksRef.doc(event.id).delete();
      }

      add(LoadTasks());
    } catch (e) {
      debugPrint('Error deleting task: $e');
      emit(TaskError(e.toString()));
    }
  }

  Future<void> _onUpdateTask(UpdateTask event, Emitter<TaskState> emit) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        emit(TaskError('User not authenticated'));
        return;
      }

      // Update in local storage
      final taskMap = {
        'id': event.task.id,
        'title': event.task.title,
        'description': event.task.description,
        'dueDate': event.task.dueDate?.toIso8601String(),
        'isCompleted': event.task.isCompleted,
        'createdAt': event.task.createdAt.toIso8601String(),
        'userId': user.uid,
        'isSynced': false,
      };
      await _taskBox.put(event.task.id, taskMap);

      // Try to sync with Firestore if online
      final connectivityResult = await _connectivity.checkConnectivity();
      if (connectivityResult != ConnectivityResult.none) {
        await _syncTask(event.task, user.uid);
      }

      add(LoadTasks());
    } catch (e) {
      debugPrint('Error updating task: $e');
      emit(TaskError(e.toString()));
    }
  }

  Future<void> _onSyncTasks(SyncTasks event, Emitter<TaskState> emit) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        emit(TaskError('User not authenticated'));
        return;
      }

      final connectivityResult = await _connectivity.checkConnectivity();
      if (connectivityResult != ConnectivityResult.none) {
        // Sync unsynced tasks to Firestore
        final unsyncedTasks = _taskBox.values
            .where((task) => !(task['isSynced'] ?? false))
            .map((data) => TaskEntity(
                  id: data['id'],
                  title: data['title'],
                  description: data['description'],
                  dueDate: data['dueDate'] != null
                      ? DateTime.parse(data['dueDate'])
                      : null,
                  isCompleted: data['isCompleted'] ?? false,
                  isSynced: false,
                  userId: data['userId'],
                  createdAt: DateTime.parse(data['createdAt']),
                ))
            .toList();

        for (var task in unsyncedTasks) {
          await _syncTask(task, user.uid);
        }

        // Fetch latest from Firestore
        await _syncWithFirestore(user.uid, emit);
      }
    } catch (e) {
      debugPrint('Error syncing tasks: $e');
      emit(TaskError(e.toString()));
    }
  }

  @override
  Future<void> close() {
    _taskBox.close();
    return super.close();
  }
}
