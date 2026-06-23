abstract class AuthRepository {
  Future<String> login(String email, String password);
  Future<String> register(String fullName, String email, String password);
}