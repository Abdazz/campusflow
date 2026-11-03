import 'package:campusflow/models/task.dart';
import 'package:campusflow/screens/home_shell.dart';
import 'package:campusflow/screens/task_detail_screen.dart';
import 'package:campusflow/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
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

Widget _app() => MaterialApp(
  theme: AppTheme.light(),
  locale: const Locale('fr', 'FR'),
  supportedLocales: const [Locale('fr', 'FR')],
  localizationsDelegates: GlobalMaterialLocalizations.delegates,
  home: HomeShell(initialTasks: _tasks),
);

void _setScreenSize(WidgetTester tester, Size size) {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
}

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

  testWidgets('Filtre « Terminées » et case à cocher de la carte', (
    tester,
  ) async {
    _setScreenSize(tester, const Size(390, 844));
    await tester.pumpWidget(_app());

    await tester.tap(find.byTooltip('Marquer Rendu TP Dart comme fait'));
    await tester.pump();
    expect(find.text('1 échéance à venir'), findsOneWidget);
    expect(find.text('Rendu TP Dart'), findsNothing);

    await tester.tap(find.text('Terminées · 2'));
    await tester.pump();
    expect(find.text('Rendu TP Dart'), findsOneWidget);
    expect(find.text('Fiche persona'), findsOneWidget);
  });

  testWidgets('Détail : « Marquer comme fait » met à jour la liste', (
    tester,
  ) async {
    _setScreenSize(tester, const Size(390, 844));
    await tester.pumpWidget(_app());

    await tester.tap(find.text('Rendu TP Dart'));
    await tester.pumpAndSettle();
    expect(find.text('Modèles et tests'), findsOneWidget);
    expect(find.text('Demain'), findsOneWidget);

    await tester.tap(find.text('Marquer comme fait'));
    await tester.pump();
    expect(find.text('Marquer comme à faire'), findsOneWidget);
    expect(find.text('Terminée'), findsOneWidget);

    Navigator.of(tester.element(find.byType(TaskDetailScreen))).pop();
    await tester.pumpAndSettle();
    expect(find.text('1 échéance à venir'), findsOneWidget);
  });

  testWidgets('Formulaire : validation puis SnackBar à l’enregistrement', (
    tester,
  ) async {
    _setScreenSize(tester, const Size(390, 844));
    await tester.pumpWidget(_app());

    await tester.tap(find.text('Nouvelle tâche'));
    await tester.pumpAndSettle();
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

    // Pas de nouvel écran : le détail s'affiche à droite de la liste.
    expect(find.byType(TaskDetailScreen), findsNothing);
    expect(find.text('Marquer comme fait'), findsOneWidget);
    expect(find.text('Examen UX'), findsNWidgets(2));
  });
}
