import 'package:flutter/material.dart';

import '../data/sample_data.dart';
import '../models/task.dart';
import '../theme/app_theme.dart';
import '../utils/date_labels.dart';
import 'brand.dart';

/// Carte de tâche du design system : états urgente (sous 24 h), à faire,
/// faite. La case de 48 dp marque la tâche ; le reste ouvre le détail.
class TaskTile extends StatelessWidget {
  const TaskTile({
    super.key,
    required this.task,
    required this.onTap,
    required this.onToggleDone,
    this.selected = false,
    this.now,
  });

  final Task task;
  final VoidCallback onTap;
  final VoidCallback onToggleDone;
  final bool selected;
  final DateTime? now;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final campus = context.campusColors;
    final state = task.stateAt(now ?? DateTime.now());
    final course = courseById(task.courseId);
    final done = state == TaskState.done;
    final late = state == TaskState.overdue || state == TaskState.urgent;

    final Color background = done
        ? campus.successContainer
        : selected
        ? colors.primaryContainer
        : colors.surface;
    final BorderSide border = selected
        ? BorderSide(color: colors.primary, width: 1.5)
        : late
        ? BorderSide(color: campus.urgentBorder, width: 1.5)
        : BorderSide(color: colors.outlineVariant);

    final (String chip, Color chipBg, Color chipFg) = switch (state) {
      TaskState.overdue => ('En retard', campus.urgentContainer, campus.urgent),
      TaskState.urgent => (
        hourLabel(task.dueDate),
        campus.urgentContainer,
        campus.urgent,
      ),
      TaskState.todo when _isTomorrow(task.dueDate) => (
        hourLabel(task.dueDate),
        colors.primaryContainer,
        colors.onPrimaryContainer,
      ),
      _ => (hourLabel(task.dueDate), campus.neutralChip, campus.onNeutralChip),
    };

    return Material(
      color: background,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.card),
        side: border,
      ),
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.only(left: 4, right: 14),
        horizontalTitleGap: 4,
        minVerticalPadding: 10,
        leading: _DoneBox(
          state: state,
          title: task.title,
          onPressed: onToggleDone,
        ),
        title: Text(
          task.title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: done
              ? theme.textTheme.titleSmall?.copyWith(
                  color: campus.success,
                  decoration: TextDecoration.lineThrough,
                  decorationColor: campus.success,
                )
              : null,
        ),
        subtitle: Text(
          done ? 'Terminée · ${course.name}' : course.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: done ? TextStyle(color: campus.success) : null,
        ),
        trailing: done
            ? null
            : Pill(label: chip, background: chipBg, foreground: chipFg),
      ),
    );
  }

  bool _isTomorrow(DateTime date) {
    final today = now ?? DateTime.now();
    final tomorrow = DateTime(today.year, today.month, today.day + 1);
    return date.year == tomorrow.year &&
        date.month == tomorrow.month &&
        date.day == tomorrow.day;
  }
}

/// Case à cocher de 48 × 48 dp (cible tactile Material).
class _DoneBox extends StatelessWidget {
  const _DoneBox({
    required this.state,
    required this.title,
    required this.onPressed,
  });

  final TaskState state;
  final String title;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final campus = context.campusColors;
    final done = state == TaskState.done;
    final borderColor = switch (state) {
      TaskState.overdue || TaskState.urgent => campus.urgent,
      TaskState.done => campus.success,
      TaskState.todo => Theme.of(context).colorScheme.onSurfaceVariant,
    };

    return IconButton(
      onPressed: onPressed,
      tooltip: done
          ? 'Marquer $title comme à faire'
          : 'Marquer $title comme fait',
      constraints: const BoxConstraints.tightFor(width: 48, height: 48),
      padding: EdgeInsets.zero,
      icon: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 22,
        height: 22,
        decoration: BoxDecoration(
          color: done ? campus.success : Colors.transparent,
          borderRadius: BorderRadius.circular(7),
          border: done ? null : Border.all(color: borderColor, width: 2),
        ),
        child: done
            ? const Icon(Icons.check_rounded, size: 18, color: Colors.white)
            : null,
      ),
    );
  }
}
