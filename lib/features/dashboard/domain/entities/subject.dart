import 'package:equatable/equatable.dart';

/// Domain entity for a student subject.
/// Maps to the backend SubjectResponse DTO: { subjectId, name, faculty, semester, creditHours }
class Subject extends Equatable {
  final int subjectId;
  final String name;
  final String faculty;
  final int semester;
  final int creditHours;

  const Subject({
    required this.subjectId,
    required this.name,
    required this.faculty,
    required this.semester,
    required this.creditHours,
  });

  @override
  List<Object?> get props => [subjectId, name, faculty, semester, creditHours];
}
