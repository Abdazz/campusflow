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
    courseId: 'c1',
    dueDate: _now.add(const Duration(days: 1)),
    description: 'Modèles et tests',
  ),
  Task(
    id: 'b',
    title: 'Examen UX',
    courseId: 'c3',
    dueDate: _now.add(const Duration(days: 4)),
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

  testWidgets('Échéances : liste, bouton flottant et barre de navigation', (
    tester,
  ) async {
    _setScreenSize(tester, const Size(400, 800));
    await tester.pumpWidget(_app());

    expect(find.widgetWithText(AppBar, 'Échéances'), findsOneWidget);
    expect(find.byType(ListTile), findsNWidgets(2));
    expect(find.text('Rendu TP Dart'), findsOneWidget);
    expect(find.text('Nouvelle tâche'), findsOneWidget);
    expect(find.byType(NavigationBar), findsOneWidget);
  });

  testWidgets('Détail : « Marquer comme fait » met à jour la liste', (
    tester,
  ) async {
    _setScreenSize(tester, const Size(400, 800));
    await tester.pumpWidget(_app());

    await tester.tap(find.text('Rendu TP Dart'));
    await tester.pumpAndSettle();
    expect(find.text('Modèles et tests'), findsOneWidget);

    await tester.tap(find.text('Marquer comme fait'));
    await tester.pump();
    expect(find.text('Marquer comme à faire'), findsOneWidget);

    Navigator.of(tester.element(find.byType(TaskDetailScreen))).pop();
    await tester.pumpAndSettle();
    expect(find.text('1 échéance à venir'), findsOneWidget);
  });

  testWidgets('Formulaire : validation puis SnackBar à l’enregistrement', (
    tester,
  ) async {
    _setScreenSize(tester, const Size(400, 800));
    await tester.pumpWidget(_app());

    await tester.tap(find.text('Nouvelle tâche'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Enregistrer'));
    await tester.pump();
    expect(find.text('Titre requis'), findsOneWidget);
    expect(find.text('Choisis un cours'), findsOneWidget);
    expect(find.text('Date requise'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField).first, 'Projet ML');
    await tester.tap(find.byType(DropdownButtonFormField<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Apprentissage automatique').last);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Échéance'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('OK')); // date
    await tester.pumpAndSettle();
    await tester.tap(find.text('OK')); // heure
    await tester.pumpAndSettle();

    await tester.tap(find.text('Enregistrer'));
    await tester.pumpAndSettle();

    expect(find.byType(SnackBar), findsOneWidget);
    expect(find.text('Projet ML'), findsOneWidget);
    expect(find.text('3 échéances à venir'), findsOneWidget);
  });

  testWidgets('Tablette (≥ 840 dp) : liste et détail côte à côte', (
    tester,
  ) async {
    _setScreenSize(tester, const Size(1280, 800));
    await tester.pumpWidget(_app());

    expect(
      find.text('Sélectionne une échéance pour voir le détail.'),
      findsOneWidget,
    );

    await tester.tap(find.text('Examen UX'));
    await tester.pumpAndSettle();

    // Pas de nouvel écran : le détail s'affiche à droite de la liste.
    expect(find.byType(BackButton), findsNothing);
    expect(find.text('Marquer comme fait'), findsOneWidget);
    expect(find.text('Examen UX'), findsNWidgets(2));
  });
}
