import 'package:flutter/material.dart';

import '../models/task.dart';
import '../theme/app_theme.dart';
import '../widgets/task_tile.dart';
import 'task_detail_screen.dart';

/// Contenu de l'onglet Échéances.
///
/// Sous 840 dp : la liste seule, un appui ouvre l'écran Détail.
/// À partir de 840 dp : liste et détail côte à côte (LayoutBuilder).
class TasksView extends StatelessWidget {
  const TasksView({
    super.key,
    required this.tasks,
    required this.selectedTaskId,
    required this.onSelect,
    required this.onToggleDone,
  });

  final List<Task> tasks;
  final String? selectedTaskId;
  final ValueChanged<Task> onSelect;
  final ValueChanged<Task> onToggleDone;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= AppBreakpoints.expanded) {
          return _ExpandedLayout(
            tasks: tasks,
            selectedTaskId: selectedTaskId,
            onSelect: onSelect,
            onToggleDone: onToggleDone,
          );
        }
        return _TaskList(
          tasks: tasks,
          onTap: (task) => _openDetail(context, task),
        );
      },
    );
  }

  void _openDetail(BuildContext context, Task task) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) =>
            TaskDetailScreen(task: task, onToggleDone: onToggleDone),
      ),
    );
  }
}

class _ExpandedLayout extends StatelessWidget {
  const _ExpandedLayout({
    required this.tasks,
    required this.selectedTaskId,
    required this.onSelect,
    required this.onToggleDone,
  });

  final List<Task> tasks;
  final String? selectedTaskId;
  final ValueChanged<Task> onSelect;
  final ValueChanged<Task> onToggleDone;

  @override
  Widget build(BuildContext context) {
    final selected = tasks.where((t) => t.id == selectedTaskId).firstOrNull;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          flex: 2,
          child: _TaskList(
            tasks: tasks,
            selectedTaskId: selectedTaskId,
            onTap: onSelect,
          ),
        ),
        const VerticalDivider(width: 1),
        Expanded(
          flex: 3,
          child: selected == null
              ? const _EmptyDetail()
              : TaskDetailView(
                  key: ValueKey(selected.id),
                  task: selected,
                  onToggleDone: () =>
                      onToggleDone(selected.copyWith(isDone: !selected.isDone)),
                ),
        ),
      ],
    );
  }
}

class _TaskList extends StatelessWidget {
  const _TaskList({
    required this.tasks,
    required this.onTap,
    this.selectedTaskId,
  });

  final List<Task> tasks;
  final ValueChanged<Task> onTap;
  final String? selectedTaskId;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final remaining = tasks.where((t) => !t.isDone).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.sm,
            AppSpacing.md,
            AppSpacing.sm,
          ),
          child: Text(
            remaining == 0
                ? 'Tout est fait, bravo !'
                : '$remaining échéance${remaining > 1 ? 's' : ''} à venir',
            style: theme.textTheme.titleSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        // Expanded : sans lui, le ListView dans la Column reçoit une
        // hauteur non bornée.
        Expanded(
          child: tasks.isEmpty
              ? const Center(child: Text('Aucune échéance.'))
              : ListView.builder(
                  // Marge basse pour ne pas masquer la dernière ligne
                  // sous le bouton flottant.
                  padding: const EdgeInsets.only(bottom: 88),
                  itemCount: tasks.length,
                  itemBuilder: (context, index) {
                    final task = tasks[index];
                    return TaskTile(
                      task: task,
                      selected: task.id == selectedTaskId,
                      onTap: () => onTap(task),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class _EmptyDetail extends StatelessWidget {
  const _EmptyDetail();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.touch_app_outlined, size: 48, color: colors.outline),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Sélectionne une échéance pour voir le détail.',
            style: TextStyle(color: colors.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}
