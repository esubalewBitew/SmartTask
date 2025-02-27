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
  final String priority;
  final List<String> tags;

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
    this.priority = 'medium',
    this.tags = const [],
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
    String? priority,
    List<String>? tags,
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
      priority: priority ?? this.priority,
      tags: tags ?? this.tags,
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
        priority,
        tags,
      ];
}
