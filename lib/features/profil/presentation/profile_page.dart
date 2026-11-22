import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:campusflow/core/widgets/async_vue.dart';
import 'package:campusflow/core/widgets/header_bar.dart';
import 'package:campusflow/features/cours/data/cours_catalogue.dart';
import 'package:campusflow/core/theme.dart';
import 'package:campusflow/features/auth/application/auth_provider.dart';
import 'package:campusflow/features/auth/domain/utilisateur.dart';
import 'package:campusflow/features/taches/application/taches_provider.dart';
import 'package:campusflow/features/taches/domain/task.dart';

/// Destination `/profil`.
class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final utilisateur = ref.watch(authProvider).value;
    // Sans session, le routeur redirige vers /login.
    if (utilisateur == null) return const SizedBox.shrink();
    return TabScaffold(
      title: 'Profil',
      subtitle: utilisateur.programme,
      showAvatar: false,
      body: AsyncVue(
        valeur: ref.watch(tachesProvider),
        chargement: 'Chargement du profil',
        onRetry: () => ref.invalidate(tachesProvider),
        donnee: (taches) => ProfileView(
          utilisateur: utilisateur,
          tasks: taches,
          // Le jeton est effacé, puis on ouvre `/login` sans « suite » : la
          // reconnexion mène aux échéances, pas au profil.
          onDeconnexion: () async {
            final router = GoRouter.of(context);
            await ref.read(authProvider.notifier).deconnecter();
            router.go('/login');
          },
        ),
      ),
    );
  }
}

/// Onglet Profil : l'étudiant connecté, ses chiffres et la déconnexion.
class ProfileView extends StatelessWidget {
  const ProfileView({
    super.key,
    required this.utilisateur,
    required this.tasks,
    required this.onDeconnexion,
  });

  final Utilisateur utilisateur;
  final List<Task> tasks;
  final VoidCallback onDeconnexion;

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
                    utilisateur.initiales,
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
                      Text(utilisateur.nom, style: theme.textTheme.titleMedium),
                      const SizedBox(height: 4),
                      Text(
                        utilisateur.email,
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
        const SizedBox(height: AppSpacing.lg),
        OutlinedButton.icon(
          onPressed: onDeconnexion,
          icon: const Icon(Icons.logout_rounded),
          label: const Text('Se déconnecter'),
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
