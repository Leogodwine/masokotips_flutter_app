import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../models/service.dart';
import '../models/market_info.dart';
import '../services/admin_service.dart';

class AdminProvider with ChangeNotifier {
  final AdminService _adminService = AdminService();
  bool _isLoading = false;
  String? _error;
  bool _isAdmin = false;
  Map<String, dynamic>? _dashboardData;
  List<User> _users = [];
  List<Service> _services = [];
  List<MarketInfo> _marketInfo = [];

  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAdmin => _isAdmin;
  Map<String, dynamic>? get dashboardData => _dashboardData;
  List<User> get users => _users;
  List<Service> get services => _services;
  List<MarketInfo> get marketInfo => _marketInfo;

  void setAuthToken(String token) {
    _adminService.setAuthToken(token);
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _adminService.login(email, password);

      if (response.containsKey('token')) {
        _isAdmin = true;
        setAuthToken(response['token']);
        return true;
      } else {
        _error = 'Invalid admin credentials';
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
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _dashboardData = await _adminService.getDashboardData();
    } catch (e) {
      _error = e.toString();
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

  void logout() {
    _isAdmin = false;
    _dashboardData = null;
    _users = [];
    _services = [];
    _marketInfo = [];
    notifyListeners();
  }
}
