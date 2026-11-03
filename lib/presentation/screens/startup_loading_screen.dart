import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

/// Instant first paint — system fonts only (no Google Fonts network on cold start).
class StartupLoadingScreen extends StatelessWidget {
  const StartupLoadingScreen({super.key, this.message});

  final String? message;

  static const _titleRegular = TextStyle(
    fontSize: 34,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.8,
    height: 1.1,
    color: AppColors.textPrimary,
  );

  static const _titleAccent = TextStyle(
    fontSize: 34,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.6,
    height: 1.1,
    color: AppColors.navyMid,
  );

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
                  children: const [
                    TextSpan(text: 'Event ', style: _titleRegular),
                    TextSpan(text: 'Ticket', style: _titleAccent),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
            ),
            if (message != null) ...[
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  message!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textMuted,
                  ),
                ),
              ),
            ],
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
