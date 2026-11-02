import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

class TicketTearDivider extends StatelessWidget {
  const TicketTearDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 28,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: _DashedLinePainter(color: AppColors.outlineVariant.withValues(alpha: 0.5)),
            ),
          ),
          Row(
            children: [
              _Notch(side: _NotchSide.left),
              const Spacer(),
              _Notch(side: _NotchSide.right),
            ],
          ),
        ],
      ),
    );
  }
}

enum _NotchSide { left, right }

class _Notch extends StatelessWidget {
  const _Notch({required this.side});

  final _NotchSide side;

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: Offset(side == _NotchSide.left ? -12 : 12, 0),
      child: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: AppColors.background,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 2,
              offset: const Offset(0, 1),
            ),
          ],
        ),
      ),
    );
  }
}

class _DashedLinePainter extends CustomPainter {
  _DashedLinePainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    const dashWidth = 6.0;
    const dashSpace = 4.0;
    double startX = 24;
    final y = size.height / 2;
    while (startX < size.width - 24) {
      canvas.drawLine(Offset(startX, y), Offset(startX + dashWidth, y), paint);
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
