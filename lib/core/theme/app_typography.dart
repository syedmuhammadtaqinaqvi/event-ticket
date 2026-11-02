import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

abstract final class AppTypography {
  static TextTheme get textTheme {
    final base = GoogleFonts.plusJakartaSansTextTheme();
    return base.copyWith(
      displayLarge: _sans(36, FontWeight.w800, -1.0, 1.08),
      headlineLarge: _sans(30, FontWeight.w800, -0.8, 1.12),
      headlineMedium: _sans(26, FontWeight.w700, -0.6, 1.15),
      headlineSmall: _sans(22, FontWeight.w700, -0.4, 1.2),
      titleLarge: _sans(18, FontWeight.w700, -0.25, 1.25),
      titleMedium: _sans(16, FontWeight.w700, -0.15, 1.3),
      titleSmall: _sans(14, FontWeight.w600, -0.05, 1.35),
      bodyLarge: _sans(16, FontWeight.w500, 0, 1.45),
      bodyMedium: _sans(14, FontWeight.w500, 0.01, 1.45),
      bodySmall: _sans(12, FontWeight.w500, 0.02, 1.4),
      labelLarge: _sans(13, FontWeight.w700, 0.02, 1.25),
      labelMedium: _sans(12, FontWeight.w600, 0.04, 1.2),
      labelSmall: _sans(11, FontWeight.w700, 0.12, 1.15),
    );
  }

  /// Splash / marketing wordmark.
  static TextStyle get brandSplash => GoogleFonts.plusJakartaSans(
        fontSize: 34,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.8,
        height: 1.1,
        color: AppColors.textPrimary,
      );

  static TextStyle get brandSplashAccent => brandSplash.copyWith(
        fontWeight: FontWeight.w800,
        color: AppColors.navyMid,
        letterSpacing: -0.6,
      );

  static TextStyle get appBarTitle => GoogleFonts.plusJakartaSans(
        fontSize: 17,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.35,
        height: 1.2,
        color: AppColors.textPrimary,
      );

  /// Small caps row above card titles.
  static TextStyle get eyebrow => GoogleFonts.plusJakartaSans(
        fontSize: 10,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.4,
        height: 1.2,
        color: AppColors.textSecondary,
      );

  static TextStyle get cardTitle => GoogleFonts.plusJakartaSans(
        fontSize: 20,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.45,
        height: 1.2,
        color: AppColors.textPrimary,
      );

  static TextStyle get bodyMuted => GoogleFonts.plusJakartaSans(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.01,
        height: 1.45,
        color: AppColors.textSecondary,
      );

  static TextStyle get fieldLabel => GoogleFonts.plusJakartaSans(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.02,
        height: 1.25,
        color: AppColors.textPrimary,
      );

  static TextStyle get navTab => GoogleFonts.plusJakartaSans(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.01,
        height: 1.2,
      );

  static TextStyle get buttonLabel => GoogleFonts.plusJakartaSans(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.1,
        height: 1.2,
      );

  static TextStyle codeSm = GoogleFonts.jetBrainsMono(
    fontSize: 12,
    height: 16 / 12,
    letterSpacing: 0.02,
    fontWeight: FontWeight.w500,
    color: AppColors.onSurface,
  );

  static TextStyle _sans(
    double size,
    FontWeight weight,
    double letterSpacing,
    double height,
  ) {
    return GoogleFonts.plusJakartaSans(
      fontSize: size,
      fontWeight: weight,
      letterSpacing: letterSpacing,
      height: height,
      color: AppColors.onSurface,
    );
  }
}
