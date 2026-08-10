import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final secureStorageProvider = Provider<SecureStorageService>(
  (ref) => SecureStorageService(),
);

class SecureStorageService {
  final FlutterSecureStorage _storage;

  static String? _cachedAccessToken;
  static String? _cachedRefreshToken;
  static String? _cachedUserEmail;
  static String? _cachedUserName;
  static String? _cachedUserRole;

  static const String _keyAccessToken = 'auth_access_token';
  static const String _keyRefreshToken = 'auth_refresh_token';
  static const String _keyUserEmail = 'auth_user_email';
  static const String _keyUserName = 'auth_user_name';
  static const String _keyUserRole = 'auth_user_role';

  SecureStorageService({FlutterSecureStorage? storage})
      : _storage = storage ??
            const FlutterSecureStorage(
              aOptions: AndroidOptions(encryptedSharedPreferences: true),
              iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
            );

  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    _cachedAccessToken = accessToken;
    _cachedRefreshToken = refreshToken;
    await _storage.write(key: _keyAccessToken, value: accessToken);
    await _storage.write(key: _keyRefreshToken, value: refreshToken);
  }

  Future<String?> getAccessToken() async {
    if (_cachedAccessToken != null && _cachedAccessToken!.isNotEmpty) {
      return _cachedAccessToken;
    }
    final val = await _storage.read(key: _keyAccessToken);
    if (val != null) _cachedAccessToken = val;
    return val;
  }

  Future<String?> getRefreshToken() async {
    if (_cachedRefreshToken != null && _cachedRefreshToken!.isNotEmpty) {
      return _cachedRefreshToken;
    }
    final val = await _storage.read(key: _keyRefreshToken);
    if (val != null) _cachedRefreshToken = val;
    return val;
  }

  Future<void> saveUserEmail(String email) async {
    _cachedUserEmail = email;
    await _storage.write(key: _keyUserEmail, value: email);
  }

  Future<String?> getUserEmail() async {
    if (_cachedUserEmail != null) return _cachedUserEmail;
    final val = await _storage.read(key: _keyUserEmail);
    if (val != null) _cachedUserEmail = val;
    return val;
  }

  Future<void> saveUserName(String name) async {
    _cachedUserName = name;
    await _storage.write(key: _keyUserName, value: name);
  }

  Future<String?> getUserName() async {
    if (_cachedUserName != null) return _cachedUserName;
    final val = await _storage.read(key: _keyUserName);
    if (val != null) _cachedUserName = val;
    return val;
  }

  Future<void> saveUserRole(String role) async {
    _cachedUserRole = role;
    await _storage.write(key: _keyUserRole, value: role);
  }

  Future<String?> getUserRole() async {
    if (_cachedUserRole != null) return _cachedUserRole;
    final val = await _storage.read(key: _keyUserRole);
    if (val != null) _cachedUserRole = val;
    return val;
  }

  Future<void> clearAll() async {
    _cachedAccessToken = null;
    _cachedRefreshToken = null;
    _cachedUserEmail = null;
    _cachedUserName = null;
    _cachedUserRole = null;
    await _storage.deleteAll();
  }
}
