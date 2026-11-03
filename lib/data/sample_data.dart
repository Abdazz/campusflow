import '../models/course.dart';
import '../models/task.dart';

/// Données statiques en attendant l'API (séance 7).
///
/// Les dates sont calculées à partir d'aujourd'hui pour que la liste
/// « Cette semaine » reste réaliste quel que soit le jour du lancement.
const sampleCourses = [
  Course(id: 'c1', name: 'Programmation mobile', teacher: 'M. Compaoré'),
  Course(id: 'c2', name: 'Apprentissage automatique', teacher: 'Mme Ouédraogo'),
  Course(id: 'c3', name: 'UX design', teacher: 'M. Sawadogo'),
];

List<Task> sampleTasks([DateTime? now]) {
  final n = now ?? DateTime.now();
  DateTime at(int days, int hour, [int minute = 0]) =>
      DateTime(n.year, n.month, n.day + days, hour, minute);

  return [
    Task(
      id: 't1',
      title: 'Rendu TP Dart',
      courseId: 'c1',
      dueDate: at(1, 23, 59),
      description: 'Modèles Task, Course et User avec leurs tests.',
    ),
    Task(
      id: 't2',
      title: 'Projet Flutter',
      courseId: 'c1',
      dueDate: at(3, 17),
      description:
          'Application CampusFlow complète : trois écrans, thème, '
          'version tablette.',
    ),
    Task(id: 't3', title: 'Examen UX', courseId: 'c3', dueDate: at(6, 8)),
    Task(
      id: 't4',
      title: 'Mini-projet de classification',
      courseId: 'c2',
      dueDate: at(9, 23, 59),
      description:
          'Entraîner et comparer deux modèles sur le jeu de données '
          'fourni.',
    ),
    Task(
      id: 't5',
      title: "Lecture d'article",
      courseId: 'c2',
      dueDate: at(-1, 10),
      isDone: true,
    ),
  ];
}

Course courseById(String id) => sampleCourses.firstWhere(
  (course) => course.id == id,
  orElse: () => Course(id: id, name: 'Cours inconnu', teacher: '—'),
);
