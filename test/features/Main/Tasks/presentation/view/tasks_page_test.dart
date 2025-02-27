import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mockito/mockito.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:smarttask/features/Main/Tasks/domain/entities/task_entity.dart';
import 'package:smarttask/features/Main/Tasks/presentation/bloc/task_bloc.dart';
import 'package:smarttask/features/Main/Tasks/presentation/view/tasks_page.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MockTaskBloc extends MockBloc<TaskEvent, TaskState> implements TaskBloc {}

void main() {
  group('TasksPage Widget Tests', () {
    late MockTaskBloc mockTaskBloc;
    late MockUser mockUser;

    setUp(() {
      mockTaskBloc = MockTaskBloc();
      mockUser = MockUser(
        uid: 'test-user-id',
        email: 'test@example.com',
        displayName: 'Test User',
      );
    });

    final testTasks = [
      TaskEntity(
        id: '1',
        title: 'Test Task 1',
        createdAt: DateTime.now(),
        userId: 'test-user-id',
        priority: 'high',
        tags: ['work'],
      ),
      TaskEntity(
        id: '2',
        title: 'Test Task 2',
        createdAt: DateTime.now(),
        userId: 'test-user-id',
        priority: 'low',
        tags: ['personal'],
      ),
    ];

    Widget createWidgetUnderTest() {
      return MaterialApp(
        home: BlocProvider<TaskBloc>.value(
          value: mockTaskBloc,
          child: const TasksPage(),
        ),
      );
    }

    testWidgets('renders TasksPage with loading state',
        (WidgetTester tester) async {
      when(mockTaskBloc.state).thenReturn(TaskLoading());

      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('renders TasksPage with loaded tasks',
        (WidgetTester tester) async {
      when(mockTaskBloc.state).thenReturn(TasksLoaded(testTasks));

      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.text('Test Task 1'), findsOneWidget);
      expect(find.text('Test Task 2'), findsOneWidget);
    });

    testWidgets('shows error message when in error state',
        (WidgetTester tester) async {
      when(mockTaskBloc.state)
          .thenReturn(const TaskError('Failed to load tasks'));

      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.text('Failed to load tasks'), findsOneWidget);
    });

    testWidgets('can toggle search mode', (WidgetTester tester) async {
      when(mockTaskBloc.state).thenReturn(TasksLoaded(testTasks));

      await tester.pumpWidget(createWidgetUnderTest());

      // Initially search should be hidden
      expect(find.byType(TextField), findsNothing);

      // Tap search icon
      await tester.tap(find.byIcon(Icons.search));
      await tester.pump();

      // Search field should be visible
      expect(find.byType(TextField), findsOneWidget);

      // Tap close icon
      await tester.tap(find.byIcon(Icons.close));
      await tester.pump();

      // Search field should be hidden again
      expect(find.byType(TextField), findsNothing);
    });

    testWidgets('can filter tasks', (WidgetTester tester) async {
      when(mockTaskBloc.state).thenReturn(TasksLoaded(testTasks));

      await tester.pumpWidget(createWidgetUnderTest());

      // Open search
      await tester.tap(find.byIcon(Icons.search));
      await tester.pump();

      // Enter search text
      await tester.enterText(find.byType(TextField), 'Task 1');
      await tester.pump();

      // Should show only Task 1
      expect(find.text('Test Task 1'), findsOneWidget);
      expect(find.text('Test Task 2'), findsNothing);
    });

    testWidgets('can delete task', (WidgetTester tester) async {
      when(mockTaskBloc.state).thenReturn(TasksLoaded(testTasks));

      await tester.pumpWidget(createWidgetUnderTest());

      // Find and tap delete button for first task
      await tester.tap(find.byIcon(Icons.delete_outline).first);
      await tester.pump();

      verify(mockTaskBloc.add(DeleteTask('1'))).called(1);
    });
  });
}
