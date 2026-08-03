import '../../domain/entities/subject.dart';

/// Data model mapping the backend SubjectResponse JSON to the domain entity.
/// Backend payload: { subjectId, name, faculty, semester, creditHours }
class SubjectModel extends Subject {
  const SubjectModel({
    required super.subjectId,
    required super.name,
    required super.faculty,
    required super.semester,
    required super.creditHours,
  });

  factory SubjectModel.fromJson(Map<String, dynamic> json) {
    return SubjectModel(
      subjectId: (json['subjectId'] as num).toInt(),
      name: json['name'] as String,
      faculty: json['faculty'] as String,
      semester: (json['semester'] as num).toInt(),
      creditHours: (json['creditHours'] as num).toInt(),
    );
  }
}
