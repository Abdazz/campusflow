import 'package:campusflow/main.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets("L'écran de titre affiche le nom de l'application", (
    tester,
  ) async {
    await tester.pumpWidget(const ProviderScope(child: CampusFlowApp()));
    expect(find.text('CampusFlow'), findsOneWidget);
    expect(find.text('Commencer'), findsOneWidget);
  });
}
