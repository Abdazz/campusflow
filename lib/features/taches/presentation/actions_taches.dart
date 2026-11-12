import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:campusflow/core/api_exception.dart';
import 'package:campusflow/features/taches/application/taches_provider.dart';
import 'package:campusflow/features/taches/domain/task.dart';

/// Lance une action sur le serveur. En cas d'échec, l'écran reste en place
/// et une SnackBar explique pourquoi. Renvoie `true` si l'action a réussi.
Future<bool> executerAction(
  BuildContext context,
  Future<void> Function() action,
) async {
  final messages = ScaffoldMessenger.of(context);
  try {
    await action();
    return true;
  } on ApiException catch (e) {
    // 401 : l'écran de connexion explique déjà « Session expirée ».
    if (!e.nonAuthentifie) {
      messages.showSnackBar(SnackBar(content: Text(e.message)));
    }
    return false;
  }
}

/// Coche ou décoche [tache] : `PATCH /taches/:id`.
Future<void> basculerTache(BuildContext context, WidgetRef ref, Task tache) =>
    executerAction(
      context,
      () => ref.read(tachesProvider.notifier).basculer(tache.id),
    );

/// Demande confirmation, puis `DELETE /taches/:id` et retour à la liste.
Future<void> supprimerTache(
  BuildContext context,
  WidgetRef ref,
  Task tache,
) async {
  final confirme = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Supprimer la tâche ?'),
      content: Text('« ${tache.title} » sera supprimée du serveur.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Annuler'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text('Supprimer'),
        ),
      ],
    ),
  );
  if (confirme != true || !context.mounted) return;

  final messages = ScaffoldMessenger.of(context);
  final router = GoRouter.of(context);
  final ok = await executerAction(
    context,
    () => ref.read(tachesProvider.notifier).supprimer(tache.id),
  );
  if (!ok) return;
  router.go('/taches');
  messages.showSnackBar(
    SnackBar(content: Text('« ${tache.title} » supprimée')),
  );
}
