import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Intercepts every outgoing request and attaches the Bearer token from
/// secure storage. Also handles 401 responses by calling [onUnauthorized]
/// to trigger a global logout.
class AuthInterceptor extends Interceptor {
  final FlutterSecureStorage _storage;
  final void Function()? onUnauthorized;

  static const _keyAccessToken = 'auth_access_token';

  AuthInterceptor({
    required FlutterSecureStorage storage,
    this.onUnauthorized,
  }) : _storage = storage;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Don't attach tokens to public endpoints
    final isPublic = _isPublicPath(options.path);
    if (!isPublic) {
      final token = await _storage.read(key: _keyAccessToken);
      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 401) {
      // Token expired or invalid — trigger global logout
      onUnauthorized?.call();
    }
    handler.next(err);
  }

  bool _isPublicPath(String path) {
    const publicPaths = [
      '/api/auth/login',
      '/api/auth/register',
      '/api/auth/forgot-password',
      '/api/auth/verify-otp',
      '/api/auth/reset-password',
      '/api/auth/refresh',
      '/api/institutions/register',
    ];
    return publicPaths.any((p) => path.contains(p));
  }
}
