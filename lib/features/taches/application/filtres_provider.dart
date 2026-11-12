import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:campusflow/features/taches/application/taches_provider.dart';
import 'package:campusflow/features/taches/domain/filtre_taches.dart';
import 'package:campusflow/features/taches/domain/task.dart';

// Les écrans importent ce fichier pour le filtre et son énumération.
export 'package:campusflow/features/taches/domain/filtre_taches.dart';

/// Le filtre actif. C'est un état d'application : il est conservé quand
/// on change d'onglet puis qu'on revient aux échéances.
class FiltreNotifier extends Notifier<FiltreTaches> {
  @override
  FiltreTaches build() => FiltreTaches.aFaire;

  void choisir(FiltreTaches filtre) => state = filtre;
}

final filtreProvider = NotifierProvider<FiltreNotifier, FiltreTaches>(
  FiltreNotifier.new,
);

/// Fournisseur dérivé : les tâches qui passent le filtre actif, triées.
///
/// Il se recalcule tout seul quand la liste ou le filtre change ; aucun
/// écran ne recopie la logique de filtrage.
final tachesFiltreesProvider = Provider<List<Task>>((ref) {
  final filtre = ref.watch(filtreProvider);
  final now = ref.watch(horlogeProvider)();
  final taches = ref.watch(tachesProvider).value ?? const <Task>[];
  return taches.where((t) => filtre.garde(t, now)).toList()
    // Les terminées : la plus récente d'abord ; sinon la plus proche.
    ..sort(
      (a, b) => filtre == FiltreTaches.faites
          ? b.dueDate.compareTo(a.dueDate)
          : a.dueDate.compareTo(b.dueDate),
    );
});

/// Nombre de tâches par filtre, pour les libellés « À faire · 3 ».
final compteursProvider = Provider<Map<FiltreTaches, int>>((ref) {
  final taches = ref.watch(tachesProvider).value ?? const <Task>[];
  final now = ref.watch(horlogeProvider)();
  return {
    for (final filtre in FiltreTaches.values)
      filtre: taches.where((t) => filtre.garde(t, now)).length,
  };
});
