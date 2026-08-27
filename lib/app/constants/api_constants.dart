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

  // Institution Registration (public)
  static const String institutionRegister = '/api/auth/register-institution';

  // Super Admin — Dashboard Metrics
  static const String superAdminDashboardInstTotal = '/api/super-admin/dashboard/institutions/total';
  static const String superAdminDashboardInstPending = '/api/super-admin/dashboard/institutions/pending';
  static const String superAdminDashboardInstActive = '/api/super-admin/dashboard/institutions/active';
  static const String superAdminDashboardInstSuspended = '/api/super-admin/dashboard/institutions/suspended';
  static const String superAdminDashboardUsersTotal = '/api/super-admin/dashboard/users/total';
  static const String superAdminDashboardUsersStudents = '/api/super-admin/dashboard/users/students';
  static const String superAdminDashboardUsersTeachers = '/api/super-admin/dashboard/users/teachers';
  static const String superAdminDashboardUsersAdmins = '/api/super-admin/dashboard/users/admins';

  // Super Admin — Institution & User Management
  static const String superAdminInstitutionsPending = '/api/super-admin/institutions/pending';
  static const String superAdminInstitutions = '/api/super-admin/institutions';
  static const String superAdminUsers = '/api/super-admin/users';
  static const String superAdminAdmins = '/api/super-admin/admins';

  // Dashboard
  static const String adminDashboard = '/api/admin/dashboard';

  // Admin Users & Teachers
  static const String adminUsersFilter = '/api/admin/users/filter';
  static const String adminUsersSearch = '/api/admin/users/search';
  static const String adminUsers = '/api/admin/users';
  static const String adminTeachers = '/api/admin/teachers';
  static const String adminTeacherAssignments = '/api/v1/admin/teachers';
  static const String adminStudents = '/api/admin/students';
  static const String adminStudentsFilterOptions = '/api/admin/students/filter-options';
  static const String adminStudentsBulkTransfer = '/api/admin/students/bulk-transfer';

  // Academic
  static const String mySubjects = '/api/academic/subjects/my-subjects';
  static const String academicSubjectsAll = '/api/academic/subjects/all';
  static const String academicSubjectsSearch = '/api/academic/subjects/search';
  static const String academicStudentSubjects = '/api/academic/subjects/student';

  // Admin Academic Management
  static const String adminAcademicFaculties = '/api/admin/academic/faculties';
  static const String adminAcademicClasses = '/api/admin/academic/classes';
  static const String adminAcademicSubjects = '/api/admin/academic/subjects';
  static const String adminAcademicSubjectsBatch = '/api/admin/academic/subjects/batch';

  // Teacher Academic
  static const String teacherMyClasses = '/api/v1/teacher/academic/my-classes';
  static const String teacherClassDetails = '/api/v1/teacher/academic/classes'; // + /{classId}/details

  // Student Academic
  static const String studentClassDetails = '/api/v1/student/academic/class-details';
}
