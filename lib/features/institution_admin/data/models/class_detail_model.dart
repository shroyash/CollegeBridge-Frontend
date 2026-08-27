class ClassStudentModel {
  final int studentId;
  final int? userId;
  final String fullName;
  final String email;
  final String status;

  const ClassStudentModel({
    required this.studentId,
    this.userId,
    required this.fullName,
    required this.email,
    required this.status,
  });

  factory ClassStudentModel.fromJson(Map<String, dynamic> json) {
    return ClassStudentModel(
      studentId: (json['studentId'] as num?)?.toInt() ?? 0,
      userId: (json['userId'] as num?)?.toInt(),
      fullName: json['fullName'] as String? ?? 'Unknown',
      email: json['email'] as String? ?? '',
      status: json['status'] as String? ?? 'ACTIVE',
    );
  }
}

class ClassTeacherModel {
  final int teacherId;
  final int? userId;
  final String fullName;
  final String email;
  final List<String> assignedSubjects;
  final bool isClassTeacher;

  const ClassTeacherModel({
    required this.teacherId,
    this.userId,
    required this.fullName,
    required this.email,
    required this.assignedSubjects,
    required this.isClassTeacher,
  });

  factory ClassTeacherModel.fromJson(Map<String, dynamic> json) {
    final subList = (json['assignedSubjects'] as List?)?.map((e) => e.toString()).toList() ?? [];
    return ClassTeacherModel(
      teacherId: (json['teacherId'] as num?)?.toInt() ?? 0,
      userId: (json['userId'] as num?)?.toInt(),
      fullName: json['fullName'] as String? ?? 'Unknown',
      email: json['email'] as String? ?? '',
      assignedSubjects: subList,
      isClassTeacher: json['isClassTeacher'] as bool? ?? false,
    );
  }
}

class ClassDetailModel {
  final int classId;
  final String displayName;
  final String faculty;
  final int semester;
  final int totalStudents;
  final int? classTeacherId;
  final String? classTeacherName;
  final int institutionId;
  final String institutionName;
  final String createdBy;
  final String createdAt;
  final List<ClassStudentModel> students;
  final List<ClassTeacherModel> teachers;

  const ClassDetailModel({
    required this.classId,
    required this.displayName,
    required this.faculty,
    required this.semester,
    required this.totalStudents,
    this.classTeacherId,
    this.classTeacherName,
    required this.institutionId,
    required this.institutionName,
    required this.createdBy,
    required this.createdAt,
    required this.students,
    required this.teachers,
  });

  factory ClassDetailModel.fromJson(Map<String, dynamic> json) {
    final studentsJson = (json['students'] as List?)
            ?.whereType<Map>()
            .map((e) => ClassStudentModel.fromJson(Map<String, dynamic>.from(e)))
            .toList() ??
        [];
    final teachersJson = (json['teachers'] as List?)
            ?.whereType<Map>()
            .map((e) => ClassTeacherModel.fromJson(Map<String, dynamic>.from(e)))
            .toList() ??
        [];

    return ClassDetailModel(
      classId: (json['classId'] as num?)?.toInt() ?? 0,
      displayName: json['displayName'] as String? ?? '',
      faculty: json['faculty'] as String? ?? '',
      semester: (json['semester'] as num?)?.toInt() ?? 1,
      totalStudents: (json['totalStudents'] as num?)?.toInt() ?? 0,
      classTeacherId: (json['classTeacherId'] as num?)?.toInt(),
      classTeacherName: json['classTeacherName'] as String?,
      institutionId: (json['institutionId'] as num?)?.toInt() ?? 0,
      institutionName: json['institutionName'] as String? ?? '',
      createdBy: json['createdBy'] as String? ?? 'Institution Admin',
      createdAt: json['createdAt'] as String? ?? '',
      students: studentsJson,
      teachers: teachersJson,
    );
  }
}
