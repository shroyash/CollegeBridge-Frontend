import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:logger/logger.dart';

import '../../app/constants/api_constants.dart';
import 'auth_interceptor.dart';
import 'error_interceptor.dart';

/// Singleton-safe Dio wrapper with:
/// - JWT auth interceptor (attaches Bearer token from SecureStorage)
/// - Error interceptor (maps Dio errors → typed Failures)
/// - Auto-logout on 401 via [onUnauthorized] callback
class ApiClient {
  final Dio dio;
  final Logger logger;

  ApiClient({
    Dio? dioClient,
    Logger? customLogger,
    FlutterSecureStorage? secureStorage,
    void Function()? onUnauthorized,
  })  : dio = dioClient ??
            Dio(
              BaseOptions(
                baseUrl: ApiConstants.baseUrl,
                connectTimeout: ApiConstants.connectTimeout,
                receiveTimeout: ApiConstants.receiveTimeout,
                headers: {
                  'Accept': 'application/json',
                },
              ),
            ),
        logger = customLogger ?? Logger() {
    final storage = secureStorage ?? const FlutterSecureStorage();
    dio.interceptors.add(
      AuthInterceptor(storage: storage, onUnauthorized: onUnauthorized),
    );
    dio.interceptors.add(ErrorInterceptor());
    dio.interceptors.add(
      LogInterceptor(
        request: true,
        requestHeader: true,
        requestBody: true,
        responseHeader: false,
        responseBody: true,
        error: true,
        logPrint: (obj) => logger.d(obj.toString()),
      ),
    );
  }

  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return dio.get<T>(path, queryParameters: queryParameters, options: options);
  }

  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return dio.post<T>(path, data: data, queryParameters: queryParameters, options: options);
  }

  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Options? options,
  }) async {
    return dio.put<T>(path, data: data, options: options);
  }

  Future<Response<T>> delete<T>(
    String path, {
    Options? options,
  }) async {
    return dio.delete<T>(path, options: options);
  }

  // Legacy helpers — kept for backward compat with existing code
  void setAuthHeader(String token) {
    dio.options.headers['Authorization'] = 'Bearer $token';
  }

  void clearAuthHeader() {
    dio.options.headers.remove('Authorization');
  }
}
