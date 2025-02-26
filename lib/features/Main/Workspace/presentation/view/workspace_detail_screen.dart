import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/workspace_bloc.dart';
import '../../domain/entities/workspace_entity.dart';
import 'widgets/edit_workspace_dialog.dart';
import 'widgets/invite_member_dialog.dart';

class WorkspaceDetailScreen extends StatelessWidget {
  final WorkspaceEntity workspace;

  const WorkspaceDetailScreen({
    Key? key,
    required this.workspace,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(workspace.name),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) => _handleAction(context, value),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'edit',
                child: Text('Edit'),
              ),
              const PopupMenuItem(
                value: 'leave',
                child: Text('Leave'),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Text('Delete'),
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoCard(),
            const SizedBox(height: 24),
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
              value: workspace.description,
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
              icon: Icons.people_outline,
              title: 'Members',
              value: '${workspace.memberCount} members',
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
              icon: Icons.calendar_today_outlined,
              title: 'Created',
              value: _formatDate(workspace.createdAt),
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
              icon: Icons.update_outlined,
              title: 'Last Updated',
              value: _formatDate(workspace.updatedAt),
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
            if (workspace.ownerId == workspace.id)
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
            itemCount: workspace.memberIds.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final memberId = workspace.memberIds[index];
              final isOwner = memberId == workspace.ownerId;
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
                    : workspace.ownerId == workspace.id
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

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _handleAction(BuildContext context, String action) {
    final bloc = context.read<WorkspaceBloc>();

    switch (action) {
      case 'edit':
        showDialog(
          context: context,
          builder: (context) => EditWorkspaceDialog(workspace: workspace),
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
        content: Text('Are you sure you want to leave "${workspace.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              bloc.add(LeaveWorkspace(workspace.id));
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
          'Are you sure you want to delete "${workspace.name}"? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              bloc.add(DeleteWorkspace(workspace.id));
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
      builder: (context) => InviteMemberDialog(workspaceId: workspace.id),
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
                    RemoveMember(
                      workspaceId: workspace.id,
                      memberId: memberId,
                    ),
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
}
