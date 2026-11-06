import 'package:campusflow/models/task.dart';
import 'package:campusflow/state/filtres_provider.dart';
import 'package:campusflow/state/taches_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// Les fournisseurs se testent sans afficher de widget.
void main() {
  final now = DateTime(2026, 11, 6, 12);

  ProviderContainer conteneur() {
    final container = ProviderContainer(
      overrides: [
        horlogeProvider.overrideWithValue(() => now),
        tachesProvider.overrideWith(
          () => TachesNotifier([
            Task(
              id: 'retard',
              title: 'Rapport en retard',
              courseId: 'dm',
              dueDate: now.subtract(const Duration(hours: 3)),
            ),
            Task(
              id: 'demain',
              title: 'Exposé',
              courseId: 'fd',
              dueDate: now.add(const Duration(days: 1)),
            ),
            Task(
              id: 'fait',
              title: 'Fiche persona',
              courseId: 'dm',
              dueDate: now.subtract(const Duration(days: 2)),
              isDone: true,
            ),
          ]),
        ),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  List<String> ids(ProviderContainer c) =>
      c.read(tachesFiltreesProvider).map((t) => t.id).toList();

  test('À faire par défaut : les non terminées, la plus proche d’abord', () {
    final c = conteneur();
    expect(c.read(filtreProvider), FiltreTaches.aFaire);
    expect(ids(c), ['retard', 'demain']);
  });

  test('Faites et En retard', () {
    final c = conteneur();
    c.read(filtreProvider.notifier).choisir(FiltreTaches.faites);
    expect(ids(c), ['fait']);

    c.read(filtreProvider.notifier).choisir(FiltreTaches.enRetard);
    expect(ids(c), ['retard']);
  });

  test('Le fournisseur dérivé suit les changements de la liste', () {
    final c = conteneur();
    c.read(filtreProvider.notifier).choisir(FiltreTaches.enRetard);
    expect(c.read(compteursProvider), {
      FiltreTaches.aFaire: 2,
      FiltreTaches.faites: 1,
      FiltreTaches.enRetard: 1,
    });

    // Cocher la tâche en retard la fait sortir du filtre.
    c.read(tachesProvider.notifier).basculer('retard');
    expect(ids(c), isEmpty);
    expect(c.read(compteursProvider)[FiltreTaches.faites], 2);
  });

  test('ajouter et modifier remplacent la liste (état immuable)', () {
    final c = conteneur();
    final avant = c.read(tachesProvider);

    final nouvelle = Task(
      id: 'n',
      title: 'Projet ML',
      courseId: 'aa',
      dueDate: now.add(const Duration(days: 3)),
    );
    c.read(tachesProvider.notifier).ajouter(nouvelle);
    final apres = c.read(tachesProvider);
    expect(identical(avant, apres), isFalse);
    expect(apres, hasLength(4));

    c
        .read(tachesProvider.notifier)
        .modifier(nouvelle.copyWith(title: 'Projet ML v2'));
    expect(c.read(tacheProvider('n'))?.title, 'Projet ML v2');
    expect(c.read(tacheProvider('inconnue')), isNull);
  });
}
