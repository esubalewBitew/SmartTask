import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';
import 'package:smarttask/features/Main/Tasks/domain/entities/task_entity.dart';
import 'package:smarttask/features/Main/Tasks/presentation/bloc/task_bloc.dart';
import 'package:add_2_calendar/add_2_calendar.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:smarttask/core/services/notification_service.dart';

class AddTaskBottomSheet extends StatefulWidget {
  const AddTaskBottomSheet({Key? key}) : super(key: key);

  @override
  State<AddTaskBottomSheet> createState() => _AddTaskBottomSheetState();
}

class _AddTaskBottomSheetState extends State<AddTaskBottomSheet> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  bool _addToCalendar = false;
  bool _setReminder = false;
  int _reminderMinutes = 15; // Default reminder time

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        top: 16,
        left: 16,
        right: 16,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Add New Task',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Task Title',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descriptionController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _selectDate(context),
                    icon: const Icon(Icons.calendar_today),
                    label: Text(
                      _selectedDate != null
                          ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
                          : 'Select Date',
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _selectTime(context),
                    icon: const Icon(Icons.access_time),
                    label: Text(
                      _selectedTime != null
                          ? _selectedTime!.format(context)
                          : 'Select Time',
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Set Reminder'),
              value: _setReminder,
              onChanged: (bool value) {
                setState(() {
                  _setReminder = value;
                });
              },
            ),
            if (_setReminder) ...[
              DropdownButtonFormField<int>(
                value: _reminderMinutes,
                decoration: const InputDecoration(
                  labelText: 'Reminder Time',
                  border: OutlineInputBorder(),
                ),
                items: [
                  DropdownMenuItem(value: 5, child: Text('5 minutes before')),
                  DropdownMenuItem(value: 15, child: Text('15 minutes before')),
                  DropdownMenuItem(value: 30, child: Text('30 minutes before')),
                  DropdownMenuItem(value: 60, child: Text('1 hour before')),
                ],
                onChanged: (value) {
                  setState(() {
                    _reminderMinutes = value!;
                  });
                },
              ),
            ],
            const SizedBox(height: 8),
            SwitchListTile(
              title: const Text('Add to Calendar'),
              value: _addToCalendar,
              onChanged: (bool value) {
                setState(() {
                  _addToCalendar = value;
                });
              },
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _saveTask,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
              ),
              child: const Text('Save Task'),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  Future<void> _scheduleNotification(
      String taskId, String title, DateTime dateTime) async {
    await NotificationService().scheduleTaskReminder(
      taskId,
      'Task Reminder',
      'Your task "$title" is due soon',
      dateTime,
    );
  }

  void _addEventToCalendar(
      String title, String? description, DateTime startDate, DateTime endDate) {
    final Event event = Event(
      title: title,
      description: description ?? '',
      startDate: startDate,
      endDate: endDate,
    );
    Add2Calendar.addEvent2Cal(event);
  }

  void _saveTask() {
    if (_titleController.text.isEmpty ||
        _selectedDate == null ||
        _selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all required fields')),
      );
      return;
    }

    final DateTime taskDateTime = DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
      _selectedTime!.hour,
      _selectedTime!.minute,
    );

    final task = TaskEntity(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: _titleController.text,
      description: _descriptionController.text,
      dueDate: taskDateTime,
      isCompleted: false,
      isSynced: false,
      userId: '',
      createdAt: DateTime.now(),
    );

    context.read<TaskBloc>().add(AddTask(task));

    // Show immediate notification
    NotificationService().showCustomNotification(
      title: 'Task Created',
      body: 'New task "${task.title}" has been created',
      channelId: 'task_notifications',
      channelName: 'Task Notifications',
      channelDescription: 'Notifications for task management',
    );
    debugPrint('Task created notification shown');

    // Schedule notification if reminder is enabled
    if (_setReminder) {
      final reminderTime =
          taskDateTime.subtract(Duration(minutes: _reminderMinutes));
      _scheduleNotification(task.id, task.title, reminderTime);
    }

    // Add to calendar if enabled
    if (_addToCalendar) {
      _addEventToCalendar(
        task.title,
        task.description,
        taskDateTime,
        taskDateTime.add(const Duration(hours: 1)),
      );
    }

    Navigator.pop(context);
  }
}
