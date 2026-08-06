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

  // Dashboard
  static const String adminDashboard = '/api/admin/dashboard';

  // Admin Users & Teachers
  static const String adminUsersFilter = '/api/admin/users/filter';
  static const String adminUsersSearch = '/api/admin/users/search';
  static const String adminUsers = '/api/admin/users';
  static const String adminTeachers = '/api/admin/teachers';
  static const String adminTeacherAssignments = '/api/v1/admin/teachers';

  // Academic
  static const String mySubjects = '/api/academic/subjects/my-subjects';
  static const String academicSubjectsAll = '/api/academic/subjects/all';
  static const String academicSubjectsSearch = '/api/academic/subjects/search';
  static const String academicStudentSubjects = '/api/academic/subjects/student';
}
