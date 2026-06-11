import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../models/term_model.dart';

class AcademicRemoteDataSource {
  final ApiClient apiClient;

  AcademicRemoteDataSource({required this.apiClient});

  Future<TermModel> getActiveTerm() async {
    try {
      final response = await apiClient.dio.get('/terms/active-tree');
      return TermModel.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Error al obtener el semestre activo');
    }
  }
}