import 'package:flutter/material.dart';

/// Design system v1 de CampusFlow (séance 2), traduit en Flutter.
///
/// Tous les écrans lisent ces valeurs via `Theme.of(context)` :
/// aucune couleur ni taille de texte n'est écrite en dur dans les widgets.
abstract final class AppColors {
  /// Couleur d'accent unique de CampusFlow (« un seul accent »).
  static const seed = Color(0xFFEC3013);
}

/// Espacements sur une grille de 4 dp.
abstract final class AppSpacing {
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 16.0;
  static const lg = 24.0;
  static const xl = 32.0;
}

/// Arrondis des composants.
abstract final class AppRadius {
  static const card = 12.0;
  static const field = 8.0;
}

/// Tailles de fenêtre visées (Material 3).
abstract final class AppBreakpoints {
  /// À partir de 840 dp : liste et détail côte à côte.
  static const expanded = 840.0;
}

abstract final class AppTheme {
  static ThemeData light() => _build(Brightness.light);

  static ThemeData dark() => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.seed,
      brightness: brightness,
    );
    final textTheme = _textTheme(
      ThemeData(brightness: brightness).textTheme,
    ).apply(
      bodyColor: colorScheme.onSurface,
      displayColor: colorScheme.onSurface,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      textTheme: textTheme,
      scaffoldBackgroundColor: colorScheme.surface,
      appBarTheme: AppBarTheme(
        centerTitle: false,
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        titleTextStyle: textTheme.titleLarge,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: colorScheme.surfaceContainerLow,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.card),
          side: BorderSide(color: colorScheme.outlineVariant),
        ),
      ),
      listTileTheme: const ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
        minVerticalPadding: AppSpacing.sm,
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.field),
        ),
        filled: true,
        fillColor: colorScheme.surfaceContainerLowest,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          // Cible tactile d'au moins 48 dp (accessibilité).
          minimumSize: const Size(64, 48),
          textStyle: textTheme.labelLarge,
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
      ),
      navigationBarTheme: NavigationBarThemeData(
        indicatorColor: colorScheme.primaryContainer,
      ),
      snackBarTheme: const SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Échelle typographique Material (Roboto par défaut),
  /// avec des titres plus affirmés pour la hiérarchie.
  static TextTheme _textTheme(TextTheme base) {
    return base.copyWith(
      displaySmall: base.displaySmall?.copyWith(
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
      ),
      headlineSmall: base.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
      titleLarge: base.titleLarge?.copyWith(fontWeight: FontWeight.w600),
      titleMedium: base.titleMedium?.copyWith(fontWeight: FontWeight.w600),
      labelLarge: base.labelLarge?.copyWith(fontWeight: FontWeight.w600),
    );
  }
}
