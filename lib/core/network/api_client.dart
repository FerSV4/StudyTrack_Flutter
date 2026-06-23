import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiClient {
  final Dio dio;
  final SharedPreferences sharedPreferences;

  ApiClient({required this.dio, required this.sharedPreferences}) {
    dio.options.baseUrl = 'http://54.173.55.131:30000/api';
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
        return handler.next(e);
      },
    ));
  }
}