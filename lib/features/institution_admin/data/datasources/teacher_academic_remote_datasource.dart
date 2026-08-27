import 'package:dio/dio.dart';

import '../../../../app/constants/api_constants.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/storage/secure_storage_service.dart';
import '../../../institution_admin/data/models/academic_class_model.dart';
import '../../../institution_admin/data/models/class_detail_model.dart';

class TeacherAcademicRemoteDataSource {
  final ApiClient _apiClient;
  final SecureStorageService _storage;

  const TeacherAcademicRemoteDataSource(this._apiClient, this._storage);

  Future<Options> _authOptions() async {
    final token = await _storage.getAccessToken();
    return Options(headers: {'Authorization': 'Bearer $token'});
  }

  Exception _mapDioError(DioException e) {
    final code = e.response?.statusCode;
    if (code == 401) return Exception('Session expired. Please log in again.');
    if (code == 403) return Exception('You are not authorised to access this class.');
    if (code == 404) return Exception('Class not found.');
    return Exception('Something went wrong. Please try again.');
  }

  /// GET /api/v1/teacher/academic/my-classes
  Future<List<AcademicClassModel>> fetchMyClasses() async {
    try {
      final options = await _authOptions();
      final response = await _apiClient.get<Map<String, dynamic>>(
        ApiConstants.teacherMyClasses,
        options: options,
      );
      final data = response.data!['data'] as List<dynamic>;
      return data
          .map((e) => AcademicClassModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  /// GET /api/v1/teacher/academic/classes/{classId}/details
  Future<ClassDetailModel> fetchClassDetails(int classId) async {
    try {
      final options = await _authOptions();
      final response = await _apiClient.get<Map<String, dynamic>>(
        '${ApiConstants.teacherClassDetails}/$classId/details',
        options: options,
      );
      final data = response.data!['data'] as Map<String, dynamic>;
      return ClassDetailModel.fromJson(data);
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }
}
