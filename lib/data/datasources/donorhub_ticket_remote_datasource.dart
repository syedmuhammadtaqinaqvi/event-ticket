import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../core/config/api_config.dart';
import '../models/public_ticket_dto.dart';
import '../models/ticket_api_exception.dart';
import 'ticket_remote_datasource.dart';

class DonorHubTicketRemoteDataSource implements TicketRemoteDataSource {
  DonorHubTicketRemoteDataSource({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Uri get _base => Uri.parse(ApiConfig.baseUrl);

  @override
  Future<PublicTicketDto> lookupTicket({
    required String eventId,
    required String ticketReference,
    String? deviceId,
  }) async {
    final body = <String, dynamic>{
      'eventId': eventId.trim(),
      'ticketReference': ticketReference.trim(),
    };
    if (deviceId != null && deviceId.isNotEmpty) {
      body['deviceId'] = deviceId;
    }

    final response = await _client
        .post(
          _base.replace(path: ApiConfig.lookupPath),
          headers: _headers,
          body: jsonEncode(body),
        )
        .timeout(ApiConfig.connectTimeout);

    return _parseTicketResponse(response, allowMissingQr: true);
  }

  @override
  Future<PublicTicketDto> claimTicket({
    required String eventId,
    required String ticketReference,
    required String deviceId,
    required String platform,
    required String appVersion,
  }) async {
    final response = await _client
        .post(
          _base.replace(path: ApiConfig.claimPath),
          headers: _headers,
          body: jsonEncode({
            'eventId': eventId.trim(),
            'ticketReference': ticketReference.trim(),
            'deviceId': deviceId,
            'platform': platform,
            'appVersion': appVersion,
          }),
        )
        .timeout(ApiConfig.connectTimeout);

    return _parseTicketResponse(response, allowMissingQr: false);
  }

  @override
  Future<List<PublicTicketDto>> listDeviceTickets({
    required String deviceId,
    String? eventId,
  }) async {
    final query = <String, String>{'deviceId': deviceId};
    if (eventId != null && eventId.isNotEmpty) {
      query['eventId'] = eventId;
    }

    final uri = _base.replace(
      path: ApiConfig.deviceTicketsPath,
      queryParameters: query,
    );

    final response = await _client.get(uri, headers: _headers).timeout(ApiConfig.connectTimeout);

    final map = _decode(response);
    if (response.statusCode >= 200 && response.statusCode < 300 && map['success'] == true) {
      final list = map['tickets'] as List<dynamic>? ?? [];
      return list
          .map((e) => PublicTicketDto.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    throw TicketApiException(
      message: map['error'] as String? ?? 'Could not load wallet tickets',
      statusCode: response.statusCode,
    );
  }

  Map<String, String> get _headers => const {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

  PublicTicketDto _parseTicketResponse(
    http.Response response, {
    required bool allowMissingQr,
  }) {
    final map = _decode(response);
    final success = map['success'] == true;
    final ticketJson = map['ticket'];

    if (response.statusCode >= 200 && response.statusCode < 300 && success && ticketJson != null) {
      final ticket = PublicTicketDto.fromJson(ticketJson as Map<String, dynamic>);
      if (!allowMissingQr && (ticket.qrPayload == null || ticket.qrPayload!.isEmpty)) {
        throw TicketApiException(
          message: 'Claim succeeded but QR payload was missing',
          statusCode: response.statusCode,
          partialTicket: ticket,
        );
      }
      return ticket;
    }

    PublicTicketDto? partial;
    if (ticketJson is Map<String, dynamic>) {
      partial = PublicTicketDto.fromJson(ticketJson);
    }

    throw TicketApiException(
      message: map['error'] as String? ?? _defaultMessage(response.statusCode),
      statusCode: response.statusCode,
      partialTicket: partial,
    );
  }

  Map<String, dynamic> _decode(http.Response response) {
    try {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } catch (_) {
      throw TicketApiException(
        message: 'Unexpected server response',
        statusCode: response.statusCode,
      );
    }
  }

  String _defaultMessage(int code) {
    return switch (code) {
      400 => 'Missing or invalid ticket details',
      404 => 'Wrong event ID or ticket reference',
      409 => 'Ticket already claimed on another device or used at the door',
      410 => 'This ticket was cancelled',
      429 => 'Too many requests — try again shortly',
      _ => 'Request failed ($code)',
    };
  }
}
