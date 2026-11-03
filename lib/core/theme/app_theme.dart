import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_colors.dart';
import 'app_typography.dart';
import 'app_ui.dart';

abstract final class AppTheme {
  static ThemeData get light => _base(textTheme: AppTypography.textTheme);

  /// System fonts only — first frame on cold start (no Google Fonts network).
  static ThemeData get fastLight => _base(
        textTheme: Typography.englishLike2021.apply(
          bodyColor: AppColors.textPrimary,
          displayColor: AppColors.textPrimary,
        ),
      );

  static ThemeData _base({required TextTheme textTheme}) {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      canvasColor: AppColors.background,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: const ColorScheme.light(
        surface: AppColors.surface,
        onSurface: AppColors.onSurface,
        surfaceTint: Colors.transparent,
        primary: AppColors.primary,
        onPrimary: AppColors.onPrimary,
        primaryContainer: AppColors.primaryContainer,
        onPrimaryContainer: AppColors.onPrimaryContainer,
        secondary: AppColors.secondary,
        onSecondary: AppColors.onSecondary,
        secondaryContainer: AppColors.secondaryContainer,
        onSecondaryContainer: AppColors.onSecondaryContainer,
        error: AppColors.error,
        errorContainer: AppColors.errorContainer,
        onErrorContainer: AppColors.onErrorContainer,
        outlineVariant: AppColors.outlineVariant,
      ),
      textTheme: textTheme,
      inputDecorationTheme: InputDecorationTheme(
        labelStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
        hintStyle: const TextStyle(
          fontSize: 13,
          color: AppColors.textMuted,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(style: AppUi.primaryButton()),
      dividerTheme: const DividerThemeData(
        color: Colors.transparent,
        thickness: 0,
        space: 0,
      ),
      appBarTheme: const AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        backgroundColor: Colors.transparent,
      ),
    );
  }
}
