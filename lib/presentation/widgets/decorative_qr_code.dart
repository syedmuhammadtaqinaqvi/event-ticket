import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

/// Visual QR placeholder matching the HTML SVG aesthetic.
class DecorativeQrCode extends StatelessWidget {
  const DecorativeQrCode({super.key, this.size = 208});

  final double size;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.square(size),
      painter: _QrPainter(color: AppColors.textPrimary),
    );
  }
}

class _QrPainter extends CustomPainter {
  _QrPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / 160;
    canvas.scale(scale);
    final fill = Paint()..color = color;

    void r(double x, double y, double w, double h, [double radius = 0]) {
      if (radius > 0) {
        canvas.drawRRect(
          RRect.fromRectAndRadius(Rect.fromLTWH(x, y, w, h), Radius.circular(radius)),
          fill,
        );
      } else {
        canvas.drawRect(Rect.fromLTWH(x, y, w, h), fill);
      }
    }

    void whiteR(double x, double y, double w, double h, [double radius = 0]) {
      final p = Paint()..color = Colors.white;
      if (radius > 0) {
        canvas.drawRRect(
          RRect.fromRectAndRadius(Rect.fromLTWH(x, y, w, h), Radius.circular(radius)),
          p,
        );
      } else {
        canvas.drawRect(Rect.fromLTWH(x, y, w, h), p);
      }
    }

    // Finder patterns
    for (final offset in [const Offset(10, 10), const Offset(114, 10), const Offset(10, 114)]) {
      r(offset.dx, offset.dy, 36, 36, 6);
      whiteR(offset.dx + 6, offset.dy + 6, 24, 24, 3);
      r(offset.dx + 12, offset.dy + 12, 12, 12, 2);
    }

    // Data modules (subset from HTML)
    final modules = <List<double>>[
      [52, 22, 6, 6], [64, 22, 6, 6], [76, 22, 6, 6], [88, 22, 6, 6], [100, 22, 6, 6],
      [22, 52, 6, 6], [22, 64, 6, 6], [22, 76, 6, 6], [22, 88, 6, 6], [22, 100, 6, 6],
      [52, 52, 12, 12], [82, 52, 12, 12], [70, 64, 18, 6], [52, 76, 6, 12], [64, 82, 12, 12],
      [100, 100, 12, 6], [112, 100, 12, 12], [130, 100, 12, 12], [100, 130, 12, 12],
    ];
    for (final m in modules) {
      r(m[0], m[1], m[2], m[3]);
    }

    // Center badge
    final badge = Paint()..color = AppColors.qrBadge;
    canvas.drawRRect(
      RRect.fromRectAndRadius(const Rect.fromLTWH(68, 68, 24, 24), Radius.circular(6)),
      badge,
    );
    final check = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(
      Path()
        ..moveTo(75, 80)
        ..lineTo(79, 84)
        ..lineTo(85, 76),
      check,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
