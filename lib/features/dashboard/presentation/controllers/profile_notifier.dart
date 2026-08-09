import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../admin_users/domain/entities/user_profile.dart';
import '../../../admin_users/domain/usecases/manage_teacher_assignments_usecase.dart';

// ── State ──────────────────────────────────────────────────────────────────────

abstract class ProfileState {
  const ProfileState();
}

class ProfileInitial extends ProfileState {
  const ProfileInitial();
}

class ProfileLoading extends ProfileState {
  const ProfileLoading();
}

class ProfileSuccess extends ProfileState {
  final UserProfile profile;
  final bool isSaving;

  const ProfileSuccess(this.profile, {this.isSaving = false});

  ProfileSuccess copyWith({UserProfile? profile, bool? isSaving}) {
    return ProfileSuccess(
      profile ?? this.profile,
      isSaving: isSaving ?? this.isSaving,
    );
  }
}

class ProfileFailure extends ProfileState {
  final String message;
  const ProfileFailure(this.message);
}

// ── Notifier ──────────────────────────────────────────────────────────────────

class ProfileNotifier extends StateNotifier<ProfileState> {
  final ManageTeacherAssignmentsUseCase _useCase;

  ProfileNotifier(this._useCase) : super(const ProfileInitial());

  Future<void> fetchProfile() async {
    state = const ProfileLoading();
    try {
      final profile = await _useCase.getMyProfile();
      state = ProfileSuccess(profile);
    } catch (e) {
      state = ProfileFailure(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  Future<bool> updateName(String newName) async {
    if (state is! ProfileSuccess) return false;
    final current = (state as ProfileSuccess).profile;
    state = ProfileSuccess(current, isSaving: true);
    // Optimistic update – actual API call would go here
    await Future.delayed(const Duration(milliseconds: 600));
    state = ProfileSuccess(
      UserProfile(
        userId: current.userId,
        teacherId: current.teacherId,
        name: newName,
        email: current.email,
        role: current.role,
        status: current.status,
        imageUrl: current.imageUrl,
        fcmToken: current.fcmToken,
        studentDetails: current.studentDetails,
      ),
    );
    return true;
  }
}
