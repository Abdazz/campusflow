import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:campusflow/core/date_labels.dart';
import 'package:campusflow/core/theme.dart';
import 'package:campusflow/core/widgets/async_vue.dart';
import 'package:campusflow/core/widgets/header_bar.dart';
import 'package:campusflow/features/cours/data/cours_catalogue.dart';
import 'package:campusflow/features/taches/application/taches_provider.dart';
import 'package:campusflow/features/taches/domain/task.dart';
import 'package:campusflow/features/taches/domain/task_state.dart';

/// Destination `/cours`.
class CoursesPage extends ConsumerWidget {
  const CoursesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return TabScaffold(
      title: 'Mes cours',
      subtitle: 'Semestre 1 · ${sampleCourses.length} modules',
      body: AsyncVue(
        valeur: ref.watch(tachesProvider),
        chargement: 'Chargement des cours',
        onRetry: () => ref.invalidate(tachesProvider),
        donnee: (taches) => CoursesView(tasks: taches),
      ),
    );
  }
}

/// Onglet Cours (maquette H5) : un cours par carte, la prochaine échéance
/// et le nombre de tâches restantes.
class CoursesView extends StatelessWidget {
  const CoursesView({super.key, required this.tasks});

  final List<Task> tasks;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
      itemCount: sampleCourses.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final course = sampleCourses[index];
        final pending =
            tasks.where((t) => t.courseId == course.id && !t.isDone).toList()
              ..sort((a, b) => a.dueDate.compareTo(b.dueDate));
        final next = pending.firstOrNull;
        final urgent =
            next != null &&
            switch (next.stateAt(now)) {
              TaskState.urgent || TaskState.overdue => true,
              _ => false,
            };
        return _CourseCard(
          initials: course.initials,
          name: course.name,
          subtitle: next == null
              ? 'À jour'
              : 'Prochaine : ${shortDayLabel(next.dueDate, now: now)}, '
                    '${hourLabel(next.dueDate)}',
          pending: pending.length,
          urgent: urgent,
        );
      },
    );
  }
}

class _CourseCard extends StatelessWidget {
  const _CourseCard({
    required this.initials,
    required this.name,
    required this.subtitle,
    required this.pending,
    required this.urgent,
  });

  final String initials;
  final String name;
  final String subtitle;
  final int pending;
  final bool urgent;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final campus = context.campusColors;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: urgent ? colors.primary : colors.primaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              initials,
              style: theme.textTheme.labelLarge?.copyWith(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: urgent ? colors.onPrimary : colors.onPrimaryContainer,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          if (pending > 0)
            Container(
              constraints: const BoxConstraints(minWidth: 28),
              height: 28,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              alignment: Alignment.center,
              decoration: ShapeDecoration(
                color: urgent
                    ? campus.urgentContainer
                    : colors.primaryContainer,
                shape: const StadiumBorder(),
              ),
              child: Text(
                '$pending',
                semanticsLabel:
                    '$pending tâche${pending > 1 ? 's' : ''} à faire',
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: urgent ? campus.urgent : colors.onPrimaryContainer,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
