import '../entities/user.dart';

abstract class AuthRepository {
  Future<User> login({
    required String email,
    required String password,
  });

  Future<User> register({
    required String email,
    required String password,
    required String name,
  });

  Future<void> logout();

  Future<User?> getCurrentUser();

  Future<User> updateProfile({
    String? name,
    String? profilePicture,
  });

  Future<void> refreshToken();

  Future<bool> isLoggedIn();

  Future<String?> getToken();
}





