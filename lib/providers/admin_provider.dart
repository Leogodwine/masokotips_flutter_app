import '../models/user.dart';
import '../models/service.dart';
import '../models/market_info.dart';
import '../models/product.dart';
import '../models/organic_product.dart';
import '../models/transport.dart';
import '../services/admin_service.dart';
import '../services/admin_auth_service.dart';
import '../models/admin_dashboard_data.dart';
import '../utils/logger.dart';
import '../models/category.dart' as models;
import 'package:flutter/material.dart';

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
  List<Product> _products = [];
  List<OrganicProduct> _organicProducts = [];
  List<Transport> _transports = [];
  List<models.Category> _categories = [];

  AdminProvider() {
    _initializeAuth();
  }

  Future<void> _initializeAuth() async {
    try {
      Log.d('Initializing admin auth');
      await _adminAuthService.initializeAuthToken();
      final token = _adminAuthService.authToken;

      if (token != null && token.isNotEmpty) {
        Log.d('Auth token found: ${token.substring(0, 10)}...');
        setAuthToken(token);
        Log.d('Auth token set in services');

        // Verify the token is valid by making a test request
        try {
          await loadDashboardData();
          Log.d('Auth token verified successfully');
        } catch (e) {
          Log.e('Auth token verification failed: $e');
          // Clear invalid token
          await _adminAuthService.logout();
          _isAdmin = false;
          _dashboardData = null;
        }
      } else {
        Log.d('No valid auth token found');
        _isAdmin = false;
        _dashboardData = null;
      }
    } catch (e, stackTrace) {
      Log.e('Error initializing auth: $e\n$stackTrace');
      _isAdmin = false;
      _dashboardData = null;
    }
  }

  AdminDashboardData? get dashboardData => _dashboardData;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAdmin => _isAdmin;
  List<User> get users => _users;
  List<Service> get services => _services;
  List<MarketInfo> get marketInfo => _marketInfo;
  List<Product> get products => _products;
  List<OrganicProduct> get organicProducts => _organicProducts;
  List<Transport> get transports => _transports;
  List<models.Category> get categories => _categories;

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

      if (_adminAuthService.authToken == null ||
          _adminAuthService.authToken!.isEmpty) {
        Log.e('No valid auth token available for dashboard request');
        _error = 'Not authenticated. Please login again.';
        _isAdmin = false;
        _dashboardData = null;
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
        if (response['message']
                ?.toString()
                .toLowerCase()
                .contains('unauthenticated') ??
            false) {
          Log.e('Authentication failed, clearing token');
          await _adminAuthService.logout();
          _isAdmin = false;
          _dashboardData = null;
          _error = 'Session expired. Please login again.';
        } else {
          _error = response['message'] ?? 'Failed to load dashboard data';
          Log.e('Dashboard load failed: $_error');
        }
      }
    } catch (e, stackTrace) {
      Log.e('Error loading dashboard data: $e\n$stackTrace');
      if (e.toString().toLowerCase().contains('unauthenticated')) {
        await _adminAuthService.logout();
        _isAdmin = false;
        _dashboardData = null;
        _error = 'Session expired. Please login again.';
      } else {
        _error = 'Failed to load dashboard data: $e';
      }
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

  Future<void> loadProducts() async {
    try {
      _isLoading = true;
      _error = null;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });

      _products = await _adminService.getProducts();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
    }
  }

  Future<void> loadOrganicProducts() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _organicProducts = await _adminService.getOrganicProducts();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadTransports() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _transports = await _adminService.getTransports();
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
      final index =
          _marketInfo.indexWhere((info) => info.id == marketInfoId.toString());
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

  Future<bool> deleteProduct(int productId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _adminService.deleteProduct(productId);
      _products.removeWhere((product) => product.id == productId);
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Product> updateProduct(
      int productId, Map<String, dynamic> productData) async {
    try {
      Log.d('AdminProvider - updateProduct:');
      Log.d('- is_active: ${productData['is_active']}');
      Log.d('- is_featured: ${productData['is_featured']}');

      _isLoading = true;
      _error = null;
      notifyListeners();

      final updatedProduct =
          await _adminService.updateProduct(productId, productData);
      final index = _products.indexWhere((p) => p.id == productId);
      if (index != -1) {
        _products[index] = updatedProduct;
      }
      return updatedProduct;
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Product> createProduct(Map<String, dynamic> productData) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final product = await _adminService.createProduct(
        name: productData['name'],
        description: productData['description'],
        price: productData['price'],
        stock: productData['stock'],
        unit: productData['unit'],
        categoryId: productData['category_id'],
        isActive: productData['is_active'] is bool
            ? productData['is_active']
            : productData['is_active'] == 1,
        isFeatured: productData['is_featured'] is bool
            ? productData['is_featured']
            : productData['is_featured'] == 1,
        images: productData['images'],
      );
      _products.add(product);
      return product;
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteOrganicProduct(int productId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _adminService.deleteOrganicProduct(productId);
      _organicProducts.removeWhere((product) => product.id == productId);
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteTransport(int transportId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _adminService.deleteTransport(transportId);
      _transports.removeWhere((transport) => transport.id == transportId);
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
      _products = [];
      _organicProducts = [];
      _transports = [];
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<List<models.Category>> getCategories() async {
    try {
      Log.d('Starting to load categories');
      _isLoading = true;
      _error = null;
      notifyListeners();

      Log.d('Calling _adminService.getCategories()');
      final categories = await _adminService.getCategories();
      Log.d(
          'Categories received from service: ${categories.length} categories');

      _categories = categories;
      Log.d('Categories set in provider: ${_categories.length} categories');

      return categories;
    } catch (e, stackTrace) {
      Log.e('Error loading categories: $e\n$stackTrace');
      _error = e.toString();
      return [];
    } finally {
      _isLoading = false;
      notifyListeners();
      Log.d('Categories loading completed');
    }
  }

  Future<OrganicProduct> addOrganicProduct(OrganicProduct product) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _adminService.createOrganicProduct(product);
      _organicProducts.add(response);
      return response;
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<OrganicProduct> updateOrganicProduct(OrganicProduct product) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _adminService.updateOrganicProduct(product);
      final index = _organicProducts.indexWhere((p) => p.id == product.id);
      if (index != -1) {
        _organicProducts[index] = response;
      }
      return response;
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createTransport(Transport transport) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final success = await _adminService.createTransport(transport);
      if (success) {
        await loadTransports();
      }
      return success;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateTransport(Transport transport) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final success = await _adminService.updateTransport(transport);
      if (success) {
        await loadTransports();
      }
      return success;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> removeTransport(int id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final success = await _adminService.deleteTransport(id);
      if (success) {
        await loadTransports();
      }
      return success;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
