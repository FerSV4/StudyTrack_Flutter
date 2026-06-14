import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../models/task_model.dart';

abstract class TaskRemoteDataSource {
  Future<List<TaskModel>> getTasks();
  Future<void> updateTaskStatus(String id, bool isCompleted);
  Future<void> createTask(TaskModel task);
  Future<void> updateTaskDetails(String id, TaskModel task);
  Future<void> deleteTask(String id);
}

class TaskRemoteDataSourceImpl implements TaskRemoteDataSource {
  final ApiClient apiClient;

  TaskRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<List<TaskModel>> getTasks() async {
    try {
      final response = await apiClient.dio.get('/tasks');
      
      if (response.data is List) {
        final List<dynamic> list = response.data;
        return list.map((json) => TaskModel.fromJson(json)).toList();
      } else {
        throw Exception('Formato de respuesta inválido de la API de tareas');
      }
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Error al obtener las tareas de NestJS');
    }
  }
  @override
  Future<void> updateTaskStatus(String id, bool isCompleted) async {
    try {
      final statusString = isCompleted ? 'completed' : 'pending'; 

      await apiClient.dio.patch(
        '/tasks/$id/status',
        data: {'status': statusString},
      );
    } on DioException catch (e) {
      throw Exception('Error al actualizar tarea: ${e.response?.data['message']}');
    }
  }

  @override
  Future<void> createTask(TaskModel task) async {
    try {
      await apiClient.dio.post(
        '/tasks',
        data: task.toCreateOrUpdateJson(),
      );
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Error al crear la tarea');
    }
  }

  @override
  Future<void> updateTaskDetails(String id, TaskModel task) async {
    try {
      await apiClient.dio.patch(
        '/tasks/$id',
        data: task.toCreateOrUpdateJson(),
      );
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Error al editar la tarea');
    }
  }

  @override
  Future<void> deleteTask(String id) async {
    try {
      await apiClient.dio.delete('/tasks/$id');
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Error al eliminar la tarea');
    }
  }
}
