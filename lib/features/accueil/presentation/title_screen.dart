import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:campusflow/core/theme.dart';
import 'package:campusflow/core/widgets/ecran_marque.dart';
import 'package:campusflow/features/auth/application/auth_provider.dart';

/// Écran de titre, sur le modèle de la maquette « Connexion » :
/// bandeau bleu avec le logo, feuille blanche avec l'action principale.
///
/// « Commencer » ouvre les échéances ; sans session, le routeur redirige
/// d'abord vers l'écran de connexion.
class TitleScreen extends ConsumerWidget {
  const TitleScreen({super.key, required this.onStart});

  final VoidCallback onStart;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final utilisateur = ref.watch(authProvider).value;

    return EcranMarque(
      feuille: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            utilisateur == null ? 'Bienvenue' : 'Bonjour ${utilisateur.prenom}',
            style: theme.textTheme.headlineSmall,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Voici ce qui t’attend cette semaine, trié par urgence.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          FilledButton(onPressed: onStart, child: const Text('Commencer')),
        ],
      ),
    );
  }
}
