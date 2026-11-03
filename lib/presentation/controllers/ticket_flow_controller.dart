import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../core/utils/ticket_input_normalizer.dart';
import '../../data/models/ticket_api_exception.dart';
import '../../data/models/ticket_record.dart';
import '../../data/repositories/ticket_repository.dart';
import '../../domain/enums/lookup_error_kind.dart';
import '../../domain/enums/ticket_flow_state.dart';

class FlowProgressConfig {
  const FlowProgressConfig({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.dots,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final List<bool> dots;
}

class TicketFlowController extends ChangeNotifier {
  TicketFlowController(this._repository);

  final TicketRepository _repository;

  TicketFlowState currentState = TicketFlowState.lookup;
  String eventId = '';
  String ticketReference = '';
  TicketRecord? ticket;
  List<TicketRecord> walletTickets = [];
  bool isLookupLoading = false;
  bool isClaimLoading = false;
  bool isWalletLoading = false;
  bool showRegistrationBadge = false;
  String? lookupErrorMessage;
  LookupErrorKind lookupErrorKind = LookupErrorKind.none;
  bool passQrFallbackActive = false;
  String? toastMessage;
  IconData toastIcon = Icons.check_circle;

  Timer? _toastTimer;

  String get deviceDisplayLabel => _repository.deviceDisplayLabel;

  String get deviceId => _repository.deviceId;

  void setPassQrFallbackActive(bool active) {
    if (passQrFallbackActive == active) return;
    passQrFallbackActive = active;
    notifyListeners();
  }

  static const flowConfigs = {
    TicketFlowState.lookup: FlowProgressConfig(
      title: 'Enter ticket codes',
      subtitle: 'Event ID + ticket reference from email',
      icon: Icons.manage_search,
      dots: [true, false, false],
    ),
    TicketFlowState.ticketFound: FlowProgressConfig(
      title: 'Ticket preview',
      subtitle: 'Verify event details before claim',
      icon: Icons.check_circle,
      dots: [true, true, false],
    ),
    TicketFlowState.deviceReg: FlowProgressConfig(
      title: 'Claim on this phone',
      subtitle: 'Bind ticket to this device',
      icon: Icons.phonelink_lock,
      dots: [true, true, true],
    ),
    TicketFlowState.qrActive: FlowProgressConfig(
      title: 'Entry pass ready',
      subtitle: 'NFC tap or QR at venue gate',
      icon: Icons.qr_code_2,
      dots: [true, true, true],
    ),
    TicketFlowState.error: FlowProgressConfig(
      title: 'Could not load ticket',
      subtitle: 'Check codes and try again',
      icon: Icons.error_outline,
      dots: [false, false, false],
    ),
  };

  FlowProgressConfig get progressConfig {
    if (currentState == TicketFlowState.error) {
      return switch (lookupErrorKind) {
        LookupErrorKind.notFound => const FlowProgressConfig(
            title: 'Ticket not found',
            subtitle: 'Check Event ID and TKT from email',
            icon: Icons.search_off,
            dots: [false, false, false],
          ),
        LookupErrorKind.wrongDevice => const FlowProgressConfig(
            title: 'Different device',
            subtitle: 'Ticket is bound to another phone ID',
            icon: Icons.phonelink_erase,
            dots: [false, false, false],
          ),
        LookupErrorKind.validation => const FlowProgressConfig(
            title: 'Check your codes',
            subtitle: 'Fix the fields below',
            icon: Icons.edit_note,
            dots: [false, false, false],
          ),
        _ => flowConfigs[TicketFlowState.error]!,
      };
    }
    return flowConfigs[currentState] ?? flowConfigs[TicketFlowState.lookup]!;
  }

  bool get canGoBack => currentState != TicketFlowState.lookup;

  Future<void> _restoreFromCache() async {
    final cached = await _repository.readCachedActiveTicketWithSecret();
    if (cached != null && cached.hasQr) {
      ticket = cached;
      eventId = cached.eventId;
      ticketReference = cached.reference;
      currentState = TicketFlowState.qrActive;
    }
  }

  Future<void> bootstrap() async {
    try {
      await _repository.warmUp().timeout(const Duration(seconds: 8));
      await _restoreFromCache();
      notifyListeners();
    } catch (_) {
      // Prefs slow — user can still use lookup; cache restores on next launch.
    }
    try {
      await refreshWallet(silent: true).timeout(const Duration(seconds: 4));
    } catch (_) {}
  }

  void goBack() {
    switch (currentState) {
      case TicketFlowState.error:
      case TicketFlowState.ticketFound:
        currentState = TicketFlowState.lookup;
        lookupErrorMessage = null;
        lookupErrorKind = LookupErrorKind.none;
      case TicketFlowState.deviceReg:
        currentState = TicketFlowState.ticketFound;
        showRegistrationBadge = false;
        isClaimLoading = false;
      case TicketFlowState.qrActive:
        currentState = TicketFlowState.deviceReg;
        showRegistrationBadge = false;
        passQrFallbackActive = false;
      case TicketFlowState.lookup:
        return;
    }
    notifyListeners();
  }

  void switchState(TicketFlowState state) {
    if (state == TicketFlowState.lookup) {
      currentState = state;
      lookupErrorMessage = null;
      lookupErrorKind = LookupErrorKind.none;
      notifyListeners();
      return;
    }
    if (state == TicketFlowState.ticketFound && ticket == null) return;
    if (state == TicketFlowState.deviceReg && ticket == null) return;
    if (state == TicketFlowState.qrActive && (ticket == null || !ticket!.hasQr)) {
      return;
    }
    currentState = state;
    if (state == TicketFlowState.deviceReg) {
      showRegistrationBadge = false;
      isClaimLoading = false;
    }
    notifyListeners();
  }

  void clearEventId() {
    eventId = '';
    notifyListeners();
  }

  void clearTicketInput() {
    ticketReference = '';
    notifyListeners();
  }

  void setEventId(String value) {
    eventId = value;
    notifyListeners();
  }

  void setTicketReference(String value) {
    ticketReference = value;
    notifyListeners();
  }

  Future<void> submitLookup() async {
    final eid = TicketInputNormalizer.normalizeEventId(eventId);
    final ref = TicketInputNormalizer.normalizeTicketReference(ticketReference);
    eventId = eid;
    ticketReference = ref;
    notifyListeners();

    if (eid.isEmpty || ref.isEmpty) {
      _failLookup(
        'Enter both Event ID and ticket reference (TKT-…).',
        LookupErrorKind.validation,
      );
      return;
    }

    if (!TicketInputNormalizer.isValidEventId(eid)) {
      _failLookup(
        'Event ID must be a full UUID from your email (8-4-4-4-12 characters). '
        'Check you copied the entire ID, not just part of it.',
        LookupErrorKind.validation,
      );
      return;
    }

    isLookupLoading = true;
    lookupErrorMessage = null;
    lookupErrorKind = LookupErrorKind.none;
    notifyListeners();

    try {
      await _repository.warmUp();
      ticket = await _repository.lookupTicket(eventId: eid, ticketReference: ref);
      ticketReference = ticket!.reference;

      if (_isBoundToThisDevice(ticket!)) {
        try {
          ticket = await _reclaimTicketForQr(ticket!);
          if (ticket!.hasQr) {
            await _repository.cacheActiveTicket(ticket!);
            currentState = TicketFlowState.qrActive;
            lookupErrorKind = LookupErrorKind.none;
            showToast('Your door QR is ready', Icons.verified);
            notifyListeners();
            return;
          }
        } on TicketApiException catch (e) {
          _failLookup(_messageForClaimFailure(e, ticket), LookupErrorKind.wrongDevice);
          return;
        }
      }

      if (_isClaimedOnAnotherDevice(ticket!)) {
        final fromWallet = await _ticketFromWalletIfBound(ref);
        if (fromWallet != null && _isBoundToThisDevice(fromWallet)) {
          ticket = fromWallet;
          try {
            ticket = await _reclaimTicketForQr(ticket!);
            if (ticket!.hasQr) {
              await _repository.cacheActiveTicket(ticket!);
              currentState = TicketFlowState.qrActive;
              lookupErrorKind = LookupErrorKind.none;
              showToast('Your door QR is ready', Icons.verified);
              notifyListeners();
              return;
            }
          } on TicketApiException catch (e) {
            _failLookup(_messageForClaimFailure(e, ticket), LookupErrorKind.wrongDevice);
            return;
          }
        }
        _failLookup(_messageClaimedOnOtherDevice(ticket!), LookupErrorKind.wrongDevice);
        return;
      }

      if (ticket!.claimedOnThisDevice || ticket!.claimed) {
        currentState = TicketFlowState.deviceReg;
        lookupErrorKind = LookupErrorKind.none;
        showToast('Already claimed — tap Claim to refresh QR', Icons.info_outline);
      } else if (!ticket!.canClaim) {
        _failLookup(
          ticket!.isCheckedIn
              ? 'This ticket was already used at the door.'
              : 'This ticket cannot be claimed right now.',
          ticket!.isCheckedIn ? LookupErrorKind.checkedIn : LookupErrorKind.generic,
        );
        return;
      } else {
        currentState = TicketFlowState.ticketFound;
        lookupErrorKind = LookupErrorKind.none;
        showToast('Ticket found: ${ticket!.attendeeName}', Icons.check_circle);
      }
    } on TicketNotFoundException catch (e) {
      _failLookup(
        e.message.isNotEmpty
            ? e.message
            : 'No ticket matches that Event ID and TKT reference. '
                'Use both values from the same confirmation email.',
        LookupErrorKind.notFound,
      );
      return;
    } on TicketApiException catch (e) {
      _failLookup(e.message, LookupErrorKind.generic);
      return;
    } catch (_) {
      _failLookup('Network error. Check connection and try again.', LookupErrorKind.network);
      return;
    } finally {
      isLookupLoading = false;
      notifyListeners();
    }
  }

  Future<void> claimOnThisDevice() async {
    final eid = ticket?.eventId ?? eventId.trim();
    final ref = ticket?.reference ?? ticketReference.trim();
    if (eid.isEmpty || ref.isEmpty) return;

    isClaimLoading = true;
    notifyListeners();

    try {
      ticket = await _repository.claimTicket(eventId: eid, ticketReference: ref);
      showRegistrationBadge = true;
      isClaimLoading = false;
      notifyListeners();
      await Future<void>.delayed(const Duration(milliseconds: 400));
      currentState = TicketFlowState.qrActive;
      showToast('Ticket claimed on this phone', Icons.verified);
    } on TicketApiException catch (e) {
      _failLookup(_messageForClaimFailure(e, ticket), LookupErrorKind.wrongDevice);
      isClaimLoading = false;
      showRegistrationBadge = false;
    } catch (_) {
      _failLookup('Could not claim ticket. Try again when online.', LookupErrorKind.network);
      isClaimLoading = false;
      showRegistrationBadge = false;
    }
    notifyListeners();
  }

  Future<void> refreshWallet({bool silent = false}) async {
    if (!silent) {
      isWalletLoading = true;
      notifyListeners();
    }
    try {
      walletTickets = await _repository.getWalletTickets();
      if (ticket != null) {
        final match = walletTickets.where((t) => t.reference == ticket!.reference).toList();
        if (match.isNotEmpty) {
          ticket = _preferRicherQrTicket(ticket!, match.first);
          await _repository.cacheActiveTicket(ticket!);
        }
      } else if (walletTickets.isNotEmpty) {
        final withQr = walletTickets.where((t) => t.hasQr).toList();
        if (withQr.length == 1) {
          ticket = withQr.first;
          eventId = ticket!.eventId;
          ticketReference = ticket!.reference;
          await _repository.cacheActiveTicket(ticket!);
        }
      }
    } catch (_) {
      if (!silent) {
        showToast('Could not refresh wallet', Icons.cloud_off);
      }
    } finally {
      isWalletLoading = false;
      notifyListeners();
    }
  }

  void selectWalletTicket(TicketRecord record) {
    ticket = record;
    eventId = record.eventId;
    ticketReference = record.reference;
    if (record.hasQr) {
      _repository.cacheActiveTicket(record);
      currentState = TicketFlowState.qrActive;
    } else {
      currentState = TicketFlowState.ticketFound;
    }
    notifyListeners();
  }

  void _failLookup(String message, LookupErrorKind kind) {
    lookupErrorMessage = message;
    lookupErrorKind = kind;
    currentState = TicketFlowState.error;
    notifyListeners();
  }

  bool _isBoundToThisDevice(TicketRecord record) {
    if (record.claimedOnThisDevice) return true;
    final localId = _repository.deviceId;
    if (localId.isEmpty) return false;
    final bound = record.boundDeviceId;
    return record.claimed &&
        bound != null &&
        bound.isNotEmpty &&
        bound == localId;
  }

  bool _isClaimedOnAnotherDevice(TicketRecord record) {
    if (_isBoundToThisDevice(record)) return false;
    if (!record.claimed) return false;
    final localId = _repository.deviceId;
    final bound = record.boundDeviceId;
    if (bound != null && bound.isNotEmpty && localId.isNotEmpty) {
      return bound != localId;
    }
    return record.claimedOnOtherDevice;
  }

  Future<TicketRecord?> _ticketFromWalletIfBound(String reference) async {
    try {
      walletTickets = await _repository.getWalletTickets();
      for (final t in walletTickets) {
        if (t.reference == reference && _isBoundToThisDevice(t)) {
          return t;
        }
      }
    } catch (_) {}
    return null;
  }

  Future<TicketRecord> _reclaimTicketForQr(TicketRecord current) async {
    if (current.hasQr) return current;
    return _repository.claimTicket(
      eventId: current.eventId,
      ticketReference: current.reference,
    );
  }

  String _messageClaimedOnOtherDevice(TicketRecord record) {
    final bound = record.boundDeviceId ?? '';
    final local = _repository.deviceId;
    final legacyBinding = _isLegacyDeviceBindingMismatch(bound: bound, local: local);

    final phoneHint = deviceDisplayLabel.isNotEmpty
        ? ' This phone is registered as $deviceDisplayLabel.'
        : '';

    if (legacyBinding) {
      return 'This ticket is still linked to an older install ID on the server '
          '(not this phone’s current ID).$phoneHint '
          'Ask event staff to unbind the ticket, then tap Preview ticket again.';
    }
    return 'This ticket is already claimed on another device.$phoneHint '
        'Use the phone that claimed it, or ask the organizer to unbind so you can claim here.';
  }

  bool _isLegacyDeviceBindingMismatch({required String bound, required String local}) {
    if (bound.isEmpty || local.isEmpty || bound == local) return false;
    final boundLooksUuid = bound.contains('-') && bound.length >= 32;
    if (!boundLooksUuid) return false;
    if (defaultTargetPlatform == TargetPlatform.android) {
      final localAndroidId = RegExp(r'^[a-f0-9]{8,16}$', caseSensitive: false).hasMatch(local);
      return localAndroidId;
    }
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      final localLooksUuid = local.contains('-') && local.length >= 32;
      return !localLooksUuid;
    }
    return false;
  }

  String _messageForClaimFailure(TicketApiException e, TicketRecord? record) {
    if (e.isConflict && record != null) {
      return _messageClaimedOnOtherDevice(record);
    }
    return e.message;
  }

  TicketRecord _preferRicherQrTicket(TicketRecord local, TicketRecord remote) {
    if (remote.hasQr && !local.hasQr) return remote;
    return local;
  }

  void showToast(String message, IconData icon) {
    toastMessage = message;
    toastIcon = icon;
    notifyListeners();
    _toastTimer?.cancel();
    _toastTimer = Timer(const Duration(milliseconds: 2800), () {
      toastMessage = null;
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _toastTimer?.cancel();
    super.dispose();
  }
}
