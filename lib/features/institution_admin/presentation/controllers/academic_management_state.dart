import 'package:equatable/equatable.dart';
import '../../../dashboard/domain/entities/subject.dart';
import '../../domain/entities/academic_class.dart';

class AcademicManagementState extends Equatable {
  final bool isLoading;
  final bool isSubmitting;
  final String? errorMessage;
  final String? successMessage;
  final List<String> supportedFaculties;
  final String selectedFaculty;
  final int selectedSemester;
  final List<AcademicClass> academicClasses;
  final List<Subject> subjects;

  const AcademicManagementState({
    this.isLoading = false,
    this.isSubmitting = false,
    this.errorMessage,
    this.successMessage,
    this.supportedFaculties = const [],
    this.selectedFaculty = '',
    this.selectedSemester = 1,
    this.academicClasses = const [],
    this.subjects = const [],
  });

  AcademicManagementState copyWith({
    bool? isLoading,
    bool? isSubmitting,
    String? errorMessage,
    String? successMessage,
    List<String>? supportedFaculties,
    String? selectedFaculty,
    int? selectedSemester,
    List<AcademicClass>? academicClasses,
    List<Subject>? subjects,
    bool clearError = false,
    bool clearSuccess = false,
  }) {
    return AcademicManagementState(
      isLoading: isLoading ?? this.isLoading,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      successMessage: clearSuccess ? null : (successMessage ?? this.successMessage),
      supportedFaculties: supportedFaculties ?? this.supportedFaculties,
      selectedFaculty: selectedFaculty ?? this.selectedFaculty,
      selectedSemester: selectedSemester ?? this.selectedSemester,
      academicClasses: academicClasses ?? this.academicClasses,
      subjects: subjects ?? this.subjects,
    );
  }

  @override
  List<Object?> get props => [
        isLoading,
        isSubmitting,
        errorMessage,
        successMessage,
        supportedFaculties,
        selectedFaculty,
        selectedSemester,
        academicClasses,
        subjects,
      ];
}
