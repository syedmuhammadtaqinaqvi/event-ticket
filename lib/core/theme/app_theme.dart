import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_colors.dart';
import 'app_typography.dart';
import 'app_ui.dart';

abstract final class AppTheme {
  static ThemeData get light {
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
      textTheme: AppTypography.textTheme,
      inputDecorationTheme: InputDecorationTheme(
        labelStyle: AppTypography.fieldLabel,
        hintStyle: AppTypography.bodyMuted.copyWith(color: AppColors.textMuted),
        floatingLabelStyle: AppTypography.fieldLabel,
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
