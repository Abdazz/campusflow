import 'package:campusflow_models/campusflow_models.dart';
import 'package:test/test.dart';

// Tests complémentaires : Course, User, toJson et cas d'erreur.
void main() {
  group('copyWith', () {
    test('Course : change le nom, garde le reste', () {
      const course = Course(id: 'c1', name: 'Mobile', teacher: 'M. Compaoré');
      final renamed = course.copyWith(name: 'Programmation mobile');

      expect(renamed.name, 'Programmation mobile');
      expect(renamed.id, course.id);
      expect(renamed.teacher, course.teacher);
    });

    test('User : sans argument, la copie est égale à l\'original', () {
      const user = User(id: 'u1', name: 'Amina', email: 'amina@campus.bf');
      expect(user.copyWith(), user);
    });
  });

  group('fromJson / toJson', () {
    test('Course.fromJson lit les trois champs', () {
      final course = Course.fromJson({
        'id': 'c3',
        'name': 'UX design',
        'teacher': 'M. Sawadogo',
      });
      expect(
        course,
        const Course(id: 'c3', name: 'UX design', teacher: 'M. Sawadogo'),
      );
    });

    test('User.fromJson lit les trois champs', () {
      final user = User.fromJson({
        'id': 'u1',
        'name': 'Amina',
        'email': 'amina@campus.bf',
      });
      expect(user.email, 'amina@campus.bf');
    });

    test('Task : toJson puis fromJson redonne le même objet', () {
      final task = Task(
        id: 't1',
        title: 'Rendu TP Dart',
        courseId: 'c1',
        dueDate: DateTime(2026, 10, 27, 23, 59),
        description: 'Modèles en Dart pur',
        isDone: true,
      );
      expect(Task.fromJson(task.toJson()), task);
    });
  });

  group('erreurs attendues', () {
    test('Task : mauvais type pour isDone', () {
      expect(
        () => Task.fromJson({
          'id': 't1',
          'title': 'TP',
          'courseId': 'c1',
          'dueDate': '2026-10-27T23:59:00',
          'isDone': 'oui',
        }),
        throwsFormatException,
      );
    });

    test('Task : date illisible', () {
      expect(
        () => Task.fromJson({
          'id': 't1',
          'title': 'TP',
          'courseId': 'c1',
          'dueDate': 'demain',
        }),
        throwsFormatException,
      );
    });

    test('Task : titre vide', () {
      expect(
        () => Task.fromJson({
          'id': 't1',
          'title': '  ',
          'courseId': 'c1',
          'dueDate': '2026-10-27T23:59:00',
        }),
        throwsFormatException,
      );
    });

    test('Course : champ teacher manquant', () {
      expect(
        () => Course.fromJson({'id': 'c1', 'name': 'Mobile'}),
        throwsFormatException,
      );
    });

    test('User : email sans @', () {
      expect(
        () => User.fromJson({'id': 'u1', 'name': 'Amina', 'email': 'amina'}),
        throwsFormatException,
      );
    });
  });

  group('isOverdue', () {
    final task = Task(
      id: 't1',
      title: 'Rendu TP Dart',
      courseId: 'c1',
      dueDate: DateTime(2026, 10, 27, 23, 59),
    );

    test('en retard après l\'échéance si non faite', () {
      expect(task.isOverdue(DateTime(2026, 10, 28)), isTrue);
    });

    test('pas en retard avant l\'échéance', () {
      expect(task.isOverdue(DateTime(2026, 10, 27)), isFalse);
    });

    test('pas en retard si la tâche est faite', () {
      final done = task.copyWith(isDone: true);
      expect(done.isOverdue(DateTime(2026, 10, 28)), isFalse);
    });
  });
}
