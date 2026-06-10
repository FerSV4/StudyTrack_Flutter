import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiClient {
  final Dio dio;
  final SharedPreferences sharedPreferences;

  ApiClient({required this.dio, required this.sharedPreferences}) {
    dio.options.baseUrl = 'http://10.0.2.2:3000/api'; // IP especial del emulador Android hacia localhost
    dio.options.connectTimeout = const Duration(seconds: 10);
    
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        final token = sharedPreferences.getString('jwt_token');
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onError: (DioException e, handler) {
        // Aquí puedes manejar errores globales (ej. 401 Unauthorized)
        return handler.next(e);
      },
    ));
  }
}