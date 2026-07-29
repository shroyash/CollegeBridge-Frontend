import 'package:dio/dio.dart';
import 'package:logger/logger.dart';

import '../../app/constants/api_constants.dart';
import 'error_interceptor.dart';

class ApiClient {
  final Dio dio;
  final Logger logger;

  ApiClient({Dio? dioClient, Logger? customLogger})
      : dio = dioClient ??
            Dio(
              BaseOptions(
                baseUrl: ApiConstants.baseUrl,
                connectTimeout: ApiConstants.connectTimeout,
                receiveTimeout: ApiConstants.receiveTimeout,
                headers: {
                  'Content-Type': 'application/json',
                  'Accept': 'application/json',
                },
              ),
            ),
        logger = customLogger ?? Logger() {
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

  void setAuthHeader(String token) {
    dio.options.headers['Authorization'] = 'Bearer $token';
  }

  void clearAuthHeader() {
    dio.options.headers.remove('Authorization');
  }
}
