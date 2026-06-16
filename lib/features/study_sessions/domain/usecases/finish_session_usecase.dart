import '../entities/study_session_entity.dart';
import '../repositories/study_session_repository.dart';

class FinishSessionUseCase {
  final StudySessionRepository repository;

  FinishSessionUseCase(this.repository);

  Future<StudySessionEntity> call(String id) {
    return repository.finishSession(id);
  }
}
