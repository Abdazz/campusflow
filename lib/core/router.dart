import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:campusflow/core/theme.dart';
import 'package:campusflow/core/widgets/home_shell.dart';
import 'package:campusflow/features/accueil/presentation/title_screen.dart';
import 'package:campusflow/features/auth/application/auth_provider.dart';
import 'package:campusflow/features/auth/domain/utilisateur.dart';
import 'package:campusflow/features/auth/presentation/login_screen.dart';
import 'package:campusflow/features/cours/presentation/courses_page.dart';
import 'package:campusflow/features/profil/presentation/profile_page.dart';
import 'package:campusflow/features/taches/presentation/task_form_screen.dart';
import 'package:campusflow/features/taches/presentation/tasks_screen.dart';

/// Les routes de CampusFlow (séances 6 et 7) :
///
/// | Chemin                 | Écran                      | Niveau           |
/// |------------------------|----------------------------|------------------|
/// | `/`                    | Écran de titre             | Hors barre       |
/// | `/login`               | Connexion                  | Hors barre       |
/// | `/taches`              | Échéances (liste)          | Destination 1    |
/// | `/taches/nouvelle`     | Formulaire de création     | Écran secondaire |
/// | `/taches/:id`          | Détail d'une tâche         | Écran secondaire |
/// | `/taches/:id/modifier` | Formulaire de modification | Écran secondaire |
/// | `/cours`               | Liste des cours            | Destination 2    |
/// | `/profil`              | Compte                     | Destination 3    |
///
/// Sans session, toute page autre que `/` et `/login` redirige vers
/// `/login?suite=<page demandée>` ; après la connexion, le routeur ouvre
/// la page demandée.
GoRouter creerRouter(Ref ref, {String initialLocation = '/'}) {
  final rootKey = GlobalKey<NavigatorState>(debugLabel: 'racine');
  final shellKey = GlobalKey<NavigatorState>(debugLabel: 'ossature');

  // Connexion, déconnexion, jeton expiré : le routeur réévalue `redirect`.
  final sessionChangee = ValueNotifier(0);
  ref.listen(authProvider, (_, _) => sessionChangee.value++);
  ref.onDispose(sessionChangee.dispose);

  return GoRouter(
    navigatorKey: rootKey,
    initialLocation: initialLocation,
    refreshListenable: sessionChangee,
    redirect: (context, state) =>
        redirectionSession(ref.read(authProvider), state.uri),
    errorBuilder: (context, state) => const _PageIntrouvable(),
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) =>
            TitleScreen(onStart: () => context.go('/taches')),
      ),
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
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
  final router = creerRouter(ref);
  ref.onDispose(router.dispose);
  return router;
});

/// La règle de redirection, testable sans routeur :
/// - session en cours de lecture : on ne bouge pas ;
/// - pas de session : `/login`, en retenant la page demandée ;
/// - session ouverte sur `/login` : la page demandée, ou les échéances.
String? redirectionSession(AsyncValue<Utilisateur?> session, Uri adresse) {
  if (!session.hasValue) return null;
  final connecte = session.value != null;
  final chemin = adresse.path;
  final publique = chemin == '/' || chemin == '/login';

  if (!connecte && !publique) {
    return Uri(
      path: '/login',
      queryParameters: {'suite': adresse.toString()},
    ).toString();
  }
  if (connecte && chemin == '/login') {
    final suite = adresse.queryParameters['suite'];
    // Seulement une adresse interne : jamais de redirection vers un autre
    // site.
    return suite != null && suite.startsWith('/') && !suite.startsWith('//')
        ? suite
        : '/taches';
  }
  return null;
}

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
