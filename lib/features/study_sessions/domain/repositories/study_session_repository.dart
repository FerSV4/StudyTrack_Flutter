import '../entities/study_session_entity.dart';

abstract class StudySessionRepository {
  Future<StudySessionEntity> startSession(String taskId);
  Future<StudySessionEntity> finishSession(String id);
}
