import 'package:flutter/material.dart';

abstract final class AppColors {
  static const Color textPrimary = Color(0xFF0A0A0A);
  static const Color textSecondary = Color(0xFF334155);
  static const Color textMuted = Color(0xFF64748B);

  static const Color onSurface = textPrimary;
  static const Color onSurfaceVariant = textSecondary;

  static const Color brandBlue = Color(0xFF2563EB);
  static const Color background = Color(0xFFFFFFFF);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceBlue = Color(0xFFF8FAFC);

  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color surfaceContainerLow = Color(0xFFF1F5F9);
  static const Color surfaceContainer = Color(0xFFE2E8F0);
  static const Color surfaceContainerHigh = Color(0xFFDBEAFE);
  static const Color surfaceContainerHighest = Color(0xFFBFDBFE);
  static const Color surfaceDim = Color(0xFFDBEAFE);

  static const Color navy = Color(0xFF0F172A);
  static const Color navyMid = Color(0xFF1E40AF);
  static const Color navySoft = Color(0xFFDBEAFE);
  static const Color navyGlow = Color(0xFF1D4ED8);
  static const Color onNavy = Color(0xFFFFFFFF);
  static const Color onNavyMuted = Color(0xFFE2E8F0);

  static const Color onBlue = Color(0xFFFFFFFF);
  static const Color onBlueMuted = Color(0xCCFFFFFF);

  static const Color accent = navyMid;
  static const Color accentDark = navyGlow;
  static const Color onAccent = onNavy;
  static const Color accentSoft = navySoft;

  static const Color primary = navyMid;
  static const Color onPrimary = onNavy;
  static const Color primaryContainer = navyGlow;
  static const Color onPrimaryContainer = textPrimary;

  static const Color highlight = Color(0xFFFBBF24);
  static const Color highlightSoft = Color(0xFFFEF3C7);

  static const Color secondary = highlight;
  static const Color onSecondary = textPrimary;
  static const Color secondaryContainer = highlightSoft;
  static const Color onSecondaryContainer = textPrimary;
  static const Color secondaryFixed = highlight;

  static const Color primaryFixedDim = Color(0xFF93C5FD);

  static const Color outline = Color(0xFF94A3B8);
  static const Color outlineVariant = Color(0xFFCBD5E1);

  static const Color error = Color(0xFFDC2626);
  static const Color errorContainer = Color(0xFFFFDAD6);
  static const Color onErrorContainer = Color(0xFF93000A);

  static const Color passHeader = navyGlow;
  static const Color onPassHeader = onNavy;
  static const Color onPassHeaderMuted = onNavyMuted;

  static const Color qrBadge = navyMid;
}
