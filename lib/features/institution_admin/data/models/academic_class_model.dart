import '../../domain/entities/academic_class.dart';

class AcademicClassModel extends AcademicClass {
  const AcademicClassModel({
    required super.classId,
    required super.faculty,
    required super.semester,
    required super.displayName,
  });

  factory AcademicClassModel.fromJson(Map<String, dynamic> json) {
    final facultyStr = json['faculty'] as String? ?? '';
    final semInt = (json['semester'] as num?)?.toInt() ?? 1;

    return AcademicClassModel(
      classId: (json['classId'] as num?)?.toInt() ?? 0,
      faculty: facultyStr,
      semester: semInt,
      displayName: json['displayName'] as String? ?? '$facultyStr Sem $semInt',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'classId': classId,
      'faculty': faculty,
      'semester': semester,
      'displayName': displayName,
    };
  }
}
