import 'package:campusflow_models/campusflow_models.dart';
import 'package:test/test.dart';

// Les trois tests demandés par l'atelier : copyWith, fromJson, erreur attendue.
void main() {
  test('copyWith modifie un seul champ et garde l\'original intact', () {
    final task = Task(
      id: 't1',
      title: 'Rendu TP Dart',
      courseId: 'c1',
      dueDate: DateTime(2026, 10, 27, 23, 59),
    );

    final done = task.copyWith(isDone: true);

    expect(done.isDone, isTrue);
    expect(done, task.copyWith(isDone: true));
    expect(done.title, task.title);
    expect(done.dueDate, task.dueDate);
    expect(task.isDone, isFalse); // l'objet d'origine n'a pas changé
  });

  test('fromJson construit une tâche à partir d\'une Map', () {
    final task = Task.fromJson({
      'id': 't2',
      'title': 'Projet Flutter',
      'courseId': 'c1',
      'dueDate': '2026-10-30T17:00:00',
      'description': 'Application CampusFlow complète',
    });

    expect(task.id, 't2');
    expect(task.title, 'Projet Flutter');
    expect(task.dueDate, DateTime(2026, 10, 30, 17));
    expect(task.description, 'Application CampusFlow complète');
    expect(task.isDone, isFalse); // valeur par défaut
  });

  test('fromJson lève une FormatException si un champ manque', () {
    expect(
      () => Task.fromJson({'id': 't3', 'courseId': 'c1'}),
      throwsA(
        isA<FormatException>().having(
          (e) => e.message,
          'message',
          contains('title'),
        ),
      ),
    );
  });
}
