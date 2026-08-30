import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../dashboard/domain/entities/subject.dart';
import '../../data/datasources/academic_admin_remote_datasource.dart';
import '../../domain/entities/academic_level.dart';
import '../../domain/entities/academic_program.dart';
import 'academic_management_state.dart';

class AcademicManagementNotifier extends StateNotifier<AcademicManagementState> {
  final AcademicAdminRemoteDataSource _dataSource;

  AcademicManagementNotifier(this._dataSource) : super(const AcademicManagementState());

  /// Load all programs for this institution.
  Future<void> init() async {
    state = state.copyWith(isLoading: true, clearError: true, clearSuccess: true);
    try {
      final programs = await _dataSource.getPrograms();
      state = state.copyWith(
        isLoading: false,
        programs: List<AcademicProgram>.from(programs),
      );

      // Auto-select first program if available
      if (programs.isNotEmpty) {
        await selectProgram(programs.first);
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      );
    }
  }

  Future<void> selectProgram(AcademicProgram program) async {
    state = state.copyWith(
      selectedProgram: program,
      levels: [],
      subjects: [],
      loadingLevels: true,
      clearSelectedLevel: true,
      clearError: true,
    );
    try {
      final levels = await _dataSource.getLevels(programId: program.programId);
      state = state.copyWith(
        levels: List<AcademicLevel>.from(levels),
        loadingLevels: false,
      );

      // Auto-select first level if available, otherwise clear level & subjects
      if (levels.isNotEmpty) {
        await selectLevel(levels.first);
      } else {
        state = state.copyWith(
          clearSelectedLevel: true,
          subjects: [],
        );
      }
    } catch (e) {
      state = state.copyWith(
        loadingLevels: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      );
    }
  }

  Future<void> selectLevel(AcademicLevel level) async {
    state = state.copyWith(selectedLevel: level, subjects: [], isLoading: true, clearError: true);
    try {
      final subjects = await _dataSource.getSubjects(levelId: level.levelId);
      state = state.copyWith(
        isLoading: false,
        subjects: List<Subject>.from(subjects),
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      );
    }
  }

  Future<void> refreshSubjects() async {
    if (state.selectedLevel == null) return;
    await selectLevel(state.selectedLevel!);
  }

  // ── Programs ──────────────────────────────────────────────────────────────

  Future<bool> createProgram({required String name, required String code}) async {
    state = state.copyWith(isSubmitting: true, clearError: true, clearSuccess: true);
    try {
      final program = await _dataSource.createProgram(name: name, code: code);
      final updatedPrograms = [...state.programs, program as AcademicProgram];
      state = state.copyWith(
        isSubmitting: false,
        programs: updatedPrograms,
        successMessage: 'Program "$name" created successfully.',
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      );
      return false;
    }
  }

  Future<bool> deleteProgram(int programId) async {
    state = state.copyWith(isSubmitting: true, clearError: true, clearSuccess: true);
    try {
      await _dataSource.deleteProgram(programId);
      final updatedPrograms = state.programs.where((p) => p.programId != programId).toList();
      state = state.copyWith(
        isSubmitting: false,
        programs: updatedPrograms,
        successMessage: 'Program deleted.',
        clearSelectedProgram: true,
        levels: [],
        subjects: [],
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      );
      return false;
    }
  }

  // ── Levels ────────────────────────────────────────────────────────────────

  Future<bool> createLevel({
    required int programId,
    required int levelNumber,
    required String name,
    required String type,
  }) async {
    state = state.copyWith(isSubmitting: true, clearError: true, clearSuccess: true);
    try {
      final level = await _dataSource.createLevel(
        programId: programId,
        levelNumber: levelNumber,
        name: name,
        type: type,
      );
      final updatedLevels = [...state.levels, level as AcademicLevel];
      state = state.copyWith(
        isSubmitting: false,
        levels: updatedLevels,
        successMessage: 'Level "$name" created successfully.',
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      );
      return false;
    }
  }

  Future<bool> deleteLevel(int levelId) async {
    state = state.copyWith(isSubmitting: true, clearError: true, clearSuccess: true);
    try {
      await _dataSource.deleteLevel(levelId);
      final updatedLevels = state.levels.where((l) => l.levelId != levelId).toList();
      state = state.copyWith(
        isSubmitting: false,
        levels: updatedLevels,
        successMessage: 'Level deleted.',
        clearSelectedLevel: true,
        subjects: [],
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      );
      return false;
    }
  }

  // ── Subjects ──────────────────────────────────────────────────────────────

  Future<bool> createSubject({
    required String name,
    String? code,
    int creditHours = 3,
  }) async {
    final levelId = state.selectedLevel?.levelId;
    if (levelId == null) return false;

    state = state.copyWith(isSubmitting: true, clearError: true, clearSuccess: true);
    try {
      await _dataSource.createSubject(
        name: name,
        levelId: levelId,
        code: code,
        creditHours: creditHours,
      );
      state = state.copyWith(
        isSubmitting: false,
        successMessage: 'Subject "$name" created successfully.',
      );
      await refreshSubjects();
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
    String? code,
    int creditHours = 3,
  }) async {
    state = state.copyWith(isSubmitting: true, clearError: true, clearSuccess: true);
    try {
      await _dataSource.updateSubject(
        subjectId: subjectId,
        name: name,
        code: code,
        creditHours: creditHours,
      );
      state = state.copyWith(
        isSubmitting: false,
        successMessage: 'Subject "$name" updated successfully.',
      );
      await refreshSubjects();
      return true;
    } catch (e) {
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      );
      return false;
    }
  }

  Future<bool> batchCreateSubjects({required List<Map<String, dynamic>> subjects}) async {
    final levelId = state.selectedLevel?.levelId;
    if (levelId == null) return false;

    state = state.copyWith(isSubmitting: true, clearError: true, clearSuccess: true);
    try {
      final created = await _dataSource.batchCreateSubjects(
        levelId: levelId,
        subjects: subjects,
      );
      state = state.copyWith(
        isSubmitting: false,
        successMessage: '${created.length} subject(s) added successfully.',
      );
      await refreshSubjects();
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
      await _dataSource.deleteSubject(subjectId);
      state = state.copyWith(
        isSubmitting: false,
        successMessage: 'Subject deleted successfully.',
      );
      await refreshSubjects();
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
