import 'package:dio/dio.dart';

import '../../../../app/constants/api_constants.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/storage/secure_storage_service.dart';
import '../../domain/entities/super_admin_models.dart';

class SuperAdminRemoteDataSource {
  final ApiClient _apiClient;
  final SecureStorageService _storage;

  const SuperAdminRemoteDataSource(this._apiClient, this._storage);

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
      403 => Exception('Super Admin permissions required.'),
      404 => Exception(msg.isNotEmpty ? msg : 'Resource not found.'),
      400 => Exception(msg.isNotEmpty ? msg : 'Invalid request.'),
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

  /// GET Dashboard stats (combines metric endpoints)
  Future<SuperAdminDashboardStats> getDashboardStats() async {
    try {
      final options = await _authOptions();

      final results = await Future.wait([
        _apiClient.get<Map<String, dynamic>>(ApiConstants.superAdminDashboardInstTotal, options: options),
        _apiClient.get<Map<String, dynamic>>(ApiConstants.superAdminDashboardInstPending, options: options),
        _apiClient.get<Map<String, dynamic>>(ApiConstants.superAdminDashboardInstActive, options: options),
        _apiClient.get<Map<String, dynamic>>(ApiConstants.superAdminDashboardInstSuspended, options: options),
        _apiClient.get<Map<String, dynamic>>(ApiConstants.superAdminDashboardUsersTotal, options: options),
        _apiClient.get<Map<String, dynamic>>(ApiConstants.superAdminDashboardUsersStudents, options: options),
        _apiClient.get<Map<String, dynamic>>(ApiConstants.superAdminDashboardUsersTeachers, options: options),
        _apiClient.get<Map<String, dynamic>>(ApiConstants.superAdminDashboardUsersAdmins, options: options),
      ]);

      int extractCount(Response<Map<String, dynamic>> res) {
        final data = res.data?['data'];
        if (data is int) return data;
        if (data is num) return data.toInt();
        return 0;
      }

      return SuperAdminDashboardStats(
        totalInstitutions: extractCount(results[0]),
        pendingInstitutions: extractCount(results[1]),
        activeInstitutions: extractCount(results[2]),
        suspendedInstitutions: extractCount(results[3]),
        totalUsers: extractCount(results[4]),
        totalStudents: extractCount(results[5]),
        totalTeachers: extractCount(results[6]),
        totalAdmins: extractCount(results[7]),
      );
    } on DioException catch (e) {
      throw _mapDioException(e);
    }
  }

  /// GET /api/super-admin/users
  Future<PaginatedResponse<SuperAdminUser>> getUsers({
    int page = 0,
    int size = 20,
    String? search,
    String? role,
    String? status,
    int? institutionId,
  }) async {
    try {
      final options = await _authOptions();
      final queryParams = <String, dynamic>{
        'page': page,
        'size': size,
      };
      if (search != null && search.trim().isNotEmpty) queryParams['search'] = search.trim();
      if (role != null && role.trim().isNotEmpty && role != 'ALL') queryParams['role'] = role.toUpperCase();
      if (status != null && status.trim().isNotEmpty && status != 'ALL') queryParams['status'] = status.toUpperCase();
      if (institutionId != null) queryParams['institutionId'] = institutionId;

      final response = await _apiClient.get<Map<String, dynamic>>(
        ApiConstants.superAdminUsers,
        queryParameters: queryParams,
        options: options,
      );

      final data = response.data!['data'] as Map<String, dynamic>;
      return PaginatedResponse<SuperAdminUser>.fromJson(data, SuperAdminUser.fromJson);
    } on DioException catch (e) {
      throw _mapDioException(e);
    }
  }

  /// GET /api/super-admin/admins
  Future<PaginatedResponse<SuperAdminUser>> getAdmins({
    int page = 0,
    int size = 20,
    String? search,
    String? status,
  }) async {
    try {
      final options = await _authOptions();
      final queryParams = <String, dynamic>{
        'page': page,
        'size': size,
      };
      if (search != null && search.trim().isNotEmpty) queryParams['search'] = search.trim();
      if (status != null && status.trim().isNotEmpty && status != 'ALL') queryParams['status'] = status.toUpperCase();

      final response = await _apiClient.get<Map<String, dynamic>>(
        ApiConstants.superAdminAdmins,
        queryParameters: queryParams,
        options: options,
      );

      final data = response.data!['data'] as Map<String, dynamic>;
      return PaginatedResponse<SuperAdminUser>.fromJson(data, SuperAdminUser.fromJson);
    } on DioException catch (e) {
      throw _mapDioException(e);
    }
  }

  /// GET /api/super-admin/institutions
  Future<PaginatedResponse<SuperAdminInstitution>> getInstitutions({
    int page = 0,
    int size = 20,
    String? search,
    String? status,
  }) async {
    try {
      final options = await _authOptions();
      final queryParams = <String, dynamic>{
        'page': page,
        'size': size,
      };
      if (search != null && search.trim().isNotEmpty) queryParams['search'] = search.trim();
      if (status != null && status.trim().isNotEmpty && status != 'ALL') queryParams['status'] = status.toUpperCase();

      final response = await _apiClient.get<Map<String, dynamic>>(
        ApiConstants.superAdminInstitutions,
        queryParameters: queryParams,
        options: options,
      );

      final data = response.data!['data'] as Map<String, dynamic>;
      return PaginatedResponse<SuperAdminInstitution>.fromJson(data, SuperAdminInstitution.fromJson);
    } on DioException catch (e) {
      throw _mapDioException(e);
    }
  }

  /// GET /api/super-admin/institutions/pending
  Future<PaginatedResponse<SuperAdminPendingInstitution>> getPendingInstitutions({
    int page = 0,
    int size = 20,
    String? search,
  }) async {
    try {
      final options = await _authOptions();
      final queryParams = <String, dynamic>{
        'page': page,
        'size': size,
      };
      if (search != null && search.trim().isNotEmpty) queryParams['search'] = search.trim();

      final response = await _apiClient.get<Map<String, dynamic>>(
        ApiConstants.superAdminInstitutionsPending,
        queryParameters: queryParams,
        options: options,
      );

      final data = response.data!['data'] as Map<String, dynamic>;
      return PaginatedResponse<SuperAdminPendingInstitution>.fromJson(data, SuperAdminPendingInstitution.fromJson);
    } on DioException catch (e) {
      throw _mapDioException(e);
    }
  }

  /// POST /api/super-admin/institutions/{id}/approve
  Future<void> approveInstitution(int id) async {
    try {
      final options = await _authOptions();
      await _apiClient.post<dynamic>(
        '${ApiConstants.superAdminInstitutions}/$id/approve',
        options: options,
      );
    } on DioException catch (e) {
      throw _mapDioException(e);
    }
  }

  /// POST /api/super-admin/institutions/{id}/reject
  Future<void> rejectInstitution(int id, String reason) async {
    try {
      final options = await _authOptions();
      await _apiClient.post<dynamic>(
        '${ApiConstants.superAdminInstitutions}/$id/reject',
        data: {'rejectionReason': reason},
        options: options,
      );
    } on DioException catch (e) {
      throw _mapDioException(e);
    }
  }

  /// POST /api/super-admin/institutions/{id}/suspend
  Future<void> suspendInstitution(int id) async {
    try {
      final options = await _authOptions();
      await _apiClient.post<dynamic>(
        '${ApiConstants.superAdminInstitutions}/$id/suspend',
        options: options,
      );
    } on DioException catch (e) {
      throw _mapDioException(e);
    }
  }

  /// POST /api/super-admin/institutions/{id}/reactivate
  Future<void> reactivateInstitution(int id) async {
    try {
      final options = await _authOptions();
      await _apiClient.post<dynamic>(
        '${ApiConstants.superAdminInstitutions}/$id/reactivate',
        options: options,
      );
    } on DioException catch (e) {
      throw _mapDioException(e);
    }
  }

  /// POST /api/super-admin/users/{id}/suspend
  Future<void> suspendUser(int id) async {
    try {
      final options = await _authOptions();
      await _apiClient.post<dynamic>(
        '${ApiConstants.superAdminUsers}/$id/suspend',
        options: options,
      );
    } on DioException catch (e) {
      throw _mapDioException(e);
    }
  }

  /// POST /api/super-admin/users/{id}/activate
  Future<void> activateUser(int id) async {
    try {
      final options = await _authOptions();
      await _apiClient.post<dynamic>(
        '${ApiConstants.superAdminUsers}/$id/activate',
        options: options,
      );
    } on DioException catch (e) {
      throw _mapDioException(e);
    }
  }
}
