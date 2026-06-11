import '../../domain/entities/task_entity.dart';
import '../../domain/repositories/task_repository.dart';
import '../datasources/task_remote_data_source.dart';

class TaskRepositoryImpl implements TaskRepository {
  final TaskRemoteDataSource remoteDataSource;

  TaskRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<TaskEntity>> getTasks() async {
    return await remoteDataSource.getTasks();
  }
  @override
  Future<void> updateTaskStatus(String id, bool isCompleted) async {
    return await remoteDataSource.updateTaskStatus(id, isCompleted);
  }
}