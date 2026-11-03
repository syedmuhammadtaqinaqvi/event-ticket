import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'stable_device_id_resolver.dart';

/// Stable device id for DonorHub claim APIs (max 128 chars).
class DeviceIdService {
  DeviceIdService(
    this._prefs, {
    FlutterSecureStorage? secureStorage,
  }) : _secure = secureStorage ?? const FlutterSecureStorage();

  final SharedPreferences _prefs;
  final FlutterSecureStorage _secure;

  String _resolvedId = '';
  bool _isReady = false;

  bool get isReady => _isReady && _resolvedId.isNotEmpty;

  /// Must complete before [id] is read for API calls.
  Future<void> warmUp() async {
    if (_isReady) return;
    _resolvedId = await StableDeviceIdResolver.resolve(
      prefs: _prefs,
      secureStorage: _secure,
    );
    _isReady = true;
  }

  String get id {
    if (!_isReady || _resolvedId.isEmpty) {
      throw StateError('DeviceIdService.warmUp() must complete before reading id');
    }
    return _resolvedId;
  }

  String get displayLabel {
    final value = isReady ? _resolvedId : '…';
    if (value.length <= 12) return value;
    return '${value.substring(0, 8)}…${value.substring(value.length - 4)}';
  }
}
