import 'dart:convert';

import 'package:crypto/crypto.dart';

/// Offline rotating door payload (shared by NFC tap and QR fallback).
class RotatingEntryPayloadCodec {
  RotatingEntryPayloadCodec._();

  static const defaultPeriodSeconds = 30;

  static int timeStepFor({
    required int qrPeriodSeconds,
    DateTime? now,
  }) {
    final unix = _unixSeconds(now);
    return unix ~/ qrPeriodSeconds;
  }

  static int secondsRemainingInPeriod({
    required int qrPeriodSeconds,
    DateTime? now,
  }) {
    final unix = _unixSeconds(now);
    return qrPeriodSeconds - (unix % qrPeriodSeconds);
  }

  static String buildPayload({
    required String eventId,
    required String reference,
    required String deviceId,
    required String qrSecret,
    required int qrPeriodSeconds,
    DateTime? now,
    int? timeStepOverride,
  }) {
    assert(qrPeriodSeconds > 0);
    final ref = reference.trim().toUpperCase();
    final t = timeStepOverride ?? timeStepFor(qrPeriodSeconds: qrPeriodSeconds, now: now);
    final message = 'DHB1R|$eventId|$ref|$deviceId|$t';
    final signature = _hmacHex32(qrSecret, message);

    final jsonBytes = utf8.encode(
      jsonEncode(<String, dynamic>{
        'v': 2,
        'e': eventId,
        'r': ref,
        'd': deviceId,
        't': t,
        's': signature,
      }),
    );

    return 'DHB1.${_base64UrlNoPadding(jsonBytes)}';
  }

  static String _hmacHex32(String secret, String message) {
    final mac = Hmac(sha256, utf8.encode(secret));
    final digest = mac.convert(utf8.encode(message));
    return digest.toString().substring(0, 32);
  }

  static String _base64UrlNoPadding(List<int> bytes) {
    return base64Url.encode(bytes).replaceAll('=', '');
  }

  static int _unixSeconds(DateTime? now) {
    final instant = now ?? DateTime.now().toUtc();
    return instant.millisecondsSinceEpoch ~/ 1000;
  }
}
