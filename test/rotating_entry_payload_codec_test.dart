import 'package:event_ticket/core/services/rotating_entry_payload_codec.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('RotatingEntryPayloadCodec', () {
    const eventId = '154bb128-c5c6-412e-badc-041202be720d';
    const deviceId = 'android-stable-id';
    const secret = 'test-qr-secret';
    const period = 30;

    test('payload uses DHB1 prefix and changes each period', () {
      final a = RotatingEntryPayloadCodec.buildPayload(
        eventId: eventId,
        reference: 'tkt-abc',
        deviceId: deviceId,
        qrSecret: secret,
        qrPeriodSeconds: period,
        timeStepOverride: 10,
      );
      final b = RotatingEntryPayloadCodec.buildPayload(
        eventId: eventId,
        reference: 'tkt-abc',
        deviceId: deviceId,
        qrSecret: secret,
        qrPeriodSeconds: period,
        timeStepOverride: 11,
      );
      expect(a, startsWith('DHB1.'));
      expect(a, isNot(equals(b)));
    });
  });
}
