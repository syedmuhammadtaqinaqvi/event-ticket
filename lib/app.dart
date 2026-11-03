import 'dart:async';

import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'data/repositories/lazy_ticket_repository.dart';
import 'data/repositories/ticket_repository.dart';
import 'presentation/controllers/ticket_flow_controller.dart';
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
  late final TicketFlowController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TicketFlowController(
      widget.repository ?? LazyTicketRepository(),
    );
    unawaited(_controller.bootstrap());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Event Ticket',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: TicketPortalScreen(controller: _controller),
    );
  }
}
