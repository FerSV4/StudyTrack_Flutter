import '../../domain/entities/study_session_entity.dart';
import '../../domain/repositories/study_session_repository.dart';
import '../datasources/study_session_remote_data_source.dart';

class StudySessionRepositoryImpl implements StudySessionRepository {
  final StudySessionRemoteDataSource remoteDataSource;

  StudySessionRepositoryImpl({required this.remoteDataSource});

  @override
  Future<StudySessionEntity> startSession(String taskId) {
    return remoteDataSource.startSession(taskId);
  }

  @override
  Future<StudySessionEntity> finishSession(String id) {
    return remoteDataSource.finishSession(id);
  }
}
