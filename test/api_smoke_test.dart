@Tags(['live-api'])
library;

import 'package:event_ticket/core/config/api_config.dart';
import 'package:event_ticket/data/datasources/donorhub_ticket_remote_datasource.dart';
import 'package:event_ticket/data/models/ticket_api_exception.dart';
import 'package:flutter_test/flutter_test.dart';

/// Live API smoke tests — hit DonorHub production public ticket routes.
void main() {
  const sampleEventId = '154bb128-c5c6-412e-badc-041202be720d';
  const sampleTicketRef = 'TKT-8ZXRPBPJ';
  final deviceId = 'event-ticket-smoke-${DateTime.now().millisecondsSinceEpoch}';

  late DonorHubTicketRemoteDataSource api;

  setUp(() {
    api = DonorHubTicketRemoteDataSource();
  });

  test('base URL is DonorHub production', () {
    expect(ApiConfig.baseUrl, 'https://api.donorhub.cloud');
  });

  test('lookup returns success and ticket preview (no qrPayload)', () async {
    final ticket = await api.lookupTicket(
      eventId: sampleEventId,
      ticketReference: sampleTicketRef,
      deviceId: deviceId,
    );

    expect(ticket.eventId, sampleEventId);
    expect(ticket.reference.toUpperCase(), sampleTicketRef);
    expect(ticket.eventTitle, isNotEmpty);
    expect(ticket.qrPayload, isNull);
    expect(ticket.claimed, isFalse);
  }, timeout: const Timeout(Duration(seconds: 20)));

  test('lookup with bad reference throws 404', () async {
    expect(
      () => api.lookupTicket(
        eventId: sampleEventId,
        ticketReference: 'TKT-DOESNOTEXIST99',
      ),
      throwsA(isA<TicketApiException>().having((e) => e.statusCode, 'status', 404)),
    );
  }, timeout: const Timeout(Duration(seconds: 20)));

  test('device-tickets returns success list for new device', () async {
    final tickets = await api.listDeviceTickets(deviceId: deviceId);
    expect(tickets, isA<List>());
  }, timeout: const Timeout(Duration(seconds: 20)));

  test('claim on checked-in sample ticket returns 409', () async {
    expect(
      () => api.claimTicket(
        eventId: sampleEventId,
        ticketReference: sampleTicketRef,
        deviceId: deviceId,
        platform: 'android',
        appVersion: '1.0.0',
      ),
      throwsA(
        isA<TicketApiException>()
            .having((e) => e.statusCode, 'status', 409)
            .having((e) => e.message, 'message', contains('door')),
      ),
    );
  }, timeout: const Timeout(Duration(seconds: 20)));
}
