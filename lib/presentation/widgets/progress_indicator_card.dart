import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/app_ui.dart';
import '../controllers/ticket_flow_controller.dart';

class ProgressIndicatorCard extends StatelessWidget {
  const ProgressIndicatorCard({super.key, required this.controller});

  final TicketFlowController controller;

  @override
  Widget build(BuildContext context) {
    final config = controller.progressConfig;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: AppUi.cardDecoration().copyWith(
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: Row(
        children: [
          Icon(config.icon, color: AppColors.textPrimary, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  config.title,
                  style: AppTypography.fieldLabel.copyWith(fontSize: 13),
                ),
                Text(
                  config.subtitle,
                  style: AppTypography.bodyMuted.copyWith(fontSize: 12),
                ),
              ],
            ),
          ),
          Row(
            children: List.generate(3, (index) {
              final active = index < config.dots.length && config.dots[index];
              return Container(
                width: 10,
                height: 6,
                margin: const EdgeInsets.only(left: 4),
                decoration: BoxDecoration(
                  color: active ? AppColors.navyMid : AppColors.surfaceContainer,
                  borderRadius: BorderRadius.circular(999),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
