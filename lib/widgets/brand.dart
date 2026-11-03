import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Symbole « C-coche » (asset déclaré dans pubspec.yaml).
class CampusLogo extends StatelessWidget {
  const CampusLogo({super.key, this.size = 96, this.onPrimary = false});

  final double size;

  /// Sur fond bleu : variante « icône d'application », plus claire.
  final bool onPrimary;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      onPrimary ? 'assets/images/logo_app.png' : 'assets/images/logo.png',
      width: size,
      height: size,
      semanticLabel: 'Logo CampusFlow',
    );
  }
}

/// Logotype « CampusFlow » : Figtree ExtraBold, interlettrage −3,5 %.
class Wordmark extends StatelessWidget {
  const Wordmark({super.key, this.fontSize = 32, this.onPrimary = false});

  final double fontSize;
  final bool onPrimary;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final base = TextStyle(
      fontFamily: AppTheme.fontFamily,
      fontSize: fontSize,
      height: 1,
      fontWeight: FontWeight.w800,
      letterSpacing: -0.035 * fontSize,
    );
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: 'Campus',
            style: base.copyWith(
              color: onPrimary ? colors.onPrimary : colors.onSurface,
            ),
          ),
          TextSpan(
            text: 'Flow',
            style: base.copyWith(
              color: onPrimary ? context.campusColors.amber : colors.primary,
            ),
          ),
        ],
      ),
      semanticsLabel: 'CampusFlow',
    );
  }
}

/// Pastille arrondie (badges d'heure, d'état).
class Pill extends StatelessWidget {
  const Pill({
    super.key,
    required this.label,
    required this.background,
    required this.foreground,
  });

  final String label;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: ShapeDecoration(
        color: background,
        shape: const StadiumBorder(),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelSmall
              ?.copyWith(color: foreground),
        ),
      ),
    );
  }
}

/// En-tête de section en petites capitales (« AUJOURD'HUI », « CONSIGNE »).
class SectionLabel extends StatelessWidget {
  const SectionLabel(this.text, {super.key, this.color});

  final String text;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Text(
      text.toUpperCase(),
      style: theme.textTheme.labelSmall?.copyWith(
        letterSpacing: 0.72,
        color: color ?? theme.colorScheme.onSurfaceVariant,
      ),
    );
  }
}
