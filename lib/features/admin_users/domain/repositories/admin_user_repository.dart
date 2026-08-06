import '../entities/user_profile.dart';
import '../entities/teacher_assignment.dart';
import '../../../dashboard/domain/entities/subject.dart';

abstract class AdminUserRepository {
  Future<List<UserProfile>> filterUsers({
    required String role,
    required String status,
    int page = 0,
    int size = 20,
  });

  Future<List<UserProfile>> searchUsers({
    required String query,
    int page = 0,
    int size = 20,
  });

  Future<void> suspendUser(int userId);

  Future<void> activateUser(int userId);

  Future<void> registerTeacher({
    required String name,
    required String email,
    required String password,
  });

  Future<List<TeacherAssignment>> getTeacherAssignments(int teacherId);

  Future<List<TeacherAssignment>> replaceTeacherAssignments(
    int teacherId,
    List<int> subjectIds,
  );

  Future<List<Subject>> getStudentSubjects(int studentId);

  Future<List<Subject>> getAllSubjects();

  Future<List<Subject>> searchSubjects(String name);
}
