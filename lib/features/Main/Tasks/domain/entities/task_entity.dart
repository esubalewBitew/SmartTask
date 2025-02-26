import 'package:equatable/equatable.dart';

class TaskEntity extends Equatable {
  final String id;
  final String title;
  final String? description;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? dueDate;
  final bool isCompleted;
  final String userId;
  final bool isSynced;
  final DateTime? lastSyncedAt;

  const TaskEntity({
    required this.id,
    required this.title,
    this.description,
    required this.createdAt,
    this.updatedAt,
    this.dueDate,
    this.isCompleted = false,
    required this.userId,
    this.isSynced = false,
    this.lastSyncedAt,
  });

  TaskEntity copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? dueDate,
    bool? isCompleted,
    String? userId,
    bool? isSynced,
    DateTime? lastSyncedAt,
  }) {
    return TaskEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      dueDate: dueDate ?? this.dueDate,
      isCompleted: isCompleted ?? this.isCompleted,
      userId: userId ?? this.userId,
      isSynced: isSynced ?? this.isSynced,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        createdAt,
        updatedAt,
        dueDate,
        isCompleted,
        userId,
        isSynced,
        lastSyncedAt,
      ];
}
