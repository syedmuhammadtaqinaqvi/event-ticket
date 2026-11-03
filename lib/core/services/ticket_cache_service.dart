import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/models/public_ticket_dto.dart';

/// Offline cache for claimed ticket + rotating QR material ([qrSecret] in secure storage).
class TicketCacheService {
  TicketCacheService(
    this._prefs, {
    FlutterSecureStorage? secureStorage,
  }) : _secure = secureStorage ?? const FlutterSecureStorage();

  static const _activeTicketKey = 'donorhub_active_ticket_v2';
  static const _legacyTicketKey = 'donorhub_active_ticket_v1';

  final SharedPreferences _prefs;
  final FlutterSecureStorage _secure;

  String _secretStorageKey(PublicTicketDto ticket) =>
      'donorhub_qr_secret_${ticket.eventId}_${ticket.reference.trim().toUpperCase()}';

  PublicTicketDto? readActiveTicket() {
    var raw = _prefs.getString(_activeTicketKey);
    raw ??= _prefs.getString(_legacyTicketKey);
    if (raw == null || raw.isEmpty) return null;
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      return PublicTicketDto.fromJson(map);
    } catch (_) {
      return null;
    }
  }

  /// Loads ticket from prefs and merges [qrSecret] from secure storage when needed.
  Future<PublicTicketDto?> readActiveTicketWithSecret() async {
    final ticket = readActiveTicket();
    if (ticket == null) return null;
    if (ticket.qrSecret != null && ticket.qrSecret!.isNotEmpty) {
      return ticket;
    }
    final secret = await _secure.read(key: _secretStorageKey(ticket));
    if (secret == null || secret.isEmpty) return ticket;
    return ticket.copyWith(qrSecret: secret);
  }

  Future<void> saveActiveTicket(PublicTicketDto ticket) async {
    final secret = ticket.qrSecret;
    if (secret != null && secret.isNotEmpty) {
      await _secure.write(key: _secretStorageKey(ticket), value: secret);
    }
    await _prefs.setString(
      _activeTicketKey,
      jsonEncode(ticket.toJson(stripQrSecret: true)),
    );
  }

  Future<void> clearActiveTicket() async {
    final existing = readActiveTicket();
    if (existing != null) {
      await _secure.delete(key: _secretStorageKey(existing));
    }
    await _prefs.remove(_activeTicketKey);
  }
}
