import 'public_ticket_dto.dart';

class TicketApiException implements Exception {
  TicketApiException({
    required this.message,
    this.statusCode,
    this.partialTicket,
  });

  final String message;
  final int? statusCode;
  final PublicTicketDto? partialTicket;

  bool get isNotFound => statusCode == 404;
  bool get isConflict => statusCode == 409;
  bool get isGone => statusCode == 410;
  bool get isBadRequest => statusCode == 400;

  @override
  String toString() => message;
}

class TicketNotFoundException extends TicketApiException {
  TicketNotFoundException(
    String reference, {
    String? message,
  }) : super(
          message: message ?? 'Ticket not found for reference $reference',
          statusCode: 404,
        );
}
