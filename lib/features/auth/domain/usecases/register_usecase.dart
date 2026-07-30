import '../entities/auth_user.dart';
import '../entities/faculty.dart';
import '../repositories/auth_repository.dart';

/// Single responsibility use-case: register a new student account.
class RegisterUseCase {
  final AuthRepository _repository;

  const RegisterUseCase(this._repository);

  Future<AuthUser> call({
    required String name,
    required String email,
    required String password,
    required Faculty faculty,
    required int semester,
  }) {
    return _repository.register(
      name: name,
      email: email,
      password: password,
      faculty: faculty,
      semester: semester,
    );
  }
}
