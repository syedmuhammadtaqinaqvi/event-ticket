import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_typography.dart';

abstract final class AppUi {
  static const double buttonHeight = 52;
  static const double buttonHeightSecondary = 48;
  static const double cardRadius = 16;
  static const double cardPadding = 14;
  static const double buttonRadius = 12;

  static TextStyle get primaryButtonText =>
      AppTypography.buttonLabel.copyWith(color: AppColors.onNavy);

  static ButtonStyle primaryButton({Color? background}) {
    return FilledButton.styleFrom(
      backgroundColor: background ?? AppColors.navyMid,
      foregroundColor: AppColors.onNavy,
      disabledBackgroundColor: AppColors.navyMid.withValues(alpha: 0.45),
      disabledForegroundColor: AppColors.onNavy.withValues(alpha: 0.7),
      minimumSize: const Size(double.infinity, buttonHeight),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(buttonRadius)),
      textStyle: primaryButtonText,
    );
  }

  static ButtonStyle secondaryButton() {
    return FilledButton.styleFrom(
      backgroundColor: AppColors.highlight,
      foregroundColor: AppColors.textPrimary,
      minimumSize: const Size(double.infinity, buttonHeight),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(buttonRadius)),
      textStyle: AppTypography.buttonLabel.copyWith(color: AppColors.textPrimary),
    );
  }

  static ButtonStyle compactActionButton() {
    return OutlinedButton.styleFrom(
      backgroundColor: AppColors.surfaceContainerLowest,
      foregroundColor: AppColors.textPrimary,
      minimumSize: const Size(double.infinity, buttonHeightSecondary),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(buttonRadius)),
      side: const BorderSide(color: AppColors.outlineVariant),
      textStyle: AppTypography.buttonLabel.copyWith(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
    );
  }

  static BoxDecoration cardDecoration() {
    return BoxDecoration(
      color: AppColors.surfaceContainerLowest,
      borderRadius: BorderRadius.circular(cardRadius),
      border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.8)),
      boxShadow: [
        BoxShadow(
          color: AppColors.navy.withValues(alpha: 0.08),
          blurRadius: 10,
          offset: const Offset(0, 3),
        ),
      ],
    );
  }
}
