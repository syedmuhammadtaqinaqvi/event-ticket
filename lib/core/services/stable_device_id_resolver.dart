import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

/// Resolves a DonorHub [deviceId] (max 128 chars) that survives reinstall where possible.
class StableDeviceIdResolver {
  StableDeviceIdResolver._();

  static const maxLength = 128;
  static const prefsKey = 'donorhub_device_id';
  static const keychainKey = 'donorhub_install_device_id';

  /// Upgrade-safe: existing prefs id wins. Fresh install uses ANDROID_ID (Android) or Keychain UUID (iOS).
  static Future<String> resolve({
    required SharedPreferences prefs,
    FlutterSecureStorage? secureStorage,
    DeviceInfoPlugin? deviceInfo,
    String? androidIdOverride,
    String? iosKeychainOverride,
  }) async {
    final existing = prefs.getString(prefsKey);
    if (existing != null && existing.trim().isNotEmpty) {
      final id = clampDeviceId(existing.trim());
      if (!kIsWeb && defaultTargetPlatform == TargetPlatform.iOS && iosKeychainOverride == null) {
        final secure = secureStorage ?? const FlutterSecureStorage();
        final fromKeychain = await secure.read(key: keychainKey);
        if (fromKeychain == null || fromKeychain.trim().isEmpty) {
          await secure.write(key: keychainKey, value: id);
        }
      }
      return id;
    }

    final secure = secureStorage ?? const FlutterSecureStorage();
    final info = deviceInfo ?? DeviceInfoPlugin();

    String candidate;
    if (androidIdOverride != null) {
      candidate = androidIdOverride;
    } else if (iosKeychainOverride != null) {
      candidate = iosKeychainOverride;
    } else if (kIsWeb) {
      candidate = const Uuid().v4();
    } else if (defaultTargetPlatform == TargetPlatform.android) {
      final android = await info.androidInfo;
      candidate = android.id;
      if (candidate.trim().isEmpty) {
        candidate = const Uuid().v4();
      }
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      final fromKeychain = await secure.read(key: keychainKey);
      if (fromKeychain != null && fromKeychain.trim().isNotEmpty) {
        candidate = fromKeychain.trim();
      } else {
        candidate = const Uuid().v4();
        await secure.write(key: keychainKey, value: candidate);
      }
    } else {
      candidate = const Uuid().v4();
    }

    final id = clampDeviceId(candidate);
    await prefs.setString(prefsKey, id);
    if (defaultTargetPlatform == TargetPlatform.iOS && iosKeychainOverride == null) {
      await secure.write(key: keychainKey, value: id);
    }
    return id;
  }

  static String clampDeviceId(String value) {
    final trimmed = value.trim();
    if (trimmed.length <= maxLength) return trimmed;
    return trimmed.substring(0, maxLength);
  }
}
