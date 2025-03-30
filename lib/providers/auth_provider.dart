import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import '../services/transport_service.dart';
import '../models/user.dart';

class AuthProvider with ChangeNotifier {
  final ApiService _apiService = ApiService(
    baseUrl: 'http://127.0.0.1:8000/api',
    apiKey: 'your-api-key', // Replace with actual API key
  );
  final TransportService _transportService = TransportService();
  String? _token;
  User? _user;

  String? get token => _token;
  User? get user => _user;

  bool get isAuthenticated => _token != null;

  // Update user profile
  Future<void> updateProfile({
    required String name,
    required String email,
    String? phone,
    String? bio,
    String? avatarPath, // Added avatarPath parameter
  }) async {
    try {
      _user = await _apiService.updateProfile(
        name: name,
        email: email,
        phone: phone,
        bio: bio,
        avatarPath: avatarPath, // Pass avatarPath to ApiService
      );
      notifyListeners();
    } catch (e) {
      throw Exception('Failed to update profile: $e');
    }
  }

  // Change password
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      await _apiService.changePassword(
        currentPassword,
        newPassword,
      );
    } catch (e) {
      throw Exception('Failed to change password: $e');
    }
  }

  // Login
  Future<void> login(String email, String password) async {
    try {
      final response = await _apiService.login(email, password);

      // Handle the response format from Laravel
      if (response['token'] != null) {
        _token = response['token'];
        await _saveToken(_token!);

        // Set the auth token in TransportService
        _transportService.setAuthToken(_token!);

        // Create user object from the response
        if (response['user'] != null) {
          _user = User.fromJson(response['user']);
        }

        notifyListeners();
      } else {
        throw Exception('Invalid response format: Token not found');
      }
    } catch (e) {
      throw Exception('Login failed: $e');
    }
  }

  // Register
  Future<void> register(String name, String email, String password,
      {String role = 'buyer'}) async {
    try {
      await _apiService.register(name, email, password, role: role);
    } catch (e) {
      throw Exception('Registration failed: $e');
    }
  }

  // Logout
  Future<void> logout() async {
    try {
      await _apiService.logout();
      _token = null;
      _user = null;
      await _clearToken();
      notifyListeners();
    } catch (e) {
      throw Exception('Logout failed: $e');
    }
  }

  // Fetch user profile
  Future<void> fetchUserProfile() async {
    try {
      _user = await _apiService.getUserProfile();
      notifyListeners();
    } catch (e) {
      throw Exception('Failed to fetch user profile: $e');
    }
  }

  // Duplicate changePassword method removed

  // Upload profile image
  Future<void> uploadProfileImage(String imagePath) async {
    try {
      await _apiService.uploadProfileImage(imagePath);
      await fetchUserProfile(); // Refresh user profile after upload
    } catch (e) {
      throw Exception('Failed to upload profile image: $e');
    }
  }

  // Save token to shared preferences
  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  // Clear token from shared preferences
  Future<void> _clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }

  // Load token from shared preferences
  Future<void> loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('auth_token');
    if (_token != null) {
      // Set the auth token in TransportService
      _transportService.setAuthToken(_token!);
      await fetchUserProfile();
    }
    notifyListeners();
  }
}
