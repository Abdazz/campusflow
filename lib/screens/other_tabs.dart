import 'package:flutter/material.dart';

import '../data/sample_data.dart';
import '../models/task.dart';
import '../theme/app_theme.dart';
import '../utils/date_labels.dart';

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
          initials: courseInitials(course),
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

/// Onglet Profil : la persona du dossier de conception et ses chiffres.
class ProfileView extends StatelessWidget {
  const ProfileView({super.key, required this.tasks});

  final List<Task> tasks;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final todo = tasks.where((t) => !t.isDone).length;
    final done = tasks.length - todo;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 36,
                  backgroundColor: colors.primaryContainer,
                  child: Text(
                    currentUser.initials,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: colors.onPrimaryContainer,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        currentUser.name,
                        style: theme.textTheme.titleMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        currentUser.email,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _Stat(value: todo, label: 'À faire'),
            const SizedBox(width: 12),
            _Stat(value: done, label: 'Terminées'),
            const SizedBox(width: 12),
            _Stat(value: sampleCourses.length, label: 'Cours'),
          ],
        ),
      ],
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.value, required this.label});

  final int value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            children: [
              Text(
                '$value',
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: theme.colorScheme.primary,
                ),
              ),
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
