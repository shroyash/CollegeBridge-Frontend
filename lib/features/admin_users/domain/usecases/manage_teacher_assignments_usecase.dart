import '../entities/teacher_assignment.dart';
import '../entities/user_profile.dart';
import '../repositories/admin_user_repository.dart';
import '../../../dashboard/domain/entities/subject.dart';

class ManageTeacherAssignmentsUseCase {
  final AdminUserRepository _repository;

  ManageTeacherAssignmentsUseCase(this._repository);

  Future<UserProfile> getMyProfile() {
    return _repository.getMyProfile();
  }

  Future<List<TeacherAssignment>> getTeacherAssignments(int teacherId) {
    return _repository.getTeacherAssignments(teacherId);
  }

  Future<List<TeacherAssignment>> saveAssignments(
    int teacherId,
    List<int> subjectIds,
  ) {
    return _repository.replaceTeacherAssignments(teacherId, subjectIds);
  }

  Future<List<Subject>> getAllSubjects() {
    return _repository.getAllSubjects();
  }

  Future<List<Subject>> searchSubjects(String query) {
    return _repository.searchSubjects(query);
  }
}
