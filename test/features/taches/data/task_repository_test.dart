import 'package:campusflow/core/api_exception.dart';
import 'package:campusflow/features/taches/data/api_task_repository.dart';
import 'package:campusflow/features/taches/data/fake_task_repository.dart';
import 'package:campusflow/features/taches/domain/task.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/fake_http.dart';

Map<String, dynamic> _json(String id, {bool terminee = false}) => {
  'id': id,
  'titre': 'Projet Flutter',
  'coursId': 'dm',
  'echeance': '2026-11-20T17:00:00',
  'terminee': terminee,
  'description': null,
  'rappel': 'dayBefore',
};

final _tache = Task(
  id: 't1',
  title: 'Projet Flutter',
  courseId: 'dm',
  dueDate: DateTime(2026, 11, 20, 17),
);

void main() {
  group('Task JSON (contrat du serveur)', () {
    test('fromJson lit les clés françaises et un id entier', () {
      final t = Task.fromJson({..._json('x'), 'id': 42, 'terminee': true});
      expect(t.id, '42');
      expect(t.title, 'Projet Flutter');
      expect(t.dueDate, DateTime(2026, 11, 20, 17));
      expect(t.isDone, isTrue);
    });

    test('toJson puis fromJson redonne la même tâche', () {
      expect(Task.fromJson(_tache.toJson()), _tache);
      expect(_tache.toJson()['echeance'], '2026-11-20T17:00:00.000');
    });
  });

  group('ApiTaskRepository', () {
    test('lister : GET /taches, JSON converti en Task', () async {
      final http = FakeHttpAdapter(
        (_) => (code: 200, json: [_json('t1'), _json('t2', terminee: true)]),
      );
      final taches = await ApiTaskRepository(dioDeTest(http)).lister();

      expect(http.requetes.single.methode, 'GET');
      expect(http.requetes.single.chemin, '/taches');
      expect(taches.map((t) => t.id), ['t1', 't2']);
      expect(taches.last.isDone, isTrue);
    });

    test('ajouter : POST sans id, le serveur attribue le sien', () async {
      final http = FakeHttpAdapter((_) => (code: 201, json: _json('srv7')));
      final creee = await ApiTaskRepository(dioDeTest(http)).ajouter(_tache);

      final requete = http.requetes.single;
      expect(requete.methode, 'POST');
      expect(requete.chemin, '/taches');
      expect((requete.corps! as Map).containsKey('id'), isFalse);
      expect(creee.id, 'srv7');
    });

    test('cocher : PATCH /taches/:id avec {"terminee": true}', () async {
      final http = FakeHttpAdapter(
        (_) => (code: 200, json: _json('t1', terminee: true)),
      );
      final cochee = await ApiTaskRepository(dioDeTest(http))
          .cocher('t1', terminee: true);

      expect(http.requetes.single.methode, 'PATCH');
      expect(http.requetes.single.chemin, '/taches/t1');
      expect(http.requetes.single.corps, {'terminee': true});
      expect(cochee.isDone, isTrue);
    });

    test('supprimer : DELETE /taches/:id', () async {
      final http = FakeHttpAdapter((_) => (code: 200, json: {}));
      await ApiTaskRepository(dioDeTest(http)).supprimer('t1');
      expect(http.requetes.single.methode, 'DELETE');
      expect(http.requetes.single.chemin, '/taches/t1');
    });

    test('erreurs traduites : 404, serveur coupé, JSON illisible', () async {
      final introuvable = ApiTaskRepository(
        dioDeTest(FakeHttpAdapter((_) => (code: 404, json: {}))),
      );
      await expectLater(
        introuvable.cocher('zz', terminee: true),
        throwsA(
          isA<ApiException>().having((e) => e.statusCode, 'statusCode', 404),
        ),
      );

      final coupe = FakeHttpAdapter((_) => (code: 200, json: []))
        ..horsLigne = true;
      await expectLater(
        ApiTaskRepository(dioDeTest(coupe)).lister(),
        throwsA(
          isA<ApiException>().having(
            (e) => e.message,
            'message',
            contains('Impossible de joindre le serveur'),
          ),
        ),
      );

      final illisible = FakeHttpAdapter(
        (_) => (
          code: 200,
          json: [
            {'id': 't1'},
          ],
        ),
      );
      await expectLater(
        ApiTaskRepository(dioDeTest(illisible)).lister(),
        throwsA(isA<ApiException>()),
      );
    });
  });

  group('FakeTaskRepository', () {
    test('CRUD en mémoire, sans réseau', () async {
      final repo = FakeTaskRepository(
        initiales: [_tache],
        latence: Duration.zero,
      );

      final creee = await repo.ajouter(_tache.copyWith(title: 'Exposé'));
      expect(creee.id, isNot(_tache.id));
      expect(await repo.lister(), hasLength(2));

      await repo.cocher('t1', terminee: true);
      expect((await repo.lister()).first.isDone, isTrue);

      await repo.supprimer(creee.id);
      expect((await repo.lister()).map((t) => t.id), ['t1']);
    });

    test('enPanne : chaque appel lève une ApiException', () async {
      final repo = FakeTaskRepository(latence: Duration.zero)..enPanne = true;
      await expectLater(repo.lister(), throwsA(isA<ApiException>()));
    });
  });
}
