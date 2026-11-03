import 'package:event_ticket/core/utils/ticket_input_normalizer.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('normalizeEventId strips whitespace', () {
    expect(
      TicketInputNormalizer.normalizeEventId(' 5f3ee318-f7f6-4393-b0f8-7edb5bd7a62b '),
      '5f3ee318-f7f6-4393-b0f8-7edb5bd7a62b',
    );
  });

  test('normalizeTicketReference adds TKT prefix', () {
    expect(
      TicketInputNormalizer.normalizeTicketReference('cg6ugwea'),
      'TKT-CG6UGWEA',
    );
  });

  test('isValidEventId rejects partial uuid', () {
    expect(
      TicketInputNormalizer.isValidEventId('-f7f6-4393-b0f8-7edb5bd7a62b'),
      isFalse,
    );
    expect(
      TicketInputNormalizer.isValidEventId('5f3ee318-f7f6-4393-b0f8-7edb5bd7a62b'),
      isTrue,
    );
  });
}
