import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/services/nfc_entry_service.dart';
import '../../core/services/rotating_entry_payload_codec.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../data/models/ticket_record.dart';
import 'ticket_qr_view.dart';

/// Door entry — NFC tap (primary) or rotating QR fallback (non-NFC / NFC off).
class EntryPassPanel extends StatefulWidget {
  const EntryPassPanel({
    super.key,
    required this.ticket,
    required this.deviceId,
    required this.onQrFallbackVisible,
    this.qrSize = 196,
  });

  final TicketRecord ticket;
  final String deviceId;
  final ValueChanged<bool> onQrFallbackVisible;
  final double qrSize;

  @override
  State<EntryPassPanel> createState() => _EntryPassPanelState();
}

class _EntryPassPanelState extends State<EntryPassPanel> with WidgetsBindingObserver {
  Timer? _timer;
  String? _payload;
  int? _lastStep;
  int _secondsLeft = 0;
  NfcEntryStatus? _nfcStatus;
  bool _showQrBackup = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _refreshNfcStatus();
    _tick();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _refreshNfcStatus();
    }
  }

  Future<void> _refreshNfcStatus() async {
    final status = await NfcEntryService.checkStatus();
    if (!mounted) return;
    setState(() => _nfcStatus = status);
    _notifyQrFallback();
    _publishIfNeeded(force: true);
  }

  @override
  void didUpdateWidget(covariant EntryPassPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.ticket != widget.ticket || oldWidget.deviceId != widget.deviceId) {
      _lastStep = null;
      _tick();
    }
  }

  bool get _nfcPrimary {
    final status = _nfcStatus;
    return status != null &&
        status.isReadyForTap &&
        widget.ticket.isEntryValid &&
        !_showQrBackup;
  }

  void _notifyQrFallback() {
    final useQrPrimary = !_nfcPrimary || !widget.ticket.isEntryValid;
    widget.onQrFallbackVisible(useQrPrimary && widget.ticket.hasQr);
  }

  bool get _shouldPublishToHce {
    if (!widget.ticket.isEntryValid || _showQrBackup) return false;
    final status = _nfcStatus;
    if (status == null) return true;
    if (!status.hardwareAvailable) return false;
    return status.nfcEnabled;
  }

  void _publishIfNeeded({bool force = false}) {
    final payload = _payload;
    if (!_shouldPublishToHce || payload == null || payload.isEmpty) {
      if (!widget.ticket.isEntryValid || _showQrBackup) {
        unawaited(NfcEntryService.clearPayload());
      }
      return;
    }
    if (force || payload.isNotEmpty) {
      final ticket = widget.ticket;
      unawaited(
        NfcEntryService.publishPayload(
          payload,
          recordType: ticket.nfcRecordType,
          mimeType: ticket.nfcMimeType,
        ),
      );
    }
  }

  void _tick() {
    final ticket = widget.ticket;
    if (!ticket.hasQr) {
      unawaited(NfcEntryService.clearPayload());
      return;
    }

    if (widget.deviceId.isEmpty) return;

    final payload = ticket.entryPayloadFor(widget.deviceId);
    final period = ticket.qrPeriodSeconds ?? RotatingEntryPayloadCodec.defaultPeriodSeconds;
    final step = ticket.hasRotatingEntry
        ? RotatingEntryPayloadCodec.timeStepFor(qrPeriodSeconds: period)
        : null;
    final remaining = ticket.hasRotatingEntry
        ? RotatingEntryPayloadCodec.secondsRemainingInPeriod(qrPeriodSeconds: period)
        : 0;

    if (payload != null &&
        payload.isNotEmpty &&
        (payload != _payload || step != _lastStep || remaining != _secondsLeft)) {
      setState(() {
        _payload = payload;
        _lastStep = step;
        _secondsLeft = remaining;
      });
      _publishIfNeeded(force: true);
      _notifyQrFallback();
    } else if (remaining != _secondsLeft && ticket.hasRotatingEntry) {
      setState(() => _secondsLeft = remaining);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    unawaited(NfcEntryService.clearPayload());
    widget.onQrFallbackVisible(false);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ticket = widget.ticket;
    final payload = _payload;
    final status = _nfcStatus;

    if (_nfcPrimary) {
      return Column(
        children: [
          Container(
            height: 196,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.navy.withValues(alpha: 0.15)),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.nfc, size: 56, color: AppColors.navy.withValues(alpha: 0.85)),
                const SizedBox(height: 12),
                Text(
                  'Hold phone to reader',
                  style: AppTypography.cardTitle.copyWith(fontSize: 18),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 6),
                Text(
                  ticket.nfcHint ??
                      'Hold the top of your phone flat on the venue NFC reader until it beeps.',
                  textAlign: TextAlign.center,
                  style: AppTypography.bodyMuted.copyWith(fontSize: 12),
                ),
              ],
            ),
          ),
          if (status?.needsDefaultServiceHint == true) ...[
            const SizedBox(height: 8),
            Text(
              'If tap fails: Settings → NFC → Contactless payments → set Event Ticket as default for Other.',
              textAlign: TextAlign.center,
              style: AppTypography.bodyMuted.copyWith(fontSize: 11),
            ),
          ],
          if (ticket.hasRotatingEntry && _secondsLeft > 0) ...[
            const SizedBox(height: 8),
            Text(
              'Tap code refreshes in ${_secondsLeft}s',
              style: AppTypography.bodyMuted.copyWith(fontSize: 12),
            ),
          ],
          TextButton(
            onPressed: () {
              setState(() => _showQrBackup = true);
              _notifyQrFallback();
              unawaited(NfcEntryService.clearPayload());
            },
            child: const Text('Show QR backup'),
          ),
        ],
      );
    }

    return Column(
      children: [
        if (status != null && status.hardwareAvailable && !status.nfcEnabled) ...[
          Text(
            'NFC is off — enable it for tap entry, or use QR below.',
            textAlign: TextAlign.center,
            style: AppTypography.bodyMuted.copyWith(fontSize: 12),
          ),
          TextButton(
            onPressed: NfcEntryService.openNfcSettings,
            child: const Text('Open NFC settings'),
          ),
          const SizedBox(height: 4),
        ],
        if (payload != null)
          TicketQrView(key: ValueKey(payload), qrPayload: payload, size: widget.qrSize)
        else
          SizedBox(
            height: widget.qrSize,
            child: const Center(
              child: Icon(Icons.qr_code_2, size: 64, color: AppColors.outline),
            ),
          ),
        if (ticket.hasRotatingEntry && _secondsLeft > 0) ...[
          const SizedBox(height: 8),
          Text(
            'New code in ${_secondsLeft}s · rotates every ${ticket.qrPeriodSeconds ?? 30}s',
            textAlign: TextAlign.center,
            style: AppTypography.bodyMuted.copyWith(fontSize: 12),
          ),
        ],
        if (status != null && !status.hardwareAvailable) ...[
          const SizedBox(height: 6),
          Text(
            'This device has no NFC — use rotating QR at the gate.',
            textAlign: TextAlign.center,
            style: AppTypography.bodyMuted.copyWith(fontSize: 11),
          ),
        ],
        if (status != null && status.isReadyForTap && !_showQrBackup) ...[
          const SizedBox(height: 8),
          TextButton(
            onPressed: () {
              setState(() => _showQrBackup = false);
              _refreshNfcStatus();
              _notifyQrFallback();
              _publishIfNeeded(force: true);
            },
            child: const Text('Use NFC tap instead'),
          ),
        ],
      ],
    );
  }
}
