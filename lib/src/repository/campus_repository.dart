import 'dart:convert';

import '../models/course.dart';
import '../models/task.dart';
import '../models/user.dart';

/// Réponses qu'une future API renverrait, sous forme de texte JSON.
const defaultCoursesJson = '''
[
  {"id": "c1", "name": "Programmation mobile", "teacher": "M. Compaoré"},
  {"id": "c2", "name": "Apprentissage automatique", "teacher": "Mme Ouédraogo"},
  {"id": "c3", "name": "UX design", "teacher": "M. Sawadogo"}
]
''';

const defaultTasksJson = '''
[
  {"id": "t1", "title": "Rendu TP Dart", "courseId": "c1",
   "dueDate": "2026-10-27T23:59:00", "isDone": false},
  {"id": "t2", "title": "Projet Flutter", "courseId": "c1",
   "dueDate": "2026-10-30T17:00:00",
   "description": "Application CampusFlow complète"},
  {"id": "t3", "title": "Examen UX", "courseId": "c3",
   "dueDate": "2026-11-02T08:00:00", "isDone": true}
]
''';

const defaultUserJson = '''
{"id": "u1", "name": "Amina", "email": "amina@campus.bf"}
''';

/// Levée quand une tâche demandée n'existe pas dans le dépôt.
class TaskNotFoundException implements Exception {
  final String id;

  const TaskNotFoundException(this.id);

  @override
  String toString() => 'TaskNotFoundException : aucune tâche "$id"';
}

/// Dépôt simulé : imite un appel réseau avec [Future.delayed]
/// avant de décoder le JSON en objets du modèle.
///
/// Les réponses JSON peuvent être remplacées (ex. : dans les tests, pour
/// simuler un serveur qui renvoie des données invalides).
class CampusRepository {
  /// Latence simulée du serveur.
  final Duration latency;
  final String coursesJson;
  final String tasksJson;
  final String userJson;

  const CampusRepository({
    this.latency = const Duration(milliseconds: 500),
    this.coursesJson = defaultCoursesJson,
    this.tasksJson = defaultTasksJson,
    this.userJson = defaultUserJson,
  });

  Future<List<Course>> fetchCourses() =>
      _load(coursesJson, (json) => _decodeList(json, Course.fromJson));

  Future<List<Task>> fetchTasks() =>
      _load(tasksJson, (json) => _decodeList(json, Task.fromJson));

  Future<User> fetchCurrentUser() =>
      _load(userJson, (json) => User.fromJson(json as Map<String, dynamic>));

  Future<List<Task>> fetchTasksForCourse(String courseId) async {
    final tasks = await fetchTasks();
    return tasks.where((task) => task.courseId == courseId).toList();
  }

  /// Lève [TaskNotFoundException] si l'identifiant est inconnu.
  Future<Task> fetchTaskById(String id) async {
    final tasks = await fetchTasks();
    for (final task in tasks) {
      if (task.id == id) return task;
    }
    throw TaskNotFoundException(id);
  }

  Future<T> _load<T>(String body, T Function(dynamic json) parse) {
    return Future.delayed(latency, () => parse(jsonDecode(body)));
  }

  static List<T> _decodeList<T>(
    dynamic json,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    if (json is! List) {
      throw const FormatException(
        'Réponse inattendue : une liste est attendue',
      );
    }
    return json.cast<Map<String, dynamic>>().map(fromJson).toList();
  }
}
