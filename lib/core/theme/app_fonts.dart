import 'package:flutter/painting.dart';
import 'package:google_fonts/google_fonts.dart';

/// Preloads typography used across the app so first screens do not block on network.
abstract final class AppFonts {
  static Future<void>? _loadFuture;

  static Future<void> ensureLoaded() {
    return _loadFuture ??= _load();
  }

  static void preload() {
    ensureLoaded();
  }

  static Future<void> _load() async {
    await GoogleFonts.pendingFonts([
      for (final weight in [
        FontWeight.w500,
        FontWeight.w600,
        FontWeight.w700,
        FontWeight.w800,
      ])
        GoogleFonts.plusJakartaSans(fontWeight: weight),
      GoogleFonts.jetBrainsMono(fontWeight: FontWeight.w500),
    ]);
  }
}
