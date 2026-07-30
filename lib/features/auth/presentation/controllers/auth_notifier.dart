import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/storage/secure_storage_service.dart';
import '../../domain/entities/faculty.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/register_usecase.dart';
import 'auth_state.dart';

/// StateNotifier for auth — orchestrates login/register flows.
/// Saves tokens to SecureStorage on success.
class AuthNotifier extends StateNotifier<AuthState> {
  final LoginUseCase _loginUseCase;
  final RegisterUseCase _registerUseCase;
  final SecureStorageService _storageService;

  AuthNotifier({
    required LoginUseCase loginUseCase,
    required RegisterUseCase registerUseCase,
    required SecureStorageService storageService,
  })  : _loginUseCase = loginUseCase,
        _registerUseCase = registerUseCase,
        _storageService = storageService,
        super(const AuthInitial());

  Future<void> login({
    required String email,
    required String password,
  }) async {
    state = const AuthLoading();
    try {
      final user = await _loginUseCase(email: email, password: password);
      await _storageService.saveTokens(
        accessToken: user.accessToken,
        refreshToken: user.refreshToken,
      );
      await _storageService.saveUserEmail(user.email);
      state = AuthSuccess(user);
    } catch (e) {
      state = AuthFailure(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  Future<void> register({
    required String name,
    required String email,
    required String password,
    required Faculty faculty,
    required int semester,
  }) async {
    state = const AuthLoading();
    try {
      final user = await _registerUseCase(
        name: name,
        email: email,
        password: password,
        faculty: faculty,
        semester: semester,
      );
      await _storageService.saveTokens(
        accessToken: user.accessToken,
        refreshToken: user.refreshToken,
      );
      await _storageService.saveUserEmail(user.email);
      state = AuthSuccess(user);
    } catch (e) {
      state = AuthFailure(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  void reset() => state = const AuthInitial();
}
