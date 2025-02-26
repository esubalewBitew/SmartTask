import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:smarttask/core/di/injection_container.dart';
import 'package:smarttask/features/Main/Tasks/domain/entities/task_entity.dart';
import 'package:smarttask/features/Main/Tasks/presentation/bloc/task_bloc.dart';
import 'package:uuid/uuid.dart';

class TasksScreen extends StatelessWidget {
  const TasksScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<TaskBloc>()..add(LoadTasks()),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Tasks'),
          actions: [
            BlocBuilder<TaskBloc, TaskState>(
              builder: (context, state) {
                if (state is TasksLoaded && state.hasUnsyncedTasks) {
                  return IconButton(
                    icon: const Icon(Icons.sync),
                    onPressed: () {
                      context.read<TaskBloc>().add(SyncTasks());
                    },
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
        body: BlocBuilder<TaskBloc, TaskState>(
          builder: (context, state) {
            if (state is TaskLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is TasksLoaded) {
              if (state.tasks.isEmpty) {
                return const Center(child: Text('No tasks yet'));
              }
              return ListView.builder(
                itemCount: state.tasks.length,
                itemBuilder: (context, index) {
                  final task = state.tasks[index];
                  return ListTile(
                    title: Text(task.title),
                    subtitle: Text(task.description ?? ''),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (!task.isSynced)
                          const Icon(Icons.sync_problem, color: Colors.orange),
                        Checkbox(
                          value: task.isCompleted,
                          onChanged: (value) {
                            context.read<TaskBloc>().add(
                                  UpdateTask(
                                    task.copyWith(isCompleted: value ?? false),
                                  ),
                                );
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () {
                            context.read<TaskBloc>().add(DeleteTask(task.id));
                          },
                        ),
                      ],
                    ),
                  );
                },
              );
            } else if (state is TaskError) {
              return Center(child: Text('Error: ${state.message}'));
            }
            return const SizedBox.shrink();
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _showAddTaskDialog(context),
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  void _showAddTaskDialog(BuildContext context) {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    final userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please sign in to create tasks')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Task'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (titleController.text.isNotEmpty) {
                final task = TaskEntity(
                  id: const Uuid().v4(),
                  title: titleController.text,
                  description: descriptionController.text,
                  createdAt: DateTime.now(),
                  userId: userId,
                );
                context.read<TaskBloc>().add(AddTask(task));
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}
