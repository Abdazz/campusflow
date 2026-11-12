import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:campusflow/features/auth/application/auth_provider.dart';

/// Page d'un onglet : grand en-tête (titre, sous-titre, avatar) et contenu.
class TabScaffold extends StatelessWidget {
  const TabScaffold({
    super.key,
    required this.title,
    required this.subtitle,
    required this.body,
    this.showAvatar = true,
  });

  final String title;
  final String subtitle;
  final Widget body;

  /// L'avatar mène au profil ; inutile sur l'onglet Profil lui-même.
  final bool showAvatar;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: HeaderBar(
        title: title,
        subtitle: subtitle,
        onAvatarTap: showAvatar ? () => context.go('/profil') : null,
      ),
      body: body,
    );
  }
}

/// En-tête des onglets : grand titre, sous-titre et avatar de l'étudiant
/// connecté.
class HeaderBar extends ConsumerWidget implements PreferredSizeWidget {
  const HeaderBar({
    super.key,
    required this.title,
    required this.subtitle,
    required this.onAvatarTap,
  });

  final String title;
  final String subtitle;
  final VoidCallback? onAvatarTap;

  @override
  Size get preferredSize => const Size.fromHeight(88);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final utilisateur = ref.watch(authProvider).value;
    return AppBar(
      toolbarHeight: 88,
      titleSpacing: 20,
      automaticallyImplyLeading: false,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(title, style: theme.textTheme.headlineMedium),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w400,
              color: colors.onSurfaceVariant,
            ),
          ),
        ],
      ),
      actions: [
        if (onAvatarTap != null && utilisateur != null)
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Tooltip(
              message: 'Profil de ${utilisateur.nom}',
              child: Material(
                color: colors.primaryContainer,
                shape: const CircleBorder(),
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: onAvatarTap,
                  child: SizedBox(
                    width: 48,
                    height: 48,
                    child: Center(
                      child: Text(
                        utilisateur.initiales,
                        style: theme.textTheme.labelLarge?.copyWith(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: colors.onPrimaryContainer,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
