import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/services/device_id_service.dart';
import 'core/services/ticket_cache_service.dart';
import 'core/theme/app_theme.dart';
import 'data/datasources/donorhub_ticket_remote_datasource.dart';
import 'data/repositories/ticket_repository.dart';
import 'presentation/controllers/ticket_flow_controller.dart';
import 'presentation/screens/startup_loading_screen.dart';
import 'presentation/screens/ticket_portal_screen.dart';

class EventTicketApp extends StatefulWidget {
  const EventTicketApp({
    super.key,
    this.repository,
  });

  final TicketRepository? repository;

  @override
  State<EventTicketApp> createState() => _EventTicketAppState();
}

class _EventTicketAppState extends State<EventTicketApp> {
  TicketFlowController? _controller;

  @override
  void initState() {
    super.initState();
    unawaited(_init());
  }

  Future<void> _init() async {
    try {
      final repository = widget.repository ?? await _buildProductionRepository();
      final controller = TicketFlowController(repository);
      if (!mounted) return;
      setState(() => _controller = controller);
      unawaited(controller.bootstrap());
    } catch (e, st) {
      debugPrint('Startup init failed: $e\n$st');
    }
  }

  static Future<TicketRepository> _buildProductionRepository() async {
    final prefs = await SharedPreferences.getInstance();
    final deviceId = DeviceIdService(prefs);
    final cache = TicketCacheService(prefs);
    return TicketRepositoryImpl(
      remote: DonorHubTicketRemoteDataSource(),
      deviceIdService: deviceId,
      cacheService: cache,
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final home = _controller == null
        ? const StartupLoadingScreen()
        : TicketPortalScreen(controller: _controller!);

    return MaterialApp(
      title: 'Event Ticket',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: home,
    );
  }
}
