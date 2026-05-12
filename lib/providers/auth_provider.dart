import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';

import '../services/api_service.dart';
import '../services/network_service.dart';
import '../services/transport_service.dart';
import '../models/user.dart';
import '../config/api_config.dart';
import '../utils/logger.dart';

class AuthProvider with ChangeNotifier {
  late final ApiService _apiService;
  final NetworkService _networkService = NetworkService.instance;
  final TransportService _transportService = TransportService();

  String? _token;
  User? _user;
  bool _isInitialized = false;

  AuthProvider() {
    _apiService = ApiService(
      baseUrl: ApiConfig.baseUrl,
      apiKey: ApiConfig.apiKey,
    );

    _networkService.initialize();
    loadToken(); // 🔥 critical
  }

  // ---------------------------------------------------------------------------
  // GETTERS
  // ---------------------------------------------------------------------------

  String? get token => _token;
  User? get user => _user;
  bool get isAuthenticated => _token != null;
  bool get isInitialized => _isInitialized;

  // ---------------------------------------------------------------------------
  // AUTH – LOGIN
  // ---------------------------------------------------------------------------

  Future<void> login(String username, String password) async {
    try {
      final response = await _apiService.login(username, password);

      if (response['token'] == null) {
        throw Exception('Login response missing token');
      }

      _token = response['token'];
      await _saveToken(_token!);

      _applyTokenToServices(_token!);

      if (response['user'] != null) {
        _user = User.fromJson(response['user']);
      } else {
        await fetchUserProfile();
      }

      notifyListeners();
      Log.d('✅ Login successful: ${_user?.name ?? username}');
    } catch (e) {
      Log.e('❌ Login failed: $e');
      rethrow;
    }
  }

  // ---------------------------------------------------------------------------
  // AUTH – REGISTER (NO AUTO LOGIN)
  // ---------------------------------------------------------------------------

  Future<void> register(
    String name,
    String username,
    String email,
    String password, {
    String role = 'buyer',
    String? phone,
    String? location,
    String? country,
    String? proofOfAddressType,
    File? proofOfAddress,
    String? referralCode,
  }) async {
    try {
      await _apiService.register(
        name,
        username,
        email,
        password,
        role: role,
        phone: phone,
        location: location,
        country: country,
        proofOfAddressType: proofOfAddressType,
        proofOfAddress: proofOfAddress,
        referralCode: referralCode,
      );
    } catch (e) {
      throw Exception('Registration failed: $e');
    }
  }

  // ---------------------------------------------------------------------------
  // LOAD TOKEN (CRITICAL FOR SUBSCRIPTIONS)
  // ---------------------------------------------------------------------------

  Future<void> loadToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _token = prefs.getString('auth_token');

      if (_token != null) {
        _applyTokenToServices(_token!);
        await fetchUserProfile();
      }

      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      Log.e('Error loading auth token: $e');
      _isInitialized = true;
      notifyListeners();
    }
  }

  // ---------------------------------------------------------------------------
  // LOGOUT
  // ---------------------------------------------------------------------------

  Future<void> logout() async {
    try {
      final token = _token;

      _token = null;
      _user = null;
      await _clearToken();

      notifyListeners();

      if (token != null) {
        _apiService.setAuthToken(token);
        await _apiService.logout();
      }
    } catch (e) {
      Log.e('Logout error: $e');
    }
  }

  // ---------------------------------------------------------------------------
  // USER PROFILE
  // ---------------------------------------------------------------------------

  Future<void> fetchUserProfile() async {
    try {
      _user = await _apiService.getUserProfile();
      notifyListeners();
    } catch (e) {
      Log.e('Fetch profile failed: $e');
    }
  }

  Future<void> updateProfile({
    required String name,
    required String email,
    String? phone,
    String? bio,
    String? avatarPath,
  }) async {
    try {
      _user = await _apiService.updateProfile(
        name: name,
        email: email,
        phone: phone,
        bio: bio,
        avatarPath: avatarPath,
      );
      notifyListeners();
    } catch (e) {
      throw Exception('Profile update failed: $e');
    }
  }

  // ---------------------------------------------------------------------------
  // PASSWORD
  // ---------------------------------------------------------------------------

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
      throw Exception('Password change failed: $e');
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      await _apiService.resetPassword(email);
    } catch (e) {
      throw Exception('Reset password failed: $e');
    }
  }

  // ---------------------------------------------------------------------------
  // ROLE MANAGEMENT
  // ---------------------------------------------------------------------------

  Future<Map<String, dynamic>> getUserRoles() async {
    return await _apiService.getUserRoles();
  }

  Future<void> addUserRole(String role) async {
    await _apiService.addUserRole(role);
    await fetchUserProfile();
  }

  Future<void> removeUserRole(String role) async {
    await _apiService.removeUserRole(role);
    await fetchUserProfile();
  }

  // ---------------------------------------------------------------------------
  // HELPERS
  // ---------------------------------------------------------------------------

  void _applyTokenToServices(String token) {
    _apiService.setAuthToken(token);
    _transportService.setAuthToken(token);
    _networkService.setAuthToken(token);
  }

  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  Future<void> _clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }

  // ---------------------------------------------------------------------------
  // CONVENIENCE FLAGS
  // ---------------------------------------------------------------------------

  bool get isBuyer => _user?.isBuyer ?? false;
  bool get isSeller => _user?.isSeller ?? false;
  bool get isServiceProvider => _user?.isServiceProvider ?? false;
  bool get isTransporter => _user?.isTransporter ?? false;
  bool get isAdmin => _user?.isAdmin ?? false;
  bool get hasMultipleRoles => _user?.hasMultipleRoles ?? false;

  List<String> get accessibleFeatures => _user?.accessibleFeatures ?? [];
}
