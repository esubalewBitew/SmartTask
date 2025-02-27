import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:smarttask/features/Main/Tasks/domain/entities/task_entity.dart';
import 'package:smarttask/features/Main/Tasks/presentation/bloc/task_bloc.dart';

@GenerateMocks([TaskRepository])
void main() {
  group('TaskBloc', () {
    late TaskBloc taskBloc;
    late MockTaskRepository mockTaskRepository;

    setUp(() {
      mockTaskRepository = MockTaskRepository();
      taskBloc = TaskBloc(taskRepository: mockTaskRepository);
    });

    tearDown(() {
      taskBloc.close();
    });

    test('initial state should be TaskInitial', () {
      expect(taskBloc.state, isA<TaskInitial>());
    });

    final testTask = TaskEntity(
      id: '1',
      title: 'Test Task',
      createdAt: DateTime.now(),
      userId: 'user1',
    );

    blocTest<TaskBloc, TaskState>(
      'emits [TaskLoading, TasksLoaded] when LoadTasks is added',
      build: () {
        when(mockTaskRepository.getTasks()).thenAnswer((_) async => [testTask]);
        return taskBloc;
      },
      act: (bloc) => bloc.add(LoadTasks()),
      expect: () => [
        isA<TaskLoading>(),
        isA<TasksLoaded>(),
      ],
      verify: (_) {
        verify(mockTaskRepository.getTasks()).called(1);
      },
    );

    blocTest<TaskBloc, TaskState>(
      'emits [TaskLoading, TasksLoaded] when AddTask is added',
      build: () {
        when(mockTaskRepository.addTask(any)).thenAnswer((_) async => testTask);
        return taskBloc;
      },
      act: (bloc) => bloc.add(AddTask(testTask)),
      expect: () => [
        isA<TaskLoading>(),
        isA<TasksLoaded>(),
      ],
      verify: (_) {
        verify(mockTaskRepository.addTask(any)).called(1);
      },
    );

    blocTest<TaskBloc, TaskState>(
      'emits [TaskLoading, TasksLoaded] when UpdateTask is added',
      build: () {
        when(mockTaskRepository.updateTask(any))
            .thenAnswer((_) async => testTask);
        return taskBloc;
      },
      act: (bloc) => bloc.add(UpdateTask(testTask)),
      expect: () => [
        isA<TaskLoading>(),
        isA<TasksLoaded>(),
      ],
      verify: (_) {
        verify(mockTaskRepository.updateTask(any)).called(1);
      },
    );

    blocTest<TaskBloc, TaskState>(
      'emits [TaskLoading, TasksLoaded] when DeleteTask is added',
      build: () {
        when(mockTaskRepository.deleteTask(any)).thenAnswer((_) async => true);
        return taskBloc;
      },
      act: (bloc) => bloc.add(DeleteTask(testTask.id)),
      expect: () => [
        isA<TaskLoading>(),
        isA<TasksLoaded>(),
      ],
      verify: (_) {
        verify(mockTaskRepository.deleteTask(any)).called(1);
      },
    );

    blocTest<TaskBloc, TaskState>(
      'emits [TaskLoading, TaskError] when repository throws an error',
      build: () {
        when(mockTaskRepository.getTasks()).thenThrow(Exception('Test error'));
        return taskBloc;
      },
      act: (bloc) => bloc.add(LoadTasks()),
      expect: () => [
        isA<TaskLoading>(),
        isA<TaskError>(),
      ],
    );
  });
}
