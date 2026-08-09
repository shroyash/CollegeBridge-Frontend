import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../admin_users/domain/entities/teacher_assignment.dart';
import '../../../admin_users/domain/usecases/manage_teacher_assignments_usecase.dart';
import 'dashboard_state.dart';

/// StateNotifier for Teacher Dashboard — fetches and holds teacher class assignments.
class TeacherDashboardNotifier
    extends StateNotifier<DashboardState<List<TeacherAssignment>>> {
  final ManageTeacherAssignmentsUseCase _useCase;

  TeacherDashboardNotifier(this._useCase) : super(const DashboardInitial());

  Future<void> fetchTeacherAssignments([int teacherId = 0]) async {
    state = const DashboardLoading();
    try {
      int idToFetch = teacherId;
      if (idToFetch <= 0) {
        final profile = await _useCase.getMyProfile();
        idToFetch = profile.teacherId ?? profile.userId;
      }
      final assignments = await _useCase.getTeacherAssignments(idToFetch);
      state = DashboardSuccess(assignments);
    } catch (e) {
      state = DashboardFailure(e.toString().replaceFirst('Exception: ', ''));
    }
  }
}
