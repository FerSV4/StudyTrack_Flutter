import '../datasources/auth_remote_data_source.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl({required this.remoteDataSource});

  @override
  Future<String> login(String email, String password) async {
    return await remoteDataSource.login(email, password);
  }

  @override
  Future<String> register(String fullName, String email, String password) async {
    return await remoteDataSource.register(fullName, email, password);
  }
}