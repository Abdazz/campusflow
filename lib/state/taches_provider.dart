import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/sample_data.dart';
import '../models/task.dart';

/// L'heure courante, remplaçable dans les tests.
final horlogeProvider = Provider<DateTime Function()>((ref) => DateTime.now);

/// La liste des tâches, partagée par la liste, le détail et le formulaire.
///
/// L'état est immuable : chaque action assigne une nouvelle liste à
/// `state`, jamais de `state.add(...)` (l'écran ne se mettrait pas à jour).
class TachesNotifier extends Notifier<List<Task>> {
  TachesNotifier([this._initiales]);

  /// Pour les tests : remplace les données d'exemple.
  final List<Task>? _initiales;

  @override
  List<Task> build() => _initiales ?? sampleTasks(ref.watch(horlogeProvider)());

  void ajouter(Task tache) => state = [...state, tache];

  void modifier(Task tache) =>
      state = [for (final t in state) t.id == tache.id ? tache : t];

  /// Coche ou décoche la tâche [id].
  void basculer(String id) => state = [
    for (final t in state) t.id == id ? t.copyWith(isDone: !t.isDone) : t,
  ];
}

final tachesProvider = NotifierProvider<TachesNotifier, List<Task>>(
  TachesNotifier.new,
);

/// Une tâche lue par son identifiant (paramètre `:id` de la route),
/// ou `null` si elle n'existe pas.
final tacheProvider = Provider.family<Task?, String>(
  (ref, id) => ref.watch(tachesProvider).where((t) => t.id == id).firstOrNull,
);
