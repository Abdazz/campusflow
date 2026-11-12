import 'package:campusflow/core/api_exception.dart';
import 'package:campusflow/features/taches/data/sample_tasks.dart';
import 'package:campusflow/features/taches/domain/task.dart';
import 'package:campusflow/features/taches/domain/task_repository.dart';

/// Implémentation en mémoire du [TaskRepository] : aucun réseau.
///
/// Elle remplace l'API dans les tests (override de
/// `taskRepositoryProvider`) et permet une démo hors ligne :
/// `flutter run --dart-define=FAKE_API=true`.
class FakeTaskRepository implements TaskRepository {
  FakeTaskRepository({
    List<Task>? initiales,
    this.latence = const Duration(milliseconds: 400),
  }) : _taches = [...(initiales ?? sampleTasks())];

  /// Délai simulé de chaque appel ; `Duration.zero` dans les tests.
  final Duration latence;

  /// Simule une panne réseau pour tester l'état d'erreur.
  bool enPanne = false;

  List<Task> _taches;
  int _compteur = 0;

  /// Nombre d'appels reçus, pour vérifier les rechargements en test.
  int appels = 0;

  Future<void> _reseau() async {
    appels++;
    if (latence > Duration.zero) await Future<void>.delayed(latence);
    if (enPanne) {
      throw const ApiException(
        'Impossible de joindre le serveur. Vérifie ta connexion.',
      );
    }
  }

  Task _trouver(String id) => _taches.firstWhere(
    (t) => t.id == id,
    orElse: () => throw const ApiException(
      'Cette ressource n’existe pas ou plus.',
      statusCode: 404,
    ),
  );

  @override
  Future<List<Task>> lister() async {
    await _reseau();
    return List.unmodifiable(_taches);
  }

  @override
  Future<Task> ajouter(Task tache) async {
    await _reseau();
    final creee = tache.copyWith(id: 'f${++_compteur}');
    _taches = [..._taches, creee];
    return creee;
  }

  @override
  Future<Task> modifier(Task tache) async {
    await _reseau();
    _trouver(tache.id);
    _taches = [for (final t in _taches) t.id == tache.id ? tache : t];
    return tache;
  }

  @override
  Future<Task> cocher(String id, {required bool terminee}) async {
    await _reseau();
    final cochee = _trouver(id).copyWith(isDone: terminee);
    _taches = [for (final t in _taches) t.id == id ? cochee : t];
    return cochee;
  }

  @override
  Future<void> supprimer(String id) async {
    await _reseau();
    _trouver(id);
    _taches = [
      for (final t in _taches)
        if (t.id != id) t,
    ];
  }
}
