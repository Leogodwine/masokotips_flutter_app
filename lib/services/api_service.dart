import 'dart:convert';
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
  });

  void setAuthToken(String token) {
    _authToken = token;
  }

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $_authToken',
      };

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
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final url = Uri.parse('$baseUrl/auth/login');
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to login: ${response.body}');
      }
    } catch (e) {
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
  Future<void> register(String name, String email, String password,
      {String role = 'buyer'}) async {
    try {
      final url = Uri.parse('$baseUrl/auth/register');
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'name': name,
          'email': email,
          'password': password,
          'password_confirmation': password,
          'role': role,
          'is_admin': role == 'admin',
        }),
      );

      if (response.statusCode != 201) {
        throw Exception('Failed to register: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error during registration: $e');
    }
  }

  // Logout
  Future<void> logout() async {
    try {
      final url = Uri.parse('$baseUrl/auth/logout');
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
      final url = Uri.parse('$baseUrl/auth/profile');
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
      final url = Uri.parse('$baseUrl/auth/profile/upload-avatar');
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
    try {
      final url = Uri.parse('$baseUrl/auth/change-password');
      final response = await http.post(
        url,
        headers: await _getAuthHeaders(),
        body: jsonEncode({
          'current_password': currentPassword,
          'new_password': newPassword,
        }),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to change password: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error changing password: $e');
    }
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
        final List<dynamic> data = json.decode(response.body);
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
      Log.e('ApiService: Exception while fetching related products: $e');
      Log.e('ApiService: Stack trace: $stackTrace');
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

  // Get products by category
  Future<List<Product>> getProductsByCategory(
      int categoryId, String subcategory) async {
    try {
      final uri = Uri.parse('$baseUrl/products').replace(
        queryParameters: {
          'category_id': categoryId.toString(),
          if (subcategory.isNotEmpty) 'subcategory': subcategory,
        },
      );
      Log.e('Fetching products for category: $categoryId');
      Log.e('Request URL: $uri');

      final response = await http.get(uri, headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      });
      Log.e('Response status: ${response.statusCode}');
      Log.e('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        final List<dynamic> data = responseData['data'] ?? [];
        Log.e('Received ${data.length} products');

        final products = data.map((json) => Product.fromJson(json)).toList();
        Log.e('Parsed ${products.length} products');

        return products;
      } else {
        Log.e('Error response: ${response.body}');
        throw Exception('Failed to load products: ${response.statusCode}');
      }
    } catch (e) {
      Log.e('Error in getProductsByCategory: $e');
      rethrow;
    }
  }

  // Get categories
  Future<List<Category>> getCategories() async {
    try {
      final uri = Uri.parse('$baseUrl/categories');
      Log.e('ApiService: Fetching categories from: $uri');

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          if (_authToken != null) 'Authorization': 'Bearer $_authToken',
        },
      );

      Log.e(
          'ApiService: Categories API response status: ${response.statusCode}');
      Log.e('ApiService: Categories API response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        List<dynamic> categoriesJson;

        // Handle both array and object response formats
        if (data is List) {
          categoriesJson = data;
        } else if (data is Map<String, dynamic>) {
          if (data.containsKey('categories')) {
            categoriesJson = data['categories'];
          } else if (data.containsKey('data')) {
            categoriesJson = data['data'];
          } else {
            Log.e('ApiService: Unexpected categories response format: $data');
            return [];
          }
        } else {
          Log.e('ApiService: Unexpected categories response format: $data');
          return [];
        }

        final categories =
            categoriesJson.map((json) => Category.fromJson(json)).toList();
        Log.e(
            'ApiService: Successfully parsed ${categories.length} categories');
        return categories;
      } else if (response.statusCode == 401) {
        Log.e('ApiService: Authentication required for categories');
        throw Exception('Authentication required');
      } else {
        Log.e(
            'ApiService: Failed to fetch categories. Status code: ${response.statusCode}, Body: ${response.body}');
        throw Exception('Failed to fetch categories: ${response.body}');
      }
    } catch (e) {
      Log.e('ApiService: Error fetching categories: $e');
      throw Exception('Error fetching categories: $e');
    }
  }

  // Get featured products
  Future<List<Product>> getFeaturedProducts() async {
    try {
      final uri = Uri.parse('$baseUrl/products/featured');
      Log.e('Fetching featured products from: $uri');

      final response = await http.get(uri, headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      });
      Log.e('Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        final List<dynamic> data = responseData['data'] ?? [];
        Log.e('Received ${data.length} featured products');

        final products = data.map((json) => Product.fromJson(json)).toList();
        Log.e('Parsed ${products.length} featured products');

        return products;
      } else {
        throw Exception(
            'Failed to load featured products: ${response.statusCode}');
      }
    } catch (e) {
      Log.e('Error in getFeaturedProducts: $e');
      rethrow;
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

  Future<void> updateTransport(Transport transport) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/transports/${transport.id}'),
        headers: await _getAuthHeaders(),
        body: json.encode(transport.toJson()),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to update transport');
      }
    } catch (e) {
      throw Exception('Error updating transport: $e');
    }
  }

  Future<void> deleteTransport(int transportId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/transports/$transportId'),
        headers: await _getAuthHeaders(),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to delete transport');
      }
    } catch (e) {
      throw Exception('Error deleting transport: $e');
    }
  }
}
