abstract class ApiConstants {
  // Use 10.0.2.2 for Android emulator → maps to host machine localhost.
  // For physical device: use your machine's local IP (e.g. http://192.168.x.x:8080)
static const String baseUrl = 'http://localhost:8080';
  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 15);

  // Endpoints
  static const String login = '/api/auth/login';
  static const String register = '/api/auth/register';
  static const String refreshToken = '/api/auth/refresh';
  static const String logout = '/api/auth/logout';
  static const String forgotPassword = '/api/auth/forgot-password';
  static const String verifyOtp = '/api/auth/verify-otp';
  static const String resetPassword = '/api/auth/reset-password';
}
