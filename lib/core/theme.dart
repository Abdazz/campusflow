import 'package:flutter/material.dart';

/// Design system v1 de CampusFlow, repris de la « Page de tokens » du
/// dossier de conception (Material 3, un seul accent).
///
/// Les écrans lisent ces valeurs via `Theme.of(context)` et
/// `context.campusColors` : aucune couleur n'est écrite en dur ailleurs.
abstract final class AppColors {
  static const primary = Color(0xFF2E3A8C); // Bleu campus, accent unique
  static const onPrimary = Color(0xFFFFFFFF);
  static const primaryContainer = Color(0xFFE3E6F7);
  static const onPrimaryContainer = Color(0xFF1A2266);

  static const urgent = Color(0xFFA84B00); // Échéance sous 24 h
  static const urgentContainer = Color(0xFFFCE9DA);
  static const urgentBorder = Color(0xFFE8C2A3);
  static const success = Color(0xFF2F6B45); // Tâche faite
  static const successContainer = Color(0xFFDDEFE3);
  static const error = Color(0xFFB3261E); // Erreurs de saisie

  static const background = Color(0xFFF7F6F2); // Fond des écrans
  static const surface = Color(0xFFFFFFFF); // Cartes, barres
  static const onSurface = Color(0xFF1B1B1F); // Texte principal
  static const onSurfaceVariant = Color(0xFF5E5E66); // Texte secondaire
  static const outline = Color(0xFFD6D6DC); // Bordures
  static const outlineVariant = Color(0xFFE4E4E8); // Bordures de carte
  static const fieldBorder = Color(0xFFC9C9D1);
  static const neutralContainer = Color(0xFFECEBE6);
  static const neutralChip = Color(0xFFF0EFEA);
  static const onNeutralChip = Color(0xFF3F3F46);

  /// Réservé au logo, toujours sur bleu ou sur encre.
  static const amber = Color(0xFFF5B82E);
  static const primaryLight = Color(0xFF4652A8); // Piste de progression
}

/// Couleurs propres à CampusFlow, absentes du ColorScheme Material.
@immutable
class CampusColors extends ThemeExtension<CampusColors> {
  const CampusColors({
    required this.urgent,
    required this.urgentContainer,
    required this.urgentBorder,
    required this.success,
    required this.successContainer,
    required this.neutralContainer,
    required this.neutralChip,
    required this.onNeutralChip,
    required this.fieldBorder,
    required this.amber,
    required this.primaryLight,
  });

  static const light = CampusColors(
    urgent: AppColors.urgent,
    urgentContainer: AppColors.urgentContainer,
    urgentBorder: AppColors.urgentBorder,
    success: AppColors.success,
    successContainer: AppColors.successContainer,
    neutralContainer: AppColors.neutralContainer,
    neutralChip: AppColors.neutralChip,
    onNeutralChip: AppColors.onNeutralChip,
    fieldBorder: AppColors.fieldBorder,
    amber: AppColors.amber,
    primaryLight: AppColors.primaryLight,
  );

  final Color urgent;
  final Color urgentContainer;
  final Color urgentBorder;
  final Color success;
  final Color successContainer;
  final Color neutralContainer;
  final Color neutralChip;
  final Color onNeutralChip;
  final Color fieldBorder;
  final Color amber;
  final Color primaryLight;

  @override
  CampusColors copyWith({
    Color? urgent,
    Color? urgentContainer,
    Color? urgentBorder,
    Color? success,
    Color? successContainer,
    Color? neutralContainer,
    Color? neutralChip,
    Color? onNeutralChip,
    Color? fieldBorder,
    Color? amber,
    Color? primaryLight,
  }) {
    return CampusColors(
      urgent: urgent ?? this.urgent,
      urgentContainer: urgentContainer ?? this.urgentContainer,
      urgentBorder: urgentBorder ?? this.urgentBorder,
      success: success ?? this.success,
      successContainer: successContainer ?? this.successContainer,
      neutralContainer: neutralContainer ?? this.neutralContainer,
      neutralChip: neutralChip ?? this.neutralChip,
      onNeutralChip: onNeutralChip ?? this.onNeutralChip,
      fieldBorder: fieldBorder ?? this.fieldBorder,
      amber: amber ?? this.amber,
      primaryLight: primaryLight ?? this.primaryLight,
    );
  }

  @override
  CampusColors lerp(CampusColors? other, double t) {
    if (other == null) return this;
    Color mix(Color a, Color b) => Color.lerp(a, b, t)!;
    return CampusColors(
      urgent: mix(urgent, other.urgent),
      urgentContainer: mix(urgentContainer, other.urgentContainer),
      urgentBorder: mix(urgentBorder, other.urgentBorder),
      success: mix(success, other.success),
      successContainer: mix(successContainer, other.successContainer),
      neutralContainer: mix(neutralContainer, other.neutralContainer),
      neutralChip: mix(neutralChip, other.neutralChip),
      onNeutralChip: mix(onNeutralChip, other.onNeutralChip),
      fieldBorder: mix(fieldBorder, other.fieldBorder),
      amber: mix(amber, other.amber),
      primaryLight: mix(primaryLight, other.primaryLight),
    );
  }
}

extension CampusThemeContext on BuildContext {
  CampusColors get campusColors =>
      Theme.of(this).extension<CampusColors>() ?? CampusColors.light;
}

/// Espacements (space-1 à space-8).
abstract final class AppSpacing {
  static const xs = 4.0; // space-1
  static const sm = 8.0; // space-2
  static const md = 12.0; // space-3
  static const screen = 16.0; // space-4 · marge d'écran
  static const lg = 24.0; // space-6
  static const xl = 32.0; // space-8
}

/// Arrondis : champs 8, cartes 12, FAB 16, puces en pilule.
abstract final class AppRadius {
  static const field = 10.0;
  static const button = 14.0;
  static const card = 14.0;
  static const fab = 16.0;
}

/// Tailles de fenêtre visées.
abstract final class AppBreakpoints {
  /// À partir de 600 dp : rail de navigation à gauche.
  static const medium = 600.0;

  /// À partir de 840 dp : liste et détail côte à côte.
  static const expanded = 840.0;
}

abstract final class AppTheme {
  static const fontFamily = 'Figtree';

  static ThemeData light() {
    final colorScheme =
        ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          dynamicSchemeVariant: DynamicSchemeVariant.fidelity,
        ).copyWith(
          primary: AppColors.primary,
          onPrimary: AppColors.onPrimary,
          primaryContainer: AppColors.primaryContainer,
          onPrimaryContainer: AppColors.onPrimaryContainer,
          secondaryContainer: AppColors.primaryContainer,
          onSecondaryContainer: AppColors.onPrimaryContainer,
          error: AppColors.error,
          surface: AppColors.surface,
          onSurface: AppColors.onSurface,
          onSurfaceVariant: AppColors.onSurfaceVariant,
          outline: AppColors.outline,
          outlineVariant: AppColors.outlineVariant,
          surfaceContainerLowest: AppColors.surface,
          surfaceContainerLow: AppColors.background,
          surfaceContainer: AppColors.surface,
          surfaceContainerHigh: AppColors.surface,
          surfaceContainerHighest: AppColors.neutralContainer,
        );

    final textTheme = _textTheme();

    final fieldBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.field),
      borderSide: const BorderSide(color: AppColors.fieldBorder, width: 1.5),
    );

    return ThemeData(
      useMaterial3: true,
      fontFamily: fontFamily,
      colorScheme: colorScheme,
      textTheme: textTheme,
      scaffoldBackgroundColor: AppColors.background,
      extensions: const [CampusColors.light],
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.onSurface,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: textTheme.titleLarge,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: AppColors.surface,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.card),
          side: const BorderSide(color: AppColors.outlineVariant),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.outlineVariant,
        thickness: 1,
        space: 1,
      ),
      listTileTheme: ListTileThemeData(
        titleTextStyle: textTheme.titleSmall,
        subtitleTextStyle: textTheme.bodySmall?.copyWith(
          color: AppColors.onSurfaceVariant,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 16,
        ),
        hintStyle: textTheme.bodyLarge?.copyWith(
          color: AppColors.onSurfaceVariant,
        ),
        border: fieldBorder,
        enabledBorder: fieldBorder,
        focusedBorder: fieldBorder.copyWith(
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: fieldBorder.copyWith(
          borderSide: const BorderSide(color: AppColors.error, width: 1.5),
        ),
        focusedErrorBorder: fieldBorder.copyWith(
          borderSide: const BorderSide(color: AppColors.error, width: 2),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          // Cible tactile d'au moins 48 dp ; 56 pour l'action principale.
          minimumSize: const Size(64, 56),
          textStyle: textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.button),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          minimumSize: const Size(48, 48),
          textStyle: textTheme.labelLarge?.copyWith(
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.surface,
        selectedColor: AppColors.primaryContainer,
        checkmarkColor: AppColors.onPrimaryContainer,
        labelStyle: textTheme.labelLarge,
        side: const BorderSide(color: AppColors.fieldBorder, width: 1.5),
        shape: const StadiumBorder(),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        extendedTextStyle: textTheme.labelLarge?.copyWith(
          fontSize: 15,
          fontWeight: FontWeight.w700,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.fab),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        indicatorColor: AppColors.primaryContainer,
        height: 80,
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => textTheme.labelSmall?.copyWith(
            fontWeight: states.contains(WidgetState.selected)
                ? FontWeight.w700
                : FontWeight.w600,
            color: states.contains(WidgetState.selected)
                ? AppColors.onPrimaryContainer
                : AppColors.onSurfaceVariant,
          ),
        ),
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            color: states.contains(WidgetState.selected)
                ? AppColors.onPrimaryContainer
                : AppColors.onSurfaceVariant,
          ),
        ),
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: AppColors.surface,
        indicatorColor: AppColors.primaryContainer,
        selectedIconTheme: const IconThemeData(
          color: AppColors.onPrimaryContainer,
        ),
        unselectedIconTheme: const IconThemeData(
          color: AppColors.onSurfaceVariant,
        ),
        selectedLabelTextStyle: textTheme.labelSmall?.copyWith(
          color: AppColors.onPrimaryContainer,
        ),
        unselectedLabelTextStyle: textTheme.labelSmall?.copyWith(
          fontWeight: FontWeight.w600,
          color: AppColors.onSurfaceVariant,
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.onSurface,
        contentTextStyle: textTheme.bodyMedium?.copyWith(
          color: AppColors.onPrimary,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.field),
        ),
      ),
    );
  }

  /// Échelle typographique de la page de tokens (taille / interligne · graisse).
  static TextTheme _textTheme() {
    TextStyle style(
      double size,
      double height,
      FontWeight weight, {
      double letterSpacing = 0,
    }) => TextStyle(
      fontFamily: fontFamily,
      fontSize: size,
      height: height / size,
      fontWeight: weight,
      letterSpacing: letterSpacing,
      color: AppColors.onSurface,
    );

    return TextTheme(
      displaySmall: style(32, 36, FontWeight.w800, letterSpacing: -1.1),
      headlineMedium: style(28, 34, FontWeight.w800, letterSpacing: -0.56),
      headlineSmall: style(26, 32, FontWeight.w700, letterSpacing: -0.4),
      titleLarge: style(20, 26, FontWeight.w700),
      titleMedium: style(18, 24, FontWeight.w700),
      titleSmall: style(16, 22, FontWeight.w600),
      bodyLarge: style(16, 24, FontWeight.w400),
      bodyMedium: style(15, 22, FontWeight.w400),
      bodySmall: style(13, 18, FontWeight.w400),
      labelLarge: style(14, 20, FontWeight.w600),
      labelMedium: style(13, 18, FontWeight.w600),
      labelSmall: style(12, 16, FontWeight.w700),
    );
  }
}
