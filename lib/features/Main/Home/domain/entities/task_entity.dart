class TaskEntity {
  final String id;
  final String title;
  final String description;
  final DateTime dueDate;
  final bool isCompleted;
  final String? assignedTo;
  final String priority;

  TaskEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.dueDate,
    required this.isCompleted,
    this.assignedTo,
    required this.priority,
  });
}
