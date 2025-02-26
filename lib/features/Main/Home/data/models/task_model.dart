import '../../domain/entities/task_entity.dart';

class TaskModel extends TaskEntity {
  TaskModel({
    required String id,
    required String title,
    required String description,
    required DateTime dueDate,
    required bool isCompleted,
    String? assignedTo,
    required String priority,
  }) : super(
          id: id,
          title: title,
          description: description,
          dueDate: dueDate,
          isCompleted: isCompleted,
          assignedTo: assignedTo,
          priority: priority,
        );

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      dueDate: DateTime.parse(json['due_date']),
      isCompleted: json['is_completed'],
      assignedTo: json['assigned_to'],
      priority: json['priority'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'due_date': dueDate.toIso8601String(),
      'is_completed': isCompleted,
      'assigned_to': assignedTo,
      'priority': priority,
    };
  }
}
