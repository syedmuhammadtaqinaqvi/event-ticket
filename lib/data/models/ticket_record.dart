import 'package:intl/intl.dart';

import 'public_ticket_dto.dart';

class TicketRecord {
  const TicketRecord({
    required this.eventId,
    required this.reference,
    required this.eventTitle,
    this.eventStart,
    this.locationName,
    this.holderName,
    this.seat,
    this.ticketType,
    required this.status,
    this.placeNo,
    this.qrPayload,
    this.claimed = false,
    this.canClaim = true,
    this.claimedOnThisDevice = false,
    this.claimedOnOtherDevice = false,
    this.checkedInAt,
  });

  final String eventId;
  final String reference;
  final String eventTitle;
  final DateTime? eventStart;
  final String? locationName;
  final String? holderName;
  final String? seat;
  final String? ticketType;
  final String status;
  final int? placeNo;
  final String? qrPayload;
  final bool claimed;
  final bool canClaim;
  final bool claimedOnThisDevice;
  final bool claimedOnOtherDevice;
  final DateTime? checkedInAt;

  bool get hasQr => qrPayload != null && qrPayload!.isNotEmpty;
  bool get isCheckedIn => status == 'checked_in';
  bool get isEntryValid => hasQr && !isCheckedIn;

  String get shortRef => reference.length > 12 ? reference.substring(0, 12) : reference;

  String get passType => ticketType?.isNotEmpty == true ? ticketType! : (seat ?? 'Event ticket');

  String get attendeeName => holderName?.isNotEmpty == true ? holderName! : 'Guest';

  String get attendeeInitials {
    final parts = attendeeName.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return 'G';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  String get dateRange {
    if (eventStart == null) return 'Date TBA';
    return DateFormat.yMMMd().add_jm().format(eventStart!.toLocal());
  }

  String get dateSubtitle =>
      placeNo != null ? 'Place $placeNo' : 'DonorHub Events';

  String get venueName => locationName ?? 'Venue TBA';

  String get venueAddress => locationName ?? '';

  String get seatTier => seat ?? 'General admission';

  String get tierLabel => status.toUpperCase().replaceAll('_', ' ');

  String get tierSubtitle => claimed ? '• Claimed on this device' : '• Not yet claimed';

  String get attendeeRole => 'Registered guest';

  String get doorsOpen => eventStart != null
      ? DateFormat.jm().format(eventStart!.toLocal())
      : '—';

  String get doorsSubtitle => isCheckedIn ? 'Already checked in at door' : 'Show QR at venue gate';

  String get eventLocationLabel => locationName ?? eventTitle;

  String get eventShortTitle =>
      eventTitle.length > 28 ? '${eventTitle.substring(0, 25)}…' : eventTitle;

  String get gateLabel => isEntryValid ? 'DOOR QR READY' : 'TICKET STATUS';

  String get tokenHash {
    final ref = reference.replaceAll('TKT-', '');
    return ref.length > 12 ? ref.substring(0, 12) : ref;
  }

  factory TicketRecord.fromDto(PublicTicketDto dto) {
    return TicketRecord(
      eventId: dto.eventId,
      reference: dto.reference,
      eventTitle: dto.eventTitle,
      eventStart: dto.eventStart,
      locationName: dto.locationName,
      holderName: dto.holderName,
      seat: dto.seat,
      ticketType: dto.ticketType,
      status: dto.status,
      placeNo: dto.placeNo,
      qrPayload: dto.qrPayload,
      claimed: dto.claimed,
      canClaim: dto.canClaim ?? true,
      claimedOnThisDevice: dto.claimedOnThisDevice ?? false,
      claimedOnOtherDevice: dto.claimedOnOtherDevice ?? false,
      checkedInAt: dto.checkedInAt,
    );
  }

  PublicTicketDto toDto() {
    return PublicTicketDto(
      eventId: eventId,
      eventTitle: eventTitle,
      eventStart: eventStart,
      locationName: locationName,
      reference: reference,
      seat: seat,
      holderName: holderName,
      ticketType: ticketType,
      status: status,
      placeNo: placeNo,
      checkedInAt: checkedInAt,
      claimed: claimed,
      canClaim: canClaim,
      claimedOnThisDevice: claimedOnThisDevice,
      claimedOnOtherDevice: claimedOnOtherDevice,
      qrPayload: qrPayload,
    );
  }

  TicketRecord copyWith({String? qrPayload, bool? claimed, String? status}) {
    return TicketRecord(
      eventId: eventId,
      reference: reference,
      eventTitle: eventTitle,
      eventStart: eventStart,
      locationName: locationName,
      holderName: holderName,
      seat: seat,
      ticketType: ticketType,
      status: status ?? this.status,
      placeNo: placeNo,
      qrPayload: qrPayload ?? this.qrPayload,
      claimed: claimed ?? this.claimed,
      canClaim: canClaim,
      claimedOnThisDevice: claimedOnThisDevice,
      claimedOnOtherDevice: claimedOnOtherDevice,
      checkedInAt: checkedInAt,
    );
  }

  static const demo = TicketRecord(
    eventId: '00000000-0000-0000-0000-000000000000',
    reference: 'TKT-DEMO0001',
    eventTitle: 'Demo Event',
    holderName: 'Demo Guest',
    seat: 'General admission',
    status: 'issued',
    canClaim: true,
  );
}
