import '../entities/auth_user.dart';
import '../entities/faculty.dart';

/// Abstract contract that the data layer must fulfill.
/// The domain layer knows nothing about Dio, HTTP, or JSON.
abstract class AuthRepository {
  Future<AuthUser> login({
    required String email,
    required String password,
  });

  Future<AuthUser> register({
    required String name,
    required String email,
    required String password,
    required Faculty faculty,
    required int semester,
  });

  Future<void> logout({required String refreshToken});
}
