import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

/// Stable device id for DonorHub claim APIs (max 128 chars).
class DeviceIdService {
  DeviceIdService(this._prefs);

  static const _storageKey = 'donorhub_device_id';

  final SharedPreferences _prefs;

  String get id {
    final existing = _prefs.getString(_storageKey);
    if (existing != null && existing.isNotEmpty) {
      return existing;
    }
    final generated = const Uuid().v4();
    _prefs.setString(_storageKey, generated);
    return generated;
  }

  String get displayLabel {
    final value = id;
    if (value.length <= 12) return value;
    return '${value.substring(0, 8)}…${value.substring(value.length - 4)}';
  }
}
