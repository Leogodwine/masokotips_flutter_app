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

  // User-Agent header to identify as legitimate mobile app
  static const String _userAgent =
      'Mozilla/5.0 (Linux; Android 10; SM-G975F) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.120 Mobile Safari/537.36';

  String get getBaseUrl => baseUrl;

  String? get authToken => _authToken;

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
        DateTime.now().add(const Duration(minutes: _sessionTimeoutMinutes));
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

      final response = await http.post(
        Uri.parse('$baseUrl/admin/login'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json, text/plain, */*',
          'Accept-Language': 'en-US,en;q=0.9',
          'User-Agent': _userAgent,
          'Origin': baseUrl.replaceAll('/api', ''),
          'Referer': baseUrl.replaceAll('/api', ''),
        },
        body: json.encode({
          'email': email,
          'password': password,
        }),
      );

      Log.d('Verification response status: ${response.statusCode}');
      Log.d('Verification response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true && data['user'] != null) {
          final user = data['user'];
          if (user['is_admin'] == true ||
              (user['roles'] as List).contains('admin')) {
            // Set the auth token if available
            if (data['token'] != null) {
              setAuthToken(data['token']);
            }
            final sessionId = _generateSessionId();
            await _saveAdminSession(sessionId);
            Log.d('Admin credentials verified successfully');
            return true;
          }
        }
      }

      Log.e('Admin verification failed: ${response.body}');
      return false;
    } catch (e) {
      Log.e('Error verifying admin credentials: $e');
      return false;
    }
  }

  // Login admin - simplified to avoid redundant API calls
  Future<Map<String, dynamic>> loginAdmin(
      String username, String password) async {
    try {
      Log.d('Logging in admin with username: $username');

      final response = await http.post(
        Uri.parse('$baseUrl/admin/login'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json, text/plain, */*',
          'Accept-Language': 'en-US,en;q=0.9',
          'User-Agent': _userAgent,
          'Origin': baseUrl.replaceAll('/api', ''),
          'Referer': baseUrl.replaceAll('/api', ''),
        },
        body: json.encode({
          'username': username,
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
          'Accept': 'application/json, text/plain, */*',
          'Accept-Language': 'en-US,en;q=0.9',
          'User-Agent': _userAgent,
          'Origin': baseUrl.replaceAll('/api', ''),
          'Referer': baseUrl.replaceAll('/api', ''),
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
  // Main admin logout method
  Future<void> logoutAdmin() async {
    try {
      Log.d('Logging out admin');

      // Call the standard logout endpoint
      if (_authToken != null) {
        try {
          final response = await http.post(
            Uri.parse('$baseUrl/user/logout'),
            headers: {
              'Authorization': 'Bearer $_authToken',
              'Accept': 'application/json, text/plain, */*',
              'Accept-Language': 'en-US,en;q=0.9',
              'User-Agent': _userAgent,
              'Origin': baseUrl.replaceAll('/api', ''),
              'Referer': baseUrl.replaceAll('/api', ''),
            },
          );

          if (response.statusCode != 200) {
            throw Exception('Failed to logout: ${response.body}');
          }

          Log.d('Admin token revoked on server');
        } catch (e) {
          Log.w('Failed to revoke token on server: $e');
          // Continue with local cleanup even if API call fails
        }
      }

      // Clear local session
      await _clearAdminSession();

      // Clear token
      _authToken = null;

      // Clear SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_adminTokenKey);

      Log.d('Admin logout completed successfully');
    } catch (e) {
      Log.e('Error during admin logout: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getDashboardData() async {
    if (_authToken == null) {
      Log.e('No auth token available for dashboard request');
      throw Exception('Not authenticated. Please login again.');
    }

    try {
      Log.d(
          'Fetching dashboard data with token: ${_authToken!.substring(0, 10)}...');

      final response = await http.get(
        Uri.parse('$baseUrl/admin/dashboard'),
        headers: {
          'Authorization': 'Bearer $_authToken',
          'Accept': 'application/json, text/plain, */*',
          'Accept-Language': 'en-US,en;q=0.9',
          'User-Agent': _userAgent,
          'Origin': baseUrl.replaceAll('/api', ''),
          'Referer': baseUrl.replaceAll('/api', ''),
        },
      );

      Log.d('Dashboard response status: ${response.statusCode}');
      Log.d('Dashboard response headers: ${response.headers}');
      Log.d('Dashboard response body: ${response.body}');
      Log.d(
          'Dashboard response content-type: ${response.headers['content-type']}');
      Log.d('🟢 Raw response: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> decoded = jsonDecode(response.body);
        Log.d('Decoded dashboard data: $decoded');

        if (decoded.containsKey('success') &&
            decoded['success'] == true &&
            decoded.containsKey('data')) {
          final data = decoded['data'] as Map<String, dynamic>;
          return data;
        } else {
          final message = decoded['message'] ?? 'Unexpected response format';
          throw Exception(message);
        }
      } else if (response.statusCode == 401) {
        _authToken = null; // Clear invalid token
        Log.e('Session expired, clearing auth token');
        throw Exception('Session expired. Please login again.');
      } else {
        Log.e('Dashboard request failed with status: ${response.statusCode}');
        String errorMessage =
            'Failed to get dashboard data: ${response.statusCode}';
        try {
          final errorData = jsonDecode(response.body);
          if (errorData is Map<String, dynamic> &&
              errorData.containsKey('message')) {
            errorMessage = errorData['message'] ?? errorMessage;
          }
        } catch (e) {
          Log.e('Error parsing error response: $e');
        }

        throw Exception(errorMessage);
      }
    } catch (e, stackTrace) {
      final errorMessage = 'Failed to get dashboard data: $e';
      Log.e(
          'Error fetching dashboard data: $errorMessage\nStack trace: $stackTrace');
      rethrow; // Allow the original error to bubble up for now
    }
  }
}
