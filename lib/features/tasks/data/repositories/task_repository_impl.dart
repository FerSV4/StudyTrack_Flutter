import '../../domain/entities/task_entity.dart';
import '../../domain/repositories/task_repository.dart';
import '../datasources/task_remote_data_source.dart';
import '../models/task_model.dart';

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

  @override
  Future<void> createTask(TaskEntity task) async {
    return await remoteDataSource.createTask(TaskModel.fromEntity(task));
  }

  @override
  Future<void> updateTaskDetails(String id, TaskEntity task) async {
    return await remoteDataSource.updateTaskDetails(id, TaskModel.fromEntity(task));
  }

  @override
  Future<void> deleteTask(String id) async {
    return await remoteDataSource.deleteTask(id);
  }
}
