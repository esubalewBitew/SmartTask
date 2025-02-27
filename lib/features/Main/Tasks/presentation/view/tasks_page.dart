import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smarttask/core/di/injection_container.dart';
import 'package:smarttask/core/services/notification_service.dart';
import 'package:smarttask/core/services/router_name.dart';
import 'package:smarttask/features/Main/Tasks/domain/entities/task_entity.dart';
import 'package:smarttask/features/Main/Tasks/presentation/bloc/task_bloc.dart';
import 'widgets/add_task_bottom_sheet.dart';
import 'package:rxdart/rxdart.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:collection/collection.dart';
import 'dart:math' show max;

class TasksPage extends StatelessWidget {
  const TasksPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final bloc = sl<TaskBloc>();
        // Only load tasks if user is authenticated
        if (FirebaseAuth.instance.currentUser != null) {
          bloc.add(LoadTasks());
        }
        return bloc;
      },
      child: const _TasksView(),
    );
  }
}

class _TasksView extends StatefulWidget {
  const _TasksView({Key? key}) : super(key: key);

  @override
  _TasksViewState createState() => _TasksViewState();
}

class _TasksViewState extends State<_TasksView> {
  final TextEditingController _searchController = TextEditingController();
  final BehaviorSubject<String> _searchSubject = BehaviorSubject<String>();
  bool _isSearching = false;
  List<TaskEntity> _filteredTasks = [];
  String? _errorMessage;
  DateTime _selectedDate = DateTime.now();

  // Add new filter states
  String _selectedFilter = 'all'; // all, name, date, priority, tags
  List<String> _selectedTags = [];
  String _selectedPriority = 'all';

  @override
  void initState() {
    super.initState();
    _searchSubject
        .debounceTime(const Duration(milliseconds: 300))
        .listen((query) {
      _filterTasks(query);
    });

    // Check if we have permission to access tasks
    _checkTasksPermission();
  }

  Future<void> _checkTasksPermission() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // Try to access the user's tasks collection
        final tasksRef = FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('tasks');

        await tasksRef.limit(1).get();
        setState(() {
          _errorMessage = null;
        });
      }
    } catch (e) {
      setState(() {
        if (e is FirebaseException && e.code == 'permission-denied') {
          _errorMessage =
              'Permission denied: Cannot access tasks. Please check your permissions.';
        } else {
          _errorMessage = 'Error accessing tasks: ${e.toString()}';
        }
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchSubject.close();
    super.dispose();
  }

  // Add fuzzy search score calculation
  int _calculateFuzzyScore(String source, String target) {
    source = source.toLowerCase();
    target = target.toLowerCase();

    if (source == target) return 100;
    if (source.contains(target)) return 80;
    if (target.contains(source)) return 60;

    int matchCount = 0;
    int maxLength =
        source.length > target.length ? source.length : target.length;

    for (int i = 0; i < source.length && i < target.length; i++) {
      if (source[i] == target[i]) matchCount++;
    }

    return ((matchCount / maxLength) * 50).round();
  }

  void _filterTasks(String query) {
    if (!mounted) return;

    final state = context.read<TaskBloc>().state;
    if (state is TasksLoaded) {
      setState(() {
        List<TaskEntity> tasks = state.tasks;

        // First filter by date if not searching
        if (!_isSearching) {
          tasks = _filterTasksByDate(tasks, _selectedDate);
        }

        // Apply search filters
        if (query.isNotEmpty) {
          List<MapEntry<TaskEntity, int>> scoredTasks = [];

          for (var task in tasks) {
            int score = 0;

            switch (_selectedFilter) {
              case 'name':
                score = _calculateFuzzyScore(task.title, query);
                break;
              case 'date':
                final dateStr = _formatDateTime(task.dueDate!);
                score = dateStr.toLowerCase().contains(query.toLowerCase())
                    ? 100
                    : 0;
                break;
              case 'priority':
                score = task.priority
                        .toString()
                        .toLowerCase()
                        .contains(query.toLowerCase())
                    ? 100
                    : 0;
                break;
              case 'tags':
                score = task.tags?.any((tag) =>
                            tag.toLowerCase().contains(query.toLowerCase())) ??
                        false
                    ? 100
                    : 0;
                break;
              default: // 'all'
                // Check title
                score = max(score, _calculateFuzzyScore(task.title, query));
                // Check description
                if (task.description != null) {
                  score = max(
                      score, _calculateFuzzyScore(task.description!, query));
                }
                // Check date
                final dateStr = _formatDateTime(task.dueDate!);
                if (dateStr.toLowerCase().contains(query.toLowerCase())) {
                  score = max(score, 80);
                }
                // Check priority
                if (task.priority
                    .toString()
                    .toLowerCase()
                    .contains(query.toLowerCase())) {
                  score = max(score, 70);
                }
                // Check tags
                if (task.tags?.any((tag) =>
                        tag.toLowerCase().contains(query.toLowerCase())) ??
                    false) {
                  score = max(score, 60);
                }
            }

            if (score > 0) {
              scoredTasks.add(MapEntry(task, score));
            }
          }

          // Sort by score descending
          scoredTasks.sort((a, b) => b.value.compareTo(a.value));
          _filteredTasks = scoredTasks.map((e) => e.key).toList();
        } else {
          _filteredTasks = tasks;
        }

        // Apply additional filters
        if (_selectedPriority != 'all') {
          _filteredTasks = _filteredTasks
              .where((task) => task.priority.toString() == _selectedPriority)
              .toList();
        }

        if (_selectedTags.isNotEmpty) {
          _filteredTasks = _filteredTasks
              .where((task) =>
                  task.tags?.any((tag) => _selectedTags.contains(tag)) ?? false)
              .toList();
        }
      });
    }
  }

  List<TaskEntity> _filterTasksByDate(List<TaskEntity> tasks, DateTime date) {
    return tasks.where((task) {
      return task.dueDate != null && _isSameDay(task.dueDate!, date);
    }).toList();
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  @override
  Widget build(BuildContext context) {
    final isAuthenticated = FirebaseAuth.instance.currentUser != null;

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          _buildAppBar(context),
          if (_isSearching)
            SliverToBoxAdapter(
              child: _buildSearchBar(),
            ),
          if (_isSearching)
            _buildSearchResults()
          else ...[
            _buildDatePicker(),
            _buildTasksList(),
          ],
        ],
      ),
      floatingActionButton: isAuthenticated
          ? FloatingActionButton(
              onPressed: () => _showAddTaskBottomSheet(context),
              backgroundColor: Colors.blue[600],
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
    );
  }

  Widget _buildAppBar(BuildContext context) {
    final theme = Theme.of(context);
    return SliverAppBar(
      floating: true,
      pinned: true,
      backgroundColor: Colors.white,
      elevation: 0,
      title: _isSearching
          ? TextField(
              controller: _searchController,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'Search tasks...',
                border: InputBorder.none,
                hintStyle: GoogleFonts.poppins(
                  color: Colors.grey[400],
                  fontSize: 16,
                ),
              ),
              style: GoogleFonts.poppins(
                color: const Color(0xFF464646),
                fontSize: 16,
              ),
              onChanged: (value) => _searchSubject.add(value),
            )
          : Text(
              'Schedule',
              style: GoogleFonts.poppins(
                color: const Color(0xFF464646),
                fontSize: 28,
                fontWeight: FontWeight.w600,
              ),
            ),
      actions: [
        IconButton(
          icon: Icon(_isSearching ? Icons.close : Icons.search),
          onPressed: () {
            setState(() {
              if (_isSearching) {
                _isSearching = false;
                _searchController.clear();
                _filteredTasks.clear();
              } else {
                _isSearching = true;
              }
            });
          },
          color: Colors.grey[700],
        ),
        BlocBuilder<TaskBloc, TaskState>(
          builder: (context, state) {
            if (state is TasksLoaded && state.hasUnsyncedTasks) {
              return IconButton(
                icon: const Icon(Icons.sync),
                onPressed: () => context.read<TaskBloc>().add(SyncTasks()),
                color: Colors.orange,
              );
            }
            return const SizedBox.shrink();
          },
        ),
        IconButton(
          icon: const Icon(Icons.calendar_month),
          onPressed: () {
            context.push('/calendar');
          },
          color: Colors.grey[700],
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search tasks...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        _searchSubject.add('');
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onChanged: (value) => _searchSubject.add(value),
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip('All', 'all'),
                _buildFilterChip('Name', 'name'),
                _buildFilterChip('Priority', 'priority'),
                if (_selectedFilter == 'priority') ...[
                  const SizedBox(width: 8),
                  _buildPriorityFilter(),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriorityFilter() {
    return DropdownButton<String>(
      value: _selectedPriority,
      items: ['all', 'high', 'medium', 'low'].map((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(
            value.capitalize(),
            style: GoogleFonts.poppins(),
          ),
        );
      }).toList(),
      onChanged: (String? newValue) {
        if (newValue != null) {
          setState(() {
            _selectedPriority = newValue;
            _filterTasks(_searchController.text);
          });
        }
      },
    );
  }

  Widget _buildFilterChip(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: _selectedFilter == value,
        onSelected: (bool selected) {
          setState(() {
            _selectedFilter = selected ? value : 'all';
            _filterTasks(_searchController.text);
          });
        },
      ),
    );
  }

  Widget _buildSearchResults() {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          if (index >= _filteredTasks.length) return null;
          final task = _filteredTasks[index];
          return _buildTimeSlot(
            task.dueDate?.hour.toString().padLeft(2, '0') ?? '--',
            task.title,
            task.isCompleted ? Colors.green[100]! : Colors.blue[50]!,
            task,
            context,
          );
        },
        childCount: _filteredTasks.length,
      ),
    );
  }

  Widget _buildDatePicker() {
    return SliverToBoxAdapter(
      child: Container(
        height: 100,
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: 14, // Two weeks
          itemBuilder: (context, index) {
            final date = DateTime.now().add(Duration(days: index));
            final isSelected = _isSameDay(date, _selectedDate);
            return _buildDateSelector(
                date, isSelected, _isSameDay(date, DateTime.now()));
          },
        ),
      ),
    );
  }

  Widget _buildDateSelector(DateTime date, bool isSelected, bool isToday) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedDate = date;
          if (context.read<TaskBloc>().state is TasksLoaded) {
            final state = context.read<TaskBloc>().state as TasksLoaded;
            _filteredTasks = _filterTasksByDate(state.tasks, date);
          }
        });
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? theme.colorScheme.primary : theme.cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? theme.colorScheme.primary : theme.dividerColor,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              [
                'Sun',
                'Mon',
                'Tue',
                'Wed',
                'Thu',
                'Fri',
                'Sat'
              ][date.weekday % 7],
              style: TextStyle(
                color: isSelected
                    ? Colors.white
                    : theme.textTheme.bodyMedium?.color,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              date.day.toString(),
              style: TextStyle(
                color: isSelected
                    ? Colors.white
                    : theme.textTheme.bodyLarge?.color,
                fontSize: 20,
                fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            if (isToday)
              Container(
                margin: const EdgeInsets.only(top: 4),
                width: 4,
                height: 4,
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white : theme.colorScheme.primary,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTasksList() {
    return BlocBuilder<TaskBloc, TaskState>(
      builder: (context, state) {
        // Check authentication first
        final user = FirebaseAuth.instance.currentUser;
        if (user == null) {
          return SliverFillRemaining(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.lock_outline, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'Sign in to manage your tasks',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Create and track your tasks seamlessly',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey[500],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () => context.go('/auth/login'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue[600],
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                        ),
                        child: Text(
                          'Sign In',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      TextButton(
                        onPressed: () => context.go('/auth/register'),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                        ),
                        child: Text(
                          'Register',
                          style: GoogleFonts.poppins(
                            color: Colors.blue[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        }

        // Show error message if permission check failed
        if (_errorMessage != null) {
          return SliverFillRemaining(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                  const SizedBox(height: 16),
                  Text(
                    'Error',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Text(
                      _errorMessage!,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _checkTasksPermission,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[600],
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                    child: Text(
                      'Retry',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        if (state is TaskLoading) {
          return const SliverFillRemaining(
            child: Center(child: CircularProgressIndicator()),
          );
        } else if (state is TasksLoaded) {
          final tasksForSelectedDate =
              _filterTasksByDate(state.tasks, _selectedDate);

          if (tasksForSelectedDate.isEmpty) {
            return SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.event_busy, size: 64, color: Colors.grey[400]),
                    const SizedBox(height: 16),
                    Text(
                      'No tasks for this date',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return _buildTaskList();
        } else if (state is TaskError) {
          return SliverFillRemaining(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading tasks',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    state.message,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<TaskBloc>().add(LoadTasks());
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[600],
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                    child: Text(
                      'Retry',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }
        return const SliverFillRemaining(child: SizedBox.shrink());
      },
    );
  }

  Widget _buildTaskList() {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final task = _filteredTasks[index];
          return _buildTaskItem(task);
        },
        childCount: _filteredTasks.length,
      ),
    );
  }

  Widget _buildTaskItem(TaskEntity task) {
    final theme = Theme.of(context);
    return Dismissible(
      key: Key(task.id),
      background: Container(
        color: theme.colorScheme.error,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) {
        context.read<TaskBloc>().add(DeleteTask(task.id));
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12, left: 8, right: 8),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.all(16),
          leading: Checkbox(
            value: task.isCompleted,
            onChanged: (value) {
              if (value != null) {
                context.read<TaskBloc>().add(
                      UpdateTask(
                        task.copyWith(isCompleted: value),
                      ),
                    );
              }
            },
            activeColor: theme.colorScheme.primary,
          ),
          title: Text(
            task.title,
            style: GoogleFonts.poppins(
              decoration: task.isCompleted ? TextDecoration.lineThrough : null,
              color: task.isCompleted
                  ? theme.textTheme.bodyMedium?.color?.withOpacity(0.5)
                  : theme.textTheme.bodyLarge?.color,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (task.description?.isNotEmpty ?? false)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    task.description!,
                    style: GoogleFonts.poppins(
                      color:
                          theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
                      fontSize: 14,
                    ),
                  ),
                ),
              if (task.dueDate != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 16,
                        color: theme.textTheme.bodySmall?.color,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _formatDateTime(task.dueDate!),
                        style: GoogleFonts.poppins(
                          color: theme.textTheme.bodySmall?.color,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimeSlot(
    String time,
    String title,
    Color backgroundColor,
    TaskEntity task,
    BuildContext context,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SizedBox(
                width: 60,
                child: Text(
                  time,
                  style: GoogleFonts.poppins(
                    color: Colors.grey[700],
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: backgroundColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        task.isCompleted
                            ? Icons.check_circle
                            : Icons.circle_outlined,
                        color: Colors.grey[700],
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          title,
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey[800],
                            decoration: task.isCompleted
                                ? TextDecoration.lineThrough
                                : null,
                          ),
                        ),
                      ),
                      if (!task.isSynced)
                        const Icon(Icons.sync_problem, color: Colors.orange),
                      IconButton(
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () {
                          context.read<TaskBloc>().add(DeleteTask(task.id));
                        },
                        color: Colors.grey[700],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          _buildScheduleOptions(),
        ],
      ),
    );
  }

  Widget _buildScheduleOptions() {
    return Padding(
      padding: const EdgeInsets.only(left: 60, top: 8),
      child: Container(
        width: double.infinity,
        height: 2,
        color: Colors.grey[200],
      ),
    );
  }

  void _showAddTaskBottomSheet(BuildContext context) {
    // NotificationService().scheduleTaskReminder(
    //   'task.id',
    //   'Task Created',
    //   'New task "task.title}" has been created',
    //   DateTime.now().add(const Duration(seconds: 5)),
    // );
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AddTaskBottomSheet(),
    );
  }

  String _formatDateTime(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${this.substring(1)}";
  }
}
