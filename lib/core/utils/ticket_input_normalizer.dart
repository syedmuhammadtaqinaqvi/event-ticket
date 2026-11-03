/// Sanitizes Event ID + TKT reference from email paste / manual entry.
class TicketInputNormalizer {
  TicketInputNormalizer._();

  static final _uuid = RegExp(
    r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$',
  );

  static String normalizeEventId(String raw) {
    return raw.trim().replaceAll(RegExp(r'\s+'), '').replaceAll('\u200b', '');
  }

  static String normalizeTicketReference(String raw) {
    var ref = raw.trim().toUpperCase().replaceAll(RegExp(r'\s+'), '');
    if (ref.isEmpty) return ref;
    if (!ref.startsWith('TKT-')) {
      ref = 'TKT-$ref';
    }
    return ref;
  }

  static bool isValidEventId(String eventId) => _uuid.hasMatch(eventId);
}
