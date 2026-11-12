import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:campusflow/core/stockage_securise.dart';
import 'package:campusflow/main.dart';

void main() {
  testWidgets("L'écran de titre affiche le nom de l'application", (
    tester,
  ) async {
    // Le plugin natif du stockage chiffré n'existe pas en test.
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          stockageSecuriseProvider.overrideWithValue(StockageMemoire()),
        ],
        child: const CampusFlowApp(),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('CampusFlow'), findsOneWidget);
    expect(find.text('Bienvenue'), findsOneWidget); // pas encore connecté
    expect(find.text('Commencer'), findsOneWidget);
  });
}
