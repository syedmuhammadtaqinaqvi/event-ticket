/// DonorHub Events public ticket API.
abstract final class ApiConfig {
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://api.donorhub.cloud',
  );

  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 30);

  static const lookupPath = '/api/events/public/tickets/lookup';
  static const claimPath = '/api/events/public/tickets/claim';
  static const deviceTicketsPath = '/api/events/public/device-tickets';
}
