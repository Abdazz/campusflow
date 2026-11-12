import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:campusflow/core/api_exception.dart';
import 'package:campusflow/features/taches/data/task_repository_provider.dart';
import 'package:campusflow/features/taches/domain/task.dart';
import 'package:campusflow/features/taches/domain/task_repository.dart';

/// L'heure courante, remplaçable dans les tests.
final horlogeProvider = Provider<DateTime Function()>((ref) => DateTime.now);

/// La liste des tâches du serveur, partagée par la liste, le détail, le
/// formulaire, les cours et le profil.
///
/// L'état est un `AsyncValue<List<Task>>` : chargement, erreur ou donnée.
/// Le Notifier ne connaît que le [TaskRepository], jamais Dio.
class TachesNotifier extends AsyncNotifier<List<Task>> {
  TaskRepository get _repository => ref.read(taskRepositoryProvider);

  /// Premier chargement : `GET /taches`.
  @override
  Future<List<Task>> build() => ref.watch(taskRepositoryProvider).lister();

  /// `POST /taches` ; renvoie la tâche avec l'identifiant du serveur.
  Future<Task> ajouter(Task tache) => _action(
    () => _repository.ajouter(tache),
    (taches, creee) => [...taches, creee],
  );

  /// `PATCH /taches/:id` avec tous les champs.
  Future<Task> modifier(Task tache) =>
      _action(() => _repository.modifier(tache), _remplacer);

  /// Coche ou décoche : `PATCH /taches/:id` avec `{"terminee": …}`.
  Future<Task> basculer(String id) {
    final tache = state.requireValue.firstWhere((t) => t.id == id);
    return _action(
      () => _repository.cocher(id, terminee: !tache.isDone),
      _remplacer,
    );
  }

  /// `DELETE /taches/:id`
  Future<void> supprimer(String id) => _action(
    () => _repository.supprimer(id),
    (taches, _) => [
      for (final t in taches)
        if (t.id != id) t,
    ],
  );

  /// Le flux du cours : l'écran agit (`ref.read`), le Notifier passe en
  /// `AsyncLoading`, le Repository appelle le serveur, puis `AsyncData`
  /// reconstruit les widgets.
  ///
  /// Pendant le chargement, Riverpod garde la liste précédente : l'écran
  /// reste affiché avec une barre de progression. En cas d'échec, la liste
  /// redevient celle d'avant et l'erreur remonte à l'écran, qui l'affiche.
  /// L'état reste immuable : `appliquer` renvoie toujours une nouvelle liste.
  Future<R> _action<R>(
    Future<R> Function() appel,
    List<Task> Function(List<Task> taches, R resultat) appliquer,
  ) async {
    state = const AsyncLoading<List<Task>>();
    try {
      final resultat = await appel();
      if (ref.mounted) {
        state = AsyncData(appliquer(state.value ?? const [], resultat));
      }
      return resultat;
    } catch (_) {
      if (ref.mounted) state = AsyncData(state.value ?? const []);
      rethrow;
    }
  }

  static List<Task> _remplacer(List<Task> taches, Task tache) => [
    for (final t in taches) t.id == tache.id ? tache : t,
  ];
}

final tachesProvider = AsyncNotifierProvider<TachesNotifier, List<Task>>(
  TachesNotifier.new,
  // Riverpod 3 relance seul un fournisseur en erreur. Pour une erreur
  // réseau, c'est l'utilisateur qui décide (bouton « Réessayer ») ; un 401
  // ne doit pas être répété en boucle.
  retry: (essai, erreur) =>
      erreur is ApiException ? null : _relanceParDefaut(essai),
);

/// Délai de relance pour les autres erreurs : 200 ms, 400 ms… 3 essais.
Duration? _relanceParDefaut(int essai) =>
    essai >= 3 ? null : Duration(milliseconds: 200 * (1 << essai));

/// Une tâche lue par son identifiant (paramètre `:id` de la route),
/// ou `null` si elle n'existe pas ou si la liste n'est pas encore chargée.
final tacheProvider = Provider.family<Task?, String>(
  (ref, id) =>
      ref.watch(tachesProvider).value?.where((t) => t.id == id).firstOrNull,
);
