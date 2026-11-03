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
    this.qrMode,
    this.qrPeriodSeconds,
    this.qrTimeStep,
    this.qrValidForSeconds,
    this.qrSecret,
    this.entryPreferred,
    this.nfcPayload,
    this.nfcRecordType,
    this.nfcMimeType,
    this.nfcHint,
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
  final String? qrMode;
  final int? qrPeriodSeconds;
  final int? qrTimeStep;
  final int? qrValidForSeconds;
  final String? qrSecret;
  final String? entryPreferred;
  final String? nfcPayload;
  final String? nfcRecordType;
  final String? nfcMimeType;
  final String? nfcHint;

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
      qrMode: json['qrMode'] as String?,
      qrPeriodSeconds: json['qrPeriodSeconds'] as int?,
      qrTimeStep: json['qrTimeStep'] as int?,
      qrValidForSeconds: json['qrValidForSeconds'] as int?,
      qrSecret: json['qrSecret'] as String?,
      entryPreferred: json['entryPreferred'] as String?,
      nfcPayload: json['nfcPayload'] as String?,
      nfcRecordType: json['nfcRecordType'] as String?,
      nfcMimeType: json['nfcMimeType'] as String?,
      nfcHint: json['nfcHint'] as String?,
    );
  }

  bool get hasRotatingQrMaterial =>
      qrSecret != null &&
      qrSecret!.isNotEmpty &&
      (qrPeriodSeconds ?? 0) > 0;

  bool get hasStaticEntryPayload =>
      (qrPayload != null && qrPayload!.isNotEmpty) ||
      (nfcPayload != null && nfcPayload!.isNotEmpty);

  bool get prefersNfc => entryPreferred == 'nfc';

  PublicTicketDto copyWith({
    String? qrPayload,
    String? qrSecret,
    int? qrPeriodSeconds,
    String? boundDeviceId,
  }) {
    return PublicTicketDto(
      eventId: eventId,
      eventTitle: eventTitle,
      eventStart: eventStart,
      locationName: locationName,
      registrationId: registrationId,
      placeNo: placeNo,
      reference: reference,
      seat: seat,
      holderName: holderName,
      ticketType: ticketType,
      status: status,
      checkedInAt: checkedInAt,
      boundDeviceId: boundDeviceId ?? this.boundDeviceId,
      boundAt: boundAt,
      claimed: claimed,
      canClaim: canClaim,
      claimedOnThisDevice: claimedOnThisDevice,
      claimedOnOtherDevice: claimedOnOtherDevice,
      qrPayload: qrPayload ?? this.qrPayload,
      qrMode: qrMode,
      qrPeriodSeconds: qrPeriodSeconds ?? this.qrPeriodSeconds,
      qrTimeStep: qrTimeStep,
      qrValidForSeconds: qrValidForSeconds,
      qrSecret: qrSecret ?? this.qrSecret,
    );
  }

  /// JSON for prefs — omits [qrSecret] (stored separately when secure cache is used).
  Map<String, dynamic> toJson({bool stripQrSecret = false}) => {
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
        'qrMode': qrMode,
        'qrPeriodSeconds': qrPeriodSeconds,
        'qrTimeStep': qrTimeStep,
        'qrValidForSeconds': qrValidForSeconds,
        if (!stripQrSecret) 'qrSecret': qrSecret,
        'entryPreferred': entryPreferred,
        'nfcPayload': nfcPayload,
        'nfcRecordType': nfcRecordType,
        'nfcMimeType': nfcMimeType,
        'nfcHint': nfcHint,
      };

  static DateTime? _parseDate(Object? value) {
    if (value == null) return null;
    return DateTime.tryParse(value.toString());
  }
}
