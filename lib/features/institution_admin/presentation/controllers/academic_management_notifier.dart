import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../dashboard/domain/entities/subject.dart';
import '../../domain/entities/academic_class.dart';
import '../../domain/repositories/academic_admin_repository.dart';
import 'academic_management_state.dart';

class AcademicManagementNotifier extends StateNotifier<AcademicManagementState> {
  final AcademicAdminRepository _repository;

  AcademicManagementNotifier(this._repository)
      : super(const AcademicManagementState());

  Future<void> init() async {
    state = state.copyWith(isLoading: true, clearError: true, clearSuccess: true);
    try {
      final faculties = await _repository.getSupportedFaculties();

      if (faculties.isEmpty) {
        // No faculties configured yet — show empty state
        state = state.copyWith(
          isLoading: false,
          supportedFaculties: [],
          selectedFaculty: '',
        );
        return;
      }

      final initialFaculty = faculties.first;

      state = state.copyWith(
        supportedFaculties: faculties,
        selectedFaculty: initialFaculty,
        selectedSemester: 1,
      );

      await loadAcademicData();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      );
    }
  }

  Future<void> loadAcademicData() async {
    state = state.copyWith(isLoading: true, clearError: true, clearSuccess: true);
    try {
      final classes = await _repository.getAcademicClasses();
      final subjects = await _repository.getSubjects(
        faculty: state.selectedFaculty,
        semester: state.selectedSemester,
      );

      // Use List.from to re-type the lists so that runtime type is
      // List<AcademicClass>/List<Subject> (not the Model subtypes).
      // This prevents TypeError when firstWhere orElse returns a base type.
      state = state.copyWith(
        isLoading: false,
        academicClasses: List<AcademicClass>.from(classes),
        subjects: List<Subject>.from(subjects),
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      );
    }
  }

  void selectFaculty(String faculty) {
    if (state.selectedFaculty != faculty) {
      state = state.copyWith(selectedFaculty: faculty);
      loadAcademicData();
    }
  }

  Future<void> addCustomFaculty(String facultyCode) async {
    final cleaned = facultyCode.trim().toUpperCase();
    if (cleaned.isEmpty) return;

    state = state.copyWith(isSubmitting: true, clearError: true, clearSuccess: true);
    try {
      // Create first academic class (Sem 1) on backend so the faculty gets persisted
      await _repository.createAcademicClass(
        faculty: cleaned,
        semester: 1,
      );

      // Re-fetch faculties from backend to get the authoritative list
      final faculties = await _repository.getSupportedFaculties();

      state = state.copyWith(
        isSubmitting: false,
        supportedFaculties: faculties,
        selectedFaculty: cleaned,
        selectedSemester: 1,
        successMessage: 'Faculty "$cleaned" added with Semester 1.',
      );
      await loadAcademicData();
    } catch (e) {
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      );
    }
  }

  void selectSemester(int semester) {
    if (state.selectedSemester != semester) {
      state = state.copyWith(selectedSemester: semester);
      loadAcademicData();
    }
  }

  Future<bool> createAcademicClass({required int semester, String? displayName}) async {
    state = state.copyWith(isSubmitting: true, clearError: true, clearSuccess: true);
    try {
      await _repository.createAcademicClass(
        faculty: state.selectedFaculty,
        semester: semester,
        displayName: displayName,
      );

      state = state.copyWith(
        isSubmitting: false,
        successMessage: 'Academic class (${state.selectedFaculty} Sem $semester) added successfully.',
      );

      await loadAcademicData();
      return true;
    } catch (e) {
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      );
      return false;
    }
  }

  Future<bool> updateAcademicClass({
    required int classId,
    required int semester,
    String? displayName,
  }) async {
    state = state.copyWith(isSubmitting: true, clearError: true, clearSuccess: true);
    try {
      await _repository.updateAcademicClass(
        classId: classId,
        faculty: state.selectedFaculty,
        semester: semester,
        displayName: displayName,
      );

      state = state.copyWith(
        isSubmitting: false,
        successMessage: 'Academic class updated successfully.',
      );

      await loadAcademicData();
      return true;
    } catch (e) {
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      );
      return false;
    }
  }

  Future<bool> createSubject({
    required String name,
    required int creditHours,
  }) async {
    state = state.copyWith(isSubmitting: true, clearError: true, clearSuccess: true);
    try {
      await _repository.createSubject(
        name: name,
        faculty: state.selectedFaculty,
        semester: state.selectedSemester,
        creditHours: creditHours,
      );

      state = state.copyWith(
        isSubmitting: false,
        successMessage: 'Subject "$name" created successfully.',
      );

      await loadAcademicData();
      return true;
    } catch (e) {
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      );
      return false;
    }
  }

  Future<bool> updateSubject({
    required int subjectId,
    required String name,
    required int creditHours,
  }) async {
    state = state.copyWith(isSubmitting: true, clearError: true, clearSuccess: true);
    try {
      await _repository.updateSubject(
        subjectId: subjectId,
        name: name,
        faculty: state.selectedFaculty,
        semester: state.selectedSemester,
        creditHours: creditHours,
      );

      state = state.copyWith(
        isSubmitting: false,
        successMessage: 'Subject "$name" updated successfully.',
      );

      await loadAcademicData();
      return true;
    } catch (e) {
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      );
      return false;
    }
  }

  Future<bool> batchCreateSubjects({
    required List<Map<String, dynamic>> subjects,
  }) async {
    state = state.copyWith(isSubmitting: true, clearError: true, clearSuccess: true);
    try {
      final created = await _repository.batchCreateSubjects(
        faculty: state.selectedFaculty,
        semester: state.selectedSemester,
        subjects: subjects,
      );

      state = state.copyWith(
        isSubmitting: false,
        successMessage: '${created.length} subject(s) added successfully.',
      );

      await loadAcademicData();
      return true;
    } catch (e) {
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      );
      return false;
    }
  }

  Future<bool> deleteSubject(int subjectId) async {
    state = state.copyWith(isSubmitting: true, clearError: true, clearSuccess: true);
    try {
      await _repository.deleteSubject(subjectId);

      state = state.copyWith(
        isSubmitting: false,
        successMessage: 'Subject deleted successfully.',
      );

      await loadAcademicData();
      return true;
    } catch (e) {
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      );
      return false;
    }
  }

  void clearMessages() {
    state = state.copyWith(clearError: true, clearSuccess: true);
  }
}
