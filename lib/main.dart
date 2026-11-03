import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app.dart';
import 'core/bootstrap/app_preferences.dart';
import 'core/theme/app_fonts.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarBrightness: Brightness.light,
      statusBarIconBrightness: Brightness.dark,
    ),
  );
  AppPreferences.warmUp();
  unawaited(AppFonts.ensureLoaded());
  runApp(const EventTicketApp());
}
