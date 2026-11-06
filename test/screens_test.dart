import 'package:campusflow/main.dart';
import 'package:campusflow/models/task.dart';
import 'package:campusflow/router.dart';
import 'package:campusflow/screens/task_detail_screen.dart';
import 'package:campusflow/screens/task_form_screen.dart';
import 'package:campusflow/state/taches_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/date_symbol_data_local.dart';

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

/// L'application complète (routeur et Riverpod), ouverte à [location].
Widget _app({String location = '/taches'}) => ProviderScope(
  overrides: [
    tachesProvider.overrideWith(() => TachesNotifier(_tasks)),
    routerProvider.overrideWith((ref) {
      final router = creerRouter(initialLocation: location);
      ref.onDispose(router.dispose);
      return router;
    }),
  ],
  child: const CampusFlowApp(),
);

void _setScreenSize(WidgetTester tester, Size size) {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
}

GoRouter _router(WidgetTester tester) =>
    GoRouter.of(tester.element(find.byType(Navigator).first));

void main() {
  setUpAll(() => initializeDateFormatting('fr_FR'));

  testWidgets('Échéances : résumé, liste, bouton flottant et navigation', (
    tester,
  ) async {
    _setScreenSize(tester, const Size(390, 844));
    await tester.pumpWidget(_app());

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
    await tester.pumpWidget(_app());

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
    await tester.pumpWidget(_app(location: '/taches/a'));
    await tester.pumpAndSettle();

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
    await tester.pumpWidget(_app());

    await tester.tap(find.byTooltip('Marquer Rendu TP Dart comme fait'));
    await tester.pump();
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
    await tester.pumpWidget(_app());

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
    await tester.pumpWidget(_app());

    await tester.tap(find.text('Rendu TP Dart'));
    await tester.pumpAndSettle();
    expect(_router(tester).state.uri.path, '/taches/a');
    expect(find.text('Modèles et tests'), findsOneWidget);
    expect(find.text('Demain'), findsOneWidget);

    await tester.tap(find.text('Marquer comme fait'));
    await tester.pump();
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
    await tester.pumpWidget(_app());

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
    await tester.pumpWidget(_app(location: '/taches/b'));
    await tester.pumpAndSettle();

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
    await tester.pumpWidget(_app());

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
    await tester.pump();
    expect(find.text('1 échéance à venir'), findsOneWidget);
  });
}
