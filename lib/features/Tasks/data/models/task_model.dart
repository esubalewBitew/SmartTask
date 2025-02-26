import 'package:hive/hive.dart';

part 'task_model.g.dart';

@HiveType(typeId: 1)
class TaskModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String description;

  @HiveField(3)
  final DateTime dueDate;

  @HiveField(4)
  final String priority;

  @HiveField(5)
  final List<String> assignees;

  @HiveField(6)
  final bool isCompleted;

  @HiveField(7)
  final DateTime createdAt;

  @HiveField(8)
  final DateTime? lastModified;

  @HiveField(9)
  final String? lastModifiedBy;

  TaskModel({
    required this.id,
    required this.title,
    required this.description,
    required this.dueDate,
    required this.priority,
    required this.assignees,
    this.isCompleted = false,
    required this.createdAt,
    this.lastModified,
    this.lastModifiedBy,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'dueDate': dueDate.toIso8601String(),
        'priority': priority,
        'assignees': assignees,
        'isCompleted': isCompleted,
        'createdAt': createdAt.toIso8601String(),
        'lastModified': lastModified?.toIso8601String(),
        'lastModifiedBy': lastModifiedBy,
      };

  factory TaskModel.fromJson(Map<String, dynamic> json) => TaskModel(
        id: json['id'],
        title: json['title'],
        description: json['description'],
        dueDate: DateTime.parse(json['dueDate']),
        priority: json['priority'],
        assignees: List<String>.from(json['assignees']),
        isCompleted: json['isCompleted'],
        createdAt: DateTime.parse(json['createdAt']),
        lastModified: json['lastModified'] != null
            ? DateTime.parse(json['lastModified'])
            : null,
        lastModifiedBy: json['lastModifiedBy'],
      );
}
