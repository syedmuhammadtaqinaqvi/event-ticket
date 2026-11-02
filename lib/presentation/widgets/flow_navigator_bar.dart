import 'package:flutter/material.dart';

import '../../core/constants/app_spacing.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../domain/enums/ticket_flow_state.dart';
import '../controllers/ticket_flow_controller.dart';

class FlowNavigatorBar extends StatelessWidget {
  const FlowNavigatorBar({
    super.key,
    required this.controller,
    required this.onStateSelected,
  });

  final TicketFlowController controller;
  final ValueChanged<TicketFlowState> onStateSelected;

  static const _steps = [
    (TicketFlowState.lookup, 'Lookup'),
    (TicketFlowState.ticketFound, 'Found'),
    (TicketFlowState.deviceReg, 'Claim'),
    (TicketFlowState.qrActive, 'Pass'),
  ];

  int get _activeIndex => switch (controller.currentState) {
        TicketFlowState.lookup => 0,
        TicketFlowState.ticketFound => 1,
        TicketFlowState.deviceReg => 2,
        TicketFlowState.qrActive => 3,
        TicketFlowState.error => 0,
      };

  @override
  Widget build(BuildContext context) {
    final active = _activeIndex;
    final isError = controller.currentState == TicketFlowState.error;

    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.gutter,
        6,
        AppSpacing.gutter,
        10,
      ),
      color: AppColors.surface,
      child: Row(
        children: [
          for (var i = 0; i < _steps.length; i++)
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(left: i == 0 ? 0 : 4, right: i == _steps.length - 1 ? 0 : 4),
                child: _SimpleStepTab(
                  label: _steps[i].$2,
                  selected: i == active,
                  showError: isError && i == 0,
                  onTap: () => onStateSelected(_steps[i].$1),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _SimpleStepTab extends StatelessWidget {
  const _SimpleStepTab({
    required this.label,
    required this.selected,
    required this.onTap,
    this.showError = false,
  });

  final String label;
  final bool selected;
  final bool showError;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bg = selected ? AppColors.navyMid : AppColors.background;
    final borderColor = showError ? AppColors.error : AppColors.outlineVariant;
    final textColor = selected ? AppColors.onNavy : AppColors.textPrimary;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Ink(
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: selected ? AppColors.navyMid : borderColor,
            ),
          ),
          child: SizedBox(
            height: 44,
            child: Center(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.navTab.copyWith(
                      color: textColor,
                      fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                    ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
