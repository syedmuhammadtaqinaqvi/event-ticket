import 'package:flutter/material.dart';

import '../../core/constants/app_spacing.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';

class AppHeader extends StatelessWidget {
  const AppHeader({
    super.key,
    required this.showBack,
    this.onBack,
  });

  final bool showBack;
  final VoidCallback? onBack;

  static const double _sideSlot = 52;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.surface,
      child: SafeArea(
        bottom: false,
        child: SizedBox(
          height: 52,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
            child: Row(
              children: [
                SizedBox(
                  width: _sideSlot,
                  child: showBack
                      ? Material(
                          color: AppColors.navyMid,
                          borderRadius: BorderRadius.circular(10),
                          child: InkWell(
                            onTap: onBack,
                            borderRadius: BorderRadius.circular(10),
                            child: const SizedBox(
                              height: 40,
                              child: Icon(
                                Icons.arrow_back_rounded,
                                color: AppColors.onNavy,
                                size: 22,
                              ),
                            ),
                          ),
                        )
                      : null,
                ),
                Expanded(
                  child: Text(
                    'Event Ticket',
                    textAlign: TextAlign.center,
                    style: AppTypography.appBarTitle,
                  ),
                ),
                const SizedBox(width: _sideSlot),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
