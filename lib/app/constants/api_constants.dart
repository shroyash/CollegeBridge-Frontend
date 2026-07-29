abstract class ApiConstants {
  static const String baseUrl = 'http://localhost:8080'; // Configurable for backend
  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 15);

  // Endpoints
  static const String login = '/api/auth/login';
  static const String register = '/api/auth/register';
  static const String refreshToken = '/api/auth/refresh';
  static const String forgotPassword = '/api/auth/forgot-password';
}
