import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/workspace_bloc.dart';
import '../../domain/entities/workspace_entity.dart';
import 'widgets/create_workspace_dialog.dart';
import 'widgets/edit_workspace_dialog.dart';
import 'workspace_detail_screen.dart';

class WorkspaceListScreen extends StatelessWidget {
  const WorkspaceListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    context.read<WorkspaceBloc>().add(LoadWorkspaces());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Workspaces'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showCreateWorkspaceDialog(context),
          ),
        ],
      ),
      body: BlocBuilder<WorkspaceBloc, WorkspaceState>(
        builder: (context, state) {
          if (state is WorkspaceLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is WorkspaceError) {
            return Center(child: Text(state.message));
          } else if (state is WorkspaceLoaded) {
            return _buildWorkspaceList(context, state.workspaces);
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildWorkspaceList(
      BuildContext context, List<WorkspaceEntity> workspaces) {
    if (workspaces.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.group_work_outlined,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            const Text(
              'No workspaces found',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: () => _showCreateWorkspaceDialog(context),
              icon: const Icon(Icons.add),
              label: const Text('Create a workspace'),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: workspaces.length,
      itemBuilder: (context, index) {
        final workspace = workspaces[index];
        return Card(
          elevation: 2,
          margin: const EdgeInsets.only(bottom: 16),
          child: InkWell(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    WorkspaceDetailScreen(workspace: workspace),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListTile(
                  title: Text(
                    workspace.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  subtitle: Text(workspace.description),
                  trailing: PopupMenuButton<String>(
                    onSelected: (value) =>
                        _handleWorkspaceAction(context, value, workspace),
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
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.people_outline,
                        size: 16,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${workspace.memberCount} members',
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Icon(
                        Icons.calendar_today_outlined,
                        size: 16,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Created ${_formatDate(workspace.createdAt)}',
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _showCreateWorkspaceDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const CreateWorkspaceDialog(),
    );
  }

  void _handleWorkspaceAction(
    BuildContext context,
    String action,
    WorkspaceEntity workspace,
  ) {
    final bloc = context.read<WorkspaceBloc>();

    switch (action) {
      case 'edit':
        showDialog(
          context: context,
          builder: (context) => EditWorkspaceDialog(workspace: workspace),
        );
        break;
      case 'leave':
        _showLeaveWorkspaceDialog(context, workspace, bloc);
        break;
      case 'delete':
        _showDeleteWorkspaceDialog(context, workspace, bloc);
        break;
    }
  }

  void _showLeaveWorkspaceDialog(
    BuildContext context,
    WorkspaceEntity workspace,
    WorkspaceBloc bloc,
  ) {
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
              Navigator.pop(context);
            },
            child: const Text('Leave'),
          ),
        ],
      ),
    );
  }

  void _showDeleteWorkspaceDialog(
    BuildContext context,
    WorkspaceEntity workspace,
    WorkspaceBloc bloc,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Workspace'),
        content: Text(
            'Are you sure you want to delete "${workspace.name}"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              bloc.add(DeleteWorkspace(workspace.id));
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
