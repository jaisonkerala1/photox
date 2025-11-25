import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/local/local_storage.dart';
import '../datasources/remote/api_service.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final ApiService apiService;
  final LocalStorage localStorage;

  AuthRepositoryImpl({
    required this.apiService,
    required this.localStorage,
  });

  @override
  Future<User> login({
    required String email,
    required String password,
  }) async {
    final response = await apiService.login(email: email, password: password);
    final authResponse = AuthResponse.fromJson(response);
    
    await localStorage.saveToken(authResponse.token);
    if (authResponse.refreshToken != null) {
      await localStorage.saveRefreshToken(authResponse.refreshToken!);
    }
    await localStorage.saveUser(authResponse.user);
    
    return authResponse.user;
  }

  @override
  Future<User> register({
    required String email,
    required String password,
    required String name,
  }) async {
    final response = await apiService.register(
      email: email,
      password: password,
      name: name,
    );
    final authResponse = AuthResponse.fromJson(response);
    
    await localStorage.saveToken(authResponse.token);
    if (authResponse.refreshToken != null) {
      await localStorage.saveRefreshToken(authResponse.refreshToken!);
    }
    await localStorage.saveUser(authResponse.user);
    
    return authResponse.user;
  }

  @override
  Future<void> logout() async {
    await localStorage.clearTokens();
    await localStorage.clearUser();
  }

  @override
  Future<User?> getCurrentUser() async {
    return await localStorage.getUser();
  }

  @override
  Future<User> updateProfile({
    String? name,
    String? profilePicture,
  }) async {
    final response = await apiService.updateProfile(
      name: name,
      profilePicture: profilePicture,
    );
    final user = UserModel.fromJson(response['user'] ?? response);
    await localStorage.saveUser(user);
    return user;
  }

  @override
  Future<void> refreshToken() async {
    final refreshToken = await localStorage.getRefreshToken();
    if (refreshToken == null) {
      throw Exception('No refresh token available');
    }
    
    final response = await apiService.refreshToken(refreshToken);
    final newToken = response['token'] ?? response['accessToken'];
    final newRefreshToken = response['refreshToken'] ?? response['refresh_token'];
    
    if (newToken != null) {
      await localStorage.saveToken(newToken);
    }
    if (newRefreshToken != null) {
      await localStorage.saveRefreshToken(newRefreshToken);
    }
  }

  @override
  Future<bool> isLoggedIn() async {
    final token = await localStorage.getToken();
    return token != null && token.isNotEmpty;
  }

  @override
  Future<String?> getToken() async {
    return await localStorage.getToken();
  }
}


