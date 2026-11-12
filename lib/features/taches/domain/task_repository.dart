import 'package:campusflow/features/taches/domain/task.dart';

/// Le contrat d'accès aux tâches : ce que l'on peut demander, pas comment.
///
/// Deux implémentations dans `data/` :
/// - `ApiTaskRepository` parle au serveur REST avec Dio ;
/// - `FakeTaskRepository` garde les tâches en mémoire (tests, démo hors
///   ligne).
///
/// En cas d'échec, chaque méthode lève une `ApiException` (core).
abstract interface class TaskRepository {
  /// `GET /taches`
  Future<List<Task>> lister();

  /// `POST /taches` : le serveur attribue l'identifiant et renvoie la
  /// tâche créée.
  Future<Task> ajouter(Task tache);

  /// `PATCH /taches/:id` avec tous les champs modifiables.
  Future<Task> modifier(Task tache);

  /// `PATCH /taches/:id` avec `{"terminee": true}` ou `false`.
  Future<Task> cocher(String id, {required bool terminee});

  /// `DELETE /taches/:id`
  Future<void> supprimer(String id);
}
