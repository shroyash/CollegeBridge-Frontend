import '../../domain/entities/auth_user.dart';
import '../../domain/entities/faculty.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';

/// Concrete implementation of [AuthRepository].
/// Bridges the remote datasource to the domain layer.
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;

  const AuthRepositoryImpl(this._remoteDataSource);

  @override
  Future<AuthUser> login({
    required String email,
    required String password,
  }) async {
    final model = await _remoteDataSource.login(email: email, password: password);
    return model; // AuthUserModel extends AuthUser — already a domain entity
  }

  @override
  Future<AuthUser> register({
    required String name,
    required String email,
    required String password,
    required Faculty faculty,
    required int semester,
  }) async {
    final model = await _remoteDataSource.register(
      name: name,
      email: email,
      password: password,
      faculty: faculty,
      semester: semester,
    );
    return model;
  }

  @override
  Future<void> logout({required String refreshToken}) async {
    await _remoteDataSource.logout(refreshToken: refreshToken);
  }
}
