import 'package:flutter/material.dart';

import '../../core/constants/app_spacing.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/app_ui.dart';
import '../../domain/enums/ticket_flow_state.dart';
import '../controllers/ticket_flow_controller.dart';

class LookupSection extends StatefulWidget {
  const LookupSection({super.key, required this.controller});

  final TicketFlowController controller;

  @override
  State<LookupSection> createState() => _LookupSectionState();
}

class _LookupSectionState extends State<LookupSection> {
  late final TextEditingController _eventIdController;
  late final TextEditingController _ticketController;

  @override
  void initState() {
    super.initState();
    final c = widget.controller;
    _eventIdController = TextEditingController(text: c.eventId);
    _ticketController = TextEditingController(text: c.ticketReference);
    c.addListener(_syncFromController);
  }

  void _syncFromController() {
    final c = widget.controller;
    if (_eventIdController.text != c.eventId) {
      _eventIdController.text = c.eventId;
    }
    if (_ticketController.text != c.ticketReference) {
      _ticketController.text = c.ticketReference;
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_syncFromController);
    _eventIdController.dispose();
    _ticketController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;
    final showError = controller.currentState == TicketFlowState.error;

    return Container(
      padding: const EdgeInsets.all(AppUi.cardPadding),
      decoration: AppUi.cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Icon(Icons.verified_user, size: 16, color: AppColors.textSecondary),
              const SizedBox(width: 6),
              Text('DONORHUB EVENTS', style: AppTypography.eyebrow),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text('Claim your ticket', style: AppTypography.cardTitle),
          const SizedBox(height: 4),
          Text(
            'Use the Event ID and TKT reference from your confirmation email.',
            style: AppTypography.bodyMuted,
          ),
          const SizedBox(height: AppSpacing.md),
          Text('Event ID', style: AppTypography.fieldLabel),
          const SizedBox(height: 6),
          TextField(
            controller: _eventIdController,
            onChanged: controller.setEventId,
            style: AppTypography.codeSm.copyWith(color: AppColors.textPrimary, fontSize: 13),
            decoration: _fieldDecoration(
              hint: 'e.g. 154bb128-c5c6-412e-badc-041202be720d',
              icon: Icons.event_outlined,
              onClear: controller.clearEventId,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text('Ticket reference', style: AppTypography.fieldLabel),
          const SizedBox(height: 6),
          TextField(
            controller: _ticketController,
            onChanged: controller.setTicketReference,
            textCapitalization: TextCapitalization.characters,
            style: AppTypography.codeSm.copyWith(color: AppColors.textPrimary),
            decoration: _fieldDecoration(
              hint: 'e.g. TKT-8ZXRPBPJ',
              icon: Icons.confirmation_number_outlined,
              onClear: controller.clearTicketInput,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'No QR is emailed — claim here to generate your door code.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.onSurfaceVariant,
                  fontSize: 11,
                ),
          ),
          if (showError) ...[
            const SizedBox(height: AppSpacing.md),
            _ErrorBanner(
              message: controller.lookupErrorMessage ??
                  'We could not find that ticket. Check Event ID and TKT reference.',
              eventId: controller.eventId,
              ticketReference: controller.ticketReference,
            ),
          ],
          const SizedBox(height: AppSpacing.md),
          FilledButton(
            onPressed: controller.isLookupLoading ? null : controller.submitLookup,
            style: AppUi.primaryButton(),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (controller.isLookupLoading)
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.onPrimary),
                  )
                else
                  const Icon(Icons.search, size: 20, color: AppColors.onNavy),
                const SizedBox(width: 8),
                Text(
                  controller.isLookupLoading ? 'Looking up…' : 'Preview ticket',
                  style: AppUi.primaryButtonText,
                ),
              ],
            ),
          ),
          if (controller.walletTickets.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.md),
            Text('My tickets on this device', style: AppTypography.fieldLabel),
            const SizedBox(height: 8),
            ...controller.walletTickets.map(
              (t) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: OutlinedButton(
                  onPressed: () => controller.selectWalletTicket(t),
                  style: AppUi.compactActionButton(),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      '${t.reference} · ${t.eventShortTitle}',
                      style: AppTypography.codeSm.copyWith(fontSize: 12),
                    ),
                  ),
                ),
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.sm),
          OutlinedButton.icon(
            onPressed: controller.isWalletLoading ? null : controller.refreshWallet,
            style: AppUi.compactActionButton(),
            icon: controller.isWalletLoading
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.account_balance_wallet_outlined, size: 18),
            label: const Text('Refresh wallet'),
          ),
        ],
      ),
    );
  }

  InputDecoration _fieldDecoration({
    required String hint,
    required IconData icon,
    required VoidCallback onClear,
  }) {
    return InputDecoration(
      filled: true,
      fillColor: AppColors.surfaceContainerLow,
      hintText: hint,
      prefixIcon: Icon(icon, size: 20),
      suffixIcon: IconButton(
        onPressed: onClear,
        icon: const Icon(Icons.cancel_outlined, size: 18),
        color: AppColors.onSurfaceVariant,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppUi.buttonRadius),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppUi.buttonRadius),
        borderSide: const BorderSide(color: AppColors.accent, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({
    required this.message,
    required this.eventId,
    required this.ticketReference,
  });

  final String message;
  final String eventId;
  final String ticketReference;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.errorContainer,
        borderRadius: BorderRadius.circular(AppUi.buttonRadius),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.error_outline, color: AppColors.error, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  message,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: AppColors.onErrorContainer,
                      ),
                ),
                if (ticketReference.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Event: ${eventId.isEmpty ? '—' : eventId}\nTicket: $ticketReference',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.onErrorContainer.withValues(alpha: 0.9),
                        ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
