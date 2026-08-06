import 'package:dio/dio.dart';

import '../../../../app/constants/api_constants.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/storage/secure_storage_service.dart';
import '../../../dashboard/data/models/subject_model.dart';
import '../models/teacher_assignment_model.dart';
import '../models/user_profile_model.dart';

class AdminUserRemoteDataSource {
  final ApiClient _apiClient;
  final SecureStorageService _storage;

  const AdminUserRemoteDataSource(this._apiClient, this._storage);

  Future<Options> _authOptions() async {
    final token = await _storage.getAccessToken();
    return Options(
      headers: {'Authorization': 'Bearer $token'},
    );
  }

  Exception _mapDioException(DioException e) {
    final statusCode = e.response?.statusCode;
    final msg = _extractMessage(e);
    return switch (statusCode) {
      401 => Exception('Session expired. Please log in again.'),
      403 => Exception('You do not have permission to perform this action.'),
      404 => Exception(msg.isNotEmpty ? msg : 'Resource not found.'),
      400 => Exception(msg.isNotEmpty ? msg : 'Invalid input request.'),
      500 => Exception('Server error. Please try again later.'),
      _ => Exception(
          e.type == DioExceptionType.connectionTimeout ||
                  e.type == DioExceptionType.receiveTimeout
              ? 'Connection timeout. Check your network.'
              : msg.isNotEmpty
                  ? msg
                  : 'Something went wrong.',
        ),
    };
  }

  String _extractMessage(DioException e) {
    try {
      final data = e.response?.data;
      if (data is Map<String, dynamic>) {
        return data['message'] as String? ?? '';
      }
    } catch (_) {}
    return '';
  }

  /// GET /api/admin/users/filter?role={role}&status={status}&page={page}&size={size}
  Future<List<UserProfileModel>> filterUsers({
    required String role,
    required String status,
    int page = 0,
    int size = 20,
  }) async {
    try {
      final options = await _authOptions();
      final response = await _apiClient.get<Map<String, dynamic>>(
        ApiConstants.adminUsersFilter,
        queryParameters: {
          'role': role.toUpperCase(),
          'status': status.toUpperCase(),
          'page': page,
          'size': size,
        },
        options: options,
      );

      final data = response.data!['data'] as Map<String, dynamic>;
      final content = data['content'] as List<dynamic>;
      return content
          .map((e) => UserProfileModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _mapDioException(e);
    }
  }

  /// GET /api/admin/users/search?q={query}&page={page}&size={size}
  Future<List<UserProfileModel>> searchUsers({
    required String query,
    int page = 0,
    int size = 20,
  }) async {
    try {
      final options = await _authOptions();
      final response = await _apiClient.get<Map<String, dynamic>>(
        ApiConstants.adminUsersSearch,
        queryParameters: {
          'q': query,
          'page': page,
          'size': size,
        },
        options: options,
      );

      final data = response.data!['data'] as Map<String, dynamic>;
      final content = data['content'] as List<dynamic>;
      return content
          .map((e) => UserProfileModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _mapDioException(e);
    }
  }

  /// POST /api/admin/users/{id}/suspend
  Future<void> suspendUser(int userId) async {
    try {
      final options = await _authOptions();
      await _apiClient.post<dynamic>(
        '${ApiConstants.adminUsers}/$userId/suspend',
        options: options,
      );
    } on DioException catch (e) {
      throw _mapDioException(e);
    }
  }

  /// POST /api/admin/users/{id}/activate
  Future<void> activateUser(int userId) async {
    try {
      final options = await _authOptions();
      await _apiClient.post<dynamic>(
        '${ApiConstants.adminUsers}/$userId/activate',
        options: options,
      );
    } on DioException catch (e) {
      throw _mapDioException(e);
    }
  }

  /// POST /api/admin/teachers
  Future<void> registerTeacher({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final options = await _authOptions();
      await _apiClient.post<Map<String, dynamic>>(
        ApiConstants.adminTeachers,
        data: {
          'name': name,
          'email': email,
          'password': password,
        },
        options: options,
      );
    } on DioException catch (e) {
      throw _mapDioException(e);
    }
  }

  /// GET /api/v1/admin/teachers/{teacherId}/subject-assignments
  Future<List<TeacherAssignmentModel>> getTeacherAssignments(int teacherId) async {
    try {
      final options = await _authOptions();
      final response = await _apiClient.get<Map<String, dynamic>>(
        '${ApiConstants.adminTeacherAssignments}/$teacherId/subject-assignments',
        options: options,
      );

      final data = response.data!['data'] as List<dynamic>;
      return data
          .map((e) => TeacherAssignmentModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _mapDioException(e);
    }
  }

  /// PUT /api/v1/admin/teachers/{teacherId}/subject-assignments
  Future<List<TeacherAssignmentModel>> replaceTeacherAssignments(
    int teacherId,
    List<int> subjectIds,
  ) async {
    try {
      final options = await _authOptions();
      final response = await _apiClient.dio.put<Map<String, dynamic>>(
        '${ApiConstants.adminTeacherAssignments}/$teacherId/subject-assignments',
        data: {'subjectIds': subjectIds},
        options: options,
      );

      final data = response.data!['data'] as List<dynamic>;
      return data
          .map((e) => TeacherAssignmentModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _mapDioException(e);
    }
  }

  /// GET /api/academic/subjects/student/{studentId}
  Future<List<SubjectModel>> getStudentSubjects(int studentId) async {
    try {
      final options = await _authOptions();
      final response = await _apiClient.get<List<dynamic>>(
        '${ApiConstants.academicStudentSubjects}/$studentId',
        options: options,
      );

      return (response.data as List<dynamic>)
          .map((e) => SubjectModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _mapDioException(e);
    }
  }

  /// GET /api/academic/subjects/all
  Future<List<SubjectModel>> getAllSubjects() async {
    try {
      final options = await _authOptions();
      final response = await _apiClient.get<List<dynamic>>(
        ApiConstants.academicSubjectsAll,
        options: options,
      );

      return (response.data as List<dynamic>)
          .map((e) => SubjectModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _mapDioException(e);
    }
  }

  /// GET /api/academic/subjects/search?name={name}
  Future<List<SubjectModel>> searchSubjects(String name) async {
    try {
      final options = await _authOptions();
      final response = await _apiClient.get<List<dynamic>>(
        ApiConstants.academicSubjectsSearch,
        queryParameters: {'name': name},
        options: options,
      );

      return (response.data as List<dynamic>)
          .map((e) => SubjectModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _mapDioException(e);
    }
  }
}
