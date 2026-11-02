import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../core/theme/app_colors.dart';

/// Renders the exact [qrPayload] string from DonorHub claim / wallet APIs.
class TicketQrView extends StatelessWidget {
  const TicketQrView({
    super.key,
    required this.qrPayload,
    this.size = 196,
  });

  final String qrPayload;
  final double size;

  @override
  Widget build(BuildContext context) {
    return QrImageView(
      data: qrPayload,
      version: QrVersions.auto,
      size: size,
      backgroundColor: Colors.white,
      eyeStyle: const QrEyeStyle(
        eyeShape: QrEyeShape.square,
        color: AppColors.navy,
      ),
      dataModuleStyle: const QrDataModuleStyle(
        dataModuleShape: QrDataModuleShape.square,
        color: AppColors.navy,
      ),
      gapless: true,
      errorCorrectionLevel: QrErrorCorrectLevel.M,
    );
  }
}
