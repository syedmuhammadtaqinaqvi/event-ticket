import 'package:event_ticket/core/services/stable_device_id_resolver.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('StableDeviceIdResolver', () {
    test('keeps existing prefs device id on upgrade', () async {
      SharedPreferences.setMockInitialValues({
        StableDeviceIdResolver.prefsKey: 'existing-bound-id-12345',
      });
      final prefs = await SharedPreferences.getInstance();

      final id = await StableDeviceIdResolver.resolve(
        prefs: prefs,
        androidIdOverride: 'should-not-be-used',
      );

      expect(id, 'existing-bound-id-12345');
    });

    test('uses android id on fresh install and persists to prefs', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      const androidId = 'a1b2c3d4e5f67890';
      final id = await StableDeviceIdResolver.resolve(
        prefs: prefs,
        androidIdOverride: androidId,
      );

      expect(id, androidId);
      expect(prefs.getString(StableDeviceIdResolver.prefsKey), androidId);
    });

    test('clampDeviceId enforces 128 char max', () {
      final long = 'x' * 200;
      expect(StableDeviceIdResolver.clampDeviceId(long).length, 128);
    });

  });
}
