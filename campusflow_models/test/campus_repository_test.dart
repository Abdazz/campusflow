import 'package:campusflow_models/campusflow_models.dart';
import 'package:test/test.dart';

// Tests du dépôt simulé : chargement asynchrone avec Future.delayed.
void main() {
  const repository = CampusRepository(latency: Duration(milliseconds: 10));

  test('fetchTasks renvoie les tâches après la latence simulée', () async {
    final watch = Stopwatch()..start();
    final tasks = await repository.fetchTasks();

    expect(tasks, hasLength(3));
    expect(tasks.first.title, 'Rendu TP Dart');
    expect(watch.elapsed, greaterThanOrEqualTo(repository.latency));
  });

  test('fetchCourses et fetchCurrentUser décodent le JSON', () async {
    final courses = await repository.fetchCourses();
    final user = await repository.fetchCurrentUser();

    expect(courses.map((c) => c.id), ['c1', 'c2', 'c3']);
    expect(user.name, 'Amina');
  });

  test('fetchTasksForCourse filtre par cours', () async {
    final tasks = await repository.fetchTasksForCourse('c1');
    expect(tasks.map((t) => t.id), ['t1', 't2']);
  });

  test('fetchTaskById lève TaskNotFoundException si l\'id est inconnu', () {
    expect(
      repository.fetchTaskById('inconnu'),
      throwsA(isA<TaskNotFoundException>()),
    );
  });

  test('une réponse JSON invalide fait échouer le Future', () {
    const broken = CampusRepository(
      latency: Duration.zero,
      tasksJson: '[{"id": "t1"}]',
    );
    expect(broken.fetchTasks(), throwsFormatException);
  });
}
