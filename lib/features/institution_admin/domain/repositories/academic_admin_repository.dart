import '../../../dashboard/domain/entities/subject.dart';
import '../entities/academic_class.dart';

abstract class AcademicAdminRepository {
  Future<List<String>> getSupportedFaculties();

  Future<List<AcademicClass>> getAcademicClasses();

  Future<AcademicClass> createAcademicClass({
    required String faculty,
    required int semester,
    String? displayName,
  });

  Future<AcademicClass> updateAcademicClass({
    required int classId,
    required String faculty,
    required int semester,
    String? displayName,
  });

  Future<List<Subject>> getSubjects({
    String? faculty,
    int? semester,
  });

  Future<Subject> createSubject({
    required String name,
    required String faculty,
    required int semester,
    required int creditHours,
  });

  Future<Subject> updateSubject({
    required int subjectId,
    required String name,
    required String faculty,
    required int semester,
    required int creditHours,
  });

  Future<List<Subject>> batchCreateSubjects({
    required String faculty,
    required int semester,
    required List<Map<String, dynamic>> subjects,
  });

  Future<void> deleteSubject(int subjectId);
}
