import 'package:smarttask/features/Main/Tasks/domain/entities/task_entity.dart';

class TaskModel extends TaskEntity {
  const TaskModel({
    required String id,
    required String title,
    String? description,
    required DateTime createdAt,
    DateTime? updatedAt,
    DateTime? dueDate,
    bool isCompleted = false,
    required String userId,
    bool isSynced = false,
    DateTime? lastSyncedAt,
  }) : super(
          id: id,
          title: title,
          description: description,
          createdAt: createdAt,
          updatedAt: updatedAt,
          dueDate: dueDate,
          isCompleted: isCompleted,
          userId: userId,
          isSynced: isSynced,
          lastSyncedAt: lastSyncedAt,
        );

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
      dueDate: json['dueDate'] != null
          ? DateTime.parse(json['dueDate'] as String)
          : null,
      isCompleted: json['isCompleted'] as bool? ?? false,
      userId: json['userId'] as String,
      isSynced: json['isSynced'] as bool? ?? false,
      lastSyncedAt: json['lastSyncedAt'] != null
          ? DateTime.parse(json['lastSyncedAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'dueDate': dueDate?.toIso8601String(),
      'isCompleted': isCompleted,
      'userId': userId,
      'isSynced': isSynced,
      'lastSyncedAt': lastSyncedAt?.toIso8601String(),
    };
  }

  factory TaskModel.fromEntity(TaskEntity entity) {
    return TaskModel(
      id: entity.id,
      title: entity.title,
      description: entity.description,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      dueDate: entity.dueDate,
      isCompleted: entity.isCompleted,
      userId: entity.userId,
      isSynced: entity.isSynced,
      lastSyncedAt: entity.lastSyncedAt,
    );
  }
}
