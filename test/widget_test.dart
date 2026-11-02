import 'package:event_ticket/app.dart';
import 'package:event_ticket/data/repositories/ticket_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Event Ticket portal loads lookup screen', (tester) async {
    await tester.pumpWidget(
      EventTicketApp(repository: MockTicketRepository()),
    );
    await tester.pump();
    await tester.pumpAndSettle(const Duration(seconds: 5));

    expect(find.text('Claim your ticket'), findsOneWidget);
    expect(find.text('Preview ticket'), findsOneWidget);
    expect(find.text('Lookup'), findsOneWidget);
    expect(find.text('Event ID'), findsOneWidget);
  });
}
