import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'package:campusflow/core/router.dart';
import 'package:campusflow/features/taches/data/fake_task_repository.dart';
import 'package:campusflow/features/taches/data/task_repository_provider.dart';
import 'package:campusflow/features/taches/domain/task.dart';
import 'package:campusflow/features/taches/presentation/task_detail_screen.dart';
import 'package:campusflow/features/taches/presentation/task_form_screen.dart';
import 'package:campusflow/main.dart';

final _now = DateTime.now();

final _tasks = [
  Task(
    id: 'a',
    title: 'Rendu TP Dart',
    courseId: 'dm',
    dueDate: _now.add(const Duration(days: 1, hours: 2)),
    description: 'Modèles et tests',
  ),
  Task(
    id: 'b',
    title: 'Examen UX',
    courseId: 'fd',
    dueDate: _now.add(const Duration(days: 4)),
  ),
  Task(
    id: 'c',
    title: 'Fiche persona',
    courseId: 'dm',
    dueDate: _now.subtract(const Duration(days: 1)),
    isDone: true,
  ),
];

/// Le Repository de test : en mémoire, sans latence ni réseau.
late FakeTaskRepository _repo;

/// L'application complète (routeur et Riverpod), ouverte à [location].
/// Seul le Repository est remplacé : Notifier, écrans et routes sont réels.
Widget _app({String location = '/taches'}) => ProviderScope(
  overrides: [
    taskRepositoryProvider.overrideWithValue(_repo),
    routerProvider.overrideWith((ref) {
      final router = creerRouter(initialLocation: location);
      ref.onDispose(router.dispose);
      return router;
    }),
  ],
  child: const CampusFlowApp(),
);

/// Ouvre l'application et attend la fin du `GET /taches`.
Future<void> _ouvrir(WidgetTester tester, {String location = '/taches'}) async {
  await tester.pumpWidget(_app(location: location));
  await tester.pumpAndSettle();
}

void _setScreenSize(WidgetTester tester, Size size) {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
}

GoRouter _router(WidgetTester tester) =>
    GoRouter.of(tester.element(find.byType(Navigator).first));

void main() {
  setUpAll(() => initializeDateFormatting('fr_FR'));
  setUp(
    () => _repo = FakeTaskRepository(initiales: _tasks, latence: Duration.zero),
  );

  testWidgets('Échéances : résumé, liste, bouton flottant et navigation', (
    tester,
  ) async {
    _setScreenSize(tester, const Size(390, 844));
    await _ouvrir(tester);

    expect(find.text('Cette semaine'), findsOneWidget);
    expect(find.text('2 échéances à venir'), findsOneWidget);
    expect(find.text('1 sur 3 faite'), findsOneWidget);
    expect(find.text('À faire · 2'), findsOneWidget);
    expect(find.text('Rendu TP Dart'), findsOneWidget);
    expect(find.text('Fiche persona'), findsNothing); // terminée : filtrée
    expect(find.text('Nouvelle tâche'), findsOneWidget);
    expect(find.byType(NavigationBar), findsOneWidget);
  });

  testWidgets('Navigation par adresse : barre de navigation et /cours', (
    tester,
  ) async {
    _setScreenSize(tester, const Size(390, 844));
    await _ouvrir(tester);

    await tester.tap(find.text('Cours'));
    await tester.pumpAndSettle();
    expect(find.text('Mes cours'), findsOneWidget);
    expect(_router(tester).state.uri.path, '/cours');

    _router(tester).go('/profil');
    await tester.pumpAndSettle();
    expect(find.text('Ibrahim Kaboré'), findsOneWidget);
    expect(find.text('Nouvelle tâche'), findsNothing); // bouton : liste seule
  });

  testWidgets('Lien profond /taches/:id : le détail lit la tâche par id', (
    tester,
  ) async {
    _setScreenSize(tester, const Size(390, 844));
    await _ouvrir(tester, location: '/taches/a');

    expect(find.byType(TaskDetailScreen), findsOneWidget);
    expect(find.text('Modèles et tests'), findsOneWidget);

    // Le retour ramène à la liste, même sans l'avoir ouverte avant.
    _router(tester).pop();
    await tester.pumpAndSettle();
    expect(find.text('2 échéances à venir'), findsOneWidget);

    _router(tester).go('/taches/inconnue');
    await tester.pumpAndSettle();
    expect(find.text('Cette tâche n’existe pas ou plus.'), findsOneWidget);
  });

  testWidgets('Cocher dans la liste met à jour le détail et le profil', (
    tester,
  ) async {
    _setScreenSize(tester, const Size(390, 844));
    await _ouvrir(tester);

    await tester.tap(find.byTooltip('Marquer Rendu TP Dart comme fait'));
    await tester.pumpAndSettle();
    expect(find.text('1 échéance à venir'), findsOneWidget);
    expect(find.text('Rendu TP Dart'), findsNothing);

    expect(find.text('Faites · 2'), findsOneWidget);

    _router(tester).go('/taches/a');
    await tester.pumpAndSettle();
    expect(find.text('Marquer comme à faire'), findsOneWidget);

    _router(tester).go('/profil');
    await tester.pumpAndSettle();
    expect(
      find.descendant(
        of: find.ancestor(
          of: find.text('Terminées'),
          matching: find.byType(Card),
        ),
        matching: find.text('2'),
      ),
      findsOneWidget,
    );
  });

  testWidgets('Filtres : à faire, faites, en retard', (tester) async {
    _setScreenSize(tester, const Size(360, 780));
    await _ouvrir(tester);

    expect(find.text('À faire · 2'), findsOneWidget);
    expect(find.text('Faites · 1'), findsOneWidget);
    expect(find.text('En retard · 0'), findsOneWidget);

    await tester.tap(find.text('Faites · 1'));
    await tester.pump();
    expect(find.text('Fiche persona'), findsOneWidget);
    expect(find.text('Rendu TP Dart'), findsNothing);

    await tester.tap(find.text('En retard · 0'));
    await tester.pump();
    expect(find.text('Aucun retard, bravo !'), findsOneWidget);

    // Le filtre est un état partagé : il survit à un changement d'onglet.
    _router(tester).go('/cours');
    await tester.pumpAndSettle();
    _router(tester).go('/taches');
    await tester.pumpAndSettle();
    expect(find.text('Aucun retard, bravo !'), findsOneWidget);
  });

  testWidgets('Détail : « Marquer comme fait » met à jour la liste', (
    tester,
  ) async {
    _setScreenSize(tester, const Size(390, 844));
    await _ouvrir(tester);

    await tester.tap(find.text('Rendu TP Dart'));
    await tester.pumpAndSettle();
    expect(_router(tester).state.uri.path, '/taches/a');
    expect(find.text('Modèles et tests'), findsOneWidget);
    expect(find.text('Demain'), findsOneWidget);

    await tester.tap(find.text('Marquer comme fait'));
    await tester.pumpAndSettle();
    expect(find.text('Marquer comme à faire'), findsOneWidget);
    expect(find.text('Terminée'), findsOneWidget);

    _router(tester).pop();
    await tester.pumpAndSettle();
    expect(find.text('1 échéance à venir'), findsOneWidget);
  });

  testWidgets('Formulaire : validation puis ajout dans le fournisseur', (
    tester,
  ) async {
    _setScreenSize(tester, const Size(390, 844));
    await _ouvrir(tester);

    await tester.tap(find.text('Nouvelle tâche'));
    await tester.pumpAndSettle();
    expect(_router(tester).state.uri.path, '/taches/nouvelle');
    expect(find.text('Cours, date et rappel sont pré-remplis'), findsOneWidget);

    final save = find.text('Enregistrer');
    await tester.ensureVisible(save);
    await tester.tap(save);
    await tester.pump();
    expect(find.text('Titre requis'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField).first, 'Projet ML');
    await tester.ensureVisible(save);
    await tester.tap(save);
    await tester.pumpAndSettle();

    expect(find.byType(SnackBar), findsOneWidget);
    expect(find.text('Projet ML'), findsOneWidget);
    expect(find.text('3 échéances à venir'), findsOneWidget);
  });

  testWidgets('Modifier : /taches/:id/modifier pré-remplit puis enregistre', (
    tester,
  ) async {
    _setScreenSize(tester, const Size(390, 844));
    await _ouvrir(tester, location: '/taches/b');

    await tester.tap(find.text('Modifier'));
    await tester.pumpAndSettle();
    expect(find.byType(TaskFormScreen), findsOneWidget);
    expect(find.text('Modifier la tâche'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField).first, 'Examen UX final');
    final save = find.text('Enregistrer');
    await tester.ensureVisible(save);
    await tester.tap(save);
    await tester.pumpAndSettle();

    // Retour au détail, qui lit déjà la nouvelle valeur.
    expect(find.byType(TaskDetailScreen), findsOneWidget);
    expect(find.text('Examen UX final'), findsOneWidget);
  });

  testWidgets('Tablette (≥ 840 dp) : rail, liste et détail côte à côte', (
    tester,
  ) async {
    _setScreenSize(tester, const Size(1280, 800));
    await _ouvrir(tester);

    expect(find.byType(NavigationRail), findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing);
    // Le bouton d'ajout est dans le rail, pas au-dessus du détail.
    expect(
      find.descendant(
        of: find.byType(NavigationRail),
        matching: find.byTooltip('Nouvelle tâche'),
      ),
      findsOneWidget,
    );
    expect(
      find.text('Sélectionne une échéance pour voir le détail.'),
      findsOneWidget,
    );

    await tester.tap(find.text('Examen UX'));
    await tester.pumpAndSettle();

    // L'adresse change, mais le détail s'affiche à droite de la liste.
    expect(_router(tester).state.uri.path, '/taches/b');
    expect(find.byType(TaskDetailScreen), findsNothing);
    expect(find.text('Examen UX'), findsNWidgets(2));

    await tester.tap(find.text('Marquer comme fait'));
    await tester.pumpAndSettle();
    expect(find.text('1 échéance à venir'), findsOneWidget);
  });

  group('Séance 7 : liste connectée', () {
    testWidgets('Trois états : chargement, erreur puis « Réessayer »', (
      tester,
    ) async {
      _setScreenSize(tester, const Size(390, 844));
      _repo = FakeTaskRepository(
        initiales: _tasks,
        latence: const Duration(milliseconds: 300),
      )..enPanne = true;
      await tester.pumpWidget(_app());

      // Chargement : indicateur, pas encore de liste.
      expect(find.bySemanticsLabel('Chargement des échéances'), findsOneWidget);
      await tester.pumpAndSettle();

      // Erreur : message et bouton « Réessayer ».
      expect(
        find.text('Impossible de joindre le serveur. Vérifie ta connexion.'),
        findsOneWidget,
      );
      _repo.enPanne = false;
      await tester.tap(find.text('Réessayer'));
      await tester.pumpAndSettle();

      // Donnée.
      expect(find.text('Rendu TP Dart'), findsOneWidget);
      expect(_repo.appels, 2);
    });

    testWidgets('Échec d’un PATCH : SnackBar, la liste reste affichée', (
      tester,
    ) async {
      _setScreenSize(tester, const Size(390, 844));
      await _ouvrir(tester);

      _repo.enPanne = true;
      await tester.tap(find.byTooltip('Marquer Rendu TP Dart comme fait'));
      await tester.pumpAndSettle();

      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text('Rendu TP Dart'), findsOneWidget);
      expect(find.text('2 échéances à venir'), findsOneWidget);
    });

    testWidgets('Supprimer depuis le détail : confirmation puis DELETE', (
      tester,
    ) async {
      _setScreenSize(tester, const Size(390, 844));
      await _ouvrir(tester, location: '/taches/a');

      await tester.tap(find.byTooltip('Supprimer la tâche'));
      await tester.pumpAndSettle();
      expect(find.text('Supprimer la tâche ?'), findsOneWidget);
      await tester.tap(find.widgetWithText(FilledButton, 'Supprimer'));
      await tester.pumpAndSettle();

      expect(_router(tester).state.uri.path, '/taches');
      expect(find.text('« Rendu TP Dart » supprimée'), findsOneWidget);
      expect(find.text('1 échéance à venir'), findsOneWidget);
      expect((await _repo.lister()).map((t) => t.id), isNot(contains('a')));
    });

    testWidgets('Ajouter : POST, la tâche reçoit l’id du serveur', (
      tester,
    ) async {
      _setScreenSize(tester, const Size(390, 844));
      await _ouvrir(tester);

      await tester.tap(find.text('Nouvelle tâche'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextFormField).first, 'Projet ML');
      final save = find.text('Enregistrer');
      await tester.ensureVisible(save);
      await tester.tap(save);
      await tester.pumpAndSettle();

      final enregistree = (await _repo.lister()).last;
      expect(enregistree.title, 'Projet ML');
      expect(enregistree.id, isNot(isEmpty));
      expect(find.text('Projet ML'), findsOneWidget);
    });
  });
}
