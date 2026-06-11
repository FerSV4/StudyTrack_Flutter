import '../repositories/task_repository.dart';

class UpdateTaskStatusUseCase {
  final TaskRepository repository;

  UpdateTaskStatusUseCase(this.repository);

  Future<void> call(String id, bool isCompleted) async {
    return await repository.updateTaskStatus(id, isCompleted);
  }
}