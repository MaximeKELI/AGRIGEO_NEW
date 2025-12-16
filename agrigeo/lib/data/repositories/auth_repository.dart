import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';
import '../../core/constants/app_constants.dart';
import '../../core/errors/failures.dart';
import '../datasources/api_service.dart';
import '../models/user_model.dart';

class AuthRepository {
  final ApiService _apiService;
  final FlutterSecureStorage _storage;

  AuthRepository({ApiService? apiService, FlutterSecureStorage? storage})
      : _apiService = apiService ?? ApiService(),
        _storage = storage ?? const FlutterSecureStorage();

  Future<UserModel> login(String username, String password) async {
    try {
      final response = await _apiService.login(username, password);
      final token = response.data['access_token'];
      final userData = response.data['user'];

      // Sauvegarder le token
      await _storage.write(key: AppConstants.tokenKey, value: token);
      await _storage.write(key: AppConstants.userKey, value: jsonEncode(userData));

      return UserModel.fromJson(userData);
    } catch (e) {
      if (e is Failure) rethrow;
      throw ServerFailure(e.toString());
    }
  }

  Future<UserModel> register(Map<String, dynamic> data) async {
    try {
      final response = await _apiService.register(data);
      final userData = response.data['user'];
      return UserModel.fromJson(userData);
    } catch (e) {
      if (e is Failure) rethrow;
      throw ServerFailure(e.toString());
    }
  }

  Future<UserModel?> getCurrentUser() async {
    try {
      final response = await _apiService.getCurrentUser();
      return UserModel.fromJson(response.data);
    } catch (e) {
      return null;
    }
  }

  Future<void> logout() async {
    await _storage.delete(key: AppConstants.tokenKey);
    await _storage.delete(key: AppConstants.userKey);
  }

  Future<bool> isLoggedIn() async {
    final token = await _storage.read(key: AppConstants.tokenKey);
    return token != null;
  }
}

