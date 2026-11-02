import 'package:flutter/material.dart';

import '../../core/constants/app_spacing.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/ticket_record.dart';
import '../../domain/enums/ticket_flow_state.dart';
import '../controllers/ticket_flow_controller.dart';
import '../widgets/action_toast.dart';
import '../widgets/app_header.dart';
import '../widgets/device_registration_section.dart';
import '../widgets/flow_navigator_bar.dart';
import '../widgets/lookup_section.dart';
import '../widgets/progress_indicator_card.dart';
import '../widgets/qr_pass_section.dart';
import '../widgets/ticket_info_section.dart';

class TicketPortalScreen extends StatefulWidget {
  const TicketPortalScreen({super.key, required this.controller});

  final TicketFlowController controller;

  @override
  State<TicketPortalScreen> createState() => _TicketPortalScreenState();
}

class _TicketPortalScreenState extends State<TicketPortalScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onFlowChanged);
  }

  void _onFlowChanged() {
    setState(() {});
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onFlowChanged);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: ColoredBox(
        color: AppColors.background,
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Material(
                  color: AppColors.background,
                  elevation: 0,
                  shadowColor: Colors.transparent,
                  surfaceTintColor: Colors.transparent,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AppHeader(
                        showBack: controller.canGoBack,
                        onBack: controller.goBack,
                      ),
                      FlowNavigatorBar(
                        controller: controller,
                        onStateSelected: controller.switchState,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ColoredBox(
                    color: AppColors.background,
                    child: ListView(
                    controller: _scrollController,
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.gutter,
                      AppSpacing.sm,
                      AppSpacing.gutter,
                      AppSpacing.lg,
                    ),
                    children: [
                      Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 448),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              ProgressIndicatorCard(controller: controller),
                              const SizedBox(height: AppSpacing.sm),
                              _buildActiveSection(controller),
                            ],
                          ),
                        ),
                      ),
                    ],
                    ),
                  ),
                ),
              ],
            ),
            Positioned(
              left: AppSpacing.gutter,
              right: AppSpacing.gutter,
              bottom: 16,
              child: Center(
                child: ActionToast(
                  message: controller.toastMessage ?? '',
                  icon: controller.toastIcon,
                  visible: controller.toastMessage != null,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveSection(TicketFlowController controller) {
    switch (controller.currentState) {
      case TicketFlowState.lookup:
      case TicketFlowState.error:
        return LookupSection(controller: controller);
      case TicketFlowState.ticketFound:
        return TicketInfoSection(
          ticket: controller.ticket ?? TicketRecord.demo,
          onContinue: () => controller.switchState(TicketFlowState.deviceReg),
        );
      case TicketFlowState.deviceReg:
        return DeviceRegistrationSection(controller: controller);
      case TicketFlowState.qrActive:
        return QrPassSection(controller: controller);
    }
  }
}
