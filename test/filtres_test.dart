import 'package:campusflow/core/api_exception.dart';
import 'package:campusflow/features/taches/application/filtres_provider.dart';
import 'package:campusflow/features/taches/application/taches_provider.dart';
import 'package:campusflow/features/taches/data/fake_task_repository.dart';
import 'package:campusflow/features/taches/data/task_repository_provider.dart';
import 'package:campusflow/features/taches/domain/task.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// Les fournisseurs se testent sans afficher de widget ni appeler de
/// serveur : le Repository est remplacé par sa version en mémoire.
void main() {
  final now = DateTime(2026, 11, 6, 12);

  late FakeTaskRepository repo;

  Future<ProviderContainer> conteneur() async {
    repo = FakeTaskRepository(
      latence: Duration.zero,
      initiales: [
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
      ],
    );
    final container = ProviderContainer(
      overrides: [
        horlogeProvider.overrideWithValue(() => now),
        taskRepositoryProvider.overrideWithValue(repo),
      ],
    );
    addTearDown(container.dispose);
    // Attend la fin du GET /taches.
    await container.read(tachesProvider.future);
    return container;
  }

  List<String> ids(ProviderContainer c) =>
      c.read(tachesFiltreesProvider).map((t) => t.id).toList();

  group('Filtres (fournisseur dérivé)', () {
    test(
      'À faire par défaut : les non terminées, la plus proche d’abord',
      () async {
        final c = await conteneur();
        expect(c.read(filtreProvider), FiltreTaches.aFaire);
        expect(ids(c), ['retard', 'demain']);
      },
    );

    test('Faites et En retard', () async {
      final c = await conteneur();
      c.read(filtreProvider.notifier).choisir(FiltreTaches.faites);
      expect(ids(c), ['fait']);

      c.read(filtreProvider.notifier).choisir(FiltreTaches.enRetard);
      expect(ids(c), ['retard']);
    });

    test('Le fournisseur dérivé suit les changements de la liste', () async {
      final c = await conteneur();
      c.read(filtreProvider.notifier).choisir(FiltreTaches.enRetard);
      expect(c.read(compteursProvider), {
        FiltreTaches.aFaire: 2,
        FiltreTaches.faites: 1,
        FiltreTaches.enRetard: 1,
      });

      // Cocher la tâche en retard la fait sortir du filtre.
      await c.read(tachesProvider.notifier).basculer('retard');
      expect(ids(c), isEmpty);
      expect(c.read(compteursProvider)[FiltreTaches.faites], 2);
    });
  });

  group('TachesNotifier (AsyncNotifier)', () {
    test('build : chargement puis donnée venue du Repository', () async {
      repo = FakeTaskRepository(latence: Duration.zero, initiales: const []);
      final c = ProviderContainer(
        overrides: [taskRepositoryProvider.overrideWithValue(repo)],
      );
      addTearDown(c.dispose);

      expect(c.read(tachesProvider), isA<AsyncLoading<List<Task>>>());
      await c.read(tachesProvider.future);
      expect(c.read(tachesProvider), isA<AsyncData<List<Task>>>());
      expect(repo.appels, 1);
    });

    test(
      'ajouter, modifier, basculer et supprimer passent par le serveur',
      () async {
        final c = await conteneur();
        final notifier = c.read(tachesProvider.notifier);
        final avant = c.read(tachesProvider).requireValue;

        final creee = await notifier.ajouter(
          Task(
            id: '',
            title: 'Projet ML',
            courseId: 'aa',
            dueDate: now.add(const Duration(days: 3)),
          ),
        );
        expect(creee.id, isNotEmpty); // attribué par le serveur
        final apres = c.read(tachesProvider).requireValue;
        expect(identical(avant, apres), isFalse); // état immuable
        expect(apres, hasLength(4));

        await notifier.modifier(creee.copyWith(title: 'Projet ML v2'));
        expect(c.read(tacheProvider(creee.id))?.title, 'Projet ML v2');

        await notifier.basculer('demain');
        final serveur = await repo.lister();
        expect(serveur.firstWhere((t) => t.id == 'demain').isDone, isTrue);

        await notifier.supprimer(creee.id);
        expect(c.read(tacheProvider(creee.id)), isNull);
        expect(await repo.lister(), hasLength(3));
        expect(c.read(tacheProvider('inconnue')), isNull);
      },
    );

    test('Échec : l’erreur remonte, la liste reste celle d’avant', () async {
      final c = await conteneur();
      final avant = c.read(tachesProvider).requireValue;

      repo.enPanne = true;
      await expectLater(
        c.read(tachesProvider.notifier).basculer('demain'),
        throwsA(isA<ApiException>()),
      );
      expect(c.read(tachesProvider), isA<AsyncData<List<Task>>>());
      expect(c.read(tachesProvider).requireValue, avant);
    });

    test('Erreur au chargement, puis rechargement réussi', () async {
      repo = FakeTaskRepository(latence: Duration.zero)..enPanne = true;
      final c = ProviderContainer(
        overrides: [taskRepositoryProvider.overrideWithValue(repo)],
      );
      addTearDown(c.dispose);

      await expectLater(
        c.read(tachesProvider.future),
        throwsA(isA<ApiException>()),
      );
      expect(c.read(tachesProvider).hasError, isTrue);

      repo.enPanne = false;
      c.invalidate(tachesProvider);
      await c.read(tachesProvider.future);
      expect(c.read(tachesProvider).requireValue, isNotEmpty);
    });
  });
}
