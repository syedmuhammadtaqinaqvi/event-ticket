import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';

/// Shown for milliseconds while prefs/repo initialize — not a blank white screen.
class StartupLoadingScreen extends StatelessWidget {
  const StartupLoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(flex: 3),
            Center(
              child: Text.rich(
                TextSpan(
                  children: [
                    TextSpan(text: 'Event ', style: AppTypography.brandSplash),
                    TextSpan(text: 'Ticket', style: AppTypography.brandSplashAccent),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const Spacer(flex: 4),
            const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: AppColors.navyMid,
              ),
            ),
            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }
}
