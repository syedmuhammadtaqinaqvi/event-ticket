import 'package:event_ticket/data/models/ticket_record.dart';
import 'package:event_ticket/data/repositories/ticket_repository.dart';
import 'package:event_ticket/domain/enums/ticket_flow_state.dart';
import 'package:event_ticket/presentation/controllers/ticket_flow_controller.dart';
import 'package:flutter_test/flutter_test.dart';

class _ReclaimFakeRepository implements TicketRepository {
  _ReclaimFakeRepository({
    required this.localDeviceId,
    required this.lookupResult,
    this.claimResult,
  });

  final String localDeviceId;
  final TicketRecord lookupResult;
  TicketRecord? claimResult;
  var claimCallCount = 0;

  @override
  String get deviceId => localDeviceId;

  @override
  String get deviceDisplayLabel => 'test…id';

  @override
  Future<void> warmUp() async {}

  @override
  Future<TicketRecord> lookupTicket({
    required String eventId,
    required String ticketReference,
  }) async =>
      lookupResult;

  @override
  Future<TicketRecord> claimTicket({
    required String eventId,
    required String ticketReference,
  }) async {
    claimCallCount++;
    return claimResult ?? lookupResult;
  }

  @override
  Future<List<TicketRecord>> getWalletTickets({String? eventId}) async => [];

  @override
  TicketRecord? readCachedActiveTicket() => null;

  @override
  Future<TicketRecord?> readCachedActiveTicketWithSecret() async => null;

  @override
  Future<void> cacheActiveTicket(TicketRecord ticket) async {}
}

void main() {
  test('lookup auto-reclaims when claimedOnThisDevice and opens Pass with QR', () async {
    const eventId = '154bb128-c5c6-412e-badc-041202be720d';
    final repo = _ReclaimFakeRepository(
      localDeviceId: 'android-stable-id',
      lookupResult: const TicketRecord(
        eventId: eventId,
        reference: 'TKT-TEST1234',
        eventTitle: 'Test Event',
        status: 'issued',
        claimed: true,
        claimedOnThisDevice: true,
      ),
      claimResult: const TicketRecord(
        eventId: eventId,
        reference: 'TKT-TEST1234',
        eventTitle: 'Test Event',
        status: 'issued',
        claimed: true,
        claimedOnThisDevice: true,
        qrPayload: 'DHB1.reclaim-test-payload',
      ),
    );

    final controller = TicketFlowController(repo);
    controller.eventId = eventId;
    controller.ticketReference = 'TKT-TEST1234';

    await controller.submitLookup();

    expect(repo.claimCallCount, 1);
    expect(controller.currentState, TicketFlowState.qrActive);
    expect(controller.ticket?.hasQr, isTrue);
  });

  test('lookup auto-reclaims when boundDeviceId matches local device id', () async {
    const eventId = '154bb128-c5c6-412e-badc-041202be720d';
    const deviceId = 'android-stable-id';
    final repo = _ReclaimFakeRepository(
      localDeviceId: deviceId,
      lookupResult: TicketRecord(
        eventId: eventId,
        reference: 'TKT-TEST1234',
        eventTitle: 'Test Event',
        status: 'issued',
        claimed: true,
        boundDeviceId: deviceId,
      ),
      claimResult: const TicketRecord(
        eventId: eventId,
        reference: 'TKT-TEST1234',
        eventTitle: 'Test Event',
        status: 'issued',
        claimed: true,
        qrPayload: 'DHB1.bound-match-payload',
      ),
    );

    final controller = TicketFlowController(repo);
    controller.eventId = eventId;
    controller.ticketReference = 'TKT-TEST1234';

    await controller.submitLookup();

    expect(repo.claimCallCount, 1);
    expect(controller.currentState, TicketFlowState.qrActive);
  });

  test('lookup reclaims when server sets claimedOnOtherDevice but boundDeviceId matches', () async {
    const eventId = '154bb128-c5c6-412e-badc-041202be720d';
    const deviceId = 'android-stable-id';
    final repo = _ReclaimFakeRepository(
      localDeviceId: deviceId,
      lookupResult: TicketRecord(
        eventId: eventId,
        reference: 'TKT-TEST1234',
        eventTitle: 'Test Event',
        status: 'issued',
        claimed: true,
        claimedOnOtherDevice: true,
        boundDeviceId: deviceId,
      ),
      claimResult: const TicketRecord(
        eventId: eventId,
        reference: 'TKT-TEST1234',
        eventTitle: 'Test Event',
        status: 'issued',
        claimed: true,
        qrPayload: 'DHB1.flag-mismatch-payload',
      ),
    );

    final controller = TicketFlowController(repo);
    controller.eventId = eventId;
    controller.ticketReference = 'TKT-TEST1234';

    await controller.submitLookup();

    expect(repo.claimCallCount, 1);
    expect(controller.currentState, TicketFlowState.qrActive);
  });
}
