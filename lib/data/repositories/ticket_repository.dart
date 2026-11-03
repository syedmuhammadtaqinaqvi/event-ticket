import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../core/services/device_id_service.dart';
import '../../core/services/rotating_entry_payload_codec.dart';
import '../../core/services/ticket_cache_service.dart';
import '../datasources/ticket_remote_datasource.dart';
import '../models/public_ticket_dto.dart';
import '../models/ticket_api_exception.dart';
import '../models/ticket_record.dart';

abstract class TicketRepository {
  String get deviceId;
  String get deviceDisplayLabel;

  Future<void> warmUp();

  Future<TicketRecord> lookupTicket({
    required String eventId,
    required String ticketReference,
  });

  Future<TicketRecord> claimTicket({
    required String eventId,
    required String ticketReference,
  });

  Future<List<TicketRecord>> getWalletTickets({String? eventId});

  TicketRecord? readCachedActiveTicket();

  Future<TicketRecord?> readCachedActiveTicketWithSecret();

  Future<void> cacheActiveTicket(TicketRecord ticket);
}

class TicketRepositoryImpl implements TicketRepository {
  TicketRepositoryImpl({
    required TicketRemoteDataSource remote,
    required DeviceIdService deviceIdService,
    required TicketCacheService cacheService,
    PackageInfo? packageInfo,
  })  : _remote = remote,
        _deviceIdService = deviceIdService,
        _cacheService = cacheService,
        _packageInfo = packageInfo;

  final TicketRemoteDataSource _remote;
  final DeviceIdService _deviceIdService;
  final TicketCacheService _cacheService;
  PackageInfo? _packageInfo;

  @override
  String get deviceId => _deviceIdService.id;

  @override
  String get deviceDisplayLabel => _deviceIdService.displayLabel;

  @override
  Future<void> warmUp() async {
    await _deviceIdService.warmUp();
  }

  Future<String> _appVersion() async {
    _packageInfo ??= await PackageInfo.fromPlatform();
    return _packageInfo!.version;
  }

  String get _platform {
    if (kIsWeb) return 'web';
    return switch (defaultTargetPlatform) {
      TargetPlatform.iOS => 'ios',
      TargetPlatform.android => 'android',
      _ => 'other',
    };
  }

  @override
  Future<TicketRecord> lookupTicket({
    required String eventId,
    required String ticketReference,
  }) async {
    try {
      final dto = await _remote.lookupTicket(
        eventId: eventId,
        ticketReference: ticketReference,
        deviceId: deviceId,
      );
      return TicketRecord.fromDto(dto);
    } on TicketApiException catch (e) {
      if (e.isNotFound) {
        throw TicketNotFoundException(ticketReference, message: e.message);
      }
      rethrow;
    }
  }

  @override
  Future<TicketRecord> claimTicket({
    required String eventId,
    required String ticketReference,
  }) async {
    final dto = await _remote.claimTicket(
      eventId: eventId,
      ticketReference: ticketReference,
      deviceId: deviceId,
      platform: _platform,
      appVersion: await _appVersion(),
    );
    final record = TicketRecord.fromDto(dto).withClaimBinding(deviceId: deviceId);
    await cacheActiveTicket(record);
    return record;
  }

  @override
  Future<List<TicketRecord>> getWalletTickets({String? eventId}) async {
    final list = await _remote.listDeviceTickets(deviceId: deviceId, eventId: eventId);
    return list.map(TicketRecord.fromDto).toList();
  }

  @override
  TicketRecord? readCachedActiveTicket() {
    final dto = _cacheService.readActiveTicket();
    if (dto == null) return null;
    return TicketRecord.fromDto(dto);
  }

  @override
  Future<TicketRecord?> readCachedActiveTicketWithSecret() async {
    final dto = await _cacheService.readActiveTicketWithSecret();
    if (dto == null) return null;
    return TicketRecord.fromDto(dto);
  }

  @override
  Future<void> cacheActiveTicket(TicketRecord ticket) async {
    await _cacheService.saveActiveTicket(ticket.toDto());
  }
}

class MockTicketRemoteDataSource implements TicketRemoteDataSource {
  @override
  Future<PublicTicketDto> lookupTicket({
    required String eventId,
    required String ticketReference,
    String? deviceId,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 150));
    final ref = ticketReference.trim().toUpperCase();
    if (ref == 'ERROR' || ref == 'TKT-00000000') {
      throw TicketNotFoundException(ticketReference);
    }
    return PublicTicketDto(
      eventId: eventId.isEmpty ? '00000000-0000-0000-0000-000000000001' : eventId,
      eventTitle: 'Demo Conference 2026',
      eventStart: DateTime.utc(2026, 6, 15, 14, 0),
      locationName: 'Demo Arena',
      reference: ref.startsWith('TKT-') ? ref : 'TKT-$ref',
      seat: 'General admission',
      holderName: 'Demo Guest',
      status: 'issued',
      claimed: false,
      canClaim: true,
      claimedOnThisDevice: false,
      claimedOnOtherDevice: false,
    );
  }

  @override
  Future<PublicTicketDto> claimTicket({
    required String eventId,
    required String ticketReference,
    required String deviceId,
    required String platform,
    required String appVersion,
  }) async {
    final lookup = await lookupTicket(
      eventId: eventId,
      ticketReference: ticketReference,
      deviceId: deviceId,
    );
    const secret = 'mock-entry-secret-for-unit-tests';
    const period = 30;
    final payload = RotatingEntryPayloadCodec.buildPayload(
      eventId: lookup.eventId,
      reference: lookup.reference,
      deviceId: deviceId,
      qrSecret: secret,
      qrPeriodSeconds: period,
      timeStepOverride: 1_700_000_000 ~/ period,
    );
    return PublicTicketDto(
      eventId: lookup.eventId,
      eventTitle: lookup.eventTitle,
      eventStart: lookup.eventStart,
      locationName: lookup.locationName,
      reference: lookup.reference,
      seat: lookup.seat,
      holderName: lookup.holderName,
      status: lookup.status,
      boundDeviceId: deviceId,
      claimed: true,
      entryPreferred: 'nfc',
      nfcPayload: payload,
      nfcRecordType: 'text',
      qrMode: 'rotating',
      qrPeriodSeconds: period,
      qrSecret: secret,
      qrPayload: payload,
    );
  }

  @override
  Future<List<PublicTicketDto>> listDeviceTickets({
    required String deviceId,
    String? eventId,
  }) async {
    return [];
  }
}

class MockTicketRepository implements TicketRepository {
  MockTicketRepository({TicketRemoteDataSource? remote})
      : _remote = remote ?? MockTicketRemoteDataSource();

  final TicketRemoteDataSource _remote;
  TicketRecord? _cached;

  @override
  String get deviceId => 'test-device-id';

  @override
  String get deviceDisplayLabel => 'test-dev…-id';

  @override
  Future<void> warmUp() async {}

  @override
  Future<TicketRecord> lookupTicket({
    required String eventId,
    required String ticketReference,
  }) async {
    try {
      final dto = await _remote.lookupTicket(
        eventId: eventId,
        ticketReference: ticketReference,
        deviceId: deviceId,
      );
      return TicketRecord.fromDto(dto);
    } on TicketApiException catch (e) {
      if (e.isNotFound) {
        throw TicketNotFoundException(ticketReference, message: e.message);
      }
      rethrow;
    }
  }

  @override
  Future<TicketRecord> claimTicket({
    required String eventId,
    required String ticketReference,
  }) async {
    final dto = await _remote.claimTicket(
      eventId: eventId,
      ticketReference: ticketReference,
      deviceId: deviceId,
      platform: 'android',
      appVersion: '1.0.0',
    );
    final record = TicketRecord.fromDto(dto).withClaimBinding(deviceId: deviceId);
    _cached = record;
    return record;
  }

  @override
  Future<List<TicketRecord>> getWalletTickets({String? eventId}) async => [];

  @override
  TicketRecord? readCachedActiveTicket() => _cached;

  @override
  Future<TicketRecord?> readCachedActiveTicketWithSecret() async => _cached;

  @override
  Future<void> cacheActiveTicket(TicketRecord ticket) async {
    _cached = ticket;
  }
}
