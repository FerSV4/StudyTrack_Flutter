import 'package:dio/dio.dart';

import '../../../../core/network/api_client.dart';
import '../models/study_session_model.dart';

abstract class StudySessionRemoteDataSource {
  Future<StudySessionModel> startSession(String taskId);
  Future<StudySessionModel> finishSession(String id);
}

class StudySessionRemoteDataSourceImpl implements StudySessionRemoteDataSource {
  final ApiClient apiClient;

  StudySessionRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<StudySessionModel> startSession(String taskId) async {
    try {
      final response = await apiClient.dio.post(
        '/study-sessions/start',
        data: {'taskId': taskId},
      );

      final data = response.data;
      if (data is Map<String, dynamic>) {
        return StudySessionModel.fromJson(data);
      }

      throw Exception('Formato de respuesta inválido al iniciar sesión');
    } on DioException catch (e) {
      throw Exception(
        e.response?.data is Map<String, dynamic>
            ? (e.response?.data['message'] ?? 'Error al iniciar la sesión de estudio')
            : 'Error al iniciar la sesión de estudio',
      );
    }
  }

  @override
  Future<StudySessionModel> finishSession(String id) async {
    try {
      final response = await apiClient.dio.patch('/study-sessions/finish/$id');
      final data = response.data;
      if (data is Map<String, dynamic>) {
        return StudySessionModel.fromJson(data);
      }

      return StudySessionModel(
        id: id,
        taskId: '',
        startedAt: DateTime.now(),
        finishedAt: DateTime.now(),
      );
    } on DioException catch (e) {
      throw Exception(
        e.response?.data is Map<String, dynamic>
            ? (e.response?.data['message'] ?? 'Error al finalizar la sesión de estudio')
            : 'Error al finalizar la sesión de estudio',
      );
    }
  }
}
