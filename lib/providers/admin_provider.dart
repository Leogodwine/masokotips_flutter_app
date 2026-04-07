import 'dart:io';
import '../models/user.dart';
import '../models/service.dart';
import '../models/market_info.dart';
import '../models/product.dart';
import '../models/organic_product.dart';
import '../models/transport.dart';
import '../services/admin_service.dart';
import '../services/admin_auth_service.dart';
import '../config/api_config.dart';
import '../models/admin_dashboard_data.dart';
import '../utils/logger.dart' as log_util;
import '../models/category.dart' as models;
import 'package:flutter/material.dart';

class AdminProvider with ChangeNotifier {
  final AdminService _adminService = AdminService(baseUrl: ApiConfig.baseUrl);
  final AdminAuthService _adminAuthService =
      AdminAuthService(baseUrl: ApiConfig.baseUrl);
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
      log_util.Log.d('Initializing admin auth');
      await _adminAuthService.initializeAuthToken();
      final token = _adminAuthService.authToken;

      if (token != null && token.isNotEmpty) {
        log_util.Log.d('Auth token found: ${token.substring(0, 10)}...');
        setAuthToken(token);
        log_util.Log.d('Auth token set in services');

        // Verify the token is valid by making a test request
        try {
          await loadDashboardData();
          log_util.Log.d('Auth token verified successfully');
        } catch (e) {
          log_util.Log.e('Auth token verification failed: $e');
          // Clear invalid token
          await _adminAuthService.logoutAdmin();
          _isAdmin = false;
          _dashboardData = null;
        }
      } else {
        log_util.Log.d('No valid auth token found');
        _isAdmin = false;
        _dashboardData = null;
      }
    } catch (e, stackTrace) {
      log_util.Log.e('Error initializing auth: $e\n$stackTrace');
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
    log_util.Log.d('Auth token set in both services');
  }

  Future<bool> login(String username, String password) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      log_util.Log.d('Attempting admin login for username: $username');

      final response = await _adminAuthService.loginAdmin(username, password);
      log_util.Log.d('Login response: $response');

      if (response['success'] == true) {
        final token = response['token'] as String?;
        if (token != null) {
          setAuthToken(token);
          log_util.Log.d('Auth token set successfully');
          await loadDashboardData();
          return true;
        } else {
          log_util.Log.e('Login successful but no token received');
          _error = 'Login successful but no token received';
          return false;
        }
      } else {
        final errorMessage = response['message'] ?? 'Invalid credentials';
        log_util.Log.e('Login failed: $errorMessage');
        _error = errorMessage;
        return false;
      }
    } catch (e, stackTrace) {
      final errorMessage = e is Map<String, dynamic>
          ? e['message']?.toString() ?? e.toString()
          : e.toString();
      log_util.Log.e('Error during login: $errorMessage\n$stackTrace');
      _error = 'Login failed: $errorMessage';
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

  Future<void> loadDashboardData({int maxRetries = 3}) async {
    // Retry configuration for transient network issues
    const retryDelays = [500, 1000, 2000]; // ms delays between retries

    Exception? lastError;

    for (int attempt = 0; attempt < maxRetries; attempt++) {
      try {
        _isLoading = true;
        _error = null;
        notifyListeners();

        log_util.Log.d(
            'Starting to load dashboard data (attempt ${attempt + 1}/$maxRetries)');

        if (_adminAuthService.authToken == null ||
            _adminAuthService.authToken!.isEmpty) {
          log_util.Log.e('No valid auth token available for dashboard request');
          _error = 'Not authenticated. Please login again.';
          _isAdmin = false;
          _dashboardData = null;
          _isLoading = false;
          notifyListeners();
          return;
        }

        final response = await _adminAuthService.getDashboardData();
        log_util.Log.d('Dashboard response received: ${response.toString()}');

        final dashboardData = response; // Already a Map<String, dynamic>
        log_util.Log.d('Parsing dashboard data: ${dashboardData.toString()}');

        // Ensure all required fields are present
        if (!dashboardData.containsKey('stats') ||
            !dashboardData.containsKey('recent_activities') ||
            !dashboardData.containsKey('quick_links') ||
            !dashboardData.containsKey('last_updated')) {
          log_util.Log.e(
              'Invalid dashboard data structure: Missing required fields');
          _error = 'Invalid dashboard data structure';
          _isLoading = false;
          notifyListeners();
          return;
        }

        _dashboardData = AdminDashboardData.fromJson(dashboardData);
        _error = null;
        _isAdmin = true;
        log_util.Log.d('Dashboard data loaded and parsed successfully');

        _isLoading = false;
        notifyListeners();
        return; // Success - exit the retry loop
      } catch (e, stackTrace) {
        lastError = e is Exception ? e : Exception(e.toString());
        log_util.Log.e(
            'Error loading dashboard data (attempt ${attempt + 1}): $e\n$stackTrace');
        log_util.Log.e('Error type: ${e.runtimeType}');

        final errorString = e.toString().toLowerCase();

        // Check if this is a retryable network error
        final isRetryable = _isRetryableNetworkError(errorString);

        if (isRetryable && attempt < maxRetries - 1) {
          // Wait before retrying
          final delay = retryDelays[attempt];
          log_util.Log.d('Retrying in $delay ms...');
          await Future.delayed(Duration(milliseconds: delay));
          _isLoading = false;
          notifyListeners();
          continue; // Continue to next retry attempt
        }

        // Not retryable or last attempt failed - handle the error
        _handleDashboardError(e, errorString);
        _isLoading = false;
        notifyListeners();
        return;
      }
    }

    // All retries exhausted
    if (lastError != null) {
      _handleDashboardError(lastError, lastError.toString().toLowerCase());
    }
    _isLoading = false;
    notifyListeners();
  }

  /// Check if error is a transient network issue that should be retried
  bool _isRetryableNetworkError(String errorString) {
    final retryablePatterns = [
      'clientexception',
      'failed to fetch',
      'socketexception',
      'handshakeexception',
      'connection reset',
      'connection closed',
      'connection refused',
      'connection timeout',
      'receive timeout',
      'send timeout',
      'network is unreachable',
      'no internet',
      'host unreachable',
      'certificate',
      'sslexception',
    ];

    for (final pattern in retryablePatterns) {
      if (errorString.contains(pattern)) {
        return true;
      }
    }
    return false;
  }

  /// Handle dashboard errors with appropriate user messages
  void _handleDashboardError(dynamic e, String errorString) {
    // Check for specific backend SQL error
    if (errorString.contains('column not found') ||
        errorString.contains('unknown column') ||
        errorString.contains('sqlstate[42s22]') ||
        errorString.contains('error retrieving dashboard data') ||
        errorString.contains('sqlstate') ||
        errorString.contains('mysql') ||
        errorString.contains('database') ||
        (errorString.contains('role') &&
            errorString.contains('where clause'))) {
      log_util.Log.w(
          'Backend database schema issue detected. This should be fixed in the backend API.');
      log_util.Log.w('Original error: $e');

      _error =
          'Backend database schema issue. The API needs to be updated to use the correct column names.';
    } else if (errorString.contains('unauthenticated') ||
        errorString.contains('401') ||
        errorString.contains('token') && errorString.contains('invalid')) {
      _adminAuthService.logoutAdmin();
      _isAdmin = false;
      _dashboardData = null;
      _error = 'Session expired. Please login again.';
    } else {
      // For any other dashboard-related errors
      if (errorString.contains('dashboard') || errorString.contains('stats')) {
        log_util.Log.w(
            'Dashboard-related error detected. This should be fixed in the backend API.');
        log_util.Log.w('Original error: $e');

        _error =
            'Dashboard API error. Please contact the administrator to fix the backend.';
      } else {
        _error = 'Failed to load dashboard data. Please try again.';
      }
    }
  }

  Future<void> loadUsers() async {
    // Check authentication before making request
    if (_adminAuthService.authToken == null ||
        _adminAuthService.authToken!.isEmpty) {
      log_util.Log.e('No valid auth token available for users request');
      _error = 'Not authenticated. Please login as admin first.';
      _isLoading = false;
      notifyListeners();
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _users = await _adminService.getUsers();
    } catch (e) {
      _error = e.toString();
      log_util.Log.e('Error loading users: $e');

      // Check if it's an authentication error
      if (e.toString().toLowerCase().contains('unauthenticated') ||
          e.toString().toLowerCase().contains('401')) {
        log_util.Log.w('Authentication failed - clearing auth state');
        await _adminAuthService.logoutAdmin();
        _isAdmin = false;
        _error = 'Session expired. Please login again.';
      }
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
    try {
      _isLoading = true;
      _error = null;

      // Check authentication before making admin request
      if (_adminAuthService.authToken == null ||
          _adminAuthService.authToken!.isEmpty) {
        log_util.Log.e(
            'No valid auth token available for organic products request');
        _error = 'Not authenticated. Please login as admin first.';
        _isAdmin = false;
        return;
      }

      // Delay notifying listeners until after the current frame (like loadProducts method)
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });

      _organicProducts = await _adminService.getOrganicProducts();
    } catch (e) {
      _error = e.toString();
      log_util.Log.e('Error loading organic products: $e');

      // Check if it's an authentication error
      if (e.toString().toLowerCase().contains('unauthenticated') ||
          e.toString().toLowerCase().contains('401')) {
        log_util.Log.w('Authentication failed - clearing auth state');
        await _adminAuthService.logoutAdmin();
        _isAdmin = false;
        _error = 'Session expired. Please login again.';
      }
    } finally {
      _isLoading = false;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
    }
  }

  Future<List<Transport>> loadTransports(
      {int offset = 0, int limit = 10}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final allTransports = await _adminService.getTransports();

      // Simulate server-side pagination by slicing the list
      final paginatedList = allTransports.skip(offset).take(limit).toList();

      if (offset == 0) {
        _transports = paginatedList; // Reset list on first load
      } else {
        _transports.addAll(paginatedList); // Append for infinite scroll
      }

      notifyListeners();
      return paginatedList;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return [];
    } finally {
      _isLoading = false;
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
      debugPrint('🔵 Error updating user: $_error');
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
      // Remove user from the local list immediately
      _users.removeWhere((user) => user.id == userId);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> suspendUser(int userId, bool suspend) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final updatedUser = await _adminService.suspendUser(userId, suspend);

      final index = _users.indexWhere((user) => user.id == userId);
      if (index != -1) {
        _users[index] = updatedUser;
      }

      return true;
    } catch (e) {
      _error = e.toString();
      debugPrint('🔵 Error suspending user: $_error');
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
      log_util.Log.d('AdminProvider - updateProduct:');
      log_util.Log.d('- is_active: ${productData['is_active']}');
      log_util.Log.d('- is_featured: ${productData['is_featured']}');

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

  /// Logs out the admin user by clearing authentication state
  Future<void> logout() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      log_util.Log.d('Logging out admin...');

      // Clear auth token and session
      await _adminAuthService.logoutAdmin();

      // Clear service_provider state
      _isAdmin = false;
      _dashboardData = null;
      _users = [];
      _services = [];
      _marketInfo = [];
      _products = [];
      _organicProducts = [];
      _transports = [];
      _categories = [];

      log_util.Log.d('Admin logout completed');
    } catch (e, stackTrace) {
      log_util.Log.e('Error during admin logout: $e\n$stackTrace');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<List<models.Category>> getCategories() async {
    try {
      log_util.Log.d('Starting to load categories');
      _isLoading = true;
      _error = null;

      // Delay notifying listeners until after the current frame
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });

      log_util.Log.d('Calling _adminService.getCategories()');
      final categories = await _adminService.getCategories();
      log_util.Log.d(
          'Categories received from service: ${categories.length} categories');

      _categories = categories;
      log_util.Log.d(
          'Categories set in service_provider: ${_categories.length} categories');

      return categories;
    } catch (e, stackTrace) {
      log_util.Log.e('Error loading categories: $e\n$stackTrace');
      _error = e.toString();
      return [];
    } finally {
      _isLoading = false;

      // Delay notifying listeners until after the current frame
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });

      log_util.Log.d('Categories loading completed');
    }
  }

  Future<OrganicProduct> addOrganicProduct(OrganicProduct product,
      {List<File>? imageFiles}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _adminService.createOrganicProduct(product,
          imageFiles: imageFiles);
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

  Future<OrganicProduct> updateOrganicProduct(OrganicProduct product,
      {List<File>? imageFiles}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Updating organic product

      final response = await _adminService.updateOrganicProduct(product,
          imageFiles: imageFiles);

      // Update response received

      final index = _organicProducts.indexWhere((p) => p.id == product.id);
      if (index != -1) {
        _organicProducts[index] = response;
        // Updated product in service_provider list
      } else {
        // Product not found in service_provider list
      }

      return response;
    } catch (e) {
      _error = e.toString();
      // Error in updateOrganicProduct
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
        _transports.removeWhere((transport) => transport.id == id);
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

  Future<Map<String, dynamic>> uploadOrganicProductImage(File imageFile) async {
    try {
      return await _adminService.uploadOrganicProductImage(imageFile);
    } catch (e) {
      _error = e.toString();
      rethrow;
    }
  }
}
