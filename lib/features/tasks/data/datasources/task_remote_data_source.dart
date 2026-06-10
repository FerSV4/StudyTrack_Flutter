import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../models/task_model.dart';

abstract class TaskRemoteDataSource {
  Future<List<TaskModel>> getTasks();
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
}