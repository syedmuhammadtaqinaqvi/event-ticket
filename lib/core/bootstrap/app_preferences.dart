import 'package:shared_preferences/shared_preferences.dart';

/// Started before [runApp] so the first frame is not blocked in [main].
abstract final class AppPreferences {
  static Future<SharedPreferences>? _future;

  static void warmUp() {
    _future ??= SharedPreferences.getInstance();
  }

  static Future<SharedPreferences> get instance {
    warmUp();
    return _future!;
  }
}
