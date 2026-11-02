import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../data/models/public_ticket_dto.dart';

/// Offline cache for claimed ticket + [qrPayload] after successful claim.
class TicketCacheService {
  TicketCacheService(this._prefs);

  static const _activeTicketKey = 'donorhub_active_ticket_v1';

  final SharedPreferences _prefs;

  PublicTicketDto? readActiveTicket() {
    final raw = _prefs.getString(_activeTicketKey);
    if (raw == null || raw.isEmpty) return null;
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      return PublicTicketDto.fromJson(map);
    } catch (_) {
      return null;
    }
  }

  Future<void> saveActiveTicket(PublicTicketDto ticket) async {
    await _prefs.setString(_activeTicketKey, jsonEncode(ticket.toJson()));
  }

  Future<void> clearActiveTicket() async {
    await _prefs.remove(_activeTicketKey);
  }
}
