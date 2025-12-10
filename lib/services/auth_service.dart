import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/api/user_model.dart';

class AuthService {
  // Update this with your server URL
  static const String baseUrl = 'http://localhost:8080/api';
  
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'user_data';

  // Save token to local storage
  Future<void> _saveToken(String token) async {
    const storage = FlutterSecureStorage();
    await storage.write(key: _tokenKey, value: token);
  }

  // Get token from local storage
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  // Save user data to local storage
  Future<void> _saveUser(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, json.encode(user.toJson()));
  }

  // Get user data from local storage
  Future<UserModel?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userData = prefs.getString(_userKey);
    if (userData != null) {
      return UserModel.fromJson(json.decode(userData));
    }
    return null;
  }

  // Clear all auth data
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userKey);
  }

  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null;
  }

  // Register new user
  Future<Map<String, dynamic>> register({
    required String email,
    required String username,
    required String password,
    required String fullName,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'username': username,
          'password': password,
          'fullName': fullName,
        }),
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        final token = data['token'] as String;
        final user = UserModel.fromJson(data['user']);
        
        await _saveToken(token);
        await _saveUser(user);

        return {'success': true, 'user': user};
      } else {
        return {'success': false, 'error': data['error'] ?? 'Registration failed'};
      }
    } catch (e) {
      return {'success': false, 'error': 'Network error: $e'};
    }
  }

  // Login user
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'password': password,
        }),
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        final token = data['token'] as String;
        final user = UserModel.fromJson(data['user']);
        
        await _saveToken(token);
        await _saveUser(user);

        return {'success': true, 'user': user};
      } else {
        return {'success': false, 'error': data['error'] ?? 'Login failed'};
      }
    } catch (e) {
      return {'success': false, 'error': 'Network error: $e'};
    }
  }

  // Verify token
  Future<bool> verifyToken() async {
    try {
      final token = await getToken();
      if (token == null) return false;

      final response = await http.get(
        Uri.parse('$baseUrl/auth/verify'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // Get user profile
  Future<Map<String, dynamic>> getProfile() async {
    try {
      final token = await getToken();
      if (token == null) {
        return {'success': false, 'error': 'Not authenticated'};
      }

      final response = await http.get(
        Uri.parse('$baseUrl/user/profile'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        final user = UserModel.fromJson(data['user']);
        await _saveUser(user);
        return {'success': true, 'user': user};
      } else {
        return {'success': false, 'error': data['error'] ?? 'Failed to get profile'};
      }
    } catch (e) {
      return {'success': false, 'error': 'Network error: $e'};
    }
  }

  // Update user profile
  Future<Map<String, dynamic>> updateProfile({
    String? fullName,
    String? username,
  }) async {
    try {
      final token = await getToken();
      if (token == null) {
        return {'success': false, 'error': 'Not authenticated'};
      }

      final body = <String, dynamic>{};
      if (fullName != null) body['fullName'] = fullName;
      if (username != null) body['username'] = username;

      final response = await http.put(
        Uri.parse('$baseUrl/user/profile'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(body),
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        final user = UserModel.fromJson(data['user']);
        await _saveUser(user);
        return {'success': true, 'user': user};
      } else {
        return {'success': false, 'error': data['error'] ?? 'Failed to update profile'};
      }
    } catch (e) {
      return {'success': false, 'error': 'Network error: $e'};
    }
  }
}