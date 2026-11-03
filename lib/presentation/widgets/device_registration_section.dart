import 'package:flutter/material.dart';

import '../../core/constants/app_spacing.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/app_ui.dart';
import '../controllers/ticket_flow_controller.dart';

class DeviceRegistrationSection extends StatelessWidget {
  const DeviceRegistrationSection({super.key, required this.controller});

  final TicketFlowController controller;

  @override
  Widget build(BuildContext context) {
    final ticket = controller.ticket;
    final ticketRef = ticket?.reference ?? controller.ticketReference;

    return Container(
      padding: const EdgeInsets.all(AppUi.cardPadding),
      decoration: AppUi.cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Icon(Icons.security, size: 16, color: AppColors.textSecondary),
              const SizedBox(width: 6),
              Text('DEVICE BINDING', style: AppTypography.eyebrow),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text('Claim on this phone', style: AppTypography.cardTitle),
          const SizedBox(height: 4),
          Text(
            'Your door QR is tied to this device. On Android, binding survives reinstall. '
            'Another phone cannot claim the same ticket.',
            style: AppTypography.bodyMuted,
          ),
          const SizedBox(height: AppSpacing.md),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(AppUi.buttonRadius),
            ),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.smartphone, color: AppColors.textPrimary, size: 20),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'This device',
                        style: Theme.of(context).textTheme.labelMedium?.copyWith(
                              color: AppColors.textPrimary,
                            ),
                      ),
                      Text(
                        'ID: ${controller.deviceDisplayLabel}',
                        style: AppTypography.codeSm.copyWith(
                          color: AppColors.onSurfaceVariant,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (ticket != null) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              '${ticket.eventTitle}\n$ticketRef · ${ticket.seatTier}',
              style: AppTypography.bodyMuted.copyWith(fontSize: 12),
            ),
          ],
          if (controller.showRegistrationBadge) ...[
            const SizedBox(height: AppSpacing.sm),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.accentSoft,
                borderRadius: BorderRadius.circular(AppUi.buttonRadius),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle, color: AppColors.accent, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Claimed — opening QR…',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.md),
          FilledButton(
            onPressed: controller.isClaimLoading ? null : controller.claimOnThisDevice,
            style: AppUi.primaryButton(),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (controller.isClaimLoading)
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.onNavy),
                  )
                else
                  const Icon(Icons.qr_code_2, size: 20, color: AppColors.onNavy),
                const SizedBox(width: 8),
                Text(
                  controller.isClaimLoading ? 'Claiming…' : 'Claim on this phone',
                  style: AppUi.primaryButtonText,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
