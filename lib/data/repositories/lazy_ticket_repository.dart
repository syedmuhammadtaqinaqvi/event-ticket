import '../../core/bootstrap/app_preferences.dart';
import '../../core/services/device_id_service.dart';
import '../../core/services/ticket_cache_service.dart';
import '../datasources/donorhub_ticket_remote_datasource.dart';
import '../models/ticket_record.dart';
import 'ticket_repository.dart';

/// Defers [SharedPreferences] until first use so the UI can paint immediately.
class LazyTicketRepository implements TicketRepository {
  TicketRepositoryImpl? _delegate;

  Future<TicketRepositoryImpl> _impl() async {
    if (_delegate != null) return _delegate!;
    final prefs = await AppPreferences.instance;
    final impl = TicketRepositoryImpl(
      remote: DonorHubTicketRemoteDataSource(),
      deviceIdService: DeviceIdService(prefs),
      cacheService: TicketCacheService(prefs),
    );
    await impl.warmUp();
    _delegate = impl;
    return _delegate!;
  }

  @override
  Future<void> warmUp() async {
    await _impl();
  }

  @override
  String get deviceId => _delegate?.deviceId ?? '';

  @override
  String get deviceDisplayLabel =>
      _delegate?.deviceDisplayLabel ?? 'This device';

  @override
  Future<TicketRecord> lookupTicket({
    required String eventId,
    required String ticketReference,
  }) async {
    return (await _impl()).lookupTicket(
      eventId: eventId,
      ticketReference: ticketReference,
    );
  }

  @override
  Future<TicketRecord> claimTicket({
    required String eventId,
    required String ticketReference,
  }) async {
    return (await _impl()).claimTicket(
      eventId: eventId,
      ticketReference: ticketReference,
    );
  }

  @override
  Future<List<TicketRecord>> getWalletTickets({String? eventId}) async {
    return (await _impl()).getWalletTickets(eventId: eventId);
  }

  @override
  TicketRecord? readCachedActiveTicket() {
    return _delegate?.readCachedActiveTicket();
  }

  @override
  Future<TicketRecord?> readCachedActiveTicketWithSecret() async {
    return (await _impl()).readCachedActiveTicketWithSecret();
  }

  @override
  Future<void> cacheActiveTicket(TicketRecord ticket) async {
    await (await _impl()).cacheActiveTicket(ticket);
  }
}
