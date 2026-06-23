import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';

abstract class AuthRemoteDataSource {
  Future<String> login(String email, String password);
  Future<String> register(String fullName, String email, String password);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiClient apiClient;

  AuthRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<String> login(String email, String password) async {
    try {
      final response = await apiClient.dio.post(
        '/auth/login',
        data: {'email': email, 'password': password},
      );
      final token = response.data['access_token'];
      await apiClient.sharedPreferences.setString('jwt_token', token);
      return token;
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Error de conexión con NestJS');
    }
  }

  @override
  Future<String> register(String fullName, String email, String password) async {
    try {
      final response = await apiClient.dio.post(
        '/auth/register',
        data: {
          'fullName': fullName,
          'email': email,
          'password': password,
        },
      );
      final token = response.data['access_token'];
      await apiClient.sharedPreferences.setString('jwt_token', token);
      return token;
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Error de conexión con NestJS');
    }
  }
}