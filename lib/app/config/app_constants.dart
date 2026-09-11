abstract final class AppConstants {
  static const appName = 'Pillmo';
  static const apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://127.0.0.1:8080/api/v1',
  );
}
