import '../entities/study_session_entity.dart';
import '../repositories/study_session_repository.dart';

class StartSessionUseCase {
  final StudySessionRepository repository;

  StartSessionUseCase(this.repository);

  Future<StudySessionEntity> call(String taskId) {
    return repository.startSession(taskId);
  }
}
