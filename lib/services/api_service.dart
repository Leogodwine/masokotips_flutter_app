import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import '../models/user.dart';
import '../models/product.dart'; // Ensure this file contains the Product class definition
import '../models/category.dart'; // Ensure this file contains the Category class definition
import '../config/api_config.dart';
import '../models/service.dart'; // Ensure this file contains the Service class definition
import '../models/transport.dart'; // Ensure this file contains the Transport class definition
import '../utils/logger.dart';
import '../utils/extensions.dart';

class ApiService {
  final String baseUrl;
  final String apiKey;
  String? _authToken;

  ApiService({
    required this.baseUrl,
    required this.apiKey,
  }) {
    _authToken = apiKey;
  }

  void setAuthToken(String token) {
    _authToken = token;
  }

  Map<String, String> get headers => ApiConfig.getHeaders(_authToken);
  Map<String, String> get _publicHeaders => ApiConfig.getHeaders();

  bool _looksLikeHtml(String body) {
    final lowerBody = body.trimLeft().toLowerCase();
    return lowerBody.startsWith('<!doctype html') ||
        lowerBody.startsWith('<html') ||
        lowerBody.contains('<title>') ||
        lowerBody.contains('</html>');
  }

  bool _looksLikeSecurityChallenge(String body) {
    final lowerBody = body.toLowerCase();
    return _looksLikeHtml(body) ||
        lowerBody.contains('litespeed') ||
        lowerBody.contains('recaptcha') ||
        lowerBody.contains('captcha') ||
        lowerBody.contains('bot') ||
        lowerBody.contains('challenge') ||
        lowerBody.contains('verification');
  }

  dynamic _decodeJson(String body) {
    final trimmedBody = body.trim();
    if (trimmedBody.isEmpty) return {};

    if (_looksLikeSecurityChallenge(trimmedBody)) {
      Log.e('Security challenge detected: HTML returned instead of JSON');
      Log.d(
          'Challenge body snippet: ${trimmedBody.length > 500 ? trimmedBody.substring(0, 500) : trimmedBody}');
      throw Exception(
          'Security Check: The server is verifying your request. Please wait a few seconds and try again.');
    }

    try {
      return jsonDecode(trimmedBody);
    } on FormatException catch (e) {
      Log.e('Invalid JSON response: $e');
      throw Exception(
          'The server returned an invalid response. Please try again in a moment.');
    }
  }

  /// Centralized response handler to detect bot interference and format errors
  dynamic _handleResponse(http.Response response) {
    final body = response.body.trim();
    final isHtml = _looksLikeHtml(body);
    final url = response.request?.url.toString() ?? 'unknown';

    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (isHtml) {
        Log.e(
            'Bot interference detected at $url (HTML returned instead of JSON)');
        throw Exception(
            'Security Check: Our system is verifying your connection. Please try again in a moment.');
      }
      if (body.isEmpty) return {};
      return _decodeJson(body);
    }

    // Handle non-2xx status codes
    if (response.statusCode == 403 || response.statusCode == 503) {
      final lowerBody = body.toLowerCase();
      if (_looksLikeSecurityChallenge(lowerBody)) {
        Log.e(
            'Security challenge (HTTP ${response.statusCode}) detected at $url');
        throw Exception(
            'Security Check: The server is verifying your request. Please wait a few seconds and try again.');
      }
      if (response.statusCode == 503) {
        throw Exception(
            'The server is temporarily busy. Please try again in a moment.');
      }
    }

    if (response.statusCode == 401) {
      throw Exception('Your session has expired. Please log in again.');
    }

    if (response.statusCode == 404) {
      throw Exception('The requested information was not found.');
    }

    if (response.statusCode == 500) {
      throw Exception(
          'Our servers are experiencing a temporary issue. Please try again later.');
    }

    // Try to parse error message from JSON if possible
    if (!isHtml && body.isNotEmpty) {
      try {
        final errorData = _decodeJson(body);
        if (errorData is Map && errorData.containsKey('message')) {
          return errorData; // Return for specific handling (like validation errors)
        }
      } catch (_) {}
    }

    throw Exception('Request failed with status: ${response.statusCode}');
  }

  /// Helper to check for bot interference/HTML responses before parsing JSON
  void _checkBotInterference(http.BaseResponse response, String body) {
    final trimmedBody = body.trim();
    final isHtml = _looksLikeHtml(trimmedBody);

    if (isHtml || response.statusCode == 403 || response.statusCode == 503) {
      if (_looksLikeSecurityChallenge(trimmedBody)) {
        throw Exception(
            'Security Check: The server is verifying your request. Please wait a few seconds and try again.');
      }
    }
  }

  Future<dynamic> getRequest(String endpoint) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/$endpoint'),
        headers: headers,
      );

      return _handleResponse(response);
    } catch (e) {
      Log.e('Error in GET request: $e');
      rethrow;
    }
  }

  // Generic public GET method (no auth token)
  Future<dynamic> getPublicRequest(String endpoint) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/$endpoint'),
        headers: _publicHeaders,
      );

      return _handleResponse(response);
    } catch (e) {
      Log.e('Error in public GET request: $e');
      rethrow;
    }
  }

  // Generic DELETE method
  Future<Map<String, dynamic>> deleteRequest(String endpoint) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/$endpoint'),
        headers: headers,
      );

      final result = _handleResponse(response);
      if (result is Map<String, dynamic>) return result;
      return {};
    } catch (e) {
      Log.e('Error in DELETE request: $e');
      rethrow;
    }
  }

  Future<bool> checkConnection() async {
    try {
      final uri = Uri.parse('$baseUrl/health');
      Log.e('Checking API connection at: $uri');

      final response = await http.get(uri, headers: headers);
      Log.e('Health check response status: ${response.statusCode}');

      return response.statusCode == 200;
    } catch (e) {
      Log.e('Error checking API connection: $e');
      return false;
    }
  }

  // Login
  Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      final url = Uri.parse('$baseUrl/auth/login');
      final requestBody = {
        'username': username,
        'password': password,
      };

      Log.e('Login request URL: $url');
      Log.e('Login request body: ${jsonEncode(requestBody)}');

      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode(requestBody),
      );

      final result = _handleResponse(response);

      if (result is Map<String, dynamic> && result.containsKey('token')) {
        return result;
      }

      // If _handleResponse returned error data (Map with message)
      if (result is Map<String, dynamic> && result.containsKey('message')) {
        final errorData = result;
        // Check for Laravel validation errors (errors object)
        if (errorData.containsKey('errors') && errorData['errors'] is Map) {
          final errors = errorData['errors'] as Map<String, dynamic>;
          if (errors.containsKey('username')) {
            final usernameErrors = errors['username'];
            if (usernameErrors is List && usernameErrors.isNotEmpty) {
              throw Exception('Username: ${usernameErrors.first}');
            }
          }
          if (errors.containsKey('password')) {
            final passwordErrors = errors['password'];
            if (passwordErrors is List && passwordErrors.isNotEmpty) {
              throw Exception('Password: ${passwordErrors.first}');
            }
          }
        }

        final message = errorData['message'].toString().toLowerCase();
        if (message.contains('invalid') ||
            message.contains('credentials') ||
            message.contains('unauthorized')) {
          throw Exception('Invalid username or password');
        }
        throw Exception(errorData['message']);
      }

      throw Exception('Unexpected response format during login');
    } catch (e) {
      Log.e('Login error: $e');
      // Re-throw if it's already an Exception with our custom message
      if (e.toString().startsWith('Exception:')) {
        rethrow;
      }
      throw Exception('Error during login: ${e.toFriendlyError}');
    }
  }

  // Get services
  Future<Map<String, dynamic>> getServices({
    required String category,
    String? search,
    String? sortBy,
    required int page,
    required int perPage,
    double? minPrice,
    double? maxPrice,
    double? minRating,
  }) async {
    try {
      final queryParams = <String, String>{
        'category': category,
        'page': page.toString(),
        'per_page': perPage.toString(),
        if (search != null && search.isNotEmpty) 'search': search,
        if (sortBy != null && sortBy.isNotEmpty) 'sort_by': sortBy,
        if (minPrice != null) 'min_price': minPrice.toString(),
        if (maxPrice != null) 'max_price': maxPrice.toString(),
        if (minRating != null) 'min_rating': minRating.toString(),
      };

      final uri =
          Uri.parse('$baseUrl/services').replace(queryParameters: queryParams);

      Log.d('Fetching services from: $uri');

      final response = await http.get(
        uri,
        headers: headers,
      );

      Log.d('Services API response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = _decodeJson(response.body);

        // Check if the response has the expected structure
        if (data is Map<String, dynamic> && data.containsKey('services')) {
          final List<dynamic> servicesJson = data['services'];
          final List<Service> services =
              servicesJson.map((json) => Service.fromJson(json)).toList();

          return {
            'services': services,
            'currentPage': data['current_page'] ?? 1,
            'lastPage': data['last_page'] ?? 1,
          };
        } else {
          // Handle unexpected response structure
          Log.e('Unexpected API response structure: $data');
          return {
            'services': <Service>[],
            'currentPage': 1,
            'lastPage': 1,
          };
        }
      } else if (response.statusCode == 404) {
        // No services found
        Log.d('No services found for category: $category');
        return {
          'services': <Service>[],
          'currentPage': 1,
          'lastPage': 1,
        };
      } else {
        Log.e(
            'Failed to fetch services. Status code: ${response.statusCode}, Body: ${response.body}');
        throw Exception(
            'Failed to fetch services. Status code: ${response.statusCode}');
      }
    } catch (e) {
      Log.e('Error fetching services: $e');
      throw Exception('Error fetching services: ${e.toFriendlyError}');
    }
  }

  // Register
  Future<Map<String, dynamic>> register(
      String name, String username, String email, String password,
      {String role = 'buyer',
      String? phone,
      String? location,
      String? country,
      String? proofOfAddressType,
      File? proofOfAddress,
      String? referralCode}) async {
    try {
      final url = Uri.parse('$baseUrl/auth/register');

      // If there's a file, use multipart request
      if (proofOfAddress != null) {
        final request = http.MultipartRequest('POST', url);

        // Add text fields
        request.fields['name'] = name;
        request.fields['username'] = username;
        request.fields['email'] = email;
        request.fields['password'] = password;
        request.fields['password_confirmation'] = password;
        request.fields['role'] = role;
        if (phone != null) request.fields['phone'] = phone;
        if (location != null) request.fields['location'] = location;
        if (country != null) request.fields['country'] = country;
        if (proofOfAddressType != null) {
          request.fields['proof_of_address_type'] = proofOfAddressType;
        }
        if (referralCode != null && referralCode.isNotEmpty) {
          request.fields['referral_code'] = referralCode;
        }

        // Add file — use fromBytes to avoid dart:io MultipartFile.fromPath issues
        final proofBytes = await proofOfAddress.readAsBytes();
        final proofFilename =
            proofOfAddress.path.split('/').last.split('\\').last;
        request.files.add(http.MultipartFile.fromBytes(
          'proof_of_address',
          proofBytes,
          filename: proofFilename,
        ));

        // Use proper headers for multipart request
        request.headers.addAll(ApiConfig.getHeaders(_authToken));

        Log.e('Registration request URL: $url');
        Log.e('Registration request fields: ${request.fields}');
        Log.e('Registration request files: ${request.files.length}');

        final response = await request.send();
        final responseBody = await response.stream.bytesToString();

        Log.e('Registration response status: ${response.statusCode}');
        Log.e('Registration response body: $responseBody');

        if (response.statusCode == 201) {
          final responseData = _decodeJson(responseBody);
          Log.e('Registration successful, returning data: $responseData');
          return responseData;
        } else {
          throw Exception('Failed to register: $responseBody');
        }
      } else {
        // Regular JSON request without file
        final requestBody = {
          'name': name,
          'username': username,
          'email': email,
          'password': password,
          'password_confirmation': password,
          'role': role,
          if (phone != null) 'phone': phone,
          if (location != null) 'location': location,
          if (country != null) 'country': country,
          if (proofOfAddressType != null)
            'proof_of_address_type': proofOfAddressType,
          if (referralCode != null && referralCode.isNotEmpty)
            'referral_code': referralCode,
        };

        Log.e('Registration request URL: $url');
        Log.e('Registration request body: ${jsonEncode(requestBody)}');

        final response = await http.post(
          url,
          headers: headers,
          body: jsonEncode(requestBody),
        );

        Log.e('Registration response status: ${response.statusCode}');
        Log.e('Registration response body: ${response.body}');

        if (response.statusCode == 201) {
          final responseData = _decodeJson(response.body);
          Log.e('Registration successful, returning data: $responseData');
          return responseData;
        } else {
          throw Exception('Failed to register: ${response.body}');
        }
      }
    } catch (e) {
      Log.e('Registration error: $e');
      throw Exception('Error during registration: ${e.toFriendlyError}');
    }
  }

  // Logout
  Future<void> logout() async {
    try {
      final url = Uri.parse('$baseUrl/user/logout');
      final response = await http.post(
        url,
        headers: headers,
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to logout: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error during logout: ${e.toFriendlyError}');
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      final url = Uri.parse('$baseUrl/auth/forgot-password');
      final requestBody = {
        'email': email,
      };

      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final responseData = _decodeJson(response.body);
        if (responseData['success'] != true) {
          throw Exception(
              responseData['message'] ?? 'Failed to send reset email');
        }
      } else {
        final errorData = _decodeJson(response.body);
        throw Exception(errorData['message'] ?? 'Failed to send reset email');
      }
    } catch (e) {
      Log.e('Reset password error: $e');
      throw Exception(
          'Error sending reset password email: ${e.toFriendlyError}');
    }
  }

  // Get user profile
  Future<User> getUserProfile() async {
    try {
      final url = Uri.parse('$baseUrl/profile');
      final response = await http.get(
        url,
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = _decodeJson(response.body);
        // Handle case where user is wrapped in a 'user' key
        final userData = data.containsKey('user') ? data['user'] : data;
        return User.fromJson(userData);
      } else {
        throw Exception('Failed to fetch user profile: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error fetching user profile: ${e.toFriendlyError}');
    }
  }

  // Update user profile
  Future<User> updateProfile({
    required String name,
    required String email,
    String? phone,
    String? bio,
    String? avatarPath,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/user/profile');
      final request = http.MultipartRequest('POST', url);

      request.headers.addAll(ApiConfig.getHeaders(_authToken));

      // Laravel method spoofing
      request.fields['_method'] = 'PUT';

      request.fields['name'] = name;
      request.fields['email'] = email;
      if (phone != null) request.fields['phone'] = phone;
      if (bio != null) request.fields['bio'] = bio;

      if (avatarPath != null) {
        final avatarBytes = await File(avatarPath).readAsBytes();
        final avatarFilename = avatarPath.split('/').last.split('\\').last;
        request.files.add(http.MultipartFile.fromBytes(
          'avatar',
          avatarBytes,
          filename: avatarFilename,
        ));
      }

      final response = await request.send();
      final body = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final data = _decodeJson(body);
        return User.fromJson(data['user']);
      } else {
        throw Exception('Profile update failed: $body');
      }
    } catch (e) {
      throw Exception('Error updating profile: ${e.toFriendlyError}');
    }
  }

  // Removed duplicate _getAuthHeaders method to resolve the conflict.
  // Upload profile image
  Future<void> uploadProfileImage(String imagePath) async {
    try {
      final url = Uri.parse('$baseUrl/profile/avatar');
      final request = http.MultipartRequest('POST', url);
      final bytes = await File(imagePath).readAsBytes();
      final filename = imagePath.split('/').last.split('\\').last;
      request.headers['Authorization'] = 'Bearer $_authToken';
      request.headers['Accept'] = 'application/json';
      final ua = ApiConfig.userAgent;
      if (ua.isNotEmpty) request.headers['User-Agent'] = ua;
      request.files.add(
          http.MultipartFile.fromBytes('avatar', bytes, filename: filename));
      final response = await request.send();
      if (response.statusCode != 200) {
        throw Exception('Failed to upload profile image');
      }
    } catch (e) {
      throw Exception('Error uploading profile image: ${e.toFriendlyError}');
    }
  }

  // Change password
  Future<void> changePassword(
      String currentPassword, String newPassword) async {
    throw Exception('Change password endpoint not implemented in API yet');
  }

  // Fetch related products
  Future<List<Product>> getRelatedProducts(int productId) async {
    try {
      Log.e('ApiService: Fetching related products for product ID: $productId');
      final uri = Uri.parse('$baseUrl/products/$productId/related');
      Log.e('ApiService: Request URL: $uri');

      final response = await http.get(
        uri,
        headers: headers,
      );

      Log.e('ApiService: Response status code: ${response.statusCode}');
      Log.e('ApiService: Response body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = _decodeJson(response.body);
        final List<dynamic> data = responseData['data'];
        Log.e('ApiService: Parsed ${data.length} related products');

        final products = data.map((json) => Product.fromJson(json)).toList();

        // Log details of each parsed product
        for (var product in products) {
          Log.e(
              'ApiService: Parsed product - ID: ${product.id}, Name: ${product.name}');
        }

        return products;
      } else {
        Log.e(
            'ApiService: Error response: ${response.statusCode} - ${response.body}');
        throw Exception(
            'Failed to fetch related products: ${response.statusCode}');
      }
    } catch (e, stackTrace) {
      Log.e(
          'ApiService: Exception while fetching related products: $e\n$stackTrace');
      throw Exception('Failed to fetch related products: ${e.toFriendlyError}');
    }
  }

  // Get all products
  // Fetch products with pagination
  Future<List<Product>> getProducts({int page = 1, int perPage = 10}) async {
    try {
      final uri = Uri.parse('$baseUrl/products').replace(queryParameters: {
        'page': page.toString(),
        'per_page': perPage.toString(),
      });

      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        final dynamic responseData = _decodeJson(response.body);

        List<dynamic> productsData = [];
        if (responseData is Map<String, dynamic>) {
          if (responseData.containsKey('products')) {
            productsData = responseData['products'] is Map
                ? (responseData['products']['data'] ?? [])
                : responseData['products'];
          } else if (responseData.containsKey('data')) {
            productsData = responseData['data'];
          }
        } else if (responseData is List) {
          productsData = responseData;
        }

        return productsData.map((json) => Product.fromJson(json)).toList();
      } else {
        throw Exception(
            'Failed to fetch products. Status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching products: ${e.toFriendlyError}');
    }
  }

  // Get products by category (regular products)
  Future<List<Product>> getProductsByCategory(
      int categoryId, String subcategory) async {
    try {
      final uri = Uri.parse('$baseUrl/categories/$categoryId/products');
      Log.e('Fetching products for category: $categoryId');
      Log.e('Request URL: $uri');

      final response = await http.get(uri, headers: headers);

      Log.e('Response status: ${response.statusCode}');
      Log.e('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final dynamic responseData = _decodeJson(response.body);

        // Handle different response formats
        List<dynamic> productsData;
        if (responseData is Map<String, dynamic>) {
          if (responseData.containsKey('data')) {
            productsData = List<dynamic>.from(responseData['data']);
          } else if (responseData.containsKey('products')) {
            productsData = List<dynamic>.from(responseData['products']);
          } else {
            productsData = [];
          }
        } else if (responseData is List) {
          productsData = responseData;
        } else {
          productsData = [];
        }

        Log.e('Received ${productsData.length} products');
        Log.e('Products data: ${productsData.toString()}');

        final products = <Product>[];
        for (int i = 0; i < productsData.length; i++) {
          try {
            final product = Product.fromJson(productsData[i]);
            products.add(product);
            Log.e('Successfully parsed product ${i + 1}: ${product.name}');
          } catch (e) {
            Log.e('Error parsing product ${i + 1}: $e');
            Log.e('Product data: ${productsData[i]}');
          }
        }

        Log.e('Parsed ${products.length} products');
        return products;
      } else if (response.statusCode == 404) {
        Log.e('No products found for category: $categoryId');
        return [];
      } else {
        Log.e('Error response: ${response.body}');
        throw Exception(
            'Failed to load products: ${response.statusCode} - ${response.body}');
      }
    } catch (e, stackTrace) {
      Log.e('Error in getProductsByCategory: $e\n$stackTrace');
      throw Exception('Failed to load products: ${e.toFriendlyError}');
    }
  }

  // Get organic products by category
  Future<List<Map<String, dynamic>>> getOrganicProductsByCategory(
      int categoryId, String subcategory) async {
    try {
      final uri = Uri.parse('$baseUrl/categories/$categoryId/organic-products');
      Log.e('Fetching organic products for category: $categoryId');
      Log.e('Request URL: $uri');

      final response = await http.get(uri, headers: headers);

      Log.e('Organic products response status: ${response.statusCode}');
      Log.e('Organic products response body: ${response.body}');

      if (response.statusCode == 200) {
        final dynamic responseData = _decodeJson(response.body);

        // Handle different response formats
        List<dynamic> productsData;
        if (responseData is Map<String, dynamic>) {
          if (responseData.containsKey('data')) {
            productsData = List<dynamic>.from(responseData['data']);
          } else if (responseData.containsKey('products')) {
            productsData = List<dynamic>.from(responseData['products']);
          } else {
            productsData = [];
          }
        } else if (responseData is List) {
          productsData = responseData;
        } else {
          productsData = [];
        }

        Log.e('Received ${productsData.length} organic products');
        Log.e('Organic products data: ${productsData.toString()}');

        final products = <Map<String, dynamic>>[];
        for (int i = 0; i < productsData.length; i++) {
          try {
            final product = Map<String, dynamic>.from(productsData[i]);
            products.add(product);
            Log.e(
                'Successfully parsed organic product ${i + 1}: ${product['name']}');
          } catch (e) {
            Log.e('Error parsing organic product ${i + 1}: $e');
            Log.e('Organic product data: ${productsData[i]}');
          }
        }

        Log.e('Parsed ${products.length} organic products');
        return products;
      } else if (response.statusCode == 404) {
        Log.e('No organic products found for category: $categoryId');
        return [];
      } else {
        Log.e('Error response: ${response.body}');
        throw Exception(
            'Failed to load organic products: ${response.statusCode} - ${response.body}');
      }
    } catch (e, stackTrace) {
      Log.e('Error in getOrganicProductsByCategory: $e\n$stackTrace');
      throw Exception('Failed to load organic products: ${e.toFriendlyError}');
    }
  }

  Future<List<Map<String, dynamic>>> getFoodBeveragesByCategory(
      int categoryId, String subcategory) async {
    try {
      final uri = Uri.parse('$baseUrl/categories/$categoryId/food-beverages');
      Log.e('Fetching food & beverages for category: $categoryId');
      Log.e('Request URL: $uri');

      final response = await http.get(uri, headers: headers);

      Log.e('Food & beverages response status: ${response.statusCode}');
      Log.e('Food & beverages response body: ${response.body}');

      if (response.statusCode == 200) {
        final dynamic responseData = _decodeJson(response.body);

        // Handle different response formats
        List<dynamic> productsData;
        if (responseData is Map<String, dynamic>) {
          if (responseData.containsKey('data')) {
            productsData = List<dynamic>.from(responseData['data']);
          } else if (responseData.containsKey('products')) {
            productsData = List<dynamic>.from(responseData['products']);
          } else {
            productsData = [];
          }
        } else if (responseData is List) {
          productsData = responseData;
        } else {
          productsData = [];
        }

        Log.e('Received ${productsData.length} food & beverages');
        Log.e('Food & beverages data: ${productsData.toString()}');

        final products = <Map<String, dynamic>>[];
        for (int i = 0; i < productsData.length; i++) {
          try {
            final product = Map<String, dynamic>.from(productsData[i]);
            products.add(product);
            Log.e(
                'Successfully parsed food & beverage ${i + 1}: ${product['name']}');
          } catch (e) {
            Log.e('Error parsing food & beverage ${i + 1}: $e');
            Log.e('Food & beverage data: ${productsData[i]}');
          }
        }

        Log.e('Parsed ${products.length} food & beverages');
        return products;
      } else if (response.statusCode == 404) {
        Log.e('No food & beverages found for category: $categoryId');
        return [];
      } else {
        Log.e('Error response: ${response.body}');
        throw Exception(
            'Failed to load food & beverages: ${response.statusCode} - ${response.body}');
      }
    } catch (e, stackTrace) {
      Log.e('Error in getFoodBeveragesByCategory: $e\n$stackTrace');
      throw Exception('Failed to load food & beverages: ${e.toFriendlyError}');
    }
  }

  Future<List<Category>> getCategories() async {
    try {
      final uri = Uri.parse('$baseUrl/main-categories');
      Log.d('ApiService: Fetching main categories from: $uri');

      final response = await http.get(
        uri,
        headers: headers,
      );

      final data = _handleResponse(response);

      if (data is Map<String, dynamic> && data.containsKey('data')) {
        final List<dynamic> categoriesJson = data['data'];
        final categories =
            categoriesJson.map((json) => Category.fromJson(json)).toList();
        Log.e(
            'ApiService: Successfully parsed ${categories.length} main categories');
        return categories;
      }
      return [];
    } catch (e, stackTrace) {
      Log.e('ApiService: Error fetching main categories: $e');
      Log.e('ApiService: Stack trace: $stackTrace');
      throw Exception('Error fetching main categories: ${e.toFriendlyError}');
    }
  }

  // Get subcategories for a specific category
  Future<List<Category>> getSubcategories(int categoryId) async {
    try {
      final uri = Uri.parse('$baseUrl/categories/$categoryId/subcategories');
      Log.e(
          'ApiService: Fetching subcategories for category $categoryId from: $uri');

      final response = await http.get(
        uri,
        headers: headers,
      );

      final data = _handleResponse(response);

      if (data is Map<String, dynamic> && data.containsKey('data')) {
        // Wrapped response format: {"data": [...]}
        final List<dynamic> subcategoriesJson = data['data'];
        final subcategories =
            subcategoriesJson.map((json) => Category.fromJson(json)).toList();
        Log.e(
            'ApiService: Successfully parsed ${subcategories.length} subcategories from wrapped response');
        return subcategories;
      } else if (data is List) {
        // Direct array format: [...]
        final subcategories =
            data.map((json) => Category.fromJson(json)).toList();
        Log.e(
            'ApiService: Successfully parsed ${subcategories.length} subcategories from direct array');
        return subcategories;
      }
      return [];
    } catch (e, stackTrace) {
      Log.e('ApiService: Error fetching subcategories: $e');
      Log.e('ApiService: Stack trace: $stackTrace');
      throw Exception('Error fetching subcategories: ${e.toFriendlyError}');
    }
  }

  // Get Transport subcategories specifically for Add Transport screen
  Future<List<Category>> getTransportSubcategories() async {
    try {
      final uri = Uri.parse('$baseUrl/transports/subcategories');
      Log.i('ApiService: Fetching Transport subcategories from: $uri');

      final response = await http.get(
        uri,
        headers: headers,
      );

      final data = _handleResponse(response);

      // Handle the response format: {"success": true, "data": [...], "message": "..."}
      if (data is Map<String, dynamic> && data.containsKey('data')) {
        final List<dynamic> subcategoriesJson = data['data'];
        final subcategories =
            subcategoriesJson.map((json) => Category.fromJson(json)).toList();
        Log.i(
            'ApiService: Successfully parsed ${subcategories.length} Transport subcategories');
        return subcategories;
      } else if (data is List) {
        final subcategories =
            data.map((json) => Category.fromJson(json)).toList();
        return subcategories;
      }
      return [];
    } catch (e) {
      Log.e('ApiService: Error fetching Transport subcategories: $e');
      throw Exception(
          'Error fetching Transport subcategories: ${e.toFriendlyError}');
    }
  }

  Future<List<Product>> getFeaturedProducts() async {
    try {
      final uri = Uri.parse('$baseUrl/products/featured');
      Log.e('ApiService: Fetching featured products from: $uri');

      final response = await http.get(
        uri,
        headers: headers,
      );

      final data = _handleResponse(response);

      if (data is Map<String, dynamic> && data.containsKey('data')) {
        final List<dynamic> productsJson = data['data'];
        final products =
            productsJson.map((json) => Product.fromJson(json)).toList();
        Log.e(
            'ApiService: Successfully parsed ${products.length} featured products');
        return products;
      }
      return [];
    } catch (e, stackTrace) {
      Log.e('ApiService: Error fetching featured products: $e');
      Log.e('ApiService: Stack trace: $stackTrace');
      throw Exception('Error fetching featured products: ${e.toFriendlyError}');
    }
  }

  // Get product details by ID
  Future<Product> getProductDetails(int productId) async {
    try {
      final url = Uri.parse('$baseUrl/products/$productId');
      final response = await http.get(
        url,
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = _decodeJson(response.body);
        return Product.fromJson(data);
      } else {
        throw Exception(
            'Failed to fetch product details. Status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching product details: ${e.toFriendlyError}');
    }
  }

  // Add a new product
  Future<void> addProduct(Product product) async {
    try {
      final url = Uri.parse('$baseUrl/products');
      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode(product.toJson()),
      );

      if (response.statusCode != 201) {
        throw Exception(
            'Failed to add product. Status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error adding product: ${e.toFriendlyError}');
    }
  }

  // Transport methods
  Future<List<Transport>> getTransports() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/transports'),
        headers: headers,
      );

      _checkBotInterference(response, response.body);
      if (response.statusCode == 200) {
        final List<dynamic> data = _decodeJson(response.body);
        return data.map((json) => Transport.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load transports');
      }
    } catch (e) {
      throw Exception('Error loading transports: ${e.toFriendlyError}');
    }
  }

  Future<Transport?> getTransportDetails(int transportId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/transports/$transportId'),
        headers: headers,
      );

      _checkBotInterference(response, response.body);
      if (response.statusCode == 200) {
        final data = _decodeJson(response.body);
        return Transport.fromJson(data);
      } else {
        throw Exception('Failed to load transport details');
      }
    } catch (e) {
      throw Exception('Error loading transport details: ${e.toFriendlyError}');
    }
  }

  Future<void> addTransport(Transport transport) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/transports'),
        headers: headers,
        body: json.encode(transport.toJson()),
      );

      if (response.statusCode != 201) {
        throw Exception('Failed to add transport');
      }
    } catch (e) {
      throw Exception('Error adding transport: ${e.toFriendlyError}');
    }
  }

  Future<dynamic> get(String endpoint, {Map<String, String>? headers}) async {
    final response = await http.get(
      Uri.parse('$baseUrl$endpoint'),
      headers: {
        ...this.headers,
        'X-API-Key': apiKey,
        ...?headers,
      },
    );

    if (response.statusCode == 200) {
      return _decodeJson(response.body);
    } else {
      throw Exception('Failed to load data: ${response.statusCode}');
    }
  }

  Future<dynamic> post(String endpoint,
      {Map<String, String>? headers, Map<String, dynamic>? body}) async {
    final response = await http.post(
      Uri.parse('$baseUrl$endpoint'),
      headers: {
        ...this.headers,
        'X-API-Key': apiKey,
        ...?headers,
      },
      body: json.encode(body),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return _decodeJson(response.body);
    } else {
      throw Exception('Failed to post data: ${response.statusCode}');
    }
  }

  Future<dynamic> put(String endpoint,
      {Map<String, String>? headers, Map<String, dynamic>? body}) async {
    final response = await http.put(
      Uri.parse('$baseUrl$endpoint'),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'X-API-Key': apiKey,
        ...?headers,
      },
      body: json.encode(body),
    );

    if (response.statusCode == 200) {
      return _decodeJson(response.body);
    } else {
      throw Exception('Failed to update data: ${response.statusCode}');
    }
  }

  Future<void> delete(String endpoint, {Map<String, String>? headers}) async {
    final response = await http.delete(
      Uri.parse('$baseUrl$endpoint'),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'X-API-Key': apiKey,
        ...?headers,
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to delete data: ${response.statusCode}');
    }
  }

  // Order API Methods
  Future<Map<String, dynamic>> createOrder({
    required List<Map<String, dynamic>> items,
    required String shippingAddress,
    required String paymentMethod,
    String? notes,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/buyer/orders');
      Log.e('Creating order at: $uri');
      Log.e('Auth token available: ${_authToken != null}');
      Log.e('Auth token (first 10 chars): ${_authToken?.substring(0, 10)}...');

      final requestBody = {
        'items': items,
        'shipping_address': shippingAddress,
        'payment_method': paymentMethod,
        'notes': notes,
      };

      Log.e('Order request body: ${json.encode(requestBody)}');
      Log.e('Request headers: $headers');

      final response = await http.post(
        uri,
        headers: headers,
        body: json.encode(requestBody),
      );

      Log.e('Order creation response status: ${response.statusCode}');
      Log.e('Order creation response body: ${response.body}');

      _checkBotInterference(response, response.body);
      if (response.statusCode == 201) {
        final responseData = _decodeJson(response.body);
        Log.e('Order created successfully');
        return responseData;
      } else {
        Log.e('Order creation failed: ${response.body}');
        throw Exception('Failed to create order: ${response.statusCode}');
      }
    } catch (e, stackTrace) {
      Log.e('Error creating order: $e');
      Log.e('Stack trace: $stackTrace');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getOrders() async {
    try {
      final uri = Uri.parse('$baseUrl/buyer/orders');
      Log.e('Fetching user orders from: $uri');

      final response = await http.get(uri, headers: headers);
      Log.e('Orders response status: ${response.statusCode}');
      Log.e('Orders response body: ${response.body}');

      _checkBotInterference(response, response.body);
      if (response.statusCode == 200) {
        Log.e('Raw response body: ${response.body}');
        try {
          final responseData = _decodeJson(response.body);
          Log.e('Decoded response data: $responseData');
          Log.e('Data type: ${responseData.runtimeType}');
          if (responseData is Map && responseData['data'] != null) {
            Log.e('Orders data type: ${responseData['data'].runtimeType}');
            Log.e(
                'First order: ${responseData['data'].isNotEmpty ? responseData['data'][0] : 'No orders'}');
          }
          return responseData;
        } catch (e) {
          Log.e('Error decoding JSON response: $e');
          Log.e('Response body that failed to decode: ${response.body}');
          rethrow;
        }
      } else if (response.statusCode == 404) {
        Log.e('No orders found');
        return {'success': true, 'data': [], 'message': 'No orders found'};
      } else {
        Log.e('Error response: ${response.body}');
        throw Exception('Failed to load orders: ${response.statusCode}');
      }
    } catch (e, stackTrace) {
      Log.e('Error fetching orders: $e');
      Log.e('Error type: ${e.runtimeType}');
      Log.e('Stack trace: $stackTrace');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getUserOrders() async {
    try {
      final uri = Uri.parse('$baseUrl/buyer/orders');
      Log.e('Fetching user orders from: $uri');

      final response = await http.get(uri, headers: headers);
      Log.e('Orders response status: ${response.statusCode}');

      _checkBotInterference(response, response.body);
      if (response.statusCode == 200) {
        final responseData = _decodeJson(response.body);
        Log.e('Received orders response: ${response.body}');

        List<dynamic> ordersData;
        if (responseData is Map<String, dynamic>) {
          if (responseData.containsKey('data')) {
            ordersData = List<dynamic>.from(responseData['data']);
          } else {
            ordersData = [];
          }
        } else if (responseData is List) {
          ordersData = responseData;
        } else {
          ordersData = [];
        }

        Log.e('Received ${ordersData.length} orders');
        return ordersData.cast<Map<String, dynamic>>();
      } else if (response.statusCode == 404) {
        Log.e('No orders found');
        return [];
      } else {
        Log.e('Error response: ${response.body}');
        throw Exception('Failed to load orders: ${response.statusCode}');
      }
    } catch (e, stackTrace) {
      Log.e('Error fetching orders: $e');
      Log.e('Stack trace: $stackTrace');
      return [];
    }
  }

  Future<Map<String, dynamic>> getOrder(int orderId) async {
    try {
      final uri = Uri.parse('$baseUrl/buyer/orders/$orderId');
      Log.e('Fetching order from: $uri');

      final response = await http.get(uri, headers: headers);
      Log.e('Order response status: ${response.statusCode}');

      _checkBotInterference(response, response.body);
      if (response.statusCode == 200) {
        final responseData = _decodeJson(response.body);
        Log.e('Received order: ${response.body}');
        return responseData;
      } else {
        Log.e('Error response: ${response.body}');
        throw Exception('Failed to load order: ${response.statusCode}');
      }
    } catch (e, stackTrace) {
      Log.e('Error fetching order: $e');
      Log.e('Stack trace: $stackTrace');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> cancelOrder(int orderId) async {
    try {
      final uri = Uri.parse('$baseUrl/buyer/orders/$orderId/cancel');
      Log.e('Cancelling order at: $uri');

      final response = await http.put(uri, headers: headers);
      Log.e('Cancel order response status: ${response.statusCode}');

      _checkBotInterference(response, response.body);
      if (response.statusCode == 200) {
        final responseData = _decodeJson(response.body);
        Log.e('Order cancelled successfully');
        return responseData;
      } else {
        Log.e('Cancel order failed: ${response.body}');
        throw Exception('Failed to cancel order: ${response.statusCode}');
      }
    } catch (e, stackTrace) {
      Log.e('Error cancelling order: $e');
      Log.e('Stack trace: $stackTrace');
      rethrow;
    }
  }

  // Seller order management methods
  Future<Map<String, dynamic>> getSellerOrders() async {
    try {
      final uri = Uri.parse('$baseUrl/seller/orders');
      Log.e('Fetching seller orders from: $uri');

      final response = await http.get(uri, headers: headers);
      Log.e('Seller orders response status: ${response.statusCode}');
      Log.e('Seller orders response body: ${response.body}');

      _checkBotInterference(response, response.body);
      if (response.statusCode == 200) {
        final responseData = _decodeJson(response.body);
        Log.e('Received seller orders response: $responseData');
        return responseData;
      } else if (response.statusCode == 404) {
        Log.e('No seller orders found');
        return {'success': true, 'data': [], 'message': 'No orders found'};
      } else {
        Log.e('Error response: ${response.body}');
        throw Exception('Failed to load seller orders: ${response.statusCode}');
      }
    } catch (e, stackTrace) {
      Log.e('Error fetching seller orders: $e');
      Log.e('Error type: ${e.runtimeType}');
      Log.e('Stack trace: $stackTrace');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> updateOrderStatus(
      int orderId, String status) async {
    try {
      final uri = Uri.parse('$baseUrl/seller/orders/$orderId/status');
      Log.e('Updating order status: $uri');

      final response = await http.put(
        uri,
        headers: headers,
        body: json.encode({'status': status}),
      );

      Log.e('Update order status response: ${response.statusCode}');
      Log.e('Update order status body: ${response.body}');

      _checkBotInterference(response, response.body);
      if (response.statusCode == 200) {
        final responseData = _decodeJson(response.body);
        Log.e('Order status updated successfully');
        return responseData;
      } else {
        Log.e('Error updating order status: ${response.body}');
        throw Exception(
            'Failed to update order status: ${response.statusCode}');
      }
    } catch (e, stackTrace) {
      Log.e('Error updating order status: $e');
      Log.e('Stack trace: $stackTrace');
      rethrow;
    }
  }

  // Organic Products API methods
  Future<Map<String, dynamic>> getSellerOrganicProducts() async {
    try {
      Log.e('Fetching seller organic products...');
      final response = await http.get(
        Uri.parse('$baseUrl/seller/organic-products'),
        headers: headers,
      );

      Log.e('Seller organic products response status: ${response.statusCode}');
      Log.e('Seller organic products response body: ${response.body}');

      _checkBotInterference(response, response.body);
      if (response.statusCode == 200) {
        return _decodeJson(response.body);
      } else {
        throw Exception(
            'Failed to fetch seller organic products: ${response.statusCode}');
      }
    } catch (e) {
      Log.e('Error fetching seller organic products: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> createOrganicProduct(
      Map<String, dynamic> productData) async {
    try {
      Log.e('Creating organic product: ${productData['name']}');
      Log.e('Product data images: ${productData['images']}');

      // Use multipart request like regular products
      final url = '$baseUrl/seller/organic-products';
      final request = http.MultipartRequest('POST', Uri.parse(url));

      // Add enhanced headers to bypass bot detection
      request.headers.addAll({
        'Accept': 'application/json',
        'User-Agent': ApiConfig.userAgent,
        'Origin': baseUrl.replaceAll('/api', ''),
        'Referer': baseUrl.replaceAll('/api', ''),
        if (_authToken != null) 'Authorization': 'Bearer $_authToken',
      });

      // Add product fields
      request.fields.addAll({
        'name': productData['name'].toString(),
        'description': productData['description']?.toString() ?? '',
        'price': productData['price'].toString(),
        'stock': productData['stock'].toString(),
        'category_id': productData['category_id'].toString(),
        'is_active': productData['is_active'] == true ? '1' : '0',
        'is_featured': productData['is_featured'] == true ? '1' : '0',
        if (productData['certification'] != null)
          'certification': productData['certification'].toString(),
        if (productData['origin'] != null)
          'origin': productData['origin'].toString(),
        if (productData['harvest_date'] != null)
          'harvest_date': productData['harvest_date'].toString(),
        if (productData['storage_conditions'] != null)
          'storage_conditions': productData['storage_conditions'].toString(),
        if (productData['shelf_life'] != null)
          'shelf_life': productData['shelf_life'].toString(),
      });

      // Add image URL - only image_url field
      final images = productData['images'] as List<String>?;
      if (images != null && images.isNotEmpty) {
        request.fields['image_url'] = images.first;
      }

      Log.e('Sending multipart request to: $url');
      Log.e('Request fields: ${request.fields}');

      final response = await request.send();
      final responseBody = await http.Response.fromStream(response);

      Log.e('Create organic product response status: ${response.statusCode}');
      Log.e('Create organic product response body: ${responseBody.body}');

      _checkBotInterference(responseBody, responseBody.body);
      if (response.statusCode == 201) {
        return _decodeJson(responseBody.body);
      } else {
        throw Exception(
            'Failed to create organic product: ${response.statusCode}');
      }
    } catch (e) {
      Log.e('Error creating organic product: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> updateOrganicProduct(
      int productId, Map<String, dynamic> productData) async {
    try {
      Log.e('Updating organic product: $productId');

      // Use multipart request like regular products
      final url = '$baseUrl/seller/organic-products/$productId';
      final request = http.MultipartRequest('POST', Uri.parse(url));

      // Add _method to simulate PUT
      request.fields['_method'] = 'PUT';

      // Add enhanced headers to bypass bot detection
      request.headers.addAll({
        'Accept': 'application/json',
        'User-Agent': ApiConfig.userAgent,
        'Origin': baseUrl.replaceAll('/api', ''),
        'Referer': baseUrl.replaceAll('/api', ''),
        if (_authToken != null) 'Authorization': 'Bearer $_authToken',
      });

      // Add product fields
      request.fields.addAll({
        'name': productData['name'].toString(),
        'description': productData['description']?.toString() ?? '',
        'price': productData['price'].toString(),
        'stock': productData['stock'].toString(),
        'category_id': productData['category_id'].toString(),
        'is_active': productData['is_active'] == true ? '1' : '0',
        'is_featured': productData['is_featured'] == true ? '1' : '0',
        if (productData['certification'] != null)
          'certification': productData['certification'].toString(),
        if (productData['origin'] != null)
          'origin': productData['origin'].toString(),
        if (productData['harvest_date'] != null)
          'harvest_date': productData['harvest_date'].toString(),
        if (productData['storage_conditions'] != null)
          'storage_conditions': productData['storage_conditions'].toString(),
        if (productData['shelf_life'] != null)
          'shelf_life': productData['shelf_life'].toString(),
      });

      // Add image URL - only image_url field
      final images = productData['images'] as List<String>?;
      if (images != null && images.isNotEmpty) {
        request.fields['image_url'] = images.first;
      }

      Log.e('Sending multipart request to: $url');
      final response = await request.send();
      final responseBody = await http.Response.fromStream(response);

      Log.e('Update organic product response status: ${response.statusCode}');
      Log.e('Update organic product response body: ${responseBody.body}');

      _checkBotInterference(responseBody, responseBody.body);
      if (response.statusCode == 200) {
        return _decodeJson(responseBody.body);
      } else {
        throw Exception(
            'Failed to update organic product: ${response.statusCode}');
      }
    } catch (e) {
      Log.e('Error updating organic product: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> deleteOrganicProduct(int productId) async {
    try {
      Log.e('Deleting organic product: $productId');
      final response = await http.delete(
        Uri.parse('$baseUrl/seller/organic-products/$productId'),
        headers: headers,
      );

      Log.e('Delete organic product response status: ${response.statusCode}');
      Log.e('Delete organic product response body: ${response.body}');

      _checkBotInterference(response, response.body);
      if (response.statusCode == 200) {
        return _decodeJson(response.body);
      } else {
        throw Exception(
            'Failed to delete organic product: ${response.statusCode}');
      }
    } catch (e) {
      Log.e('Error deleting organic product: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> uploadOrganicProductImage(
      Uint8List imageBytes, String filename) async {
    try {
      Log.e('Uploading organic product image...');
      final bytes = imageBytes;
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/seller/organic-products/upload-image'),
      );
      request.headers['Authorization'] = 'Bearer $_authToken';
      request.headers['Accept'] = 'application/json';
      final ua = ApiConfig.userAgent;
      if (ua.isNotEmpty) request.headers['User-Agent'] = ua;
      request.files.add(
          http.MultipartFile.fromBytes('image', bytes, filename: filename));

      var response = await request.send();
      var responseBody = await response.stream.bytesToString();

      Log.e(
          'Upload organic product image response status: ${response.statusCode}');
      Log.e('Upload organic product image response body: $responseBody');

      _checkBotInterference(response, responseBody);
      if (response.statusCode == 200) {
        final decoded = _decodeJson(responseBody);
        Log.e('Parsed upload response: $decoded');
        return decoded;
      } else {
        throw Exception(
            'Failed to upload organic product image: ${response.statusCode} - $responseBody');
      }
    } catch (e) {
      Log.e('Error uploading organic product image: $e');
      rethrow;
    }
  }

  // Get organic product subcategories
  Future<List<Category>> getOrganicProductCategories() async {
    try {
      final uri = Uri.parse('$baseUrl/categories/4/subcategories');
      Log.e('Fetching organic product subcategories from: $uri');

      final response = await http.get(uri, headers: headers);

      Log.e(
          'Organic product categories response status: ${response.statusCode}');
      Log.e('Organic product categories response body: ${response.body}');

      if (response.statusCode == 200) {
        final dynamic responseData = _decodeJson(response.body);

        List<dynamic> categoriesData;
        if (responseData is Map<String, dynamic>) {
          if (responseData.containsKey('data')) {
            categoriesData = List<dynamic>.from(responseData['data']);
          } else {
            categoriesData = [];
          }
        } else if (responseData is List) {
          categoriesData = responseData;
        } else {
          categoriesData = [];
        }

        Log.e(
            'Received ${categoriesData.length} organic product subcategories');

        final categories = <Category>[];
        for (int i = 0; i < categoriesData.length; i++) {
          try {
            final category = Category.fromJson(categoriesData[i]);
            categories.add(category);
            Log.e('Parsed organic category ${i + 1}: ${category.name}');
          } catch (e) {
            Log.e('Error parsing organic category ${i + 1}: $e');
            Log.e('Category data: ${categoriesData[i]}');
          }
        }

        Log.e('Parsed ${categories.length} organic product subcategories');
        return categories;
      } else {
        throw Exception(
            'Failed to load organic product categories: ${response.statusCode}');
      }
    } catch (e) {
      Log.e('Error in getOrganicProductCategories: $e');
      throw Exception(
          'Failed to load organic product categories: ${e.toFriendlyError}');
    }
  }

  // Food and Beverages API methods
  Future<Map<String, dynamic>> getSellerFoodBeverages() async {
    try {
      Log.e('Fetching seller food and beverages...');
      final response = await http.get(
        Uri.parse('$baseUrl/seller/food-beverages'),
        headers: headers,
      );

      Log.e('Seller food beverages response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        return _decodeJson(response.body);
      } else {
        throw Exception(
            'Failed to fetch seller food and beverages: ${response.statusCode}');
      }
    } catch (e) {
      Log.e('Error fetching seller food and beverages: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getFeaturedFoodBeverages() async {
    try {
      Log.e('Fetching featured food and beverages...');
      final response = await http.get(
        Uri.parse('$baseUrl/food-beverages/featured'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return _decodeJson(response.body);
      } else {
        throw Exception(
            'Failed to fetch featured food and beverages: ${response.statusCode}');
      }
    } catch (e) {
      Log.e('Error fetching featured food and beverages: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> createFoodBeverage(
      Map<String, dynamic> productData) async {
    try {
      Log.e('Creating food beverage: ${productData['name']}');

      final url = '$baseUrl/seller/food-beverages';
      final request = http.MultipartRequest('POST', Uri.parse(url));

      request.headers.addAll({
        'Accept': 'application/json',
        'User-Agent': ApiConfig.userAgent,
        'Origin': baseUrl.replaceAll('/api', ''),
        'Referer': baseUrl.replaceAll('/api', ''),
        if (_authToken != null) 'Authorization': 'Bearer $_authToken',
      });

      request.fields.addAll({
        'name': productData['name'].toString(),
        'description': productData['description']?.toString() ?? '',
        'price': productData['price'].toString(),
        'stock': productData['stock'].toString(),
        'category_id': productData['category_id'].toString(),
        'is_active': productData['is_active'] == true ? '1' : '0',
        'is_featured': productData['is_featured'] == true ? '1' : '0',
        if (productData['ingredients'] != null)
          'ingredients': productData['ingredients'].toString(),
        if (productData['dietary_info'] != null)
          'dietary_info': productData['dietary_info'].toString(),
        if (productData['expiration_date'] != null)
          'expiration_date': productData['expiration_date'].toString(),
        if (productData['storage_conditions'] != null)
          'storage_conditions': productData['storage_conditions'].toString(),
        if (productData['preparation_time'] != null)
          'preparation_time': productData['preparation_time'].toString(),
        if (productData['unit'] != null) 'unit': productData['unit'].toString(),
      });

      final images = productData['images'] as List<String>?;
      if (images != null && images.isNotEmpty) {
        request.fields['image_url'] = images.first;
      }

      final response = await request.send();
      final responseBody = await http.Response.fromStream(response);

      if (response.statusCode == 201) {
        return _decodeJson(responseBody.body);
      } else {
        throw Exception(
            'Failed to create food beverage: ${response.statusCode}');
      }
    } catch (e) {
      Log.e('Error creating food beverage: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> updateFoodBeverage(
      int productId, Map<String, dynamic> productData) async {
    try {
      Log.e('Updating food beverage: $productId');

      final url = '$baseUrl/seller/food-beverages/$productId';
      final request = http.MultipartRequest('POST', Uri.parse(url));
      request.fields['_method'] = 'PUT';

      request.headers.addAll({
        'Accept': 'application/json',
        'User-Agent': ApiConfig.userAgent,
        'Origin': baseUrl.replaceAll('/api', ''),
        'Referer': baseUrl.replaceAll('/api', ''),
        if (_authToken != null) 'Authorization': 'Bearer $_authToken',
      });

      request.fields.addAll({
        'name': productData['name'].toString(),
        'description': productData['description']?.toString() ?? '',
        'price': productData['price'].toString(),
        'stock': productData['stock'].toString(),
        'category_id': productData['category_id'].toString(),
        'is_active': productData['is_active'] == true ? '1' : '0',
        'is_featured': productData['is_featured'] == true ? '1' : '0',
        if (productData['ingredients'] != null)
          'ingredients': productData['ingredients'].toString(),
        if (productData['dietary_info'] != null)
          'dietary_info': productData['dietary_info'].toString(),
        if (productData['expiration_date'] != null)
          'expiration_date': productData['expiration_date'].toString(),
        if (productData['storage_conditions'] != null)
          'storage_conditions': productData['storage_conditions'].toString(),
        if (productData['preparation_time'] != null)
          'preparation_time': productData['preparation_time'].toString(),
        if (productData['unit'] != null) 'unit': productData['unit'].toString(),
      });

      final images = productData['images'] as List<String>?;
      if (images != null && images.isNotEmpty) {
        request.fields['image_url'] = images.first;
      }

      final response = await request.send();
      final responseBody = await http.Response.fromStream(response);

      if (response.statusCode == 200) {
        return _decodeJson(responseBody.body);
      } else {
        throw Exception(
            'Failed to update food beverage: ${response.statusCode}');
      }
    } catch (e) {
      Log.e('Error updating food beverage: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> deleteFoodBeverage(int productId) async {
    try {
      Log.e('Deleting food beverage: $productId');
      final response = await http.delete(
        Uri.parse('$baseUrl/seller/food-beverages/$productId'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return _decodeJson(response.body);
      } else {
        throw Exception(
            'Failed to delete food beverage: ${response.statusCode}');
      }
    } catch (e) {
      Log.e('Error deleting food beverage: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> uploadFoodBeverageImage(
      Uint8List imageBytes, String filename) async {
    try {
      Log.e('Uploading food beverage image...');
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/seller/food-beverages/upload-image'),
      );
      request.headers['Authorization'] = 'Bearer $_authToken';
      request.headers['Accept'] = 'application/json';
      final ua = ApiConfig.userAgent;
      if (ua.isNotEmpty) request.headers['User-Agent'] = ua;
      request.files.add(http.MultipartFile.fromBytes('image', imageBytes,
          filename: filename));

      var response = await request.send();
      var responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        return _decodeJson(responseBody);
      } else {
        throw Exception(
            'Failed to upload food beverage image: ${response.statusCode}');
      }
    } catch (e) {
      Log.e('Error uploading food beverage image: $e');
      rethrow;
    }
  }

  Future<List<Category>> getFoodBeverageCategories() async {
    try {
      // Category ID 6 is "Food and Beverage" in database
      final uri = Uri.parse('$baseUrl/categories/6/subcategories');
      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        final dynamic responseData = _decodeJson(response.body);
        List<dynamic> categoriesData;
        if (responseData is Map<String, dynamic>) {
          categoriesData = List<dynamic>.from(responseData['data'] ?? []);
        } else {
          categoriesData = [];
        }

        return categoriesData.map((json) => Category.fromJson(json)).toList();
      } else {
        throw Exception(
            'Failed to fetch food beverage categories: ${response.statusCode}');
      }
    } catch (e) {
      Log.e('Error fetching food beverage categories: $e');
      rethrow;
    }
  }

  // Get agricultural service subcategories
  Future<List<Category>> getAgriculturalServiceCategories() async {
    try {
      final uri = Uri.parse('$baseUrl/services/agricultural-categories');
      Log.e('Fetching agricultural service subcategories from: $uri');

      final response = await http.get(uri, headers: headers);

      Log.e(
          'Agricultural service categories response status: ${response.statusCode}');
      Log.e('Agricultural service categories response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = _decodeJson(response.body);
        if (data is Map<String, dynamic> && data.containsKey('data')) {
          final List<dynamic> categoriesJson = data['data'];
          return categoriesJson.map((json) => Category.fromJson(json)).toList();
        } else if (data is List) {
          return data.map((json) => Category.fromJson(json)).toList();
        } else {
          throw Exception(
              'Unexpected response format for agricultural service categories');
        }
      } else {
        Log.e('Error response: ${response.body}');
        throw Exception(
            'Failed to load agricultural service categories: ${response.statusCode} - ${response.body}');
      }
    } catch (e, stackTrace) {
      Log.e('Error in getAgriculturalServiceCategories: $e\n$stackTrace');
      throw Exception(
          'Failed to load agricultural service categories: ${e.toFriendlyError}');
    }
  }

  // Transport API methods
  Future<Map<String, dynamic>> getTransportCategories() async {
    try {
      Log.e('Fetching transport categories...');
      final response = await http.get(
        Uri.parse('$baseUrl/public/categories'),
        headers: headers,
      );

      Log.e('Transport categories response status: ${response.statusCode}');
      Log.e('Transport categories response body: ${response.body}');

      if (response.statusCode == 200) {
        return _decodeJson(response.body);
      } else if (response.statusCode == 403) {
        // User doesn't have required role - return empty data instead of throwing exception
        Log.e(
            'User does not have required role for transports - returning empty list');
        return {'success': true, 'data': [], 'message': 'Access denied'};
      } else {
        throw Exception(
            'Failed to fetch transport categories: ${response.statusCode}');
      }
    } catch (e) {
      Log.e('Error fetching transport categories: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getSellerTransports() async {
    try {
      Log.e('Fetching seller transports...');
      Log.e('Using auth token: ${_authToken?.substring(0, 10) ?? "null"}...');
      Log.e('Headers: $headers');
      final response = await http.get(
        Uri.parse('$baseUrl/seller/transports'),
        headers: headers,
      );

      Log.e('Seller transports response status: ${response.statusCode}');
      Log.e('Seller transports response body: ${response.body}');

      if (response.statusCode == 200) {
        return _decodeJson(response.body);
      } else if (response.statusCode == 403) {
        // User doesn't have required role - return empty data instead of throwing
        Log.e(
            'User does not have required role for transports - returning empty list');
        return {'success': true, 'data': [], 'message': 'Access denied'};
      } else {
        throw Exception(
            'Failed to fetch seller transports: ${response.statusCode}');
      }
    } catch (e) {
      Log.e('Error fetching seller transports: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> createTransport(
      Map<String, dynamic> transportData) async {
    try {
      Log.e('Creating transport: $transportData');
      final response = await http.post(
        Uri.parse('$baseUrl/seller/transports'),
        headers: headers,
        body: json.encode(transportData),
      );

      Log.e('Create transport response status: ${response.statusCode}');
      Log.e('Create transport response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return _decodeJson(response.body);
      } else {
        throw Exception('Failed to create transport: ${response.statusCode}');
      }
    } catch (e) {
      Log.e('Error creating transport: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> updateTransport(
      int transportId, Map<String, dynamic> transportData) async {
    try {
      Log.e('Updating transport $transportId: $transportData');
      final response = await http.put(
        Uri.parse('$baseUrl/seller/transports/$transportId'),
        headers: headers,
        body: json.encode(transportData),
      );

      Log.e('Update transport response status: ${response.statusCode}');
      Log.e('Update transport response body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = _decodeJson(response.body);
        // Handle both direct data response and wrapped response
        if (responseData['data'] != null) {
          return responseData;
        } else {
          return responseData;
        }
      } else {
        throw Exception('Failed to update transport: ${response.statusCode}');
      }
    } catch (e) {
      Log.e('Error updating transport: $e');
      rethrow;
    }
  }

  Future<void> deleteTransport(int transportId) async {
    try {
      Log.e('Deleting transport $transportId...');
      final response = await http.delete(
        Uri.parse('$baseUrl/seller/transports/$transportId'),
        headers: headers,
      );

      Log.e('Delete transport response status: ${response.statusCode}');
      Log.e('Delete transport response body: ${response.body}');

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Failed to delete transport: ${response.statusCode}');
      }
    } catch (e) {
      Log.e('Error deleting transport: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> uploadTransportImage(
      Uint8List imageBytes, String filename) async {
    try {
      Log.e('Uploading transport image...');
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/transports/upload-image'),
      );
      request.headers['Authorization'] = 'Bearer $_authToken';
      request.headers['Accept'] = 'application/json';
      final ua = ApiConfig.userAgent;
      if (ua.isNotEmpty) request.headers['User-Agent'] = ua;
      request.files.add(
        http.MultipartFile.fromBytes('image', imageBytes, filename: filename),
      );
      var response = await request.send();
      var responseBody = await response.stream.bytesToString();
      Log.e('Upload transport image status: ${response.statusCode}');
      Log.e('Upload transport image body: $responseBody');
      if (response.statusCode == 200 || response.statusCode == 201) {
        final decoded = _decodeJson(responseBody);
        if (decoded == null || decoded is! Map<String, dynamic>) {
          throw Exception('Unexpected server response: $responseBody');
        }
        return decoded;
      } else if (response.statusCode == 403) {
        Map<String, dynamic>? decoded;
        try {
          decoded = _decodeJson(responseBody) as Map<String, dynamic>?;
        } catch (_) {}
        throw Exception(decoded?['message']?.toString() ??
            'Subscription required. Please check your subscription is active.');
      } else {
        throw Exception(
            'Failed to upload image: ${response.statusCode} — $responseBody');
      }
    } catch (e) {
      Log.e('Error uploading transport image: $e');
      rethrow;
    }
  }

  // Role Management Methods
  Future<Map<String, dynamic>> getUserRoles() async {
    try {
      Log.e('Fetching user roles...');
      final response = await http.get(
        Uri.parse('$baseUrl/user/roles'),
        headers: headers,
      );

      Log.e('Get user roles response status: ${response.statusCode}');
      Log.e('Get user roles response body: ${response.body}');

      if (response.statusCode == 200) {
        return _decodeJson(response.body);
      } else {
        throw Exception('Failed to fetch user roles: ${response.statusCode}');
      }
    } catch (e) {
      Log.e('Error fetching user roles: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> addUserRole(String role) async {
    try {
      Log.e('Adding user role: $role...');
      final response = await http.post(
        Uri.parse('$baseUrl/user/roles'),
        headers: headers,
        body: json.encode({'role': role}),
      );

      Log.e('Add user role response status: ${response.statusCode}');
      Log.e('Add user role response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return _decodeJson(response.body);
      } else {
        throw Exception('Failed to add user role: ${response.statusCode}');
      }
    } catch (e) {
      Log.e('Error adding user role: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> removeUserRole(String role) async {
    try {
      Log.e('Removing user role: $role...');
      final response = await http.delete(
        Uri.parse('$baseUrl/user/roles'),
        headers: headers,
        body: json.encode({'role': role}),
      );

      Log.e('Remove user role response status: ${response.statusCode}');
      Log.e('Remove user role response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 204) {
        return _decodeJson(response.body);
      } else {
        throw Exception('Failed to remove user role: ${response.statusCode}');
      }
    } catch (e) {
      Log.e('Error removing user role: $e');
      rethrow;
    }
  }

  // Get all conversations for current user
  Future<List<dynamic>> getConversations() async {
    try {
      final uri = Uri.parse('$baseUrl/chat/conversations');
      final response = await http.get(uri, headers: headers);
      if (response.statusCode == 200) {
        final data = _decodeJson(response.body);
        return data['data'] ?? [];
      } else {
        throw Exception('Failed to fetch conversations');
      }
    } catch (e) {
      Log.e('Error fetching conversations: $e');
      throw Exception('Error fetching conversations: ${e.toFriendlyError}');
    }
  }

  // Get single conversation details with messages
  Future<Map<String, dynamic>> getConversation(int id) async {
    try {
      final uri = Uri.parse('$baseUrl/chat/conversations/$id');
      final response = await http.get(uri, headers: headers);
      if (response.statusCode == 200) {
        final data = _decodeJson(response.body);
        return data['data'] ?? {};
      } else {
        throw Exception('Failed to load conversation: ${response.statusCode}');
      }
    } catch (e) {
      Log.e('Error fetching conversation: $e');
      throw Exception('Error fetching conversation: ${e.toFriendlyError}');
    }
  }

  // Start new conversation implicitly by sending first message
  Future<Map<String, dynamic>> startConversation(
      int receiverId, String message) async {
    try {
      final uri = Uri.parse('$baseUrl/chat/conversations');
      final response = await http.post(uri,
          headers: headers,
          body: jsonEncode({
            'receiver_id': receiverId,
            'message': message,
          }));
      if (response.statusCode == 201 || response.statusCode == 200) {
        return _decodeJson(response.body);
      } else {
        throw Exception('Failed to start conversation');
      }
    } catch (e) {
      Log.e('Error starting conversation: $e');
      throw Exception('Error starting conversation: ${e.toFriendlyError}');
    }
  }

  // Send message to existing conversation
  Future<Map<String, dynamic>> sendMessage(
      int conversationId, String content) async {
    try {
      final uri =
          Uri.parse('$baseUrl/chat/conversations/$conversationId/messages');
      final response = await http.post(uri,
          headers: headers,
          body: jsonEncode({
            'content': content,
          }));
      if (response.statusCode == 201 || response.statusCode == 200) {
        return _decodeJson(response.body);
      } else {
        throw Exception('Failed to send message');
      }
    } catch (e) {
      Log.e('Error sending message: $e');
      throw Exception('Error sending message: ${e.toFriendlyError}');
    }
  }
}
