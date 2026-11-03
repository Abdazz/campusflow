import 'package:flutter/material.dart';

import '../data/sample_data.dart';
import '../models/task.dart';
import '../utils/date_labels.dart';

/// Une ligne de la liste des échéances (composant du design system).
class TaskTile extends StatelessWidget {
  const TaskTile({
    super.key,
    required this.task,
    required this.onTap,
    this.selected = false,
  });

  final Task task;
  final VoidCallback onTap;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final overdue = task.isOverdue(DateTime.now());

    final (IconData icon, Color iconColor, String status) = task.isDone
        ? (Icons.check_circle, colors.primary, 'Terminée')
        : overdue
        ? (Icons.error_outline, colors.error, 'En retard')
        : (Icons.radio_button_unchecked, colors.onSurfaceVariant, 'À faire');

    return ListTile(
      selected: selected,
      selectedTileColor: colors.secondaryContainer,
      leading: Icon(icon, color: iconColor, semanticLabel: status),
      title: Text(
        task.title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: task.isDone
            ? TextStyle(
                decoration: TextDecoration.lineThrough,
                color: colors.onSurfaceVariant,
              )
            : null,
      ),
      subtitle: Text(
        '${courseById(task.courseId).name} · ${dueLabel(task.dueDate)}',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: overdue ? TextStyle(color: colors.error) : null,
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
