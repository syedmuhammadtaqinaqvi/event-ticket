import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_fonts.dart';
import '../../core/theme/app_typography.dart';
import '../controllers/ticket_flow_controller.dart';
import 'ticket_portal_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({
    super.key,
    required this.controller,
    this.duration = const Duration(milliseconds: 550),
  });

  final TicketFlowController controller;

  /// Minimum time on splash; use [Duration.zero] in tests to skip immediately.
  final Duration duration;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  static const _maxWaitForFonts = Duration(milliseconds: 900);

  late final AnimationController _animController;
  late final Animation<double> _fadeIn;
  bool _navigated = false;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _fadeIn = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _animController.forward();
    _schedulePortal();
  }

  Future<void> _schedulePortal() async {
    if (widget.duration <= Duration.zero) {
      SchedulerBinding.instance.addPostFrameCallback((_) => _openPortal());
      return;
    }

    await Future.wait([
      Future<void>.delayed(widget.duration),
      AppFonts.ensureLoaded().timeout(
        _maxWaitForFonts,
        onTimeout: () {},
      ),
    ]);

    _openPortal();
  }

  void _openPortal() {
    if (!mounted || _navigated) return;
    _navigated = true;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder<void>(
        pageBuilder: (context, animation, secondaryAnimation) {
          return TicketPortalScreen(controller: widget.controller);
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 200),
      ),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeIn,
          child: Column(
            children: [
              Expanded(
                child: Center(
                  child: Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: 'Event ',
                          style: AppTypography.brandSplash,
                        ),
                        TextSpan(
                          text: 'Ticket',
                          style: AppTypography.brandSplashAccent,
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
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
      ),
    );
  }
}
