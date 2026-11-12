import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:campusflow/core/api_exception.dart';
import 'package:campusflow/core/theme.dart';

/// Les trois états d'une donnée venue du serveur : chargement, erreur avec
/// « Réessayer », donnée.
///
/// Quand une donnée est déjà affichée et qu'une action est en cours
/// (création, PATCH, DELETE, rechargement), elle reste visible sous une
/// fine barre de progression.
class AsyncVue<T> extends StatelessWidget {
  const AsyncVue({
    super.key,
    required this.valeur,
    required this.donnee,
    required this.onRetry,
    this.chargement = 'Chargement…',
  });

  final AsyncValue<T> valeur;
  final Widget Function(T donnee) donnee;

  /// Relance le chargement (en général `ref.invalidate(...)`).
  final VoidCallback onRetry;

  /// Texte lu par le lecteur d'écran pendant le chargement.
  final String chargement;

  @override
  Widget build(BuildContext context) {
    if (valeur.hasValue) {
      return Stack(
        children: [
          Positioned.fill(child: donnee(valeur.requireValue)),
          if (valeur.isLoading)
            const Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: LinearProgressIndicator(minHeight: 3),
            ),
        ],
      );
    }
    if (valeur.hasError) {
      return ErreurVue(message: messagePour(valeur.error!), onRetry: onRetry);
    }
    return Center(
      child: Semantics(
        label: chargement,
        child: const CircularProgressIndicator(),
      ),
    );
  }
}

/// Erreur de chargement : message et bouton « Réessayer ».
class ErreurVue extends StatelessWidget {
  const ErreurVue({super.key, required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.cloud_off_rounded,
              size: 48,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge,
            ),
            const SizedBox(height: AppSpacing.md),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Réessayer'),
            ),
          ],
        ),
      ),
    );
  }
}
