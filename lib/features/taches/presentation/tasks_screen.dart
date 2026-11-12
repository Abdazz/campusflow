import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:campusflow/core/api_exception.dart';
import 'package:campusflow/core/date_labels.dart';
import 'package:campusflow/core/theme.dart';
import 'package:campusflow/core/widgets/async_vue.dart';
import 'package:campusflow/core/widgets/brand.dart';
import 'package:campusflow/core/widgets/header_bar.dart';
import 'package:campusflow/features/taches/application/filtres_provider.dart';
import 'package:campusflow/features/taches/application/taches_provider.dart';
import 'package:campusflow/features/taches/domain/task.dart';
import 'package:campusflow/features/taches/presentation/actions_taches.dart';
import 'package:campusflow/features/taches/presentation/task_detail_screen.dart';
import 'package:campusflow/features/taches/presentation/task_tile.dart';

/// Onglet Échéances (`/taches`) : en-tête « Cette semaine » et liste.
class TasksPage extends StatelessWidget {
  const TasksPage({super.key, this.selectedTaskId});

  /// En tablette, la tâche affichée dans le panneau de droite.
  final String? selectedTaskId;

  @override
  Widget build(BuildContext context) {
    return TabScaffold(
      title: 'Cette semaine',
      subtitle: weekRangeLabel(),
      body: TasksView(selectedTaskId: selectedTaskId),
    );
  }
}

/// Route `/taches/:id`.
///
/// Sous 840 dp : l'écran Détail seul. À partir de 840 dp : la liste et le
/// détail côte à côte, la tâche de l'adresse étant sélectionnée.
class TaskRoutePage extends StatelessWidget {
  const TaskRoutePage({super.key, required this.taskId});

  final String taskId;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) =>
          constraints.maxWidth >= AppBreakpoints.expanded
          ? TasksPage(selectedTaskId: taskId)
          : TaskDetailScreen(taskId: taskId),
    );
  }
}

/// Liste des échéances, variante A « Liste par jour » retenue dans le
/// dossier de conception : carte résumé, filtre, tâches groupées par jour,
/// l'urgent en haut.
///
/// Les tâches viennent de `tachesProvider` : cocher ici met à jour le
/// détail, le profil et les cours.
class TasksView extends ConsumerStatefulWidget {
  const TasksView({super.key, this.selectedTaskId});

  final String? selectedTaskId;

  @override
  ConsumerState<TasksView> createState() => _TasksViewState();
}

class _TasksViewState extends ConsumerState<TasksView> {
  /// Tirer pour rafraîchir : `GET /taches` à nouveau.
  Future<void> _rafraichir() async {
    final messages = ScaffoldMessenger.of(context);
    try {
      ref.invalidate(tachesProvider);
      await ref.read(tachesProvider.future);
    } on ApiException catch (e) {
      // 401 : l'écran de connexion explique déjà « Session expirée ».
      if (!e.nonAuthentifie) {
        messages.showSnackBar(SnackBar(content: Text(e.message)));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Trois états : chargement, erreur (avec « Réessayer »), donnée.
    return AsyncVue(
      valeur: ref.watch(tachesProvider),
      chargement: 'Chargement des échéances',
      onRetry: () => ref.invalidate(tachesProvider),
      donnee: (_) => _contenu(context),
    );
  }

  Widget _contenu(BuildContext context) {
    // Le filtre est un état partagé : il vit dans filtreProvider, plus dans
    // un booléen local de l'écran.
    final filtre = ref.watch(filtreProvider);
    return LayoutBuilder(
      builder: (context, constraints) {
        final expanded = constraints.maxWidth >= AppBreakpoints.expanded;
        final list = RefreshIndicator(
          onRefresh: _rafraichir,
          child: _TaskList(
            visible: ref.watch(tachesFiltreesProvider),
            counts: ref.watch(compteursProvider),
            filtre: filtre,
            now: ref.watch(horlogeProvider)(),
            onFilterChanged: ref.read(filtreProvider.notifier).choisir,
            selectedTaskId: expanded ? widget.selectedTaskId : null,
            // Navigation par adresse : la tâche est dans le chemin. Comme
            // `:id` est une sous-route de `/taches`, le retour ramène à la
            // liste.
            onTap: (task) => context.go('/taches/${task.id}'),
            onToggleDone: (task) => basculerTache(context, ref, task),
          ),
        );
        if (!expanded) return list;

        final selected = widget.selectedTaskId == null
            ? null
            : ref.watch(tacheProvider(widget.selectedTaskId!));
        return Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(flex: 2, child: list),
            const VerticalDivider(width: 1),
            Expanded(
              flex: 3,
              child: selected == null
                  ? _EmptyDetail(unknownId: widget.selectedTaskId != null)
                  : _DetailPane(key: ValueKey(selected.id), task: selected),
            ),
          ],
        );
      },
    );
  }
}

/// Panneau droit en tablette : le détail, « Modifier » et « Supprimer ».
class _DetailPane extends ConsumerWidget {
  const _DetailPane({super.key, required this.task});

  final Task task;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 12, 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                onPressed: () => supprimerTache(context, ref, task),
                tooltip: 'Supprimer la tâche',
                icon: const Icon(Icons.delete_outline_rounded),
              ),
              TextButton(
                onPressed: () => context.push('/taches/${task.id}/modifier'),
                child: const Text('Modifier'),
              ),
            ],
          ),
        ),
        Expanded(
          child: TaskDetailView(
            task: task,
            onToggleDone: () => basculerTache(context, ref, task),
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
    required this.visible,
    required this.counts,
    required this.filtre,
    required this.now,
    required this.onFilterChanged,
    required this.selectedTaskId,
    required this.onTap,
    required this.onToggleDone,
  });

  /// Les tâches du filtre actif, déjà triées (tachesFiltreesProvider).
  final List<Task> visible;
  final Map<FiltreTaches, int> counts;
  final FiltreTaches filtre;
  final DateTime now;
  final ValueChanged<FiltreTaches> onFilterChanged;
  final String? selectedTaskId;
  final ValueChanged<Task> onTap;
  final ValueChanged<Task> onToggleDone;

  /// Groupe les tâches par jour. Dans « À faire », les tâches en retard
  /// passent en tête sous leur propre en-tête.
  List<_Row> _buildRows() {
    final rows = <_Row>[];
    final overdue = filtre == FiltreTaches.aFaire
        ? visible.where((t) => t.dueDate.isBefore(now)).toList()
        : <Task>[];
    if (overdue.isNotEmpty) {
      rows.add(_HeaderRow('En retard', urgent: true));
      rows.addAll(overdue.map(_TaskRow.new));
    }

    String? lastHeader;
    for (final task in visible.where((t) => !overdue.contains(t))) {
      final header = sectionLabel(task.dueDate, now: now);
      if (header != lastHeader) {
        rows.add(_HeaderRow(header, urgent: filtre == FiltreTaches.enRetard));
        lastHeader = header;
      }
      rows.add(_TaskRow(task));
    }
    return rows;
  }

  @override
  Widget build(BuildContext context) {
    final rows = _buildRows();
    final todo = counts[FiltreTaches.aFaire]!;
    final done = counts[FiltreTaches.faites]!;

    // Résumé et filtre défilent avec la liste : rien n'est figé en hauteur.
    const leading = 2;
    return ListView.builder(
      // Toujours défilable : le geste « tirer pour rafraîchir » marche
      // même quand la liste est courte.
      physics: const AlwaysScrollableScrollPhysics(),
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
              selected: filtre,
              counts: counts,
              onChanged: onFilterChanged,
            ),
          );
        }
        if (rows.isEmpty) {
          return _EmptyList(filtre: filtre);
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

/// Filtre à trois segments « À faire · n », « Faites · n »,
/// « En retard · n ».
class _FilterToggle extends StatelessWidget {
  const _FilterToggle({
    required this.selected,
    required this.counts,
    required this.onChanged,
  });

  final FiltreTaches selected;
  final Map<FiltreTaches, int> counts;
  final ValueChanged<FiltreTaches> onChanged;

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
          for (final filtre in FiltreTaches.values)
            _Segment(
              label: '${filtre.label} · ${counts[filtre]}',
              selected: filtre == selected,
              onTap: () => onChanged(filtre),
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
                // Trois segments sur 360 dp : le libellé rétrécit plutôt
                // que de passer à la ligne.
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: Text(
                      label,
                      style: theme.textTheme.labelLarge?.copyWith(
                        fontWeight: selected
                            ? FontWeight.w700
                            : FontWeight.w600,
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
        ),
      ),
    );
  }
}

class _EmptyList extends StatelessWidget {
  const _EmptyList({required this.filtre});

  final FiltreTaches filtre;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Text(
        switch (filtre) {
          FiltreTaches.aFaire => 'Rien à rendre : profites-en !',
          FiltreTaches.faites => 'Aucune tâche terminée pour l’instant.',
          FiltreTaches.enRetard => 'Aucun retard, bravo !',
        },
        textAlign: TextAlign.center,
        style: TextStyle(color: colors.onSurfaceVariant),
      ),
    );
  }
}

class _EmptyDetail extends StatelessWidget {
  const _EmptyDetail({this.unknownId = false});

  /// L'adresse désigne une tâche qui n'existe pas.
  final bool unknownId;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            unknownId ? Icons.search_off_rounded : Icons.touch_app_outlined,
            size: 48,
            color: colors.outline,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            unknownId
                ? 'Cette tâche n’existe pas ou plus.'
                : 'Sélectionne une échéance pour voir le détail.',
            style: TextStyle(color: colors.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}
