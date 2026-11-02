import '../models/public_ticket_dto.dart';

abstract class TicketRemoteDataSource {
  Future<PublicTicketDto> lookupTicket({
    required String eventId,
    required String ticketReference,
    String? deviceId,
  });

  Future<PublicTicketDto> claimTicket({
    required String eventId,
    required String ticketReference,
    required String deviceId,
    required String platform,
    required String appVersion,
  });

  Future<List<PublicTicketDto>> listDeviceTickets({
    required String deviceId,
    String? eventId,
  });
}
