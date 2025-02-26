class TaskListEntity {
  final String id;
  final String title;
  final String description;
  final DateTime dueDate;
  final String priority;
  final bool isCompleted;
  final String? assignedTo;
  final List<String> tags;
  final String category;

  TaskListEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.dueDate,
    required this.priority,
    required this.isCompleted,
    this.assignedTo,
    required this.tags,
    required this.category,
  });
}
