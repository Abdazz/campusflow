import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../data/sample_data.dart';

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

/// En-tête des onglets : grand titre, sous-titre et avatar.
class HeaderBar extends StatelessWidget implements PreferredSizeWidget {
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
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
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
        if (onAvatarTap != null)
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Tooltip(
              message: 'Profil de ${currentUser.name}',
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
                        currentUser.initials,
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
