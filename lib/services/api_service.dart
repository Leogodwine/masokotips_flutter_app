import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../models/product.dart'; // Ensure this file contains the Product class definition
import '../models/category.dart'; // Ensure this file contains the Category class definition
import '../models/service.dart'; // Ensure this file contains the Service class definition
import '../models/transport.dart'; // Ensure this file contains the Transport class definition

class ApiService {
  static String baseUrl = 'http://127.0.0.1:8000/api';

  // Update the base URL
  static void updateBaseUrl(String newBaseUrl) {
    baseUrl = newBaseUrl;
  }

  // Check API connection
  static Future<bool> checkApiConnection() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/health-check'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['status'] == 'ok';
      }
      return false;
    } catch (e) {
      throw Exception('Failed to connect to API: $e');
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

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> servicesJson = data['services'];
        final List<Service> services =
            servicesJson.map((json) => Service.fromJson(json)).toList();

        return {
          'services': services,
          'currentPage': data['current_page'],
          'lastPage': data['last_page'],
        };
      } else {
        throw Exception(
            'Failed to fetch services. Status code: ${response.statusCode}');
      }
    } catch (e) {
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
          'role': role,
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
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // Fetch related products
  Future<List<Product>> getRelatedProducts(int productId) async {
    try {
      final url = Uri.parse('$baseUrl/products/$productId/related');
      print('Making API call to: $url');
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      print('API Response Status: ${response.statusCode}');
      print('API Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // Handle both array and object response formats
        final List<dynamic> productsData =
            data is List ? data : data['data'] ?? [];
        final products = productsData.map((json) {
          final productMap = json as Map<String, dynamic>;
          productMap['id'] = int.tryParse(productMap['id'].toString()) ??
              0; // Ensure id is an int
          return Product.fromJson(productMap);
        }).toList();
        print('Parsed ${products.length} related products');
        return products;
      } else {
        throw Exception(
            'Failed to fetch related products. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in getRelatedProducts: $e');
      throw Exception('Error fetching related products: $e');
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

  Future<List<Product>> getProductsByCategory(
      int categoryId, String subcategory) async {
    try {
      final url = Uri.parse(
          '$baseUrl/products?category_id=$categoryId&subcategory=$subcategory');
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // Handle both array and object response formats
        final List<dynamic> productsData =
            data is List ? data : data['products'] ?? [];
        return productsData.map((json) => Product.fromJson(json)).toList();
      } else {
        throw Exception(
            'Failed to fetch products by category. Status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching products by category: $e');
    }
  }

  // Get categories
  Future<List<Category>> getCategories({int? parentId}) async {
    try {
      final queryParams = <String, String>{
        if (parentId != null) 'parent_id': parentId.toString(),
      };

      final uri = Uri.parse('$baseUrl/categories')
          .replace(queryParameters: queryParams);

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // Handle both array and object response formats
        final List<dynamic> categoriesData =
            data is List ? data : data['categories'] ?? [];
        return categoriesData.map((json) => Category.fromJson(json)).toList();
      } else {
        throw Exception(
            'Failed to fetch categories. Status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching categories: $e');
    }
  }

  // Get featured products
  Future<List<Product>> getFeaturedProducts() async {
    try {
      final url = Uri.parse('$baseUrl/products/featured');
      print('Making API call to: $url');
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      print('API Response Status: ${response.statusCode}');
      print('API Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // Handle response with 'data' key
        final List<dynamic> productsData = data['data'] ?? [];
        final products =
            productsData.map((json) => Product.fromJson(json)).toList();
        print('Parsed ${products.length} featured products');
        return products;
      } else {
        throw Exception(
            'Failed to fetch featured products. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in getFeaturedProducts: $e');
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
