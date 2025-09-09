import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/user.dart';
import '../models/product.dart'; // Ensure this file contains the Product class definition
import '../models/category.dart'; // Ensure this file contains the Category class definition
import '../models/service.dart'; // Ensure this file contains the Service class definition
import '../models/transport.dart'; // Ensure this file contains the Transport class definition
import '../utils/logger.dart';

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

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'ngrok-skip-browser-warning': 'true',
        if (_authToken != null) 'Authorization': 'Bearer $_authToken',
      };

  // Generic GET method
  Future<Map<String, dynamic>> getRequest(String endpoint) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/$endpoint'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to fetch data: ${response.statusCode}');
      }
    } catch (e) {
      Log.e('Error in GET request: $e');
      rethrow;
    }
  }

  // Generic DELETE method
  Future<Map<String, dynamic>> deleteRequest(String endpoint) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/$endpoint'),
        headers: _headers,
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        return response.statusCode == 200 ? jsonDecode(response.body) : {};
      } else {
        throw Exception('Failed to delete data: ${response.statusCode}');
      }
    } catch (e) {
      Log.e('Error in DELETE request: $e');
      rethrow;
    }
  }

  Future<bool> checkConnection() async {
    try {
      final uri = Uri.parse('$baseUrl/api/health');
      Log.e('Checking API connection at: $uri');

      final response = await http.get(uri, headers: _headers);
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
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(requestBody),
      );

      Log.e('Login response status: ${response.statusCode}');
      Log.e('Login response body: ${response.body}');

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to login: ${response.body}');
      }
    } catch (e) {
      Log.e('Login error: $e');
      throw Exception('Error during login: $e');
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
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      Log.d('Services API response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

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
      throw Exception('Error fetching services: $e');
    }
  }

  // Register
  Future<void> register(
      String name, String username, String email, String password,
      {String role = 'buyer'}) async {
    try {
      final url = Uri.parse('$baseUrl/auth/register');
      final requestBody = {
        'name': name,
        'username': username,
        'email': email,
        'password': password,
        'password_confirmation': password,
        'role': role,
      };

      Log.e('Registration request URL: $url');
      Log.e('Registration request body: ${jsonEncode(requestBody)}');

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(requestBody),
      );

      Log.e('Registration response status: ${response.statusCode}');
      Log.e('Registration response body: ${response.body}');

      if (response.statusCode != 201) {
        throw Exception('Failed to register: ${response.body}');
      }
    } catch (e) {
      Log.e('Registration error: $e');
      throw Exception('Error during registration: $e');
    }
  }

  // Logout
  Future<void> logout() async {
    try {
      final url = Uri.parse('$baseUrl/user/logout');
      final response = await http.post(
        url,
        headers: await _getAuthHeaders(),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to logout: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error during logout: $e');
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
        headers: _headers,
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['success'] != true) {
          throw Exception(
              responseData['message'] ?? 'Failed to send reset email');
        }
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to send reset email');
      }
    } catch (e) {
      Log.e('Reset password error: $e');
      throw Exception('Error sending reset password email: $e');
    }
  }

  // Get user profile
  Future<User> getUserProfile() async {
    try {
      final url = Uri.parse('$baseUrl/user');
      final response = await http.get(
        url,
        headers: await _getAuthHeaders(),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return User.fromJson(data);
      } else {
        throw Exception('Failed to fetch user profile: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error fetching user profile: $e');
    }
  }

  // Update user profile
  // Update user profile
  Future<User> updateProfile({
    required String name,
    required String email,
    String? phone,
    String? bio,
    String? avatarPath, // Added avatarPath parameter
  }) async {
    try {
      final url = Uri.parse('$baseUrl/profile/');
      final request = http.MultipartRequest('POST', url);

      // Add authentication headers
      request.headers.addAll(await _getAuthHeaders());

      // Add fields to the request
      request.fields['name'] = name;
      request.fields['email'] = email;
      if (phone != null) request.fields['phone'] = phone;
      if (bio != null) request.fields['bio'] = bio;

      // Add avatar file if provided
      if (avatarPath != null) {
        request.files.add(await http.MultipartFile.fromPath(
          'avatar',
          avatarPath,
        ));
      }

      // Send the request
      final response = await request.send();
      if (response.statusCode == 200) {
        final responseBody = await response.stream.bytesToString();
        final data = jsonDecode(responseBody);
        return User.fromJson(data['user']);
      } else {
        throw Exception(
            'Failed to update profile. Status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error updating profile: $e');
    }
  }

  // Removed duplicate _getAuthHeaders method to resolve the conflict.
  // Upload profile image
  Future<void> uploadProfileImage(String imagePath) async {
    try {
      final url = Uri.parse('$baseUrl/profile/avatar');
      final request = http.MultipartRequest('POST', url);

      request.headers.addAll(await _getAuthHeaders());
      request.files.add(await http.MultipartFile.fromPath('avatar', imagePath));

      final response = await request.send();
      if (response.statusCode != 200) {
        throw Exception('Failed to upload profile image');
      }
    } catch (e) {
      throw Exception('Error uploading profile image: $e');
    }
  }

  // Change password
  Future<void> changePassword(
      String currentPassword, String newPassword) async {
    throw Exception('Change password endpoint not implemented in API yet');
  }

  // Get authentication headers
  Future<Map<String, String>> _getAuthHeaders() async {
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (_authToken != null) 'Authorization': 'Bearer $_authToken',
    };
  }

  // Fetch related products
  Future<List<Product>> getRelatedProducts(int productId) async {
    try {
      Log.e('ApiService: Fetching related products for product ID: $productId');
      final uri = Uri.parse('$baseUrl/products/$productId/related');
      Log.e('ApiService: Request URL: $uri');

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      Log.e('ApiService: Response status code: ${response.statusCode}');
      Log.e('ApiService: Response body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
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
      throw Exception('Failed to fetch related products: $e');
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

      final response = await http.get(uri, headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'ngrok-skip-browser-warning': 'true',
      });

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body)['products'];
        return data.map((json) => Product.fromJson(json)).toList();
      } else {
        throw Exception(
            'Failed to fetch products. Status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching products: $e');
    }
  }

  // Get products by category (regular products)
  Future<List<Product>> getProductsByCategory(
      int categoryId, String subcategory) async {
    try {
      final uri = Uri.parse('$baseUrl/categories/$categoryId/products');
      Log.e('Fetching products for category: $categoryId');
      Log.e('Request URL: $uri');

      final response = await http.get(uri, headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'ngrok-skip-browser-warning': 'true',
        if (_authToken != null) 'Authorization': 'Bearer $_authToken',
      });

      Log.e('Response status: ${response.statusCode}');
      Log.e('Response body: ${response.body}');

      // Check if we got the ngrok warning page
      if (response.body.contains('ngrok') &&
          response.body.contains('warning')) {
        Log.e('Received ngrok warning page instead of API response');
        throw Exception('Received ngrok warning page - check ngrok headers');
      }

      if (response.statusCode == 200) {
        final dynamic responseData = json.decode(response.body);

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
      throw Exception('Failed to load products: $e');
    }
  }

  // Get organic products by category
  Future<List<Map<String, dynamic>>> getOrganicProductsByCategory(
      int categoryId, String subcategory) async {
    try {
      final uri = Uri.parse('$baseUrl/categories/$categoryId/organic-products');
      Log.e('Fetching organic products for category: $categoryId');
      Log.e('Request URL: $uri');

      final response = await http.get(uri, headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'ngrok-skip-browser-warning': 'true',
        if (_authToken != null) 'Authorization': 'Bearer $_authToken',
      });

      Log.e('Organic products response status: ${response.statusCode}');
      Log.e('Organic products response body: ${response.body}');

      // Check if we got the ngrok warning page
      if (response.body.contains('ngrok') &&
          response.body.contains('warning')) {
        Log.e('Received ngrok warning page instead of API response');
        throw Exception('Received ngrok warning page - check ngrok headers');
      }

      if (response.statusCode == 200) {
        final dynamic responseData = json.decode(response.body);

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
      throw Exception('Failed to load organic products: $e');
    }
  }

  Future<List<Category>> getCategories() async {
    try {
      final uri = Uri.parse('$baseUrl/main-categories');
      Log.e('ApiService: Fetching main categories from: $uri');

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'ngrok-skip-browser-warning': 'true',
          if (_authToken != null) 'Authorization': 'Bearer $_authToken',
        },
      );

      Log.e('ApiService: Response status: ${response.statusCode}');
      Log.e('ApiService: Response headers: ${response.headers}');
      Log.e(
          'ApiService: Response body (partial): ${response.body.substring(0, response.body.length > 500 ? 500 : response.body.length)}');

      final contentType = response.headers['content-type'] ?? '';

      if (!contentType.contains('application/json')) {
        throw Exception('Unexpected response type: $contentType');
      }

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data is Map<String, dynamic> && data.containsKey('data')) {
          final List<dynamic> categoriesJson = data['data'];
          final categories =
              categoriesJson.map((json) => Category.fromJson(json)).toList();
          Log.e(
              'ApiService: Successfully parsed ${categories.length} main categories');
          return categories;
        } else {
          Log.e('ApiService: Unexpected JSON structure: $data');
          return [];
        }
      } else {
        Log.e('ApiService: Failed with status ${response.statusCode}');
        throw Exception(
            'Failed to fetch main categories: ${response.statusCode}');
      }
    } catch (e, stackTrace) {
      Log.e('ApiService: Error fetching main categories: $e');
      Log.e('ApiService: Stack trace: $stackTrace');
      throw Exception('Error fetching main categories: $e');
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
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'ngrok-skip-browser-warning': 'true',
          if (_authToken != null) 'Authorization': 'Bearer $_authToken',
        },
      );

      Log.e(
          'ApiService: Subcategories response status: ${response.statusCode}');
      Log.e('ApiService: Subcategories response headers: ${response.headers}');
      Log.e(
          'ApiService: Subcategories response body (partial): ${response.body.substring(0, response.body.length > 500 ? 500 : response.body.length)}');

      final contentType = response.headers['content-type'] ?? '';

      if (!contentType.contains('application/json')) {
        throw Exception('Unexpected response type: $contentType');
      }

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

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
        } else {
          Log.e(
              'ApiService: Unexpected JSON structure for subcategories: $data');
          return [];
        }
      } else {
        Log.e(
            'ApiService: Failed to fetch subcategories with status ${response.statusCode}');
        throw Exception(
            'Failed to fetch subcategories: ${response.statusCode}');
      }
    } catch (e, stackTrace) {
      Log.e('ApiService: Error fetching subcategories: $e');
      Log.e('ApiService: Stack trace: $stackTrace');
      throw Exception('Error fetching subcategories: $e');
    }
  }

  Future<List<Product>> getFeaturedProducts() async {
    try {
      final uri = Uri.parse('$baseUrl/products/featured');
      Log.e('ApiService: Fetching featured products from: $uri');

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          if (_authToken != null) 'Authorization': 'Bearer $_authToken',
        },
      );

      Log.e('ApiService: Response status: ${response.statusCode}');
      Log.e('ApiService: Response headers: ${response.headers}');
      Log.e(
          'ApiService: Response body (partial): ${response.body.substring(0, response.body.length > 500 ? 500 : response.body.length)}');

      final contentType = response.headers['content-type'] ?? '';

      if (!contentType.contains('application/json')) {
        throw Exception('Unexpected response type: $contentType');
      }

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data is Map<String, dynamic> && data.containsKey('data')) {
          final List<dynamic> productsJson = data['data'];
          final products =
              productsJson.map((json) => Product.fromJson(json)).toList();
          Log.e(
              'ApiService: Successfully parsed ${products.length} featured products');
          return products;
        } else {
          Log.e('ApiService: Unexpected JSON structure: $data');
          return [];
        }
      } else {
        Log.e('ApiService: Failed with status ${response.statusCode}');
        throw Exception(
            'Failed to fetch featured products: ${response.statusCode}');
      }
    } catch (e, stackTrace) {
      Log.e('ApiService: Error fetching featured products: $e');
      Log.e('ApiService: Stack trace: $stackTrace');
      throw Exception('Error fetching featured products: $e');
    }
  }

  // Get product details by ID
  Future<Product> getProductDetails(int productId) async {
    try {
      final url = Uri.parse('$baseUrl/products/$productId');
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Product.fromJson(data);
      } else {
        throw Exception(
            'Failed to fetch product details. Status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching product details: $e');
    }
  }

  // Add a new product
  Future<void> addProduct(Product product) async {
    try {
      final url = Uri.parse('$baseUrl/products');
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(product.toJson()),
      );

      if (response.statusCode != 201) {
        throw Exception(
            'Failed to add product. Status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error adding product: $e');
    }
  }

  // Transport methods
  Future<List<Transport>> getTransports() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/transports'),
        headers: await _getAuthHeaders(),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Transport.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load transports');
      }
    } catch (e) {
      throw Exception('Error loading transports: $e');
    }
  }

  Future<Transport?> getTransportDetails(int transportId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/transports/$transportId'),
        headers: await _getAuthHeaders(),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Transport.fromJson(data);
      } else {
        throw Exception('Failed to load transport details');
      }
    } catch (e) {
      throw Exception('Error loading transport details: $e');
    }
  }

  Future<void> addTransport(Transport transport) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/transports'),
        headers: await _getAuthHeaders(),
        body: json.encode(transport.toJson()),
      );

      if (response.statusCode != 201) {
        throw Exception('Failed to add transport');
      }
    } catch (e) {
      throw Exception('Error adding transport: $e');
    }
  }

  Future<dynamic> get(String endpoint, {Map<String, String>? headers}) async {
    final response = await http.get(
      Uri.parse('$baseUrl$endpoint'),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'X-API-Key': apiKey,
        ...?headers,
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load data: ${response.statusCode}');
    }
  }

  Future<dynamic> post(String endpoint,
      {Map<String, String>? headers, Map<String, dynamic>? body}) async {
    final response = await http.post(
      Uri.parse('$baseUrl$endpoint'),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'X-API-Key': apiKey,
        ...?headers,
      },
      body: json.encode(body),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return json.decode(response.body);
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
      return json.decode(response.body);
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
      Log.e('Request headers: $_headers');

      final response = await http.post(
        uri,
        headers: _headers,
        body: json.encode(requestBody),
      );

      Log.e('Order creation response status: ${response.statusCode}');
      Log.e('Order creation response body: ${response.body}');

      if (response.statusCode == 201) {
        final responseData = json.decode(response.body);
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

      final response = await http.get(uri, headers: _headers);
      Log.e('Orders response status: ${response.statusCode}');
      Log.e('Orders response body: ${response.body}');

      if (response.statusCode == 200) {
        Log.e('Raw response body: ${response.body}');
        try {
          final responseData = json.decode(response.body);
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

      final response = await http.get(uri, headers: _headers);
      Log.e('Orders response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
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

      final response = await http.get(uri, headers: _headers);
      Log.e('Order response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
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

      final response = await http.put(uri, headers: _headers);
      Log.e('Cancel order response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
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

      final response = await http.get(uri, headers: _headers);
      Log.e('Seller orders response status: ${response.statusCode}');
      Log.e('Seller orders response body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
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
        headers: _headers,
        body: json.encode({'status': status}),
      );

      Log.e('Update order status response: ${response.statusCode}');
      Log.e('Update order status body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
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
        headers: _headers,
      );

      Log.e('Seller organic products response status: ${response.statusCode}');
      Log.e('Seller organic products response body: ${response.body}');

      if (response.statusCode == 200) {
        return json.decode(response.body);
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
      final response = await http.post(
        Uri.parse('$baseUrl/seller/organic-products'),
        headers: _headers,
        body: json.encode(productData),
      );

      Log.e('Create organic product response status: ${response.statusCode}');
      Log.e('Create organic product response body: ${response.body}');

      if (response.statusCode == 201) {
        return json.decode(response.body);
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
      final response = await http.put(
        Uri.parse('$baseUrl/seller/organic-products/$productId'),
        headers: _headers,
        body: json.encode(productData),
      );

      Log.e('Update organic product response status: ${response.statusCode}');
      Log.e('Update organic product response body: ${response.body}');

      if (response.statusCode == 200) {
        return json.decode(response.body);
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
        headers: _headers,
      );

      Log.e('Delete organic product response status: ${response.statusCode}');
      Log.e('Delete organic product response body: ${response.body}');

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception(
            'Failed to delete organic product: ${response.statusCode}');
      }
    } catch (e) {
      Log.e('Error deleting organic product: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> uploadOrganicProductImage(File imageFile) async {
    try {
      Log.e('Uploading organic product image...');
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/seller/organic-products/upload-image'),
      );

      request.headers.addAll(_headers);
      request.files
          .add(await http.MultipartFile.fromPath('image', imageFile.path));

      var response = await request.send();
      var responseBody = await response.stream.bytesToString();

      Log.e(
          'Upload organic product image response status: ${response.statusCode}');
      Log.e('Upload organic product image response body: $responseBody');

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

  // Get organic product subcategories
  Future<List<Category>> getOrganicProductCategories() async {
    try {
      final uri = Uri.parse('$baseUrl/categories/4/subcategories');
      Log.e('Fetching organic product subcategories from: $uri');

      final response = await http.get(uri, headers: _headers);

      Log.e(
          'Organic product categories response status: ${response.statusCode}');
      Log.e('Organic product categories response body: ${response.body}');

      if (response.statusCode == 200) {
        final dynamic responseData = json.decode(response.body);

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
            Log.e(
                'Successfully parsed organic category ${i + 1}: ${category.name}');
          } catch (e) {
            Log.e('Error parsing organic category ${i + 1}: $e');
            Log.e('Category data: ${categoriesData[i]}');
          }
        }

        Log.e('Parsed ${categories.length} organic product subcategories');
        return categories;
      } else {
        Log.e('Error response: ${response.body}');
        throw Exception(
            'Failed to load organic product categories: ${response.statusCode} - ${response.body}');
      }
    } catch (e, stackTrace) {
      Log.e('Error in getOrganicProductCategories: $e\n$stackTrace');
      throw Exception('Failed to load organic product categories: $e');
    }
  }

  // Get agricultural service subcategories
  Future<List<Category>> getAgriculturalServiceCategories() async {
    try {
      final uri = Uri.parse('$baseUrl/categories/5/subcategories');
      Log.e('Fetching agricultural service subcategories from: $uri');

      final response = await http.get(uri, headers: _headers);

      Log.e(
          'Agricultural service categories response status: ${response.statusCode}');
      Log.e('Agricultural service categories response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
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
      throw Exception('Failed to load agricultural service categories: $e');
    }
  }

  // Transport API methods
  Future<Map<String, dynamic>> getTransportCategories() async {
    try {
      Log.e('Fetching transport categories...');
      final response = await http.get(
        Uri.parse('$baseUrl/public/categories'),
        headers: _headers,
      );

      Log.e('Transport categories response status: ${response.statusCode}');
      Log.e('Transport categories response body: ${response.body}');

      if (response.statusCode == 200) {
        return json.decode(response.body);
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
      final response = await http.get(
        Uri.parse('$baseUrl/seller/transports'),
        headers: _headers,
      );

      Log.e('Seller transports response status: ${response.statusCode}');
      Log.e('Seller transports response body: ${response.body}');

      if (response.statusCode == 200) {
        return json.decode(response.body);
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
        headers: _headers,
        body: json.encode(transportData),
      );

      Log.e('Create transport response status: ${response.statusCode}');
      Log.e('Create transport response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return json.decode(response.body);
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
        headers: _headers,
        body: json.encode(transportData),
      );

      Log.e('Update transport response status: ${response.statusCode}');
      Log.e('Update transport response body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
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
        headers: _headers,
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

  Future<Map<String, dynamic>> uploadTransportImage(File imageFile) async {
    try {
      Log.e('Uploading transport image...');
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/seller/transports/upload-image'),
      );

      request.headers.addAll(_headers);
      request.files
          .add(await http.MultipartFile.fromPath('image', imageFile.path));

      var response = await request.send();
      var responseBody = await response.stream.bytesToString();

      Log.e('Upload transport image response status: ${response.statusCode}');
      Log.e('Upload transport image response body: $responseBody');

      if (response.statusCode == 200) {
        return json.decode(responseBody);
      } else {
        throw Exception(
            'Failed to upload transport image: ${response.statusCode}');
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
        headers: _headers,
      );

      Log.e('Get user roles response status: ${response.statusCode}');
      Log.e('Get user roles response body: ${response.body}');

      if (response.statusCode == 200) {
        return json.decode(response.body);
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
        headers: _headers,
        body: json.encode({'role': role}),
      );

      Log.e('Add user role response status: ${response.statusCode}');
      Log.e('Add user role response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return json.decode(response.body);
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
        headers: _headers,
        body: json.encode({'role': role}),
      );

      Log.e('Remove user role response status: ${response.statusCode}');
      Log.e('Remove user role response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 204) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to remove user role: ${response.statusCode}');
      }
    } catch (e) {
      Log.e('Error removing user role: $e');
      rethrow;
    }
  }
}
