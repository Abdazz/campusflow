import 'package:flutter/material.dart';

import '../models/task.dart';
import '../theme/app_theme.dart';
import '../utils/date_labels.dart';
import '../widgets/brand.dart';
import '../widgets/task_tile.dart';
import 'task_detail_screen.dart';

/// Onglet Échéances, variante A « Liste par jour » retenue dans le dossier
/// de conception : carte résumé, filtre À faire / Terminées, tâches groupées
/// par jour, l'urgent en haut.
///
/// Sous 840 dp : la liste seule, un appui ouvre l'écran Détail.
/// À partir de 840 dp : liste et détail côte à côte (LayoutBuilder).
class TasksView extends StatefulWidget {
  const TasksView({
    super.key,
    required this.tasks,
    required this.selectedTaskId,
    required this.onSelect,
    required this.onChanged,
  });

  final List<Task> tasks;
  final String? selectedTaskId;
  final ValueChanged<Task> onSelect;
  final ValueChanged<Task> onChanged;

  @override
  State<TasksView> createState() => _TasksViewState();
}

class _TasksViewState extends State<TasksView> {
  bool _showDone = false;

  void _toggle(Task task) =>
      widget.onChanged(task.copyWith(isDone: !task.isDone));

  void _openDetail(Task task) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) =>
            TaskDetailScreen(task: task, onChanged: widget.onChanged),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final expanded = constraints.maxWidth >= AppBreakpoints.expanded;
        final list = _TaskList(
          tasks: widget.tasks,
          showDone: _showDone,
          onFilterChanged: (done) => setState(() => _showDone = done),
          selectedTaskId: expanded ? widget.selectedTaskId : null,
          onTap: expanded ? widget.onSelect : _openDetail,
          onToggleDone: _toggle,
        );
        if (!expanded) return list;

        final selected = widget.tasks
            .where((t) => t.id == widget.selectedTaskId)
            .firstOrNull;
        return Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(flex: 2, child: list),
            const VerticalDivider(width: 1),
            Expanded(
              flex: 3,
              child: selected == null
                  ? const _EmptyDetail()
                  : _DetailPane(
                      key: ValueKey(selected.id),
                      task: selected,
                      onChanged: widget.onChanged,
                    ),
            ),
          ],
        );
      },
    );
  }
}

/// Panneau droit en tablette : le détail et son bouton « Modifier ».
class _DetailPane extends StatelessWidget {
  const _DetailPane({super.key, required this.task, required this.onChanged});

  final Task task;
  final ValueChanged<Task> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Align(
          alignment: Alignment.centerRight,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(8, 8, 12, 0),
            child: TextButton(
              onPressed: () async {
                final edited = await editTask(context, task);
                if (edited != null) onChanged(edited);
              },
              child: const Text('Modifier'),
            ),
          ),
        ),
        Expanded(
          child: TaskDetailView(
            task: task,
            onToggleDone: () => onChanged(task.copyWith(isDone: !task.isDone)),
          ),
        ),
      ],
    );
  }
}

/// Une ligne de la liste : un en-tête de jour ou une tâche.
sealed class _Row {}

class _HeaderRow extends _Row {
  _HeaderRow(this.label, {this.urgent = false});
  final String label;
  final bool urgent;
}

class _TaskRow extends _Row {
  _TaskRow(this.task);
  final Task task;
}

class _TaskList extends StatelessWidget {
  const _TaskList({
    required this.tasks,
    required this.showDone,
    required this.onFilterChanged,
    required this.selectedTaskId,
    required this.onTap,
    required this.onToggleDone,
  });

  final List<Task> tasks;
  final bool showDone;
  final ValueChanged<bool> onFilterChanged;
  final String? selectedTaskId;
  final ValueChanged<Task> onTap;
  final ValueChanged<Task> onToggleDone;

  /// Groupe les tâches par jour ; les tâches en retard passent en tête.
  List<_Row> _buildRows(DateTime now) {
    final visible = tasks.where((t) => t.isDone == showDone).toList()
      ..sort(
        (a, b) => showDone
            ? b.dueDate.compareTo(a.dueDate)
            : a.dueDate.compareTo(b.dueDate),
      );

    final rows = <_Row>[];
    final overdue = showDone
        ? <Task>[]
        : visible.where((t) => t.dueDate.isBefore(now)).toList();
    if (overdue.isNotEmpty) {
      rows.add(_HeaderRow('En retard', urgent: true));
      rows.addAll(overdue.map(_TaskRow.new));
    }

    String? lastHeader;
    for (final task in visible.where((t) => !overdue.contains(t))) {
      final header = sectionLabel(task.dueDate, now: now);
      if (header != lastHeader) {
        rows.add(_HeaderRow(header));
        lastHeader = header;
      }
      rows.add(_TaskRow(task));
    }
    return rows;
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final rows = _buildRows(now);
    final todo = tasks.where((t) => !t.isDone).length;
    final done = tasks.length - todo;

    // Résumé et filtre défilent avec la liste : rien n'est figé en hauteur.
    const leading = 2;
    return ListView.builder(
      // Marge basse pour ne pas masquer la dernière carte sous le bouton
      // flottant.
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 104),
      itemCount: leading + (rows.isEmpty ? 1 : rows.length),
      itemBuilder: (context, index) {
        if (index == 0) {
          return _SummaryCard(todo: todo, done: done);
        }
        if (index == 1) {
          return Padding(
            padding: const EdgeInsets.only(top: 16, bottom: 6),
            child: _FilterToggle(
              showDone: showDone,
              todoCount: todo,
              doneCount: done,
              onChanged: onFilterChanged,
            ),
          );
        }
        if (rows.isEmpty) {
          return _EmptyList(showDone: showDone);
        }
        return switch (rows[index - leading]) {
          _HeaderRow(:final label, :final urgent) => Padding(
            padding: const EdgeInsets.fromLTRB(4, 14, 4, 8),
            child: SectionLabel(
              label,
              color: urgent ? context.campusColors.urgent : null,
            ),
          ),
          _TaskRow(:final task) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: TaskTile(
              task: task,
              now: now,
              selected: task.id == selectedTaskId,
              onTap: () => onTap(task),
              onToggleDone: () => onToggleDone(task),
            ),
          ),
        };
      },
    );
  }
}

/// Carte résumé bleue : nombre d'échéances et progression de la semaine.
class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.todo, required this.done});

  final int todo;
  final int done;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final total = todo + done;

    return Container(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
      decoration: BoxDecoration(
        color: colors.primary,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Expanded(
                child: Text(
                  todo == 0
                      ? 'Tout est fait, bravo !'
                      : '$todo échéance${todo > 1 ? 's' : ''} à venir',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: colors.onPrimary,
                  ),
                ),
              ),
              Text(
                '$done sur $total faite${done > 1 ? 's' : ''}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colors.primaryContainer,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: total == 0 ? 0 : done / total,
              minHeight: 6,
              color: colors.onPrimary,
              backgroundColor: context.campusColors.primaryLight,
              semanticsLabel: 'Progression de la semaine',
            ),
          ),
        ],
      ),
    );
  }
}

/// Filtre à deux segments « À faire · n » / « Terminées · n ».
class _FilterToggle extends StatelessWidget {
  const _FilterToggle({
    required this.showDone,
    required this.todoCount,
    required this.doneCount,
    required this.onChanged,
  });

  final bool showDone;
  final int todoCount;
  final int doneCount;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: context.campusColors.neutralContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _Segment(
            label: 'À faire · $todoCount',
            selected: !showDone,
            onTap: () => onChanged(false),
          ),
          _Segment(
            label: 'Terminées · $doneCount',
            selected: showDone,
            onTap: () => onChanged(true),
          ),
        ],
      ),
    );
  }
}

class _Segment extends StatelessWidget {
  const _Segment({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Expanded(
      child: Semantics(
        selected: selected,
        button: true,
        child: Material(
          color: selected ? colors.surface : Colors.transparent,
          elevation: selected ? 1 : 0,
          shadowColor: const Color(0x14000000),
          borderRadius: BorderRadius.circular(9),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(9),
            child: SizedBox(
              height: 40,
              child: Center(
                child: Text(
                  label,
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                    color: selected
                        ? colors.onSurface
                        : colors.onSurfaceVariant,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyList extends StatelessWidget {
  const _EmptyList({required this.showDone});

  final bool showDone;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Text(
        showDone
            ? 'Aucune tâche terminée pour l’instant.'
            : 'Rien à rendre : profites-en !',
        textAlign: TextAlign.center,
        style: TextStyle(color: colors.onSurfaceVariant),
      ),
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
