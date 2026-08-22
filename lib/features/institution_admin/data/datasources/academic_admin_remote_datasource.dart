import 'package:dio/dio.dart';

import '../../../../app/constants/api_constants.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/storage/secure_storage_service.dart';
import '../../../dashboard/data/models/subject_model.dart';
import '../models/academic_class_model.dart';

class AcademicAdminRemoteDataSource {
  final ApiClient _apiClient;
  final SecureStorageService _storage;

  const AcademicAdminRemoteDataSource(this._apiClient, this._storage);

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
      409 => Exception(msg.isNotEmpty ? msg : 'Resource already exists.'),
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

  /// GET /api/admin/academic/faculties
  Future<List<String>> getSupportedFaculties() async {
    try {
      final options = await _authOptions();
      final response = await _apiClient.get<Map<String, dynamic>>(
        ApiConstants.adminAcademicFaculties,
        options: options,
      );

      final data = response.data?['data'];
      if (data is List) {
        return data.map((e) => e.toString()).toList();
      }
      return ['BCA', 'BBA', 'BSC_CSIT', 'BIM', 'BHM'];
    } on DioException catch (e) {
      throw _mapDioException(e);
    }
  }

  /// GET /api/admin/academic/classes
  Future<List<AcademicClassModel>> getAcademicClasses() async {
    try {
      final options = await _authOptions();
      final response = await _apiClient.get<Map<String, dynamic>>(
        ApiConstants.adminAcademicClasses,
        options: options,
      );

      final data = response.data?['data'];
      if (data is List) {
        return data
            .map((e) => AcademicClassModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      return [];
    } on DioException catch (e) {
      throw _mapDioException(e);
    }
  }

  /// POST /api/admin/academic/classes
  Future<AcademicClassModel> createAcademicClass({
    required String faculty,
    required int semester,
    String? displayName,
  }) async {
    try {
      final options = await _authOptions();
      final response = await _apiClient.post<Map<String, dynamic>>(
        ApiConstants.adminAcademicClasses,
        data: {
          'faculty': faculty,
          'semester': semester,
          if (displayName != null && displayName.isNotEmpty)
            'displayName': displayName,
        },
        options: options,
      );

      final data = response.data?['data'] as Map<String, dynamic>? ?? {};
      return AcademicClassModel.fromJson(data);
    } on DioException catch (e) {
      throw _mapDioException(e);
    }
  }

  /// GET /api/admin/academic/subjects?faculty={faculty}&semester={semester}
  Future<List<SubjectModel>> getSubjects({
    String? faculty,
    int? semester,
  }) async {
    try {
      final options = await _authOptions();
      final queryParams = <String, dynamic>{};
      if (faculty != null && faculty.isNotEmpty) {
        queryParams['faculty'] = faculty;
      }
      if (semester != null) {
        queryParams['semester'] = semester;
      }

      final response = await _apiClient.get<Map<String, dynamic>>(
        ApiConstants.adminAcademicSubjects,
        queryParameters: queryParams,
        options: options,
      );

      final data = response.data?['data'];
      if (data is List) {
        return data
            .map((e) => SubjectModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      return [];
    } on DioException catch (e) {
      throw _mapDioException(e);
    }
  }

  /// POST /api/admin/academic/subjects
  Future<SubjectModel> createSubject({
    required String name,
    required String faculty,
    required int semester,
    required int creditHours,
  }) async {
    try {
      final options = await _authOptions();
      final response = await _apiClient.post<Map<String, dynamic>>(
        ApiConstants.adminAcademicSubjects,
        data: {
          'name': name,
          'faculty': faculty,
          'semester': semester,
          'creditHours': creditHours,
        },
        options: options,
      );

      final data = response.data?['data'] as Map<String, dynamic>? ?? {};
      return SubjectModel.fromJson(data);
    } on DioException catch (e) {
      throw _mapDioException(e);
    }
  }

  /// POST /api/admin/academic/subjects/batch
  Future<List<SubjectModel>> batchCreateSubjects({
    required String faculty,
    required int semester,
    required List<Map<String, dynamic>> subjects,
  }) async {
    try {
      final options = await _authOptions();
      final response = await _apiClient.post<Map<String, dynamic>>(
        ApiConstants.adminAcademicSubjectsBatch,
        data: {
          'faculty': faculty,
          'semester': semester,
          'subjects': subjects,
        },
        options: options,
      );

      final data = response.data?['data'];
      if (data is List) {
        return data
            .map((e) => SubjectModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      return [];
    } on DioException catch (e) {
      throw _mapDioException(e);
    }
  }

  /// PUT /api/admin/academic/classes/{classId}
  Future<AcademicClassModel> updateAcademicClass({
    required int classId,
    required String faculty,
    required int semester,
    String? displayName,
  }) async {
    try {
      final options = await _authOptions();
      final response = await _apiClient.dio.put<Map<String, dynamic>>(
        '${ApiConstants.adminAcademicClasses}/$classId',
        data: {
          'faculty': faculty,
          'semester': semester,
          if (displayName != null && displayName.isNotEmpty)
            'displayName': displayName,
        },
        options: options,
      );

      final data = response.data?['data'] as Map<String, dynamic>? ?? {};
      return AcademicClassModel.fromJson(data);
    } on DioException catch (e) {
      throw _mapDioException(e);
    }
  }

  /// PUT /api/admin/academic/subjects/{subjectId}
  Future<SubjectModel> updateSubject({
    required int subjectId,
    required String name,
    required String faculty,
    required int semester,
    required int creditHours,
  }) async {
    try {
      final options = await _authOptions();
      final response = await _apiClient.dio.put<Map<String, dynamic>>(
        '${ApiConstants.adminAcademicSubjects}/$subjectId',
        data: {
          'name': name,
          'faculty': faculty,
          'semester': semester,
          'creditHours': creditHours,
        },
        options: options,
      );

      final data = response.data?['data'] as Map<String, dynamic>? ?? {};
      return SubjectModel.fromJson(data);
    } on DioException catch (e) {
      throw _mapDioException(e);
    }
  }

  /// DELETE /api/admin/academic/subjects/{subjectId}
  Future<void> deleteSubject(int subjectId) async {
    try {
      final options = await _authOptions();
      await _apiClient.dio.delete<dynamic>(
        '${ApiConstants.adminAcademicSubjects}/$subjectId',
        options: options,
      );
    } on DioException catch (e) {
      throw _mapDioException(e);
    }
  }
}
