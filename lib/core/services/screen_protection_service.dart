import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Blocks OS screenshots on Android (FLAG_SECURE) while the door QR is visible.
class ScreenProtectionService {
  ScreenProtectionService._();

  static const _channel = MethodChannel('com.eventpass.event_ticket/screen_secure');

  static var _active = false;

  static Future<void> setEnabled(bool enabled) async {
    if (kIsWeb) return;
    if (enabled) {
      await enable();
    } else {
      await disable();
    }
  }

  static Future<void> enable() async {
    if (kIsWeb || _active) return;
    if (defaultTargetPlatform != TargetPlatform.android) {
      return;
    }
    try {
      await _channel.invokeMethod<void>('enable');
      _active = true;
    } catch (_) {
      // Tests / unsupported embedders.
    }
  }

  static Future<void> disable() async {
    if (kIsWeb || !_active) return;
    if (defaultTargetPlatform != TargetPlatform.android) {
      _active = false;
      return;
    }
    try {
      await _channel.invokeMethod<void>('disable');
    } catch (_) {}
    _active = false;
  }
}
