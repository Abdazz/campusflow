import 'package:campusflow/features/taches/domain/task.dart';

/// Tâches de démonstration (mêmes données que `server/db.json`), utilisées
/// par `FakeTaskRepository` : l'application tourne et se teste sans réseau.
///
/// Les dates sont calculées à partir d'aujourd'hui pour que la vue
/// « Cette semaine » reste réaliste quel que soit le jour du lancement.
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
