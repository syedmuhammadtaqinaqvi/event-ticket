import 'package:flutter/material.dart';

import '../../core/constants/app_spacing.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/app_ui.dart';
import '../../data/models/ticket_record.dart';
import '../controllers/ticket_flow_controller.dart';
import 'ticket_qr_view.dart';
import 'ticket_tear_divider.dart';

class QrPassSection extends StatelessWidget {
  const QrPassSection({super.key, required this.controller});

  final TicketFlowController controller;

  @override
  Widget build(BuildContext context) {
    final ticket = controller.ticket ?? TicketRecord.demo;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 10),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              _PassHeader(ticket: ticket),
              const TicketTearDivider(),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 4, 12, 10),
                child: Column(
                  children: [
                    if (!ticket.isEntryValid)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text(
                          ticket.isCheckedIn
                              ? 'Already checked in — QR is for your records only.'
                              : 'Claim ticket to generate door QR.',
                          textAlign: TextAlign.center,
                          style: AppTypography.bodyMuted.copyWith(fontSize: 12),
                        ),
                      ),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerLowest,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 4),
                        ],
                      ),
                      child: ticket.hasQr
                          ? TicketQrView(qrPayload: ticket.qrPayload!, size: 196)
                          : SizedBox(
                              height: 196,
                              child: Center(
                                child: Icon(Icons.qr_code_2, size: 64, color: AppColors.outline),
                              ),
                            ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Venue door QR',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Staff scan this code at the gate. Bare TKT reference is refused when bound to a device.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.verified_outlined, size: 14, color: AppColors.textSecondary),
                          const SizedBox(width: 5),
                          Text(
                            ticket.reference,
                            style: AppTypography.codeSm.copyWith(
                              color: AppColors.textMuted,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(12),
                color: AppColors.surfaceContainerLow,
                child: Column(
                  children: [
                    FilledButton(
                      onPressed: controller.triggerWalletDownload,
                      style: AppUi.primaryButton(),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.download_outlined, size: 20, color: AppColors.onNavy),
                          const SizedBox(width: 8),
                          Text('Download Ticket (PDF / Wallet)', style: AppUi.primaryButtonText),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: controller.triggerSharePass,
                            icon: const Icon(Icons.share_outlined, size: 18),
                            label: const Text('Share Pass'),
                            style: AppUi.compactActionButton(),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: controller.triggerAddToCalendar,
                            icon: const Icon(Icons.event_available_outlined, size: 18),
                            label: const Text('Add to Cal'),
                            style: AppUi.compactActionButton(),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        _ArrivalChecklist(attendeeName: ticket.attendeeName),
      ],
    );
  }
}

class _PassHeader extends StatelessWidget {
  const _PassHeader({required this.ticket});

  final TicketRecord ticket;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      color: AppColors.passHeader,
      child: Stack(
        children: [
          Positioned(
            right: -24,
            bottom: -24,
            child: Icon(
              Icons.token,
              size: 100,
              color: AppColors.onPassHeader.withValues(alpha: 0.08),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.onPassHeader.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: AppColors.highlight,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          'LIVE PASS ACTIVE',
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: AppColors.onPassHeader,
                                letterSpacing: 0.6,
                                fontSize: 9,
                              ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  Text(
                    ticket.gateLabel,
                    style: AppTypography.codeSm.copyWith(
                      color: AppColors.onPassHeaderMuted,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                ticket.eventLocationLabel.toUpperCase(),
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppColors.onPassHeaderMuted,
                      fontSize: 9,
                    ),
              ),
              Text(
                ticket.eventShortTitle,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: AppColors.onPassHeader,
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                    ),
              ),
              const SizedBox(height: 6),
              Divider(color: AppColors.onPassHeader.withValues(alpha: 0.15), height: 1),
              const SizedBox(height: 6),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'ATTENDEE',
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: AppColors.onPassHeaderMuted,
                                fontSize: 9,
                              ),
                        ),
                        Text(
                          ticket.attendeeName,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: AppColors.onPassHeader,
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'SEAT TIER',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: AppColors.onPassHeaderMuted,
                              fontSize: 9,
                            ),
                      ),
                      Text(
                        ticket.seatTier,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: AppColors.highlight,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ArrivalChecklist extends StatelessWidget {
  const _ArrivalChecklist({required this.attendeeName});

  final String attendeeName;

  @override
  Widget build(BuildContext context) {
    final items = [
      'Keep phone brightness at 80%+ at turnstile scanners.',
      'Have government photo ID matching attendee name: $attendeeName.',
      'Collect your VIP lanyard at Gate 3 Concierge.',
    ];
    return Container(
      padding: const EdgeInsets.all(AppUi.cardPadding),
      decoration: AppUi.cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'On-Site Arrival Checklist',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.textPrimary,
                  fontSize: 15,
                ),
          ),
          const SizedBox(height: 8),
          for (var i = 0; i < items.length; i++) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 18,
                  height: 18,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainer,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '${i + 1}',
                    style: AppTypography.codeSm.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w700,
                      fontSize: 10,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    items[i],
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),
                ),
              ],
            ),
            if (i < items.length - 1) const SizedBox(height: 6),
          ],
        ],
      ),
    );
  }
}
