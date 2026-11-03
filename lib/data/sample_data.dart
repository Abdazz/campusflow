import '../models/course.dart';
import '../models/task.dart';

/// Données statiques en attendant l'API (séance 7), reprises des maquettes
/// du dossier de conception (persona : Ibrahim, M1 Intelligence Artificielle).
///
/// Les dates sont calculées à partir d'aujourd'hui pour que la vue
/// « Cette semaine » reste réaliste quel que soit le jour du lancement.
const currentUser = (
  name: 'Ibrahim Kaboré',
  initials: 'IK',
  email: 'ibrahim.kabore@universite.bf',
  program: 'Master 1 Intelligence Artificielle',
);

const sampleCourses = [
  Course(id: 'dm', name: 'Développement mobile', teacher: 'M. Compaoré'),
  Course(id: 'fd', name: 'Fouille de données', teacher: 'Mme Ouédraogo'),
  Course(id: 'aa', name: 'Apprentissage automatique', teacher: 'M. Sawadogo'),
  Course(id: 'st', name: 'Statistiques', teacher: 'Mme Traoré'),
  Course(id: 'at', name: 'Anglais technique', teacher: 'Mme Zongo'),
  Course(id: 'gp', name: 'Gestion de projet', teacher: 'M. Ilboudo'),
];

List<Task> sampleTasks([DateTime? now]) {
  final n = now ?? DateTime.now();
  DateTime at(int days, int hour, [int minute = 0]) =>
      DateTime(n.year, n.month, n.day + days, hour, minute);

  return [
    Task(
      id: 't1',
      title: 'Rendu TP Dart',
      courseId: 'dm',
      dueDate: at(0, 23, 59),
      description:
          'Modèles Task, Course et User avec leurs tests. Déposer le '
          'fichier .zip sur la plateforme.',
      reminder: Reminder.sameDay,
    ),
    Task(
      id: 't2',
      title: 'Dossier de conception v1',
      courseId: 'dm',
      dueDate: at(1, 18),
      description:
          'Persona, parcours, wireframes et design system v1 de '
          'CampusFlow.',
    ),
    Task(
      id: 't3',
      title: 'Projet Flutter — maquette',
      courseId: 'dm',
      dueDate: at(2, 17),
      description:
          'Maquette haute fidélité des écrans principaux de CampusFlow, à '
          'partir du design system v1. Déposer le lien sur la plateforme.',
    ),
    Task(
      id: 't4',
      title: 'Exposé en binôme',
      courseId: 'fd',
      dueDate: at(2, 8),
    ),
    Task(
      id: 't5',
      title: 'Fiche persona',
      courseId: 'dm',
      dueDate: at(-1, 18),
      isDone: true,
    ),
    Task(
      id: 't6',
      title: 'Lecture : arbres de décision',
      courseId: 'aa',
      dueDate: at(-2, 10),
      isDone: true,
    ),
  ];
}

Course courseById(String id) => sampleCourses.firstWhere(
  (course) => course.id == id,
  orElse: () => Course(id: id, name: 'Cours inconnu', teacher: ''),
);

/// « Développement mobile » → « DM », « Fouille de données » → « FD »,
/// « Statistiques » → « ST ».
String courseInitials(Course course) {
  const minor = {'de', 'des', 'du', 'la', 'le', 'les', 'et', 'en'};
  final words = course.name
      .split(RegExp(r'\s+'))
      .where((w) => w.isNotEmpty && !minor.contains(w.toLowerCase()))
      .toList();
  if (words.length == 1) {
    // « Statistiques » → « ST ».
    return words.first.substring(0, 2).toUpperCase();
  }
  return words.take(2).map((w) => w[0].toUpperCase()).join();
}
