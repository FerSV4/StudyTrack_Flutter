import '../../domain/entities/study_session_entity.dart';

class StudySessionModel extends StudySessionEntity {
  const StudySessionModel({
    required super.id,
    required super.taskId,
    required super.startedAt,
    super.finishedAt,
  });

  factory StudySessionModel.fromJson(Map<String, dynamic> json) {
    return StudySessionModel(
      id: json['id'].toString(),
      taskId: json['taskId']?.toString() ??
          json['task_id']?.toString() ??
          '',
      startedAt: DateTime.tryParse(
            json['startedAt']?.toString() ?? json['started_at']?.toString() ?? '',
          ) ??
          DateTime.now(),
      finishedAt: json['finishedAt'] != null
          ? DateTime.tryParse(json['finishedAt'].toString())
          : null,
    );
  }

  factory StudySessionModel.fromEntity(StudySessionEntity entity) {
    return StudySessionModel(
      id: entity.id,
      taskId: entity.taskId,
      startedAt: entity.startedAt,
      finishedAt: entity.finishedAt,
    );
  }
}
