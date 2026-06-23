import '../repositories/auth_repository.dart';

class RegisterUseCase {
  final AuthRepository repository;

  RegisterUseCase(this.repository);

  Future<String> call(String fullName, String email, String password) async {
    return await repository.register(fullName, email, password);
  }
}