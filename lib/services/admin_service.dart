import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/user.dart';
import '../models/service.dart';
import '../models/market_info.dart';
import '../models/product.dart';
import '../models/organic_product.dart';
import '../models/transport.dart';
import 'package:dio/dio.dart';
import '../models/category.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../utils/logger.dart';
import 'network_service.dart';

class AdminService {
  String? _authToken;
  final String baseUrl;
  late Dio _dio;
  final NetworkService _networkService = NetworkService.instance;

  AdminService({required this.baseUrl}) {
    _initializeDio();
  }

  void _initializeDio() {
    _dio = Dio(BaseOptions(baseUrl: baseUrl));
    _dio.options.connectTimeout = const Duration(seconds: 30);
    _dio.options.receiveTimeout = const Duration(seconds: 60);
    _dio.options.sendTimeout = const Duration(seconds: 60);

    // Set enhanced headers for all Dio requests
    _dio.options.headers.addAll({
      'Accept': 'application/json, text/plain, */*',
      'Accept-Language': 'en-US,en;q=0.9',
      'User-Agent': _userAgent,
      'Origin': baseUrl.replaceAll('/api', ''),
      'Referer': baseUrl.replaceAll('/api', ''),
      'Connection': 'keep-alive',
      'Cache-Control': 'no-cache',
    });
  }

  void setAuthToken(String token) {
    _authToken = token;
    _dio.options.headers['Authorization'] = 'Bearer $token';
    _networkService.setAuthToken(token);
    Log.d('Auth token set in AdminService: ${token.substring(0, 10)}...');
  }

  bool isAuthenticated() {
    return _authToken != null;
  }

  // User-Agent header to identify as legitimate mobile app
  static const String _userAgent =
      'Mozilla/5.0 (Linux; Android 10; SM-G975F) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.120 Mobile Safari/537.36';

  // Enhanced headers to bypass bot detection
  Map<String, String> get _enhancedHeaders => {
        'Content-Type': 'application/json',
        'Accept': 'application/json, text/plain, */*',
        'Accept-Language': 'en-US,en;q=0.9',
        'User-Agent': _userAgent,
        'Origin': baseUrl.replaceAll('/api', ''),
        'Referer': baseUrl.replaceAll('/api', ''),
        if (_authToken != null) 'Authorization': 'Bearer $_authToken',
      };

  // Admin Authentication
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/admin/login'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data;
      } else {
        throw Exception('Failed to login: ${response.body}');
      }
    } catch (e) {
      Log.e('Error in admin login: $e');
      throw Exception('Failed to login: $e');
    }
  }

  Future<Map<String, dynamic>> register(
      String name, String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/admin/register'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({
          'name': name,
          'email': email,
          'password': password,
          'password_confirmation': password,
        }),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = json.decode(response.body);
        return data;
      } else {
        throw Exception('Failed to register: ${response.body}');
      }
    } catch (e) {
      Log.e('Error in admin registration: $e');
      throw Exception('Failed to register: $e');
    }
  }

  // Admin Dashboard
  Future<Map<String, dynamic>> getDashboardData() async {
    if (!isAuthenticated()) {
      throw Exception('Not authenticated');
    }

    try {
      final response = await _dio.get('/admin/dashboard');
      Log.d('Dashboard data response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception(
            'Failed to get dashboard data: ${response.statusCode} - ${response.data['message'] ?? 'Unknown error'}');
      }
    } catch (e) {
      Log.e('Error fetching dashboard data: $e');
      throw Exception('Failed to get dashboard data: $e');
    }
  }

  // User Management
  Future<List<User>> getUsers() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/admin/users'),
        headers: _enhancedHeaders,
      );

      Log.d('Users API response: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Check for different possible response structures
        if (data is Map<String, dynamic>) {
          // Check if response has 'users' field with pagination (from UserController.index)
          if (data.containsKey('users') &&
              data['users'] is Map<String, dynamic> &&
              (data['users'] as Map<String, dynamic>).containsKey('data')) {
            final usersData = data['users'] as Map<String, dynamic>;
            final List<dynamic> usersJson = usersData['data'];
            return usersJson.map((json) => User.fromJson(json)).toList();
          }
          // If we have a direct users array (non-paginated)
          else if (data.containsKey('users') && data['users'] is List) {
            final List<dynamic> usersJson = data['users'];
            return usersJson.map((json) => User.fromJson(json)).toList();
          }
          // Check if response has 'data' field (direct list)
          else if (data.containsKey('data') && data['data'] is List) {
            final List<dynamic> usersJson = data['data'];
            return usersJson.map((json) => User.fromJson(json)).toList();
          }
        }

        Log.e('Unexpected API response structure: $data');
        return [];
      } else {
        Log.e(
            'Failed API call with status: ${response.statusCode}, body: ${response.body}');
        throw Exception('Failed to get users: ${response.body}');
      }
    } catch (e) {
      Log.e('Error getting users: $e');
      throw Exception('Failed to get users: $e');
    }
  }

  Future<User> getUserDetails(int userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/admin/users/$userId'),
        headers: {
          'Authorization': 'Bearer $_authToken',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data is Map<String, dynamic> && data.containsKey('data')) {
          return User.fromJson(data['data']);
        } else {
          throw Exception('Unexpected API response structure: $data');
        }
      } else {
        throw Exception('Failed to get user details: ${response.body}');
      }
    } catch (e) {
      Log.e('Error getting user details: $e');
      throw Exception('Failed to get user details: $e');
    }
  }

  Future<User> updateUser(int userId, Map<String, dynamic> userData) async {
    final url = '$baseUrl/admin/users/$userId';

    try {
      Log.d('🔵 Updating user $userId at URL: $url');
      Log.d('🔵 Request data: ${json.encode(userData)}');
      Log.d('🔵 Auth token: ${_authToken?.substring(0, 10)}...');

      final response = await http.put(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $_authToken',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: json.encode(userData),
      );

      Log.d('🔵 Response status code: ${response.statusCode}');
      Log.d('🔵 Response body: ${response.body}');

      final Map<String, dynamic> data = json.decode(response.body);

      switch (response.statusCode) {
        case 200:
          final userMap = data['data'] ?? data['user'];
          if (userMap != null && userMap is Map<String, dynamic>) {
            return User.fromJson(userMap);
          } else {
            Log.e('🔴 Invalid user data in response');
            throw Exception('Unexpected user data in response.');
          }

        case 422:
          final errors = data['errors'] ?? {};
          final message = data['message'] ?? 'Validation failed.';
          Log.e('🔴 Validation error: $errors');
          throw Exception('$message\n${_formatValidationErrors(errors)}');

        case 401:
          throw Exception('Unauthorized. Please log in again.');

        default:
          final message = data['message'] ?? 'Unexpected error occurred.';
          Log.e('🔴 API error [$url]: $message');
          throw Exception('Failed to update user: $message');
      }
    } catch (e) {
      Log.e('🔴 Exception during updateUser: $e');
      throw Exception('Failed to update user: $e');
    }
  }

  String _formatValidationErrors(Map<String, dynamic> errors) {
    return errors.entries
        .map((e) => "${e.key}: ${(e.value as List).join(', ')}")
        .join('\n');
  }

  Future<void> deleteUser(int userId) async {
    const int maxRetries = 3;
    int retryCount = 0;

    while (retryCount < maxRetries) {
      try {
        Log.d('Attempting to delete user $userId (attempt ${retryCount + 1})');

        final response = await http
            .delete(
              Uri.parse('$baseUrl/admin/users/$userId'),
              headers: _enhancedHeaders,
            )
            .timeout(const Duration(seconds: 10));

        if (response.statusCode == 200 || response.statusCode == 204) {
          Log.d('Successfully deleted user $userId');
          return;
        } else if (response.statusCode == 404) {
          throw Exception('User not found');
        } else if (response.statusCode == 403) {
          throw Exception('Permission denied to delete user');
        } else {
          throw Exception(
              'Failed to delete user: HTTP ${response.statusCode} - ${response.body}');
        }
      } catch (e) {
        retryCount++;
        Log.e('Error deleting user (attempt $retryCount): $e');

        // Check if it's a network error that we should retry
        final errorString = e.toString().toLowerCase();
        final shouldRetry = errorString.contains('connection reset by peer') ||
            errorString.contains('connection closed') ||
            errorString.contains('timeout') ||
            errorString.contains('network') ||
            errorString.contains('socket');

        if (shouldRetry && retryCount < maxRetries) {
          Log.d('Retrying delete operation in ${retryCount * 2} seconds...');
          await Future.delayed(Duration(seconds: retryCount * 2));
          continue;
        }

        // If we've exhausted retries or it's not a retryable error
        if (retryCount >= maxRetries) {
          throw Exception(
              'Failed to delete user after $maxRetries attempts: $e');
        } else {
          throw Exception('Error deleting user: $e');
        }
      }
    }
  }

  // Suspend/Unsuspend User
  Future<User> suspendUser(int userId, bool suspend) async {
    final url = '$baseUrl/admin/users/$userId/suspend';

    try {
      Log.d(
          '${suspend ? "Suspending" : "Unsuspending"} user $userId at URL: $url');

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $_authToken',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: json.encode({'suspend': suspend}),
      );

      Log.d('Response status code: ${response.statusCode}');
      Log.d('Response body: ${response.body}');

      final Map<String, dynamic> data = json.decode(response.body);

      switch (response.statusCode) {
        case 200:
          final userMap = data['data'] ?? data['user'];
          if (userMap != null && userMap is Map<String, dynamic>) {
            return User.fromJson(userMap);
          } else {
            Log.e('Invalid user data in response');
            throw Exception('Unexpected user data in response.');
          }

        case 422:
          final errors = data['errors'] ?? {};
          final message = data['message'] ?? 'Validation failed.';
          Log.e('Validation error: $errors');
          throw Exception('$message\n${_formatValidationErrors(errors)}');

        case 401:
          throw Exception('Unauthorized. Please log in again.');

        default:
          final message = data['message'] ?? 'Unexpected error occurred.';
          Log.e('API error [$url]: $message');
          throw Exception(
              'Failed to ${suspend ? "suspend" : "unsuspend"} user: $message');
      }
    } catch (e) {
      Log.e('Exception during suspendUser: $e');
      throw Exception(
          'Failed to ${suspend ? "suspend" : "unsuspend"} user: $e');
    }
  }

  // Service Management
  Future<List<Service>> getServices() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/admin/services'),
        headers: _enhancedHeaders,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data is Map<String, dynamic> && data.containsKey('data')) {
          final List<dynamic> servicesJson = data['data'];
          return servicesJson.map((json) => Service.fromJson(json)).toList();
        } else {
          Log.e('Unexpected API response structure: $data');
          return [];
        }
      } else {
        throw Exception('Failed to get services: ${response.body}');
      }
    } catch (e) {
      Log.e('Error getting services: $e');
      throw Exception('Failed to get services: $e');
    }
  }

  Future<Service> getServiceDetails(int serviceId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/admin/services/$serviceId'),
        headers: {
          'Authorization': 'Bearer $_authToken',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data is Map<String, dynamic> && data.containsKey('data')) {
          return Service.fromJson(data['data']);
        } else {
          throw Exception('Unexpected API response structure: $data');
        }
      } else {
        throw Exception('Failed to get service details: ${response.body}');
      }
    } catch (e) {
      Log.e('Error getting service details: $e');
      throw Exception('Failed to get service details: $e');
    }
  }

  Future<Service> updateService(
      int serviceId, Map<String, dynamic> serviceData) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/admin/services/$serviceId'),
        headers: {
          'Authorization': 'Bearer $_authToken',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: json.encode(serviceData),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data is Map<String, dynamic> && data.containsKey('data')) {
          return Service.fromJson(data['data']);
        } else {
          throw Exception('Unexpected API response structure: $data');
        }
      } else {
        throw Exception('Failed to update service: ${response.body}');
      }
    } catch (e) {
      Log.e('Error updating service: $e');
      throw Exception('Failed to update service: $e');
    }
  }

  Future<void> deleteService(int serviceId) async {
    const int maxRetries = 3;
    int retryCount = 0;

    while (retryCount < maxRetries) {
      try {
        Log.d(
            'Attempting to delete service $serviceId (attempt ${retryCount + 1})');

        final response = await http
            .delete(
              Uri.parse('$baseUrl/admin/services/$serviceId'),
              headers: _enhancedHeaders,
            )
            .timeout(const Duration(seconds: 10));

        if (response.statusCode == 200 || response.statusCode == 204) {
          Log.d('Successfully deleted service $serviceId');
          return;
        } else if (response.statusCode == 404) {
          throw Exception('Service not found');
        } else if (response.statusCode == 403) {
          throw Exception('Permission denied to delete service');
        } else {
          throw Exception(
              'Failed to delete service: HTTP ${response.statusCode} - ${response.body}');
        }
      } catch (e) {
        retryCount++;
        Log.e('Error deleting service (attempt $retryCount): $e');

        // Check if it's a network error that we should retry
        final errorString = e.toString().toLowerCase();
        final shouldRetry = errorString.contains('connection reset by peer') ||
            errorString.contains('connection closed') ||
            errorString.contains('timeout') ||
            errorString.contains('network') ||
            errorString.contains('socket');

        if (shouldRetry && retryCount < maxRetries) {
          Log.d('Retrying delete operation in ${retryCount * 2} seconds...');
          await Future.delayed(Duration(seconds: retryCount * 2));
          continue;
        }

        // If we've exhausted retries or it's not a retryable error
        if (retryCount >= maxRetries) {
          throw Exception(
              'Failed to delete service after $maxRetries attempts: $e');
        } else {
          throw Exception('Error deleting service: $e');
        }
      }
    }
  }

  // Market Information Management
  Future<List<MarketInfo>> getMarketInfo() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/admin/market-info'),
        headers: _enhancedHeaders,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data is Map<String, dynamic> && data.containsKey('data')) {
          final List<dynamic> marketInfoJson = data['data'];
          return marketInfoJson
              .map((json) => MarketInfo.fromJson(json))
              .toList();
        } else {
          Log.e('Unexpected API response structure: $data');
          return [];
        }
      } else {
        throw Exception('Failed to get market info: ${response.body}');
      }
    } catch (e) {
      Log.e('Error getting market info: $e');
      throw Exception('Failed to get market info: $e');
    }
  }

  Future<MarketInfo> createMarketInfo(
      Map<String, dynamic> marketInfoData) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/admin/market-info'),
        headers: {
          'Authorization': 'Bearer $_authToken',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: json.encode(marketInfoData),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data is Map<String, dynamic> && data.containsKey('data')) {
          return MarketInfo.fromJson(data['data']);
        } else {
          throw Exception('Unexpected API response structure: $data');
        }
      } else {
        throw Exception('Failed to create market info: ${response.body}');
      }
    } catch (e) {
      Log.e('Error creating market info: $e');
      throw Exception('Failed to create market info: $e');
    }
  }

  Future<MarketInfo> updateMarketInfo(
      int marketInfoId, Map<String, dynamic> marketInfoData) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/admin/market-info/$marketInfoId'),
        headers: {
          'Authorization': 'Bearer $_authToken',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: json.encode(marketInfoData),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data is Map<String, dynamic> && data.containsKey('data')) {
          return MarketInfo.fromJson(data['data']);
        } else {
          throw Exception('Unexpected API response structure: $data');
        }
      } else {
        throw Exception('Failed to update market info: ${response.body}');
      }
    } catch (e) {
      Log.e('Error updating market info: $e');
      throw Exception('Failed to update market info: $e');
    }
  }

  Future<void> deleteMarketInfo(int marketInfoId) async {
    const int maxRetries = 3;
    int retryCount = 0;

    while (retryCount < maxRetries) {
      try {
        Log.d(
            'Attempting to delete market info $marketInfoId (attempt ${retryCount + 1})');

        final response = await http
            .delete(
              Uri.parse('$baseUrl/admin/market-info/$marketInfoId'),
              headers: _enhancedHeaders,
            )
            .timeout(const Duration(seconds: 10));

        if (response.statusCode == 200 || response.statusCode == 204) {
          Log.d('Successfully deleted market info $marketInfoId');
          return;
        } else if (response.statusCode == 404) {
          throw Exception('Market info not found');
        } else if (response.statusCode == 403) {
          throw Exception('Permission denied to delete market info');
        } else {
          throw Exception(
              'Failed to delete market info: HTTP ${response.statusCode} - ${response.body}');
        }
      } catch (e) {
        retryCount++;
        Log.e('Error deleting market info (attempt $retryCount): $e');

        // Check if it's a network error that we should retry
        final errorString = e.toString().toLowerCase();
        final shouldRetry = errorString.contains('connection reset by peer') ||
            errorString.contains('connection closed') ||
            errorString.contains('timeout') ||
            errorString.contains('network') ||
            errorString.contains('socket');

        if (shouldRetry && retryCount < maxRetries) {
          Log.d('Retrying delete operation in ${retryCount * 2} seconds...');
          await Future.delayed(Duration(seconds: retryCount * 2));
          continue;
        }

        // If we've exhausted retries or it's not a retryable error
        if (retryCount >= maxRetries) {
          throw Exception(
              'Failed to delete market info after $maxRetries attempts: $e');
        } else {
          throw Exception('Error deleting market info: $e');
        }
      }
    }
  }

  // Product Management
  Future<List<Product>> getProducts() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/admin/products'),
        headers: _enhancedHeaders,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> productsData = data['data'] ?? [];
        return productsData.map((json) => Product.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load products: ${response.statusCode}');
      }
    } catch (e) {
      Log.e('Error in getProducts: $e');
      throw Exception('Failed to load products: $e');
    }
  }

  Future<Product> updateProduct(
      int productId, Map<String, dynamic> productData) async {
    if (_authToken == null) {
      throw Exception('Not authenticated');
    }

    try {
      Log.d('Updating product $productId with data:');
      Log.d('- is_active: ${productData['is_active']}');
      Log.d('- is_featured: ${productData['is_featured']}');

      final url = '$baseUrl/admin/products/$productId';
      Log.d('Update Product URL: $url');

      // Check if images are being updated
      if (productData['images'] != null &&
          productData['images'] is List<XFile> &&
          (productData['images'] as List<XFile>).isNotEmpty) {
        // Use multipart request if there are images
        final formData = FormData.fromMap({
          'name': productData['name'],
          'description': productData['description'],
          'price': productData['price'].toString(),
          'stock': productData['stock'].toString(),
          'unit': productData['unit'],
          'category_id': productData['category_id'].toString(),
          'is_active': productData['is_active'] is bool
              ? (productData['is_active'] ? 1 : 0)
              : productData['is_active'],
          'is_featured': productData['is_featured'] is bool
              ? (productData['is_featured'] ? 1 : 0)
              : productData['is_featured'],
          '_method': 'PUT', // Method spoofing for Laravel
        });

        // Add image files using indexed field names for proper array handling
        final List<XFile> images = productData['images'] as List<XFile>;
        for (var i = 0; i < images.length; i++) {
          // Check file size before upload to prevent timeout issues
          final fileInfo = await images[i].length();
          if (fileInfo > 2 * 1024 * 1024) {
            // 2MB limit
            Log.w(
                'Image ${images[i].name} is large (${(fileInfo / 1024 / 1024).toStringAsFixed(1)}MB). Consider using smaller images.');
          }

          final filename = images[i].path.split('/').last.isNotEmpty
              ? images[i].path.split('/').last
              : 'image_$i.jpg';

          if (kIsWeb) {
            // Web platform - use bytes
            final bytes = await images[i].readAsBytes();
            formData.files.add(MapEntry(
              'images[$i]', // Use indexed field names
              MultipartFile.fromBytes(
                bytes,
                filename: filename,
              ),
            ));
          } else {
            // Mobile platform - use file path
            formData.files.add(MapEntry(
              'images[$i]', // Use indexed field names
              await MultipartFile.fromFile(
                images[i].path,
                filename: filename,
              ),
            ));
          }
        }

        Log.d('Using multipart form data for product update with images');

        final response = await _dio.post(
          url,
          data: formData,
          options: Options(
            headers: {
              'Accept': 'application/json',
              'Content-Type': 'multipart/form-data',
              'Authorization': 'Bearer $_authToken',
              'User-Agent': _userAgent,
              'Origin': baseUrl.replaceAll('/api', ''),
              'Referer': baseUrl.replaceAll('/api', ''),
            },
            sendTimeout: const Duration(seconds: 60),
            receiveTimeout: const Duration(seconds: 60),
            validateStatus: (status) => status! < 500,
          ),
        );

        if (response.statusCode == 200) {
          final responseData = response.data['data'];
          if (responseData is Map<String, dynamic>) {
            Log.d('Product updated successfully with multipart form data');
            return Product.fromJson(responseData);
          } else {
            throw Exception('Invalid response data format');
          }
        } else {
          String errorMessage = 'Failed to update product';
          if (response.data is Map) {
            final data = response.data as Map;
            if (data.containsKey('message')) {
              errorMessage = data['message'];
            } else if (data.containsKey('error')) {
              errorMessage = data['error'];
            }
          }
          throw Exception('Failed to update product: $errorMessage');
        }
      } else {
        // Use regular JSON request if no images
        Log.d('Using JSON request for product update without images');

        final response = await http.put(
          Uri.parse(url),
          headers: {
            'Authorization': 'Bearer $_authToken',
            'Accept': 'application/json',
            'Content-Type': 'application/json',
            'User-Agent': _userAgent,
            'Origin': baseUrl.replaceAll('/api', ''),
            'Referer': baseUrl.replaceAll('/api', ''),
          },
          body: json.encode({
            'name': productData['name'],
            'description': productData['description'],
            'price': productData['price'].toString(),
            'stock': productData['stock'].toString(),
            'unit': productData['unit'],
            'category_id': productData['category_id'].toString(),
            'is_active': productData['is_active'] is bool
                ? (productData['is_active'] ? 1 : 0)
                : productData['is_active'],
            'is_featured': productData['is_featured'] is bool
                ? (productData['is_featured'] ? 1 : 0)
                : productData['is_featured'],
          }),
        );

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          Log.d('Product updated successfully');
          Log.d('Response data: $data');
          if (data['success'] == true && data['data'] != null) {
            final responseData = data['data'] as Map<String, dynamic>;
            return Product.fromJson(responseData);
          } else {
            throw Exception('Failed to update product: ${data['message']}');
          }
        } else {
          Log.e('Failed to update product: ${response.body}');
          throw Exception('Failed to update product: ${response.body}');
        }
      }
    } catch (e) {
      Log.e('Error updating product: $e');

      // Re-throw DioException with better error messages
      if (e is DioException) {
        if (e.response?.statusCode == 500) {
          String errorMessage = 'Server error occurred while updating product';
          if (e.response?.data is Map) {
            final data = e.response!.data as Map;
            if (data.containsKey('message')) {
              errorMessage = data['message'];
            } else if (data.containsKey('error')) {
              errorMessage = data['error'];
            }
          }
          throw Exception('Failed to update product: $errorMessage');
        } else if (e.response?.statusCode == 422) {
          final data = e.response?.data as Map?;
          final message = data?['message'] ?? 'Validation failed';
          throw Exception('Validation error: $message');
        } else {
          throw Exception('Failed to update product: ${e.message}');
        }
      }

      // For other exceptions
      throw Exception('Error updating product: $e');
    }
  }

  Future<Product> createProduct({
    required String name,
    required String description,
    required double price,
    required int stock,
    required String unit,
    required int categoryId,
    required bool isActive,
    required bool isFeatured,
    required List<XFile> images,
  }) async {
    try {
      Log.d('Creating product with data:');
      Log.d('- name: $name');
      Log.d('- is_active: $isActive');
      Log.d('- is_featured: $isFeatured');
      Log.d('- category_id: $categoryId');

      // First, verify the category exists
      try {
        final categories = await getCategories();
        final defaultCategories = [
          Category(id: 1, name: 'Products', subcategories: [
            Category(id: 6, name: 'Vegetables'),
            Category(id: 7, name: 'Fruits'),
            Category(id: 8, name: 'Spices'),
            Category(id: 9, name: 'Cash Crops'),
            Category(id: 10, name: 'Cereals'),
            Category(id: 11, name: 'Seeds and Seedling'),
            Category(id: 12, name: 'Livestock and poultry'),
          ]),
        ];

        // Check both API categories and default categories
        final allCategories = [...categories, ...defaultCategories];
        final categoryExists = allCategories.any((category) {
          if (category.subcategories != null) {
            return category.subcategories!
                .any((child) => child.id == categoryId);
          }
          return category.id == categoryId;
        });

        if (!categoryExists) {
          throw Exception('Category with ID $categoryId does not exist');
        }
      } catch (e) {
        Log.e('Error verifying category: $e');
        rethrow;
      }

      // Generate unique slug from name with timestamp
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final baseSlug = name
          .toLowerCase()
          .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
          .replaceAll(RegExp(r'^-|-$'), '');
      final slug = '$baseSlug-$timestamp';

      Log.d('Generated unique slug: $slug');

      final formData = FormData.fromMap({
        'name': name,
        'slug': slug,
        'description': description,
        'price': price.toString(),
        'stock': stock.toString(),
        'unit': unit,
        'category_id': categoryId.toString(),
        'is_active': isActive ? 1 : 0,
        'is_featured': isFeatured ? 1 : 0,
      });

      // Handle image uploads - only add files if images are provided
      if (images.isNotEmpty) {
        Log.d('Adding ${images.length} images to form data');
        for (var i = 0; i < images.length; i++) {
          if (kIsWeb) {
            // Web platform - use bytes
            final bytes = await images[i].readAsBytes();
            formData.files.add(MapEntry(
              'images[$i]', // Use indexed field names for proper array handling
              MultipartFile.fromBytes(
                bytes,
                filename: images[i].name,
              ),
            ));
          } else {
            // Mobile platform - use file path
            formData.files.add(MapEntry(
              'images[$i]', // Use indexed field names for proper array handling
              await MultipartFile.fromFile(
                images[i].path,
                filename: images[i].name,
              ),
            ));
          }
        }
      } else {
        Log.d('No images provided, sending empty images array');
        formData.fields.add(const MapEntry('images', '[]'));
      }

      final response = await _dio.post(
        '/admin/products',
        data: formData,
        options: Options(
          headers: {
            'Accept': 'application/json',
            'Content-Type': 'multipart/form-data',
          },
          validateStatus: (status) => status! < 500,
        ),
      );

      if (response.statusCode == 201) {
        Log.d('Product created successfully');
        Log.d('Response data: ${response.data}');

        // Ensure is_featured is included in the response data
        final responseData = response.data['data'] as Map<String, dynamic>;
        if (!responseData.containsKey('is_featured')) {
          responseData['is_featured'] = isFeatured;
        }
        // Convert is_featured to boolean if it's a string
        if (responseData['is_featured'] is String) {
          responseData['is_featured'] = responseData['is_featured'] == '1';
        }

        return Product.fromJson(responseData);
      } else {
        Log.e('Failed to create product: ${response.statusMessage}');
        Log.e('Response data: ${response.data}');
        throw Exception(
            'Failed to create product: ${response.data['message'] ?? response.statusMessage}');
      }
    } catch (e) {
      Log.e('Error creating product: $e');
      rethrow;
    }
  }

  Future<void> deleteProduct(int productId) async {
    const int maxRetries = 3;
    int retryCount = 0;

    while (retryCount < maxRetries) {
      try {
        Log.d(
            'Attempting to delete product $productId (attempt ${retryCount + 1})');

        final response = await http
            .delete(
              Uri.parse('$baseUrl/admin/products/$productId'),
              headers: _enhancedHeaders,
            )
            .timeout(const Duration(seconds: 10));

        if (response.statusCode == 200 || response.statusCode == 204) {
          Log.d('Successfully deleted product $productId');
          return;
        } else if (response.statusCode == 404) {
          throw Exception('Product not found');
        } else if (response.statusCode == 403) {
          throw Exception('Permission denied to delete product');
        } else {
          throw Exception(
              'Failed to delete product: HTTP ${response.statusCode} - ${response.body}');
        }
      } catch (e) {
        retryCount++;
        Log.e('Error deleting product (attempt $retryCount): $e');

        // Check if it's a network error that we should retry
        final errorString = e.toString().toLowerCase();
        final shouldRetry = errorString.contains('connection reset by peer') ||
            errorString.contains('connection closed') ||
            errorString.contains('timeout') ||
            errorString.contains('network') ||
            errorString.contains('socket');

        if (shouldRetry && retryCount < maxRetries) {
          Log.d('Retrying delete operation in ${retryCount * 2} seconds...');
          await Future.delayed(Duration(seconds: retryCount * 2));
          continue;
        }

        // If we've exhausted retries or it's not a retryable error
        if (retryCount >= maxRetries) {
          throw Exception(
              'Failed to delete product after $maxRetries attempts: $e');
        } else {
          throw Exception('Error deleting product: $e');
        }
      }
    }
  }

  // Transport Management
  Future<List<Transport>> getTransports() async {
    try {
      final response = await _dio.get('/admin/transports');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'];
        return data.map((json) => Transport.fromJson(json)).toList();
      }
      throw Exception('Failed to load transports');
    } catch (e) {
      Log.e('Error getting transports: $e');
      rethrow;
    }
  }

  Future<bool> createTransport(Transport transport) async {
    try {
      final response = await _dio.post(
        '$baseUrl/admin/transports',
        data: transport.toJson(),
      );
      return response.statusCode == 201;
    } catch (e) {
      throw Exception('Failed to create transport: $e');
    }
  }

  Future<bool> updateTransport(Transport transport) async {
    try {
      final response = await _dio.put(
        '$baseUrl/admin/transports/${transport.id}',
        data: transport.toJson(),
      );
      return response.statusCode == 200;
    } catch (e) {
      throw Exception('Failed to update transport: $e');
    }
  }

  Future<bool> deleteTransport(int id) async {
    const int maxRetries = 3;
    int retryCount = 0;

    while (retryCount < maxRetries) {
      try {
        Log.d('Attempting to delete transport $id (attempt ${retryCount + 1})');

        final response = await _dio.delete(
          '$baseUrl/admin/transports/$id',
        );

        if (response.statusCode == 200 || response.statusCode == 204) {
          Log.d('Successfully deleted transport $id');
          return true;
        } else if (response.statusCode == 404) {
          throw Exception('Transport not found');
        } else if (response.statusCode == 403) {
          throw Exception('Permission denied to delete transport');
        } else {
          throw Exception(
              'Failed to delete transport: HTTP ${response.statusCode}');
        }
      } catch (e) {
        retryCount++;
        Log.e('Error deleting transport (attempt $retryCount): $e');

        // Check if it's a network error that we should retry
        final errorString = e.toString().toLowerCase();
        final shouldRetry = errorString.contains('connection reset by peer') ||
            errorString.contains('connection closed') ||
            errorString.contains('timeout') ||
            errorString.contains('network') ||
            errorString.contains('socket');

        if (shouldRetry && retryCount < maxRetries) {
          Log.d('Retrying delete operation in ${retryCount * 2} seconds...');
          await Future.delayed(Duration(seconds: retryCount * 2));
          continue;
        }

        // If we've exhausted retries or it's not a retryable error
        if (retryCount >= maxRetries) {
          throw Exception(
              'Failed to delete transport after $maxRetries attempts: $e');
        } else {
          throw Exception('Failed to delete transport: $e');
        }
      }
    }
    return false;
  }

  // Organic Product Management
  Future<List<OrganicProduct>> getOrganicProducts() async {
    // Check authentication first (like other admin methods)
    if (_authToken == null) {
      throw Exception('Not authenticated. Please login as admin first.');
    }

    try {
      Log.d('Fetching organic products from: $baseUrl/admin/organic-products');
      final response = await http.get(
        Uri.parse('$baseUrl/admin/organic-products'),
        headers: _enhancedHeaders,
      );

      Log.d('Organic products response status: ${response.statusCode}');
      Log.d('Organic products response body: ${response.body}');

      if (response.statusCode == 200) {
        // Check if response is actually JSON (not HTML)
        final responseBody = response.body.trim();
        if (!responseBody.startsWith('{') && !responseBody.startsWith('[')) {
          throw Exception(
              'Server returned non-JSON response. This might be an authentication or routing issue.');
        }

        final data = json.decode(responseBody);

        // Handle different response formats
        if (data['data'] is Map) {
          final paginatedData = data['data'];
          final productsList = paginatedData['data'] as List;
          return productsList
              .map((json) => OrganicProduct.fromJson(json))
              .toList();
        } else {
          final productsList = data['data'] as List;
          return productsList
              .map((json) => OrganicProduct.fromJson(json))
              .toList();
        }
      } else if (response.statusCode == 401) {
        throw Exception('Authentication failed. Please login again.');
      } else if (response.statusCode == 403) {
        throw Exception(
            'Access denied. You do not have permission to view organic products.');
      } else if (response.statusCode == 404) {
        throw Exception(
            'Organic products endpoint not found. Please check the server configuration.');
      } else {
        throw Exception(
            'Failed to load organic products: HTTP ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      Log.e('Error loading organic products: $e');

      // Provide more specific error messages
      if (e.toString().contains('FormatException')) {
        throw Exception(
            'Server returned an invalid response. This could be due to authentication issues or server misconfiguration.');
      }

      rethrow; // Re-throw the original exception with proper context
    }
  }

  Future<void> deleteOrganicProduct(int productId) async {
    const int maxRetries = 3;
    int retryCount = 0;

    while (retryCount < maxRetries) {
      try {
        Log.d(
            'Attempting to delete organic product $productId (attempt ${retryCount + 1})');

        final response = await http
            .delete(
              Uri.parse('$baseUrl/admin/organic-products/$productId'),
              headers: _enhancedHeaders,
            )
            .timeout(const Duration(seconds: 10));

        if (response.statusCode == 200 || response.statusCode == 204) {
          Log.d('Successfully deleted organic product $productId');
          return;
        } else if (response.statusCode == 404) {
          throw Exception('Organic product not found');
        } else if (response.statusCode == 403) {
          throw Exception('Permission denied to delete organic product');
        } else {
          throw Exception(
              'Failed to delete organic product: HTTP ${response.statusCode} - ${response.body}');
        }
      } catch (e) {
        retryCount++;
        Log.e('Error deleting organic product (attempt $retryCount): $e');

        // Check if it's a network error that we should retry
        final errorString = e.toString().toLowerCase();
        final shouldRetry = errorString.contains('connection reset by peer') ||
            errorString.contains('connection closed') ||
            errorString.contains('timeout') ||
            errorString.contains('network') ||
            errorString.contains('socket');

        if (shouldRetry && retryCount < maxRetries) {
          Log.d('Retrying delete operation in ${retryCount * 2} seconds...');
          await Future.delayed(Duration(seconds: retryCount * 2));
          continue;
        }

        // If we've exhausted retries or it's not a retryable error
        if (retryCount >= maxRetries) {
          throw Exception(
              'Failed to delete organic product after $maxRetries attempts: $e');
        } else {
          throw Exception('Error deleting organic product: $e');
        }
      }
    }
  }

  // Category Management
  Future<List<Category>> getCategories() async {
    try {
      Log.d('AdminService: Starting to fetch categories');

      // Try the public categories endpoint first (most likely to work)
      try {
        final response = await _dio.get('/public/categories');
        Log.d(
            'AdminService: Public categories response received: ${response.data.toString()}');

        if (response.statusCode == 200) {
          final Map<String, dynamic> responseData = response.data;
          if (responseData['success'] == true) {
            final List<dynamic> data = responseData['data'];
            Log.d(
                'AdminService: Parsing ${data.length} categories from public endpoint');

            final categories =
                data.map((item) => Category.fromJson(item)).toList();
            Log.d(
                'AdminService: Successfully parsed ${categories.length} categories from public endpoint');
            return categories;
          }
        }
      } catch (e) {
        Log.w(
            'AdminService: Public categories endpoint failed, trying general categories: $e');
      }

      // Try the general categories endpoint
      final response = await _dio.get('/categories');
      Log.d(
          'AdminService: General categories response received: ${response.data.toString()}');

      if (response.statusCode == 200) {
        // Handle different response formats
        final dynamic responseData = response.data;

        if (responseData is Map<String, dynamic>) {
          if (responseData.containsKey('data') &&
              responseData['data'] is List) {
            final List<dynamic> data = responseData['data'];
            Log.d(
                'AdminService: Parsing ${data.length} categories from general endpoint');

            final categories =
                data.map((item) => Category.fromJson(item)).toList();
            Log.d(
                'AdminService: Successfully parsed ${categories.length} categories from general endpoint');
            return categories;
          }
        } else if (responseData is List<dynamic>) {
          // Direct list response
          final List<dynamic> data = responseData;
          Log.d(
              'AdminService: Parsing ${data.length} categories from direct list');

          final categories =
              data.map((item) => Category.fromJson(item)).toList();
          return categories;
        }
      }

      // If we get here, all endpoints failed
      throw Exception('All category endpoints failed');
    } catch (e, stackTrace) {
      Log.e('AdminService: Error fetching categories: $e\n$stackTrace');
      // Return default categories if API fails
      Log.d('AdminService: Returning default categories');
      return [
        Category(
          id: 1,
          name: 'Products',
          subcategories: [
            Category(id: 6, name: 'Vegetables'),
            Category(id: 7, name: 'Fruits'),
            Category(id: 8, name: 'Spices'),
            Category(id: 9, name: 'Cash Crops'),
            Category(id: 10, name: 'Cereals'),
            Category(id: 11, name: 'Seeds and Seedling'),
            Category(id: 12, name: 'Livestock and poultry'),
          ],
        ),
        Category(
          id: 3,
          name: 'Market Information',
          subcategories: [],
        ),
        Category(
          id: 4,
          name: 'Transport',
          subcategories: [
            Category(id: 13, name: 'Tandem'),
            Category(id: 14, name: 'Kirikuu'),
            Category(id: 15, name: 'Flatbed Trucks'),
            Category(id: 16, name: 'Tanker'),
            Category(id: 17, name: 'Refrigerator Truck'),
            Category(id: 18, name: 'Box Truck'),
            Category(id: 19, name: 'Liftgate Truck'),
            Category(id: 20, name: 'Van'),
            Category(id: 21, name: 'Container Hauler'),
            Category(id: 22, name: 'Pickups Trucks'),
            Category(id: 23, name: 'Fuso'),
            Category(id: 24, name: 'Semi Trailers'),
            Category(id: 25, name: 'Tracker Trailers'),
            Category(id: 26, name: 'Cargo'),
          ],
        ),
        Category(
          id: 5,
          name: 'Organic Products',
          subcategories: [
            Category(id: 26, name: 'Organic Vegetables'),
            Category(id: 27, name: 'Organic Fruits'),
            Category(id: 28, name: 'Organic Spices'),
            Category(id: 29, name: 'Organic Cash Crops'),
            Category(id: 30, name: 'Organic Cereals'),
            Category(id: 31, name: 'Organic Livestock and Poultry'),
          ],
        ),
        Category(
          id: 6,
          name: 'Agricultural Services',
          subcategories: [
            Category(id: 32, name: 'Packaging Materials'),
            Category(id: 33, name: 'Hydroponics'),
            Category(id: 34, name: 'Fertilizer'),
            Category(id: 35, name: 'Organic Manure'),
            Category(id: 36, name: 'Machinery'),
            Category(id: 37, name: 'Beehive and Aquatic'),
            Category(id: 38, name: 'Food and Beverage'),
            Category(id: 39, name: 'Cold Rooms Services'),
            Category(id: 40, name: 'Machinery and Rental Services'),
            Category(id: 41, name: 'Agronomist Services'),
            Category(id: 42, name: 'Financial Services'),
            Category(id: 43, name: 'Irrigation Services'),
            Category(id: 44, name: 'Branding and Consultation Services'),
          ],
        ),
      ];
    }
  }

  // Organic Product CRUD Operations
  Future<OrganicProduct> createOrganicProduct(OrganicProduct product,
      {List<File>? imageFiles}) async {
    try {
      if (imageFiles != null && imageFiles.isNotEmpty) {
        // Use Dio with FormData when images are provided (same as regular products)
        final formData = FormData.fromMap({
          'name': product.name,
          'slug': product.slug,
          'description': product.description,
          'price': product.price.toString(),
          'stock': product.stock.toString(),
          'is_active': product.isActive ? 1 : 0,
          'is_featured': product.isFeatured ? 1 : 0,
          'seller_id': product.sellerId.toString(),
          'category_id': product.categoryId.toString(),
          'certification': product.certification,
          'origin': product.origin,
          'storage_conditions': product.storageConditions,
          'shelf_life': product.shelfLife,
          if (product.harvestDate != null)
            'harvest_date': product.harvestDate!.toIso8601String(),
        });

        // Add image files using indexed field names for proper array handling
        for (var i = 0; i < imageFiles.length; i++) {
          final imageFile = imageFiles[i];
          if (kIsWeb) {
            final bytes = await imageFile.readAsBytes();
            final filename = imageFile.path.split('/').last.isNotEmpty
                ? imageFile.path.split('/').last
                : 'image_$i.jpg';
            formData.files.add(MapEntry(
              'images[$i]', // Use indexed field names
              MultipartFile.fromBytes(
                bytes,
                filename: filename,
              ),
            ));
          } else {
            final filename = imageFile.path.split('/').last.isNotEmpty
                ? imageFile.path.split('/').last
                : 'image_$i.jpg';
            formData.files.add(MapEntry(
              'images[$i]', // Use indexed field names
              await MultipartFile.fromFile(
                imageFile.path,
                filename: filename,
              ),
            ));
          }
        }

        try {
          final response = await _dio.post(
            '/admin/organic-products',
            data: formData,
            options: Options(
              headers: {
                'Accept': 'application/json',
                'Content-Type': 'multipart/form-data',
                'Authorization': 'Bearer $_authToken',
                'User-Agent': _userAgent,
                'Origin': baseUrl.replaceAll('/api', ''),
                'Referer': baseUrl.replaceAll('/api', ''),
              },
              validateStatus: (status) => status! < 500,
            ),
          );

          Log.d('Response status: ${response.statusCode}');
          Log.d('Response data: ${response.data}');

          if (response.statusCode == 201) {
            Log.d('Organic product created successfully');
            final responseData = response.data['data'] as Map<String, dynamic>;
            return OrganicProduct.fromJson(responseData);
          } else {
            Log.e(
                'Failed to create organic product - Status: ${response.statusCode}');
            Log.e('Response data: ${response.data}');

            String errorMessage = 'Failed to create organic product';
            if (response.data is Map && response.data.containsKey('message')) {
              errorMessage = response.data['message'];
            } else if (response.data is Map &&
                response.data.containsKey('error')) {
              errorMessage = response.data['error'];
            }

            throw Exception('Failed to create organic product: $errorMessage');
          }
        } on DioException catch (dioError) {
          Log.e(
              'DioException during organic product creation: ${dioError.message}');
          Log.e('DioException response: ${dioError.response?.data}');
          Log.e('DioException status: ${dioError.response?.statusCode}');

          if (dioError.response?.statusCode == 500) {
            String errorMessage =
                'Server error occurred while creating organic product';
            if (dioError.response?.data is Map) {
              final data = dioError.response!.data as Map;
              if (data.containsKey('message')) {
                errorMessage = data['message'];
              } else if (data.containsKey('error')) {
                errorMessage = data['error'];
              }
            }
            throw Exception('Failed to create organic product: $errorMessage');
          } else {
            throw Exception(
                'Failed to create organic product: ${dioError.message}');
          }
        }
      } else {
        // Use regular JSON request when no image
        final productJson = product.toJson();

        // Remove fields that might cause serialization issues
        productJson.remove('created_at');
        productJson.remove('updated_at');

        // Also remove any null DateTime fields to prevent namespace issues
        if (productJson['harvest_date'] == null) {
          productJson.remove('harvest_date');
        }

        final response = await http.post(
          Uri.parse('$baseUrl/admin/organic-products'),
          headers: _enhancedHeaders,
          body: json.encode(productJson),
        );

        if (response.statusCode == 201) {
          final data = json.decode(response.body);
          return OrganicProduct.fromJson(data['data']);
        } else {
          throw Exception('Failed to create organic product: ${response.body}');
        }
      }
    } catch (e) {
      Log.e('Error creating organic product: $e');
      throw Exception('Error creating organic product: $e');
    }
  }

  Future<OrganicProduct> updateOrganicProduct(OrganicProduct product,
      {List<File>? imageFiles}) async {
    try {
      final url = '$baseUrl/admin/organic-products/${product.id}';
      Log.d('Updating organic product at: $url');

      if (imageFiles != null && imageFiles.isNotEmpty) {
        // Use multipart request if there are images
        final formData = FormData.fromMap({
          'name': product.name,
          'description': product.description,
          'price': product.price.toString(),
          'stock': product.stock.toString(),
          'category_id': product.categoryId.toString(),
          'certification': product.certification,
          'origin': product.origin,
          'storage_conditions': product.storageConditions,
          'shelf_life': product.shelfLife,
          'is_active': product.isActive ? '1' : '0',
          'is_featured': product.isFeatured ? '1' : '0',
          'seller_id': product.sellerId.toString(),
          '_method': 'PUT', // Method spoofing for Laravel
        });

        // Add image files using indexed field names for proper array handling
        for (var i = 0; i < imageFiles.length; i++) {
          final imageFile = imageFiles[i];
          final filename = imageFile.path.split('/').last.isNotEmpty
              ? imageFile.path.split('/').last
              : 'image_$i.jpg';
          formData.files.add(MapEntry(
            'images[$i]', // Use indexed field names for proper array handling
            await MultipartFile.fromFile(
              imageFile.path,
              filename: filename,
            ),
          ));
        }

        // Increase timeout for image uploads
        final response = await _dio.post(
          url,
          data: formData,
          options: Options(
            headers: {
              'Content-Type': 'multipart/form-data',
              'Authorization': 'Bearer $_authToken',
              'User-Agent': _userAgent,
              'Origin': baseUrl.replaceAll('/api', ''),
              'Referer': baseUrl.replaceAll('/api', ''),
            },
            sendTimeout: const Duration(seconds: 30),
            receiveTimeout: const Duration(seconds: 30),
          ),
        );

        if (response.statusCode == 200) {
          final responseData = response.data['data'];
          return OrganicProduct.fromJson(responseData);
        } else {
          throw Exception(
              'Failed to update organic product: ${response.data['message'] ?? response.statusMessage}');
        }
      } else {
        // Use regular JSON request if no image
        final productJson = product.toJson();

        // Remove fields that might cause serialization issues
        productJson.remove('created_at');
        productJson.remove('updated_at');

        // Also remove any null DateTime fields to prevent namespace issues
        if (productJson['harvest_date'] == null) {
          productJson.remove('harvest_date');
        }

        final response = await http.put(
          Uri.parse(url),
          headers: _enhancedHeaders,
          body: json.encode(productJson),
        );

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          return OrganicProduct.fromJson(data['data']);
        } else {
          throw Exception('Failed to update organic product: ${response.body}');
        }
      }
    } catch (e) {
      Log.e('Error updating organic product: $e');
      throw Exception('Error updating organic product: $e');
    }
  }

  Future<Map<String, dynamic>> uploadOrganicProductImage(File imageFile) async {
    try {
      Log.d('Uploading organic product image...');
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/admin/organic-products/upload-image'),
      );

      request.headers.addAll(_enhancedHeaders);
      request.files
          .add(await http.MultipartFile.fromPath('image', imageFile.path));

      var response = await request.send();
      var responseBody = await response.stream.bytesToString();

      Log.d(
          'Upload organic product image response status: ${response.statusCode}');
      Log.d('Upload organic product image response body: $responseBody');

      if (response.statusCode == 200) {
        return json.decode(responseBody);
      } else {
        throw Exception(
            'Failed to upload organic product image: ${response.statusCode}');
      }
    } catch (e) {
      Log.e('Error uploading organic product image: $e');
      rethrow;
    }
  }
}
