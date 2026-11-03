import 'package:flutter/material.dart';

import '../data/sample_data.dart';
import '../models/task.dart';
import '../theme/app_theme.dart';

/// Onglet Cours : un cours par ligne, avec le nombre de tâches restantes.
class CoursesView extends StatelessWidget {
  const CoursesView({super.key, required this.tasks});

  final List<Task> tasks;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: sampleCourses.length,
      itemBuilder: (context, index) {
        final course = sampleCourses[index];
        final remaining = tasks
            .where((t) => t.courseId == course.id && !t.isDone)
            .length;
        return ListTile(
          leading: CircleAvatar(child: Text(course.name[0])),
          title: Text(course.name),
          subtitle: Text(course.teacher),
          trailing: Badge.count(
            count: remaining,
            isLabelVisible: remaining > 0,
          ),
        );
      },
    );
  }
}

/// Onglet Profil : la persona Amina (données fictives).
class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        const CircleAvatar(radius: 40, child: Icon(Icons.person, size: 40)),
        const SizedBox(height: AppSpacing.md),
        Text(
          'Amina',
          textAlign: TextAlign.center,
          style: theme.textTheme.titleLarge,
        ),
        Text(
          'Master 1 Informatique · amina@campus.bf',
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        const ListTile(
          leading: Icon(Icons.notifications_outlined),
          title: Text('Rappels'),
          subtitle: Text('La veille de chaque échéance'),
        ),
        const ListTile(leading: Icon(Icons.logout), title: Text('Déconnexion')),
      ],
    );
  }
}
