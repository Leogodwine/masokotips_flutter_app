import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../models/service.dart';
import '../models/market_info.dart';
import '../services/admin_service.dart';
import '../services/admin_auth_service.dart';
import '../models/admin_dashboard_data.dart';
import '../utils/logger.dart';

class AdminProvider with ChangeNotifier {
  final AdminService _adminService = AdminService();
  final AdminAuthService _adminAuthService = AdminAuthService();
  bool _isLoading = false;
  String? _error;
  bool _isAdmin = false;
  AdminDashboardData? _dashboardData;
  List<User> _users = [];
  List<Service> _services = [];
  List<MarketInfo> _marketInfo = [];

  AdminProvider() {
    _initializeAuth();
  }

  Future<void> _initializeAuth() async {
    try {
      Log.d('Initializing admin auth');
      await _adminAuthService.initializeAuthToken();
      final token = _adminAuthService.authToken;
      if (token != null) {
        setAuthToken(token);
        Log.d('Auth token initialized from storage');
        await loadDashboardData();
      } else {
        Log.d('No stored auth token found');
      }
    } catch (e, stackTrace) {
      Log.e('Error initializing auth: $e\n$stackTrace');
    }
  }

  AdminDashboardData? get dashboardData => _dashboardData;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAdmin => _isAdmin;
  List<User> get users => _users;
  List<Service> get services => _services;
  List<MarketInfo> get marketInfo => _marketInfo;

  void setAuthToken(String token) {
    _adminService.setAuthToken(token);
    _adminAuthService.setAuthToken(token);
    Log.d('Auth token set in both services');
  }

  Future<bool> login(String email, String password) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      Log.d('Attempting admin login for email: $email');

      final success = await _adminAuthService.login(email, password);
      Log.d('Login result: $success');

      if (success) {
        final token = _adminAuthService.authToken;
        if (token != null) {
          setAuthToken(token);
          Log.d('Auth token set successfully');
          await loadDashboardData();
          return true;
        } else {
          Log.e('Login successful but no token received');
          _error = 'Login successful but no token received';
          return false;
        }
      } else {
        Log.e('Login failed');
        _error = 'Invalid credentials';
        return false;
      }
    } catch (e, stackTrace) {
      Log.e('Error during login: $e\n$stackTrace');
      _error = 'Login failed: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> register(String name, String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _adminService.register(name, email, password);

      if (response.containsKey('token')) {
        _isAdmin = true;
        setAuthToken(response['token']);
        return true;
      } else {
        _error = 'Failed to register admin account';
        return false;
      }
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadDashboardData() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      Log.d('Starting to load dashboard data');

      if (_adminAuthService.authToken == null) {
        Log.e('No auth token available for dashboard request');
        _error = 'Not authenticated. Please login again.';
        return;
      }

      final response = await _adminAuthService.getDashboardData();
      Log.d('Dashboard response received: ${response.toString()}');

      if (response['success'] == true) {
        final data = response['data'];
        if (data == null) {
          Log.e('Dashboard data is null');
          _error = 'Failed to load dashboard data: No data received';
          return;
        }

        try {
          final dashboardData = data as Map<String, dynamic>;
          Log.d('Parsing dashboard data: ${dashboardData.toString()}');

          // Ensure all required fields are present
          if (!dashboardData.containsKey('stats') ||
              !dashboardData.containsKey('recent_activities') ||
              !dashboardData.containsKey('system_info') ||
              !dashboardData.containsKey('quick_links') ||
              !dashboardData.containsKey('last_updated')) {
            Log.e('Invalid dashboard data structure: Missing required fields');
            _error = 'Invalid dashboard data structure';
            return;
          }

          _dashboardData = AdminDashboardData.fromJson(dashboardData);
          _error = null;
          _isAdmin = true;
          Log.d('Dashboard data loaded and parsed successfully');
        } catch (e, stackTrace) {
          Log.e('Error parsing dashboard data: $e\n$stackTrace');
          _error = 'Failed to parse dashboard data: $e';
        }
      } else {
        _error = response['message'] ?? 'Failed to load dashboard data';
        Log.e('Dashboard load failed: $_error');
      }
    } catch (e, stackTrace) {
      Log.e('Error loading dashboard data: $e\n$stackTrace');
      _error = 'Failed to load dashboard data: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadUsers() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _users = await _adminService.getUsers();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadServices() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _services = await _adminService.getServices();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadMarketInfo() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _marketInfo = await _adminService.getMarketInfo();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateUser(int userId, Map<String, dynamic> userData) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final updatedUser = await _adminService.updateUser(userId, userData);
      final index = _users.indexWhere((user) => user.id == userId);
      if (index != -1) {
        _users[index] = updatedUser;
      }
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteUser(int userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _adminService.deleteUser(userId);
      _users.removeWhere((user) => user.id == userId);
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateService(
      int serviceId, Map<String, dynamic> serviceData) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final updatedService =
          await _adminService.updateService(serviceId, serviceData);
      final index = _services.indexWhere((service) => service.id == serviceId);
      if (index != -1) {
        _services[index] = updatedService;
      }
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteService(int serviceId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _adminService.deleteService(serviceId);
      _services.removeWhere((service) => service.id == serviceId);
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createMarketInfo(Map<String, dynamic> marketInfoData) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final newMarketInfo =
          await _adminService.createMarketInfo(marketInfoData);
      _marketInfo.add(newMarketInfo);
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateMarketInfo(
      int marketInfoId, Map<String, dynamic> marketInfoData) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final updatedMarketInfo =
          await _adminService.updateMarketInfo(marketInfoId, marketInfoData);
      final index = _marketInfo.indexWhere((info) => info.id == marketInfoId);
      if (index != -1) {
        _marketInfo[index] = updatedMarketInfo;
      }
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteMarketInfo(int marketInfoId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _adminService.deleteMarketInfo(marketInfoId);
      _marketInfo.removeWhere((info) => info.id == marketInfoId);
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _adminAuthService.logout();
      _dashboardData = null;
      _error = null;
      _isAdmin = false;
      _users = [];
      _services = [];
      _marketInfo = [];
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
