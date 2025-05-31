import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../utils/logger.dart';
import '../config/api_config.dart';

class AuthService {
  static String get _baseUrl => ApiConfig.baseUrl;
  static const String _tokenKey = 'auth_token';
  String? _authToken;

  Future<bool> login(String email, String password) async {
    try {
      Log.d('Attempting login for user: $email');

      final response = await http.post(
        Uri.parse('$_baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'password': password,
        }),
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200 && data['token'] != null) {
        _authToken = data['token'];

        // Save token
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_tokenKey, _authToken!);

        Log.d('User logged in successfully');
        return true;
      }

      Log.w('Login failed: ${data['message'] ?? 'Unknown error'}');
      return false;
    } catch (e) {
      Log.e('Login error: $e');
      return false;
    }
  }

  Future<void> logout() async {
    try {
      Log.d('Logging out user');

      // Call API to revoke token if we have one
      if (_authToken != null) {
        try {
          final response = await http.post(
            Uri.parse(
                '$_baseUrl/user/logout'), // Changed from /auth/logout to /user/logout
            headers: {
              'Authorization': 'Bearer $_authToken',
              'Accept': 'application/json',
            },
          );

          if (response.statusCode == 200) {
            Log.d('Token revoked on server');
          } else {
            Log.w('Logout failed with status: ${response.statusCode}');
            throw Exception('Failed to logout: ${response.body}');
          }
        } catch (e) {
          Log.w('Failed to revoke token on server: $e');
          // Continue with local cleanup even if API call fails
        }
      }

      // Clear local storage
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_tokenKey);
      _authToken = null;

      Log.d('Logout completed successfully');
    } catch (e) {
      Log.e('Error during logout: $e');
      rethrow;
    }
  }

  Future<String?> getToken() async {
    if (_authToken != null) return _authToken;

    final prefs = await SharedPreferences.getInstance();
    _authToken = prefs.getString(_tokenKey);
    return _authToken;
  }

  Future<bool> isAuthenticated() async {
    final token = await getToken();
    return token != null;
  }

  Future<void> clearAuth() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    _authToken = null;
  }
}
