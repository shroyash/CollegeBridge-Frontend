import '../repositories/admin_user_repository.dart';
import '../../../dashboard/domain/entities/subject.dart';

class GetStudentSubjectsUseCase {
  final AdminUserRepository _repository;

  GetStudentSubjectsUseCase(this._repository);

  Future<List<Subject>> call(int studentId) {
    return _repository.getStudentSubjects(studentId);
  }
}
