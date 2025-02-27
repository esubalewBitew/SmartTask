import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smarttask/core/services/notification_service.dart';

class NotificationPreferencesScreen extends StatefulWidget {
  const NotificationPreferencesScreen({Key? key}) : super(key: key);

  @override
  State<NotificationPreferencesScreen> createState() =>
      _NotificationPreferencesScreenState();
}

class _NotificationPreferencesScreenState
    extends State<NotificationPreferencesScreen> {
  //final NotificationService _notificationService = NotificationService();
  late SharedPreferences _prefs;
  bool _taskDeadlines = true;
  bool _newAssignments = true;
  bool _teamUpdates = true;
  bool _performanceMetrics = true;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    _prefs = await SharedPreferences.getInstance();
    setState(() {
      _taskDeadlines = _prefs.getBool('notify_task_deadlines') ?? true;
      _newAssignments = _prefs.getBool('notify_new_assignments') ?? true;
      _teamUpdates = _prefs.getBool('notify_team_updates') ?? true;
      _performanceMetrics =
          _prefs.getBool('notify_performance_metrics') ?? true;
    });
  }

  Future<void> _savePreferences() async {
    await _prefs.setBool('notify_task_deadlines', _taskDeadlines);
    await _prefs.setBool('notify_new_assignments', _newAssignments);
    await _prefs.setBool('notify_team_updates', _teamUpdates);
    await _prefs.setBool('notify_performance_metrics', _performanceMetrics);

    // await _notificationService.updateNotificationPreferences(
    //   taskDeadlines: _taskDeadlines,
    //   newAssignments: _newAssignments,
    //   teamUpdates: _teamUpdates,
    //   performanceMetrics: _performanceMetrics,
    // );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Notification Preferences',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSectionHeader('Task Notifications'),
          _buildNotificationTile(
            'Task Deadlines',
            'Get notified about upcoming task deadlines',
            _taskDeadlines,
            (value) {
              setState(() {
                _taskDeadlines = value;
                _savePreferences();
              });
            },
          ),
          _buildNotificationTile(
            'New Assignments',
            'Get notified when you are assigned new tasks',
            _newAssignments,
            (value) {
              setState(() {
                _newAssignments = value;
                _savePreferences();
              });
            },
          ),
          const SizedBox(height: 24),
          _buildSectionHeader('Team Notifications'),
          _buildNotificationTile(
            'Team Updates',
            'Get notified about team activity and updates',
            _teamUpdates,
            (value) {
              setState(() {
                _teamUpdates = value;
                _savePreferences();
              });
            },
          ),
          _buildNotificationTile(
            'Performance Metrics',
            'Get notified about team performance updates',
            _performanceMetrics,
            (value) {
              setState(() {
                _performanceMetrics = value;
                _savePreferences();
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildNotificationTile(
    String title,
    String subtitle,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
        ),
      ),
      child: SwitchListTile(
        title: Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
        value: value,
        onChanged: onChanged,
        activeColor: Theme.of(context).colorScheme.primary,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    );
  }
}
