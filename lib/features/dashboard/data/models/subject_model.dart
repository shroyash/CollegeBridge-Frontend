import '../../domain/entities/subject.dart';

/// Data model mapping the normalized backend SubjectResponse JSON to the domain entity.
/// Backend payload: { subjectId, name, code, creditHours, levelId, levelName, programName }
class SubjectModel extends Subject {
  const SubjectModel({
    required super.subjectId,
    required super.name,
    super.code,
    required super.creditHours,
    required super.levelId,
    required super.levelName,
    required super.programName,
  });

  factory SubjectModel.fromJson(Map<String, dynamic> json) {
    return SubjectModel(
      subjectId: (json['subjectId'] as num?)?.toInt() ?? 0,
      name: json['name'] as String? ?? '',
      code: json['code'] as String?,
      creditHours: (json['creditHours'] as num?)?.toInt() ?? 3,
      levelId: (json['levelId'] as num?)?.toInt() ?? 0,
      levelName: json['levelName'] as String? ?? '',
      programName: json['programName'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'subjectId': subjectId,
      'name': name,
      if (code != null) 'code': code,
      'creditHours': creditHours,
      'levelId': levelId,
      'levelName': levelName,
      'programName': programName,
    };
  }
}
