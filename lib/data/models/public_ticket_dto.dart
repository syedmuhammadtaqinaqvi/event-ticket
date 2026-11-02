class PublicTicketDto {
  const PublicTicketDto({
    required this.eventId,
    required this.eventTitle,
    this.eventStart,
    this.locationName,
    this.registrationId,
    this.placeNo,
    required this.reference,
    this.seat,
    this.holderName,
    this.ticketType,
    required this.status,
    this.checkedInAt,
    this.boundDeviceId,
    this.boundAt,
    required this.claimed,
    this.canClaim,
    this.claimedOnThisDevice,
    this.claimedOnOtherDevice,
    this.qrPayload,
  });

  final String eventId;
  final String eventTitle;
  final DateTime? eventStart;
  final String? locationName;
  final String? registrationId;
  final int? placeNo;
  final String reference;
  final String? seat;
  final String? holderName;
  final String? ticketType;
  final String status;
  final DateTime? checkedInAt;
  final String? boundDeviceId;
  final DateTime? boundAt;
  final bool claimed;
  final bool? canClaim;
  final bool? claimedOnThisDevice;
  final bool? claimedOnOtherDevice;
  final String? qrPayload;

  factory PublicTicketDto.fromJson(Map<String, dynamic> json) {
    return PublicTicketDto(
      eventId: json['eventId'] as String,
      eventTitle: json['eventTitle'] as String? ?? '',
      eventStart: _parseDate(json['eventStart']),
      locationName: json['locationName'] as String?,
      registrationId: json['registrationId'] as String?,
      placeNo: json['placeNo'] as int?,
      reference: json['reference'] as String? ?? '',
      seat: json['seat'] as String?,
      holderName: json['holderName'] as String?,
      ticketType: json['ticketType'] as String?,
      status: json['status'] as String? ?? 'issued',
      checkedInAt: _parseDate(json['checkedInAt']),
      boundDeviceId: json['boundDeviceId'] as String?,
      boundAt: _parseDate(json['boundAt']),
      claimed: json['claimed'] as bool? ?? false,
      canClaim: json['canClaim'] as bool?,
      claimedOnThisDevice: json['claimedOnThisDevice'] as bool?,
      claimedOnOtherDevice: json['claimedOnOtherDevice'] as bool?,
      qrPayload: json['qrPayload'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'eventId': eventId,
        'eventTitle': eventTitle,
        'eventStart': eventStart?.toUtc().toIso8601String(),
        'locationName': locationName,
        'registrationId': registrationId,
        'placeNo': placeNo,
        'reference': reference,
        'seat': seat,
        'holderName': holderName,
        'ticketType': ticketType,
        'status': status,
        'checkedInAt': checkedInAt?.toUtc().toIso8601String(),
        'boundDeviceId': boundDeviceId,
        'boundAt': boundAt?.toUtc().toIso8601String(),
        'claimed': claimed,
        'canClaim': canClaim,
        'claimedOnThisDevice': claimedOnThisDevice,
        'claimedOnOtherDevice': claimedOnOtherDevice,
        'qrPayload': qrPayload,
      };

  static DateTime? _parseDate(Object? value) {
    if (value == null) return null;
    return DateTime.tryParse(value.toString());
  }
}
