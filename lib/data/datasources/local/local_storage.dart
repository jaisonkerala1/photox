import 'dart:convert';

import '../../../config/constants.dart';
import '../../models/user_model.dart';

class LocalStorage {
  final Map<String, dynamic> _storage = {};

  LocalStorage();

  Future<void> saveToken(String token) async { _storage[AppConstants.tokenKey] = token; }
  Future<String?> getToken() async { return _storage[AppConstants.tokenKey] as String?; }
  Future<void> saveRefreshToken(String token) async { _storage[AppConstants.refreshTokenKey] = token; }
  Future<String?> getRefreshToken() async { return _storage[AppConstants.refreshTokenKey] as String?; }
  Future<void> clearTokens() async { _storage.remove(AppConstants.tokenKey); _storage.remove(AppConstants.refreshTokenKey); }
  Future<void> saveUser(UserModel user) async { _storage[AppConstants.userKey] = jsonEncode(user.toJson()); }
  Future<UserModel?> getUser() async { final userJson = _storage[AppConstants.userKey] as String?; if (userJson != null) { return UserModel.fromJson(jsonDecode(userJson)); } return null; }
  Future<void> clearUser() async { _storage.remove(AppConstants.userKey); }
  Future<void> setOnboardingCompleted(bool completed) async { _storage[AppConstants.onboardingKey] = completed; }
  Future<bool> isOnboardingCompleted() async { return _storage[AppConstants.onboardingKey] as bool? ?? false; }
  Future<void> saveThemeMode(String mode) async { _storage[AppConstants.themeKey] = mode; }
  Future<String?> getThemeMode() async { return _storage[AppConstants.themeKey] as String?; }
  Future<void> setString(String key, String value) async { _storage[key] = value; }
  String? getString(String key) { return _storage[key] as String?; }
  Future<void> setBool(String key, bool value) async { _storage[key] = value; }
  bool? getBool(String key) { return _storage[key] as bool?; }
  Future<void> setInt(String key, int value) async { _storage[key] = value; }
  int? getInt(String key) { return _storage[key] as int?; }
  Future<void> remove(String key) async { _storage.remove(key); }
  Future<void> clearAll() async { _storage.clear(); }
}

