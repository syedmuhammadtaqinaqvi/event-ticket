enum TicketFlowState {
  lookup,
  ticketFound,
  deviceReg,
  qrActive,
  error,
}

extension TicketFlowStateX on TicketFlowState {
  String get pillId {
    return switch (this) {
      TicketFlowState.lookup => 'lookup',
      TicketFlowState.ticketFound => 'ticket-found',
      TicketFlowState.deviceReg => 'device-reg',
      TicketFlowState.qrActive => 'qr-active',
      TicketFlowState.error => 'error',
    };
  }

  static TicketFlowState? fromPillId(String id) {
    return switch (id) {
      'lookup' => TicketFlowState.lookup,
      'ticket-found' => TicketFlowState.ticketFound,
      'device-reg' => TicketFlowState.deviceReg,
      'qr-active' => TicketFlowState.qrActive,
      'error' => TicketFlowState.error,
      _ => null,
    };
  }
}
