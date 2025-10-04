import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';
import '../../../../core/network/api_client.dart';
import '../../../../core/constants/api_constants.dart';
import '../models/user_model.dart';

class AuthRepository {
  final ApiClient _apiClient = ApiClient();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  UserModel? _currentUser;
  UserModel? get currentUser => _currentUser;

  // Login
  Future<bool> login(String email, String password) async {
    try {
      print('🔵 [AUTH] Starting login attempt...');
      print('🔵 [AUTH] API Base URL: ${ApiConstants.baseUrl}');
      print('🔵 [AUTH] Login endpoint: ${ApiConstants.login}');
      print('🔵 [AUTH] Full URL: ${ApiConstants.baseUrl}${ApiConstants.login}');
      print('🔵 [AUTH] Email: $email');

      final response = await _apiClient.post(
        ApiConstants.login,
        data: {
          'email': email,
          'password': password,
        },
      );

      print('✅ [AUTH] Response received!');
      print('✅ [AUTH] Status Code: ${response.statusCode}');
      print('✅ [AUTH] Response Data: ${response.data}');

      if (response.statusCode == 200 && response.data['success'] == true) {
        print('✅ [AUTH] Login successful!');
        final user = UserModel.fromJson(response.data['user']);
        _currentUser = user;

        // Save user data
        await _storage.write(
          key: 'user_data',
          value: jsonEncode(user.toJson()),
        );
        print('✅ [AUTH] User data saved to storage');

        // Save token if provided
        if (response.data['token'] != null) {
          await _apiClient.setToken(response.data['token']);
          print('✅ [AUTH] Token saved: ${response.data['token'].substring(0, 20)}...');
        }

        return true;
      }

      print('❌ [AUTH] Login failed - invalid response');
      return false;
    } catch (e) {
      print('❌ [AUTH] Login error caught!');
      print('❌ [AUTH] Error type: ${e.runtimeType}');
      print('❌ [AUTH] Error message: ${e.toString()}');
      print('❌ [AUTH] Stack trace: ${StackTrace.current}');
      throw Exception('로그인 실패: ${e.toString()}');
    }
  }

  // Register
  Future<bool> register({
    required String email,
    required String password,
    required String name,
    required String phone,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.register,
        data: {
          'email': email,
          'password': password,
          'name': name,
          'phone': phone,
          'role': 'patient',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      }

      return false;
    } catch (e) {
      throw Exception('회원가입 실패: ${e.toString()}');
    }
  }

  // Logout
  Future<void> logout() async {
    try {
      await _apiClient.post(ApiConstants.logout);
    } catch (e) {
      // Continue logout even if API call fails
    } finally {
      _currentUser = null;
      await _apiClient.clearToken();
      await _storage.delete(key: 'user_data');
    }
  }

  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    final userData = await _storage.read(key: 'user_data');
    if (userData != null) {
      try {
        _currentUser = UserModel.fromJson(jsonDecode(userData));
        return true;
      } catch (e) {
        return false;
      }
    }
    return false;
  }

  // Get current user
  Future<UserModel?> getCurrentUser() async {
    if (_currentUser != null) return _currentUser;

    final userData = await _storage.read(key: 'user_data');
    if (userData != null) {
      try {
        _currentUser = UserModel.fromJson(jsonDecode(userData));
        return _currentUser;
      } catch (e) {
        return null;
      }
    }

    // Try to fetch from server
    try {
      final response = await _apiClient.get(ApiConstants.me);
      if (response.statusCode == 200 && response.data['user'] != null) {
        final user = UserModel.fromJson(response.data['user']);
        _currentUser = user;
        await _storage.write(
          key: 'user_data',
          value: jsonEncode(user.toJson()),
        );
        return user;
      }
    } catch (e) {
      // Failed to fetch from server
    }

    return null;
  }
}
