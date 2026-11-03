import 'package:flutter/material.dart';

import '../data/sample_data.dart';
import '../models/task.dart';
import '../theme/app_theme.dart';
import '../utils/date_labels.dart';
import '../widgets/brand.dart';
import 'task_form_screen.dart';

/// Ouvre le formulaire en mode modification ; renvoie la tâche modifiée.
Future<Task?> editTask(BuildContext context, Task task) {
  return Navigator.of(context).push<Task>(
    MaterialPageRoute(
      fullscreenDialog: true,
      builder: (_) => TaskFormScreen(initialTask: task),
    ),
  );
}

/// Écran Détail sur téléphone (maquette H3).
///
/// Il garde une copie locale de la tâche pour refléter tout de suite les
/// changements, et prévient la liste via [onChanged].
class TaskDetailScreen extends StatefulWidget {
  const TaskDetailScreen({
    super.key,
    required this.task,
    required this.onChanged,
  });

  final Task task;
  final ValueChanged<Task> onChanged;

  @override
  State<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  late Task _task = widget.task;

  void _update(Task task) {
    setState(() => _task = task);
    widget.onChanged(task);
  }

  Future<void> _edit() async {
    final edited = await editTask(context, _task);
    if (edited != null) _update(edited);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        actions: [
          TextButton(onPressed: _edit, child: const Text('Modifier')),
          const SizedBox(width: AppSpacing.sm),
        ],
      ),
      body: TaskDetailView(
        task: _task,
        onToggleDone: () => _update(_task.copyWith(isDone: !_task.isDone)),
      ),
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
    final campus = context.campusColors;
    final course = courseById(task.courseId);
    final state = task.stateAt(DateTime.now());
    final reminder = reminderDate(task);

    final (String status, Color statusBg, Color statusFg) = switch (state) {
      TaskState.done => ('Terminée', campus.successContainer, campus.success),
      TaskState.overdue || TaskState.urgent => (
        relativeDueLabel(task.dueDate),
        campus.urgentContainer,
        campus.urgent,
      ),
      TaskState.todo => (
        relativeDueLabel(task.dueDate),
        colors.primaryContainer,
        colors.onPrimaryContainer,
      ),
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Défilant : en paysage ou avec un texte agrandi, la hauteur manque.
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Pill(
                    label: status,
                    background: statusBg,
                    foreground: statusFg,
                  ),
                ),
                const SizedBox(height: 10),
                Text(task.title, style: theme.textTheme.headlineMedium),
                const SizedBox(height: 20),
                Card(
                  child: Column(
                    children: [
                      _InfoRow(
                        icon: Icons.menu_book_outlined,
                        label: 'Cours',
                        value: course.name,
                      ),
                      const Divider(indent: 70),
                      _InfoRow(
                        icon: Icons.calendar_today_outlined,
                        label: 'Échéance',
                        value: fullDateLabel(task.dueDate),
                      ),
                      const Divider(indent: 70),
                      _InfoRow(
                        icon: Icons.notifications_none_rounded,
                        label: 'Rappel',
                        value: reminder == null
                            ? 'Aucun rappel'
                            : fullDateLabel(reminder),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                const SectionLabel('Consigne'),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  task.description ?? 'Aucune consigne pour cette tâche.',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: task.description == null
                        ? colors.onSurfaceVariant
                        : null,
                  ),
                ),
              ],
            ),
          ),
        ),
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, AppSpacing.sm, 20, 20),
            child: task.isDone
                ? FilledButton.tonalIcon(
                    onPressed: onToggleDone,
                    icon: const Icon(Icons.undo_rounded),
                    label: const Text('Marquer comme à faire'),
                  )
                : FilledButton.icon(
                    onPressed: onToggleDone,
                    icon: const Icon(Icons.check_rounded),
                    label: const Text('Marquer comme fait'),
                  ),
          ),
        ),
      ],
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
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: colors.primaryContainer,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 20, color: colors.onPrimaryContainer),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 2),
                Text(value, style: theme.textTheme.titleSmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
