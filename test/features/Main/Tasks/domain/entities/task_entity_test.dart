import 'package:flutter_test/flutter_test.dart';
import 'package:smarttask/features/Main/Tasks/domain/entities/task_entity.dart';

void main() {
  group('TaskEntity', () {
    final DateTime now = DateTime.now();
    final TaskEntity task = TaskEntity(
      id: '1',
      title: 'Test Task',
      description: 'Test Description',
      createdAt: now,
      userId: 'user1',
      priority: 'high',
      tags: ['work', 'important'],
    );

    test('should create TaskEntity with correct values', () {
      expect(task.id, '1');
      expect(task.title, 'Test Task');
      expect(task.description, 'Test Description');
      expect(task.createdAt, now);
      expect(task.userId, 'user1');
      expect(task.priority, 'high');
      expect(task.tags, ['work', 'important']);
      expect(task.isCompleted, false);
      expect(task.isSynced, false);
    });

    test('should create copy with updated values using copyWith', () {
      final updatedTask = task.copyWith(
        title: 'Updated Task',
        isCompleted: true,
        priority: 'low',
      );

      expect(updatedTask.id, task.id);
      expect(updatedTask.title, 'Updated Task');
      expect(updatedTask.description, task.description);
      expect(updatedTask.isCompleted, true);
      expect(updatedTask.priority, 'low');
      expect(updatedTask.tags, task.tags);
    });

    test('should be equal when all properties match', () {
      final taskCopy = TaskEntity(
        id: '1',
        title: 'Test Task',
        description: 'Test Description',
        createdAt: now,
        userId: 'user1',
        priority: 'high',
        tags: ['work', 'important'],
      );

      expect(task, taskCopy);
    });

    test('should not be equal when properties differ', () {
      final differentTask = TaskEntity(
        id: '2',
        title: 'Different Task',
        description: 'Test Description',
        createdAt: now,
        userId: 'user1',
        priority: 'high',
        tags: ['work', 'important'],
      );

      expect(task != differentTask, true);
    });
  });
}
