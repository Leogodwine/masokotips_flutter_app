import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:crypto/crypto.dart';
import '../utils/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';

class AdminAuthService {
  String? _authToken;
  late String baseUrl;
  static const String _adminTokenKey = 'admin_auth_token';
  static const String _adminSessionKey = 'admin_session_id';
  static const int _sessionTimeoutMinutes = 30;

  AdminAuthService() {
    baseUrl = ApiConfig.baseUrl;
  }

  String get getBaseUrl => baseUrl;

  // Initialize auth token from SharedPreferences
  Future<void> initializeAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_adminTokenKey);
    if (token != null) {
      _authToken = token;
      Log.d('Admin auth token initialized from storage');
    }
  }

  void setBaseUrl(String url) {
    baseUrl = url;
    Log.d('Admin API base URL set to: $baseUrl');
  }

  void setAuthToken(String token) {
    _authToken = token;
    Log.d('Admin auth token set: ${token.substring(0, 10)}...');
    // Save token to SharedPreferences
    SharedPreferences.getInstance().then((prefs) {
      prefs.setString(_adminTokenKey, token);
    });
  }

  // Hash password with SHA-256 before sending to server
  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  // Generate a secure session ID
  String _generateSessionId() {
    final random = DateTime.now().millisecondsSinceEpoch.toString();
    final bytes = utf8.encode(random);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  // Save admin session
  Future<void> _saveAdminSession(String sessionId) async {
    final prefs = await SharedPreferences.getInstance();
    final expiryTime =
        DateTime.now().add(Duration(minutes: _sessionTimeoutMinutes));
    await prefs.setString(_adminSessionKey, sessionId);
    await prefs.setString(
        '${_adminSessionKey}_expiry', expiryTime.toIso8601String());
  }

  // Check if admin session is valid
  Future<bool> isAdminSessionValid() async {
    final prefs = await SharedPreferences.getInstance();
    final sessionId = prefs.getString(_adminSessionKey);
    final expiryStr = prefs.getString('${_adminSessionKey}_expiry');

    if (sessionId == null || expiryStr == null) {
      return false;
    }

    final expiryTime = DateTime.parse(expiryStr);
    if (DateTime.now().isAfter(expiryTime)) {
      await _clearAdminSession();
      return false;
    }

    return true;
  }

  // Clear admin session
  Future<void> _clearAdminSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_adminSessionKey);
    await prefs.remove('${_adminSessionKey}_expiry');
  }

  // Verify admin credentials with additional security
  Future<bool> verifyAdminCredentials(String email, String password) async {
    try {
      Log.d('Verifying admin credentials for email: $email');

      final deviceInfo = {
        'platform': 'flutter',
        'timestamp': DateTime.now().toIso8601String(),
      };

      Log.d('Sending verification request to: $baseUrl/admin/verify');

      final response = await http.post(
        Uri.parse('$baseUrl/admin/verify'),
        headers: {
          'Content-Type': 'application/json',
          if (_authToken != null) 'Authorization': 'Bearer $_authToken',
        },
        body: json.encode({
          'email': email,
          'password': password,
          'device_info': deviceInfo,
        }),
      );

      Log.d('Verification response status: ${response.statusCode}');
      Log.d('Verification response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          final sessionId = _generateSessionId();
          await _saveAdminSession(sessionId);
          Log.d('Admin credentials verified successfully');
          return true;
        } else {
          Log.e(
              'Admin verification failed: ${data['message'] ?? 'Unknown error'}');
          return false;
        }
      } else if (response.statusCode == 401) {
        Log.e('Admin verification failed: Unauthorized');
        return false;
      } else if (response.statusCode == 403) {
        Log.e('Admin verification failed: User is not an admin');
        return false;
      } else if (response.statusCode == 404) {
        Log.e('Admin verification failed: Admin not found');
        return false;
      } else {
        Log.e(
            'Admin verification failed with status code: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      Log.e('Error verifying admin credentials: $e');
      return false;
    }
  }

  // Login admin
  Future<Map<String, dynamic>> loginAdmin(String email, String password) async {
    try {
      Log.d('Logging in admin with email: $email');

      Log.d('Sending login request to: $baseUrl/admin/login');

      final response = await http.post(
        Uri.parse('$baseUrl/admin/login'),
        headers: {
          'Content-Type': 'application/json',
          if (_authToken != null) 'Authorization': 'Bearer $_authToken',
        },
        body: json.encode({
          'email': email,
          'password': password,
        }),
      );

      Log.d('Login response status: ${response.statusCode}');
      Log.d('Login response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          final token = data['token'];
          if (token != null) {
            setAuthToken(token);
            await _saveAdminSession(_generateSessionId());
            Log.d('Admin login successful');
            return data;
          }
        }
      }

      Log.e('Admin login failed: ${response.body}');
      throw Exception('Login failed: ${response.body}');
    } catch (e) {
      Log.e('Error during admin login: $e');
      rethrow;
    }
  }

  // Create admin account with additional security measures
  Future<bool> createAdminAccount(
      String name, String email, String password, String adminKey) async {
    try {
      Log.d('Creating admin account for email: $email');

      // Send plain text password instead of hashed
      final deviceInfo = {
        'platform': 'flutter',
        'timestamp': DateTime.now().toIso8601String(),
      };

      Log.d('Sending create admin request to: $baseUrl/admin/create');

      final response = await http.post(
        Uri.parse('$baseUrl/admin/create'),
        headers: {
          'Content-Type': 'application/json',
          if (_authToken != null) 'Authorization': 'Bearer $_authToken',
        },
        body: json.encode({
          'name': name,
          'email': email,
          'password': password, // Send plain text password
          'admin_key': adminKey,
          'device_info': deviceInfo,
        }),
      );

      Log.d('Create admin response status: ${response.statusCode}');
      Log.d('Create admin response body: ${response.body}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          Log.d('Admin account created successfully');
          return true;
        }
      }

      Log.e('Failed to create admin account: ${response.body}');
      return false;
    } catch (e) {
      Log.e('Error creating admin account: $e');
      return false;
    }
  }

  // Logout admin
  Future<void> logoutAdmin() async {
    try {
      Log.d('Logging out admin');
      await _clearAdminSession();
      _authToken = null;
      // Clear token from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_adminTokenKey);
      Log.d('Admin session cleared');
    } catch (e) {
      Log.e('Error during admin logout: $e');
      rethrow;
    }
  }
}
