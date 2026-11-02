import 'package:event_ticket/data/repositories/ticket_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('MockTicketRepository', () {
    late MockTicketRepository repo;

    setUp(() {
      repo = MockTicketRepository();
    });

    test('lookup maps DTO to TicketRecord', () async {
      final record = await repo.lookupTicket(
        eventId: '154bb128-c5c6-412e-badc-041202be720d',
        ticketReference: 'TKT-TEST1234',
      );
      expect(record.reference, 'TKT-TEST1234');
      expect(record.eventTitle, isNotEmpty);
      expect(record.hasQr, isFalse);
      expect(record.canClaim, isTrue);
    });

    test('claim returns qrPayload and caches', () async {
      await repo.lookupTicket(
        eventId: '154bb128-c5c6-412e-badc-041202be720d',
        ticketReference: 'TKT-TEST1234',
      );
      final claimed = await repo.claimTicket(
        eventId: '154bb128-c5c6-412e-badc-041202be720d',
        ticketReference: 'TKT-TEST1234',
      );
      expect(claimed.hasQr, isTrue);
      expect(claimed.qrPayload, startsWith('DHB1.'));
      expect(repo.readCachedActiveTicket()?.qrPayload, claimed.qrPayload);
    });
  });
}
