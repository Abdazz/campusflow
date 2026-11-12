import 'package:campusflow/features/taches/domain/task.dart';

/// Les trois filtres de l'écran Échéances.
enum FiltreTaches {
  aFaire('À faire'),
  faites('Faites'),
  enRetard('En retard');

  const FiltreTaches(this.label);

  final String label;

  /// La tâche passe-t-elle ce filtre à l'instant [now] ?
  bool garde(Task tache, DateTime now) => switch (this) {
    aFaire => !tache.isDone,
    faites => tache.isDone,
    enRetard => tache.isOverdue(now),
  };
}
