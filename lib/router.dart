import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'screens/home_shell.dart';
import 'screens/other_tabs.dart';
import 'screens/task_form_screen.dart';
import 'screens/tasks_screen.dart';
import 'screens/title_screen.dart';
import 'theme/app_theme.dart';

/// Les routes de CampusFlow (séance 6) :
///
/// | Chemin                 | Écran                      | Niveau           |
/// |------------------------|----------------------------|------------------|
/// | `/`                    | Écran de titre             | Hors barre       |
/// | `/taches`              | Échéances (liste)          | Destination 1    |
/// | `/taches/nouvelle`     | Formulaire de création     | Écran secondaire |
/// | `/taches/:id`          | Détail d'une tâche         | Écran secondaire |
/// | `/taches/:id/modifier` | Formulaire de modification | Écran secondaire |
/// | `/cours`               | Liste des cours            | Destination 2    |
/// | `/profil`              | Compte                     | Destination 3    |
GoRouter creerRouter({String initialLocation = '/'}) {
  final rootKey = GlobalKey<NavigatorState>(debugLabel: 'racine');
  final shellKey = GlobalKey<NavigatorState>(debugLabel: 'ossature');

  return GoRouter(
    navigatorKey: rootKey,
    initialLocation: initialLocation,
    errorBuilder: (context, state) => const _PageIntrouvable(),
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) =>
            TitleScreen(onStart: () => context.go('/taches')),
      ),
      // La ShellRoute garde la barre de navigation (ou le rail) autour des
      // trois destinations.
      ShellRoute(
        navigatorKey: shellKey,
        builder: (context, state, child) =>
            HomeShell(location: state.uri.path, child: child),
        routes: [
          GoRoute(
            path: '/taches',
            pageBuilder: (context, state) =>
                NoTransitionPage(key: state.pageKey, child: const TasksPage()),
            routes: [
              // Déclarée avant `:id`, sinon « nouvelle » serait lu comme un
              // identifiant.
              GoRoute(
                path: 'nouvelle',
                parentNavigatorKey: rootKey,
                pageBuilder: (context, state) => MaterialPage(
                  key: state.pageKey,
                  fullscreenDialog: true,
                  child: const TaskFormScreen(),
                ),
              ),
              GoRoute(
                path: ':id',
                pageBuilder: (context, state) {
                  final id = state.pathParameters['id']!;
                  final child = TaskRoutePage(taskId: id);
                  // En tablette, la liste reste en place : pas d'animation
                  // de page, seul le panneau de droite change.
                  final wide =
                      MediaQuery.sizeOf(context).width >=
                      AppBreakpoints.expanded;
                  return wide
                      ? NoTransitionPage(key: state.pageKey, child: child)
                      : MaterialPage(key: state.pageKey, child: child);
                },
                routes: [
                  GoRoute(
                    path: 'modifier',
                    parentNavigatorKey: rootKey,
                    pageBuilder: (context, state) => MaterialPage(
                      key: state.pageKey,
                      fullscreenDialog: true,
                      child: TaskFormScreen(taskId: state.pathParameters['id']),
                    ),
                  ),
                ],
              ),
            ],
          ),
          GoRoute(
            path: '/cours',
            pageBuilder: (context, state) => NoTransitionPage(
              key: state.pageKey,
              child: const CoursesPage(),
            ),
          ),
          GoRoute(
            path: '/profil',
            pageBuilder: (context, state) => NoTransitionPage(
              key: state.pageKey,
              child: const ProfilePage(),
            ),
          ),
        ],
      ),
    ],
  );
}

/// Le routeur, créé une fois et libéré avec le `ProviderScope`.
final routerProvider = Provider<GoRouter>((ref) {
  final router = creerRouter();
  ref.onDispose(router.dispose);
  return router;
});

class _PageIntrouvable extends StatelessWidget {
  const _PageIntrouvable();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Cette page n’existe pas.'),
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
}
