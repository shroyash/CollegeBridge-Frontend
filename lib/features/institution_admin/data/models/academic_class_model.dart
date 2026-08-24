import '../../domain/entities/academic_class.dart';

class AcademicClassModel extends AcademicClass {
  const AcademicClassModel({
    required super.classId,
    required super.faculty,
    required super.semester,
    required super.displayName,
    super.totalStudents = 0,
    super.classTeacherId,
    super.classTeacherName,
  });

  factory AcademicClassModel.fromJson(Map<String, dynamic> json) {
    final facultyStr = json['faculty'] as String? ?? '';
    final semInt = (json['semester'] as num?)?.toInt() ?? 1;

    return AcademicClassModel(
      classId: (json['classId'] as num?)?.toInt() ?? 0,
      faculty: facultyStr,
      semester: semInt,
      displayName: json['displayName'] as String? ?? '$facultyStr Sem $semInt',
      totalStudents: (json['totalStudents'] as num?)?.toInt() ?? 0,
      classTeacherId: (json['classTeacherId'] as num?)?.toInt(),
      classTeacherName: json['classTeacherName'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'classId': classId,
      'faculty': faculty,
      'semester': semester,
      'displayName': displayName,
      'totalStudents': totalStudents,
      'classTeacherId': classTeacherId,
      'classTeacherName': classTeacherName,
    };
  }
}
