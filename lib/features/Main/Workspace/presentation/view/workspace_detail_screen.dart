import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/workspace_entity.dart';
import '../bloc/workspace_bloc.dart';
import 'widgets/invite_member_dialog.dart';
import 'widgets/edit_workspace_dialog.dart';

class WorkspaceDetailScreen extends StatefulWidget {
  final WorkspaceEntity workspace;

  const WorkspaceDetailScreen({
    Key? key,
    required this.workspace,
  }) : super(key: key);

  @override
  State<WorkspaceDetailScreen> createState() => _WorkspaceDetailScreenState();
}

class _WorkspaceDetailScreenState extends State<WorkspaceDetailScreen> {
  Map<String, String> _userNames = {};
  StreamSubscription? _activeUsersSubscription;
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _taskTitleController = TextEditingController();
  final TextEditingController _taskDescriptionController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserNames();
    _subscribeToActiveUsers();
  }

  @override
  void dispose() {
    _activeUsersSubscription?.cancel();
    _messageController.dispose();
    _scrollController.dispose();
    _taskTitleController.dispose();
    _taskDescriptionController.dispose();
    super.dispose();
  }

  Future<void> _loadUserNames() async {
    final firestore = FirebaseFirestore.instance;
    for (String userId in widget.workspace.memberIds) {
      final userDoc = await firestore.collection('users').doc(userId).get();
      if (userDoc.exists) {
        setState(() {
          _userNames[userId] = userDoc.data()?['name'] ?? 'Unknown User';
        });
      }
    }
  }

  void _subscribeToActiveUsers() {
    _activeUsersSubscription = context
        .read<WorkspaceBloc>()
        .repository
        .getActiveUsers(widget.workspace.id)
        .listen((activeUsers) {
      // Trigger rebuild when active users change
      if (mounted) setState(() {});
    });
  }

  String _formatTimestamp(Timestamp? timestamp) {
    if (timestamp == null) return '';
    final now = DateTime.now();
    final date = timestamp.toDate();
    final difference = now.difference(date);

    if (difference.inMinutes < 1) {
      return 'just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }

  Widget _buildChatInterface() {
    return Column(
      children: [
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('workspaces')
                .doc(widget.workspace.id)
                .collection('messages')
                .orderBy('timestamp', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }

              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final messages = snapshot.data!.docs;

              return ListView.builder(
                reverse: true,
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  final message =
                      messages[index].data() as Map<String, dynamic>;
                  final userId = message['userId'] as String;
                  final isCurrentUser =
                      userId == FirebaseAuth.instance.currentUser?.uid;
                  final userName = _userNames[userId] ?? 'Unknown User';
                  final timestamp = message['timestamp'] as Timestamp;
                  final type = message['type'] as String;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Align(
                      alignment: isCurrentUser
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.75,
                        ),
                        child: Card(
                          color: isCurrentUser
                              ? Theme.of(context).primaryColor
                              : Theme.of(context).cardColor,
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      userName,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color:
                                            isCurrentUser ? Colors.white : null,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      _formatTimestamp(timestamp),
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: isCurrentUser
                                            ? Colors.white.withOpacity(0.7)
                                            : Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                if (type == 'task')
                                  _buildTaskMessage(message, isCurrentUser)
                                else
                                  Text(
                                    message['content'] as String,
                                    style: TextStyle(
                                      color:
                                          isCurrentUser ? Colors.white : null,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
        _buildMessageInput(),
      ],
    );
  }

  Widget _buildTaskMessage(Map<String, dynamic> message, bool isCurrentUser) {
    final task = message['task'] as Map<String, dynamic>;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: isCurrentUser
                ? Colors.white.withOpacity(0.1)
                : Theme.of(context).primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.task_alt,
                    size: 16,
                    color: isCurrentUser
                        ? Colors.white
                        : Theme.of(context).primaryColor,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'New Task',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isCurrentUser
                          ? Colors.white
                          : Theme.of(context).primaryColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                task['title'] as String,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isCurrentUser ? Colors.white : null,
                ),
              ),
              if (task['description'] != null) ...[
                const SizedBox(height: 4),
                Text(
                  task['description'] as String,
                  style: TextStyle(
                    color: isCurrentUser ? Colors.white.withOpacity(0.9) : null,
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextButton.icon(
              icon: Icon(
                Icons.check_circle_outline,
                color: isCurrentUser
                    ? Colors.white
                    : Theme.of(context).primaryColor,
                size: 20,
              ),
              label: Text(
                'Mark Complete',
                style: TextStyle(
                  color: isCurrentUser
                      ? Colors.white
                      : Theme.of(context).primaryColor,
                ),
              ),
              onPressed: () => _updateTaskStatus(task['id'] as String, true),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                minimumSize: Size.zero,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.add_task),
              onPressed: _showCreateTaskDialog,
              color: Theme.of(context).primaryColor,
            ),
            Expanded(
              child: TextField(
                controller: _messageController,
                decoration: const InputDecoration(
                  hintText: 'Type a message...',
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 16),
                ),
                textCapitalization: TextCapitalization.sentences,
                onSubmitted: _sendMessage,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.send),
              onPressed: () => _sendMessage(_messageController.text),
              color: Theme.of(context).primaryColor,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    await FirebaseFirestore.instance
        .collection('workspaces')
        .doc(widget.workspace.id)
        .collection('messages')
        .add({
      'content': text.trim(),
      'userId': userId,
      'type': 'message',
      'timestamp': FieldValue.serverTimestamp(),
    });

    _messageController.clear();
  }

  Future<void> _createTask() async {
    if (_taskTitleController.text.trim().isEmpty) return;

    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    // Create the task
    final taskRef = await FirebaseFirestore.instance
        .collection('workspaces')
        .doc(widget.workspace.id)
        .collection('tasks')
        .add({
      'title': _taskTitleController.text.trim(),
      'description': _taskDescriptionController.text.trim(),
      'createdBy': userId,
      'createdAt': FieldValue.serverTimestamp(),
      'isCompleted': false,
    });

    // Add task creation message
    await FirebaseFirestore.instance
        .collection('workspaces')
        .doc(widget.workspace.id)
        .collection('messages')
        .add({
      'userId': userId,
      'type': 'task',
      'timestamp': FieldValue.serverTimestamp(),
      'task': {
        'id': taskRef.id,
        'title': _taskTitleController.text.trim(),
        'description': _taskDescriptionController.text.trim(),
      },
    });

    _taskTitleController.clear();
    _taskDescriptionController.clear();
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.workspace.name),
            Text(
              '${widget.workspace.memberCount} members',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.white70,
                  ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => _showWorkspaceInfo(context),
          ),
          PopupMenuButton<String>(
            onSelected: (value) => _handleAction(context, value),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'edit',
                child: Text('Edit Workspace'),
              ),
              const PopupMenuItem(
                value: 'members',
                child: Text('Manage Members'),
              ),
              const PopupMenuItem(
                value: 'leave',
                child: Text('Leave Workspace'),
              ),
              if (widget.workspace.ownerId ==
                  FirebaseAuth.instance.currentUser?.uid)
                const PopupMenuItem(
                  value: 'delete',
                  child: Text('Delete Workspace'),
                ),
            ],
          ),
        ],
      ),
      body: _buildChatInterface(),
    );
  }

  void _showWorkspaceInfo(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildInfoCard(),
            _buildMembersSection(context),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Workspace Information',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildInfoRow(
              icon: Icons.description_outlined,
              title: 'Description',
              value: widget.workspace.description,
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
              icon: Icons.people_outline,
              title: 'Members',
              value: '${widget.workspace.memberCount} members',
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
              icon: Icons.calendar_today_outlined,
              title: 'Created',
              value: _formatDate(widget.workspace.createdAt),
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
              icon: Icons.update_outlined,
              title: 'Last Updated',
              value: widget.workspace.updatedAt != null
                  ? _formatDate(widget.workspace.updatedAt!)
                  : 'Not updated yet',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(color: Colors.grey),
          ),
        ),
      ],
    );
  }

  Widget _buildMembersSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Members',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (widget.workspace.ownerId == widget.workspace.id)
              TextButton.icon(
                onPressed: () => _showInviteMemberDialog(context),
                icon: const Icon(Icons.person_add_outlined),
                label: const Text('Invite'),
              ),
          ],
        ),
        const SizedBox(height: 16),
        Card(
          elevation: 2,
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: widget.workspace.memberIds.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final memberId = widget.workspace.memberIds[index];
              final isOwner = memberId == widget.workspace.ownerId;
              return ListTile(
                leading: CircleAvatar(
                  child: Text(
                    memberId.substring(0, 2).toUpperCase(),
                  ),
                ),
                title: Text(memberId),
                trailing: isOwner
                    ? const Chip(
                        label: Text('Owner'),
                        backgroundColor: Colors.blue,
                        labelStyle: TextStyle(color: Colors.white),
                      )
                    : widget.workspace.ownerId == widget.workspace.id
                        ? IconButton(
                            icon: const Icon(Icons.remove_circle_outline),
                            color: Colors.red,
                            onPressed: () =>
                                _showRemoveMemberDialog(context, memberId),
                          )
                        : null,
              );
            },
          ),
        ),
      ],
    );
  }

  void _handleAction(BuildContext context, String action) {
    final bloc = context.read<WorkspaceBloc>();

    switch (action) {
      case 'edit':
        showDialog(
          context: context,
          builder: (context) =>
              EditWorkspaceDialog(workspace: widget.workspace),
        );
        break;
      case 'leave':
        _showLeaveWorkspaceDialog(context, bloc);
        break;
      case 'delete':
        _showDeleteWorkspaceDialog(context, bloc);
        break;
    }
  }

  void _showLeaveWorkspaceDialog(BuildContext context, WorkspaceBloc bloc) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Leave Workspace'),
        content:
            Text('Are you sure you want to leave "${widget.workspace.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              bloc.add(RemoveMember(
                widget.workspace.id,
                FirebaseAuth.instance.currentUser!.uid,
              ));
              Navigator.of(context)
                ..pop() // Close dialog
                ..pop(); // Close detail screen
            },
            child: const Text('Leave'),
          ),
        ],
      ),
    );
  }

  void _showDeleteWorkspaceDialog(BuildContext context, WorkspaceBloc bloc) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Workspace'),
        content: Text(
          'Are you sure you want to delete "${widget.workspace.name}"? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              bloc.add(DeleteWorkspace(widget.workspace.id));
              Navigator.of(context)
                ..pop() // Close dialog
                ..pop(); // Close detail screen
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showInviteMemberDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) =>
          InviteMemberDialog(workspaceId: widget.workspace.id),
    );
  }

  void _showRemoveMemberDialog(BuildContext context, String memberId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Member'),
        content: Text('Are you sure you want to remove this member?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<WorkspaceBloc>().add(
                    RemoveMember(widget.workspace.id, memberId),
                  );
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _updateTaskStatus(String taskId, bool isCompleted) async {
    await FirebaseFirestore.instance
        .collection('workspaces')
        .doc(widget.workspace.id)
        .collection('tasks')
        .doc(taskId)
        .update({'isCompleted': isCompleted});
  }

  void _showCreateTaskDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create Task'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _taskTitleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                hintText: 'Enter task title',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _taskDescriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                hintText: 'Enter task description',
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              _taskTitleController.clear();
              _taskDescriptionController.clear();
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => _createTask(),
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }
}
