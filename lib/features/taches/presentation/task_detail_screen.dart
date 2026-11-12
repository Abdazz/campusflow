import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:campusflow/core/date_labels.dart';
import 'package:campusflow/core/theme.dart';
import 'package:campusflow/core/widgets/brand.dart';
import 'package:campusflow/features/cours/data/cours_catalogue.dart';
import 'package:campusflow/features/taches/application/taches_provider.dart';
import 'package:campusflow/features/taches/domain/task.dart';
import 'package:campusflow/features/taches/domain/task_state.dart';

/// Écran Détail sur téléphone (maquette H3), route `/taches/:id`.
///
/// Il ne reçoit que l'identifiant : la tâche est lue dans `tachesProvider`,
/// donc « Marquer comme fait » se voit aussitôt dans la liste.
class TaskDetailScreen extends ConsumerWidget {
  const TaskDetailScreen({super.key, required this.taskId});

  final String taskId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final task = ref.watch(tacheProvider(taskId));
    if (task == null) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Cette tâche n’existe pas ou plus.'),
              const SizedBox(height: AppSpacing.md),
              FilledButton(
                onPressed: () => context.go('/taches'),
                child: const Text('Retour aux échéances'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        actions: [
          TextButton(
            onPressed: () => context.push('/taches/$taskId/modifier'),
            child: const Text('Modifier'),
          ),
          const SizedBox(width: AppSpacing.sm),
        ],
      ),
      body: TaskDetailView(
        task: task,
        onToggleDone: () => ref.read(tachesProvider.notifier).basculer(taskId),
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
