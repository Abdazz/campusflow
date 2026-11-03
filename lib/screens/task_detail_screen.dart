import 'package:flutter/material.dart';

import '../data/sample_data.dart';
import '../models/task.dart';
import '../theme/app_theme.dart';
import '../utils/date_labels.dart';

/// Écran Détail sur téléphone : un Scaffold autour de [TaskDetailView].
///
/// Il garde une copie locale de la tâche pour refléter tout de suite
/// « Marquer comme fait », et prévient la liste via [onToggleDone].
class TaskDetailScreen extends StatefulWidget {
  const TaskDetailScreen({
    super.key,
    required this.task,
    required this.onToggleDone,
  });

  final Task task;
  final ValueChanged<Task> onToggleDone;

  @override
  State<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  late Task _task = widget.task;

  void _toggle() {
    setState(() => _task = _task.copyWith(isDone: !_task.isDone));
    widget.onToggleDone(_task);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_task.title)),
      body: TaskDetailView(task: _task, onToggleDone: _toggle),
    );
  }
}

/// Contenu du détail, réutilisé tel quel dans le panneau droit en tablette.
class TaskDetailView extends StatelessWidget {
  const TaskDetailView({
    super.key,
    required this.task,
    required this.onToggleDone,
  });

  final Task task;
  final VoidCallback onToggleDone;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final course = courseById(task.courseId);
    final overdue = task.isOverdue(DateTime.now());

    // Défilant : en paysage ou avec un texte agrandi, la hauteur manque.
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(task.title, style: theme.textTheme.headlineSmall),
          const SizedBox(height: AppSpacing.sm),
          Align(
            alignment: Alignment.centerLeft,
            child: _StatusChip(isDone: task.isDone, overdue: overdue),
          ),
          const SizedBox(height: AppSpacing.md),
          Card(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
              child: Column(
                children: [
                  _InfoRow(
                    icon: Icons.school_outlined,
                    label: 'Cours',
                    value: course.name,
                  ),
                  _InfoRow(
                    icon: Icons.person_outline,
                    label: 'Enseignant',
                    value: course.teacher,
                  ),
                  _InfoRow(
                    icon: Icons.event_outlined,
                    label: 'Échéance',
                    value: fullDateLabel(task.dueDate),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Description', style: theme.textTheme.titleMedium),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    task.description ?? 'Aucune description.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: task.description == null
                          ? colors.onSurfaceVariant
                          : null,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          if (task.isDone)
            FilledButton.tonalIcon(
              onPressed: onToggleDone,
              icon: const Icon(Icons.undo),
              label: const Text('Marquer comme à faire'),
            )
          else
            FilledButton.icon(
              onPressed: onToggleDone,
              icon: const Icon(Icons.check),
              label: const Text('Marquer comme fait'),
            ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(label),
      subtitle: Text(value),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.isDone, required this.overdue});

  final bool isDone;
  final bool overdue;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final (label, background, foreground) = isDone
        ? ('Terminée', colors.primaryContainer, colors.onPrimaryContainer)
        : overdue
        ? ('En retard', colors.errorContainer, colors.onErrorContainer)
        : ('À faire', colors.surfaceContainerHighest, colors.onSurface);

    return Chip(
      label: Text(label),
      backgroundColor: background,
      labelStyle: TextStyle(color: foreground),
      side: BorderSide.none,
    );
  }
}
