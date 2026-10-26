import 'dart:convert';

import '../models/course.dart';
import '../models/task.dart';
import '../models/user.dart';

/// Données qu'une future API renverrait, sous forme de texte JSON.
const _coursesJson = '''
[
  {"id": "c1", "name": "Programmation mobile", "teacher": "M. Compaoré"},
  {"id": "c2", "name": "Apprentissage automatique", "teacher": "Mme Ouédraogo"},
  {"id": "c3", "name": "UX design", "teacher": "M. Sawadogo"}
]
''';

const _tasksJson = '''
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

const _userJson = '''
{"id": "u1", "name": "Amina", "email": "amina@campus.bf"}
''';

/// Dépôt simulé : imite un appel réseau avec [Future.delayed]
/// avant de décoder le JSON en objets du modèle.
class CampusRepository {
  /// Latence simulée du « serveur ».
  final Duration latency;

  const CampusRepository({this.latency = const Duration(milliseconds: 500)});

  Future<List<Course>> fetchCourses() =>
      _load(_coursesJson, (json) => _decodeList(json, Course.fromJson));

  Future<List<Task>> fetchTasks() =>
      _load(_tasksJson, (json) => _decodeList(json, Task.fromJson));

  Future<User> fetchCurrentUser() =>
      _load(_userJson, (json) => User.fromJson(json as Map<String, dynamic>));

  Future<T> _load<T>(String body, T Function(dynamic json) parse) {
    return Future.delayed(latency, () => parse(jsonDecode(body)));
  }

  static List<T> _decodeList<T>(
    dynamic json,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    return (json as List).cast<Map<String, dynamic>>().map(fromJson).toList();
  }
}
