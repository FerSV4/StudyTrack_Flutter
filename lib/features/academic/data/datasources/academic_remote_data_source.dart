import 'package:dio/dio.dart';
import 'dart:convert';
import '../../../../core/network/api_client.dart';
import '../dtos/create_subject_dto.dart';
import '../dtos/create_term_dto.dart';
import '../models/subject_model.dart';
import '../models/term_model.dart';

class AcademicRemoteDataSource {
  final ApiClient apiClient;

  AcademicRemoteDataSource({required this.apiClient});

  Future<TermModel?> getActiveTerm() async {
    try {
      final response = await apiClient.dio.get('/terms/active-tree');
      
      if (response.data == null) return null;
      
      if (response.data is String) {
        final textData = response.data.toString().trim();
        if (textData.isEmpty || textData == 'null') return null;
        
        final decoded = jsonDecode(textData);
        if (decoded == null) return null;
        return TermModel.fromJson(decoded as Map<String, dynamic>);
      }

      if (response.data is Map<String, dynamic>) {
        if ((response.data as Map).isEmpty) return null;
        return TermModel.fromJson(response.data as Map<String, dynamic>);
      }

      return null;
      
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Error al obtener el semestre activo');
    }
  }

  Future<TermModel> createTerm(CreateTermDto dto) async {
    try {
      final response = await apiClient.dio.post(
        '/terms',
        data: dto.toJson(),
      );
      return TermModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Error al crear el semestre');
    }
  }

  Future<SubjectModel> createSubject(String termId, CreateSubjectDto dto) async {
    try {
      final response = await apiClient.dio.post(
        '/subjects/$termId',
        data: dto.toJson(),
      );
      return SubjectModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Error al crear la materia');
    }
  }
}
