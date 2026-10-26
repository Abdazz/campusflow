import 'package:campusflow_models/campusflow_models.dart';

Future<void> main() async {
  const repository = CampusRepository();

  print('Chargement des données…');
  final user = await repository.fetchCurrentUser();
  final courses = await repository.fetchCourses();
  final tasks = await repository.fetchTasks();

  print('Bonjour ${user.name} (${user.email})');
  print('\n${courses.length} cours :');
  for (final course in courses) {
    print('  - ${course.name} · ${course.teacher}');
  }

  final now = DateTime(2026, 10, 28);
  print('\nÉchéances au ${now.toIso8601String().substring(0, 10)} :');
  for (final task in tasks) {
    final status = task.isDone
        ? 'fait'
        : task.isOverdue(now)
        ? 'EN RETARD'
        : 'à faire';
    print('  - ${task.title} [$status]');
  }

  // Marquer comme fait : on remplace l'objet par une copie.
  final updated = tasks.first.copyWith(isDone: true);
  print('\nAprès copyWith : $updated');
}
