import '../../../dashboard/domain/entities/subject.dart';
import '../datasources/academic_admin_remote_datasource.dart';
import '../../domain/entities/academic_class.dart';
import '../../domain/repositories/academic_admin_repository.dart';

class AcademicAdminRepositoryImpl implements AcademicAdminRepository {
  final AcademicAdminRemoteDataSource _remoteDataSource;

  const AcademicAdminRepositoryImpl(this._remoteDataSource);

  @override
  Future<List<String>> getSupportedFaculties() =>
      _remoteDataSource.getSupportedFaculties();

  @override
  Future<List<AcademicClass>> getAcademicClasses() =>
      _remoteDataSource.getAcademicClasses();

  @override
  Future<AcademicClass> createAcademicClass({
    required String faculty,
    required int semester,
    String? displayName,
  }) =>
      _remoteDataSource.createAcademicClass(
        faculty: faculty,
        semester: semester,
        displayName: displayName,
      );

  @override
  Future<AcademicClass> updateAcademicClass({
    required int classId,
    required String faculty,
    required int semester,
    String? displayName,
  }) =>
      _remoteDataSource.updateAcademicClass(
        classId: classId,
        faculty: faculty,
        semester: semester,
        displayName: displayName,
      );

  @override
  Future<List<Subject>> getSubjects({String? faculty, int? semester}) =>
      _remoteDataSource.getSubjects(faculty: faculty, semester: semester);

  @override
  Future<Subject> createSubject({
    required String name,
    required String faculty,
    required int semester,
    required int creditHours,
  }) =>
      _remoteDataSource.createSubject(
        name: name,
        faculty: faculty,
        semester: semester,
        creditHours: creditHours,
      );

  @override
  Future<Subject> updateSubject({
    required int subjectId,
    required String name,
    required String faculty,
    required int semester,
    required int creditHours,
  }) =>
      _remoteDataSource.updateSubject(
        subjectId: subjectId,
        name: name,
        faculty: faculty,
        semester: semester,
        creditHours: creditHours,
      );

  @override
  Future<List<Subject>> batchCreateSubjects({
    required String faculty,
    required int semester,
    required List<Map<String, dynamic>> subjects,
  }) =>
      _remoteDataSource.batchCreateSubjects(
        faculty: faculty,
        semester: semester,
        subjects: subjects,
      );

  @override
  Future<void> deleteSubject(int subjectId) =>
      _remoteDataSource.deleteSubject(subjectId);
}
