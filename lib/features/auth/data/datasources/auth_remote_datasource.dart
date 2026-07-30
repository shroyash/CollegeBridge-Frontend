import 'package:dio/dio.dart';

import '../../../../app/constants/api_constants.dart';
import '../../../../core/network/api_client.dart';
import '../../domain/entities/faculty.dart';
import '../models/auth_user_model.dart';

/// Handles all remote HTTP calls for the auth feature.
/// Wraps ApiClient (Dio) and maps raw JSON to AuthUserModel.
class AuthRemoteDataSource {
  final ApiClient _apiClient;

  const AuthRemoteDataSource(this._apiClient);

  /// POST /api/auth/login
  Future<AuthUserModel> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _apiClient.post<Map<String, dynamic>>(
        ApiConstants.login,
        data: {'email': email, 'password': password},
      );
      // Backend wraps payload in ApiResponse: { success, message, data }
      final data = response.data!['data'] as Map<String, dynamic>;
      return AuthUserModel.fromJson(data);
    } on DioException catch (e) {
      throw _mapDioException(e);
    }
  }

  /// POST /api/auth/register
  Future<AuthUserModel> register({
    required String name,
    required String email,
    required String password,
    required Faculty faculty,
    required int semester,
  }) async {
    try {
      final response = await _apiClient.post<Map<String, dynamic>>(
        ApiConstants.register,
        data: {
          'name': name,
          'email': email,
          'password': password,
          'faculty': faculty.value,
          'semester': semester,
        },
      );
      final data = response.data!['data'] as Map<String, dynamic>;
      return AuthUserModel.fromJson(data);
    } on DioException catch (e) {
      throw _mapDioException(e);
    }
  }

  /// POST /api/auth/logout
  Future<void> logout({required String refreshToken}) async {
    try {
      await _apiClient.post<dynamic>(
        ApiConstants.logout,
        data: {'refreshToken': refreshToken},
      );
    } on DioException catch (e) {
      throw _mapDioException(e);
    }
  }

  Exception _mapDioException(DioException e) {
    final statusCode = e.response?.statusCode;
    final message = _extractMessage(e);
    return switch (statusCode) {
      400 => Exception(message.isNotEmpty ? message : 'Invalid request.'),
      401 => Exception('Invalid credentials. Please try again.'),
      409 => Exception('An account with this email already exists.'),
      500 => Exception('Server error. Please try again later.'),
      _ => Exception(
          e.type == DioExceptionType.connectionTimeout ||
                  e.type == DioExceptionType.receiveTimeout
              ? 'Connection timeout. Check your network.'
              : message.isNotEmpty
                  ? message
                  : 'Something went wrong.',
        ),
    };
  }

  String _extractMessage(DioException e) {
    try {
      final responseData = e.response?.data;
      if (responseData is Map<String, dynamic>) {
        return responseData['message'] as String? ?? '';
      }
    } catch (_) {}
    return '';
  }
}
