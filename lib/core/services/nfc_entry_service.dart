import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// NFC tap entry — Android HCE payload bridge + capability checks.
class NfcEntryService {
  NfcEntryService._();

  static const _channel = MethodChannel('com.eventpass.event_ticket/nfc_entry');

  /// Hardware present, NFC enabled, and HCE service registered as default for "other".
  static Future<NfcEntryStatus> checkStatus() async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) {
      return const NfcEntryStatus(
        hardwareAvailable: false,
        nfcEnabled: false,
        hceDefault: false,
      );
    }
    try {
      final hardware = await _channel.invokeMethod<bool>('hasNfcHardware') ?? false;
      if (!hardware) {
        return const NfcEntryStatus(hardwareAvailable: false, nfcEnabled: false, hceDefault: false);
      }
      final enabled = await _channel.invokeMethod<bool>('isNfcEnabled') ?? false;
      final hceDefault = await _channel.invokeMethod<bool>('isHceRegistered') ?? false;
      return NfcEntryStatus(
        hardwareAvailable: true,
        nfcEnabled: enabled,
        hceDefault: hceDefault,
      );
    } catch (_) {
      return const NfcEntryStatus(hardwareAvailable: false, nfcEnabled: false, hceDefault: false);
    }
  }

  static Future<bool> isNfcReady() async {
    final status = await checkStatus();
    return status.isReadyForTap;
  }

  static Future<void> openNfcSettings() async {
    if (defaultTargetPlatform != TargetPlatform.android) return;
    try {
      await _channel.invokeMethod<void>('openNfcSettings');
    } catch (_) {}
  }

  static Future<void> publishPayload(
    String payload, {
    String? recordType,
    String? mimeType,
  }) async {
    if (payload.isEmpty) return;
    if (defaultTargetPlatform != TargetPlatform.android) return;
    try {
      await _channel.invokeMethod<void>('setEntryPayload', {
        'payload': payload,
        if (recordType != null && recordType.isNotEmpty) 'recordType': recordType,
        if (mimeType != null && mimeType.isNotEmpty) 'mimeType': mimeType,
      });
    } catch (_) {}
  }

  static Future<void> clearPayload() async {
    if (defaultTargetPlatform != TargetPlatform.android) return;
    try {
      await _channel.invokeMethod<void>('clearEntryPayload');
    } catch (_) {}
  }
}

class NfcEntryStatus {
  const NfcEntryStatus({
    required this.hardwareAvailable,
    required this.nfcEnabled,
    required this.hceDefault,
  });

  final bool hardwareAvailable;
  final bool nfcEnabled;
  final bool hceDefault;

  bool get isReadyForTap => hardwareAvailable && nfcEnabled;

  /// Tap may still work if user sets default tap & pay / NFC service in system UI.
  bool get needsDefaultServiceHint => isReadyForTap && !hceDefault;
}
