import 'dart:async';

import 'package:flutter/material.dart';

import '../../data/models/ticket_api_exception.dart';
import '../../data/models/ticket_record.dart';
import '../../data/repositories/ticket_repository.dart';
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
  TicketFlowController(this._repository) {
    _restoreFromCache();
  }

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
  String? toastMessage;
  IconData toastIcon = Icons.check_circle;

  Timer? _toastTimer;

  String get deviceDisplayLabel => _repository.deviceDisplayLabel;

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
      title: 'Door QR ready',
      subtitle: 'Show at venue gate scanner',
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

  FlowProgressConfig get progressConfig =>
      flowConfigs[currentState] ?? flowConfigs[TicketFlowState.lookup]!;

  bool get canGoBack => currentState != TicketFlowState.lookup;

  void _restoreFromCache() {
    final cached = _repository.readCachedActiveTicket();
    if (cached != null && cached.hasQr) {
      ticket = cached;
      eventId = cached.eventId;
      ticketReference = cached.reference;
      currentState = TicketFlowState.qrActive;
    }
  }

  Future<void> bootstrap() async {
    try {
      await refreshWallet(silent: true).timeout(const Duration(seconds: 5));
    } catch (_) {
      // Offline or slow network — local cache from constructor is enough to open app.
    }
  }

  void goBack() {
    switch (currentState) {
      case TicketFlowState.error:
      case TicketFlowState.ticketFound:
        currentState = TicketFlowState.lookup;
        lookupErrorMessage = null;
      case TicketFlowState.deviceReg:
        currentState = TicketFlowState.ticketFound;
        showRegistrationBadge = false;
        isClaimLoading = false;
      case TicketFlowState.qrActive:
        currentState = TicketFlowState.deviceReg;
        showRegistrationBadge = false;
      case TicketFlowState.lookup:
        return;
    }
    notifyListeners();
  }

  void switchState(TicketFlowState state) {
    if (state == TicketFlowState.lookup) {
      currentState = state;
      lookupErrorMessage = null;
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
    final eid = eventId.trim();
    final ref = ticketReference.trim();
    if (eid.isEmpty || ref.isEmpty) {
      lookupErrorMessage = 'Enter both Event ID and ticket reference (TKT-…).';
      currentState = TicketFlowState.error;
      notifyListeners();
      return;
    }

    isLookupLoading = true;
    lookupErrorMessage = null;
    notifyListeners();

    try {
      ticket = await _repository.lookupTicket(eventId: eid, ticketReference: ref);
      ticketReference = ticket!.reference;

      if (ticket!.claimedOnOtherDevice) {
        lookupErrorMessage =
            'This ticket is already claimed on another phone. Transfer is not available yet.';
        currentState = TicketFlowState.error;
        notifyListeners();
        return;
      }

      if (ticket!.claimedOnThisDevice && ticket!.hasQr) {
        await _repository.cacheActiveTicket(ticket!);
        currentState = TicketFlowState.qrActive;
        showToast('Ticket already on this device', Icons.verified);
        notifyListeners();
        return;
      }

      if (ticket!.claimedOnThisDevice || ticket!.claimed) {
        currentState = TicketFlowState.deviceReg;
        showToast('Already claimed — tap to refresh QR', Icons.info_outline);
      } else if (!ticket!.canClaim) {
        lookupErrorMessage = ticket!.isCheckedIn
            ? 'This ticket was already used at the door.'
            : 'This ticket cannot be claimed right now.';
        currentState = TicketFlowState.error;
      } else {
        currentState = TicketFlowState.ticketFound;
        showToast('Ticket found: ${ticket!.attendeeName}', Icons.check_circle);
      }
    } on TicketNotFoundException {
      lookupErrorMessage = 'Wrong event ID or ticket reference.';
      currentState = TicketFlowState.error;
    } on TicketApiException catch (e) {
      lookupErrorMessage = e.message;
      currentState = TicketFlowState.error;
    } catch (_) {
      lookupErrorMessage = 'Network error. Check connection and try again.';
      currentState = TicketFlowState.error;
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
      lookupErrorMessage = e.message;
      currentState = TicketFlowState.error;
      isClaimLoading = false;
      showRegistrationBadge = false;
    } catch (_) {
      lookupErrorMessage = 'Could not claim ticket. Try again when online.';
      currentState = TicketFlowState.error;
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
      if (walletTickets.isNotEmpty && ticket == null) {
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

  void triggerWalletDownload() {
    showToast('Save QR offline — it stays in My tickets', Icons.offline_pin);
  }

  void triggerSharePass() {
    showToast('QR payload stays on this device only', Icons.security);
  }

  void triggerAddToCalendar() {
    showToast('Event: ${ticket?.eventTitle ?? ''}', Icons.event);
  }

  @override
  void dispose() {
    _toastTimer?.cancel();
    super.dispose();
  }
}
