import '../../domain/entities/task_list_entity.dart';

class TaskListModel extends TaskListEntity {
  TaskListModel({
    required String id,
    required String title,
    required String description,
    required DateTime dueDate,
    required String priority,
    required bool isCompleted,
    String? assignedTo,
    required List<String> tags,
    required String category,
  }) : super(
          id: id,
          title: title,
          description: description,
          dueDate: dueDate,
          priority: priority,
          isCompleted: isCompleted,
          assignedTo: assignedTo,
          tags: tags,
          category: category,
        );

  factory TaskListModel.fromJson(Map<String, dynamic> json) {
    return TaskListModel(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      dueDate: DateTime.parse(json['due_date']),
      priority: json['priority'],
      isCompleted: json['is_completed'],
      assignedTo: json['assigned_to'],
      tags: List<String>.from(json['tags']),
      category: json['category'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'due_date': dueDate.toIso8601String(),
      'priority': priority,
      'is_completed': isCompleted,
      'assigned_to': assignedTo,
      'tags': tags,
      'category': category,
    };
  }
}
