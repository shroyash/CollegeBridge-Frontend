import 'package:equatable/equatable.dart';

class AcademicClass extends Equatable {
  final int classId;
  final String faculty;
  final int semester;
  final String displayName;

  const AcademicClass({
    required this.classId,
    required this.faculty,
    required this.semester,
    required this.displayName,
  });

  @override
  List<Object?> get props => [classId, faculty, semester, displayName];
}
