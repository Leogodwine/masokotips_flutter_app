import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user.dart';
import '../models/service.dart';
import '../models/market_info.dart';
import '../models/product.dart';
import '../models/organic_product.dart';
import '../models/transport.dart';
import '../utils/logger.dart';
import '../config/api_config.dart';
import 'package:dio/dio.dart';
import '../models/category.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class AdminService {
  String? _authToken;
  String baseUrl = ApiConfig.baseUrl;
  late Dio _dio;

  AdminService() {
    _dio = Dio(BaseOptions(baseUrl: baseUrl));
    _dio.options.connectTimeout = const Duration(seconds: 5);
    _dio.options.receiveTimeout = const Duration(seconds: 3);
  }

  void setAuthToken(String token) {
    _authToken = token;
    _dio.options.headers['Authorization'] = 'Bearer $token';
    Log.d('Auth token set in AdminService: ${token.substring(0, 10)}...');
  }

  bool isAuthenticated() {
    return _authToken != null;
  }

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
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/admin/dashboard'),
        headers: {
          'Authorization': 'Bearer $_authToken',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data;
      } else {
        throw Exception('Failed to get dashboard data: ${response.body}');
      }
    } catch (e) {
      Log.e('Error getting dashboard data: $e');
      throw Exception('Failed to get dashboard data: $e');
    }
  }

  // User Management
  Future<List<User>> getUsers() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/admin/users'),
        headers: {
          'Authorization': 'Bearer $_authToken',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data is Map<String, dynamic> && data.containsKey('data')) {
          final List<dynamic> usersJson = data['data'];
          return usersJson.map((json) => User.fromJson(json)).toList();
        } else {
          Log.e('Unexpected API response structure: $data');
          return [];
        }
      } else {
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
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/admin/users/$userId'),
        headers: {
          'Authorization': 'Bearer $_authToken',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: json.encode(userData),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data is Map<String, dynamic> && data.containsKey('data')) {
          return User.fromJson(data['data']);
        } else {
          throw Exception('Unexpected API response structure: $data');
        }
      } else {
        throw Exception('Failed to update user: ${response.body}');
      }
    } catch (e) {
      Log.e('Error updating user: $e');
      throw Exception('Failed to update user: $e');
    }
  }

  Future<void> deleteUser(int userId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/admin/users/$userId'),
        headers: {
          'Authorization': 'Bearer $_authToken',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to delete user: ${response.body}');
      }
    } catch (e) {
      Log.e('Error deleting user: $e');
      throw Exception('Failed to delete user: $e');
    }
  }

  // Service Management
  Future<List<Service>> getServices() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/admin/services'),
        headers: {
          'Authorization': 'Bearer $_authToken',
          'Accept': 'application/json',
        },
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
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/admin/services/$serviceId'),
        headers: {
          'Authorization': 'Bearer $_authToken',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to delete service: ${response.body}');
      }
    } catch (e) {
      Log.e('Error deleting service: $e');
      throw Exception('Failed to delete service: $e');
    }
  }

  // Market Information Management
  Future<List<MarketInfo>> getMarketInfo() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/admin/market-info'),
        headers: {
          'Authorization': 'Bearer $_authToken',
          'Accept': 'application/json',
        },
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
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/admin/market-info/$marketInfoId'),
        headers: {
          'Authorization': 'Bearer $_authToken',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to delete market info: ${response.body}');
      }
    } catch (e) {
      Log.e('Error deleting market info: $e');
      throw Exception('Failed to delete market info: $e');
    }
  }

  // Product Management
  Future<List<Product>> getProducts() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/products'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          if (_authToken != null) 'Authorization': 'Bearer $_authToken',
        },
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
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/admin/products/$productId'),
      );

      // Add headers
      request.headers['Authorization'] = 'Bearer $_authToken';

      // Add non-file fields
      Log.d('Product update data before sending:');
      Log.d('- is_active: ${productData['is_active']}');
      Log.d('- is_featured: ${productData['is_featured']}');

      request.fields.addAll({
        '_method': 'PUT',
        'name': productData['name'],
        'description': productData['description'],
        'price': productData['price'].toString(),
        'stock': productData['stock'].toString(),
        'unit': productData['unit'],
        'category_id': productData['category_id'].toString(),
        'is_active': productData['is_active'] is bool
            ? (productData['is_active'] ? '1' : '0')
            : productData['is_active'].toString(),
        'is_featured': productData['is_featured'] is bool
            ? (productData['is_featured'] ? '1' : '0')
            : productData['is_featured'].toString(),
      });

      // Log the request data
      Log.d('Update Product Request Data:');
      Log.d('- is_active: ${request.fields['is_active']}');
      Log.d('- is_featured: ${request.fields['is_featured']}');

      // Handle images
      if (productData['images'] != null) {
        final List<XFile> images = productData['images'] as List<XFile>;
        for (var i = 0; i < images.length; i++) {
          if (kIsWeb) {
            final bytes = await images[i].readAsBytes();
            request.files.add(
              http.MultipartFile.fromBytes(
                'images[]',
                bytes,
                filename: 'image_$i.jpg',
              ),
            );
          } else {
            request.files.add(
              await http.MultipartFile.fromPath(
                'images[]',
                images[i].path,
                filename: 'image_$i.jpg',
              ),
            );
          }
        }
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        Log.d('Product updated successfully');
        Log.d('Response data: $data');
        if (data['success'] == true && data['data'] != null) {
          // Ensure is_featured is included in the response data
          final responseData = data['data'] as Map<String, dynamic>;
          Log.d('Raw is_featured value: ${responseData['is_featured']}');
          Log.d(
              'Raw is_featured type: ${responseData['is_featured'].runtimeType}');

          if (!responseData.containsKey('is_featured')) {
            responseData['is_featured'] = productData['is_featured'];
          }
          // Convert is_featured to boolean if it's a string
          if (responseData['is_featured'] is String) {
            responseData['is_featured'] = responseData['is_featured'] == '1';
          } else if (responseData['is_featured'] is int) {
            responseData['is_featured'] = responseData['is_featured'] == 1;
          }
          Log.d('Processed is_featured value: ${responseData['is_featured']}');
          Log.d(
              'Processed is_featured type: ${responseData['is_featured'].runtimeType}');

          return Product.fromJson(responseData);
        } else {
          throw Exception('Failed to update product: ${data['message']}');
        }
      } else {
        Log.e('Failed to update product: ${response.body}');
        throw Exception('Failed to update product: ${response.body}');
      }
    } catch (e) {
      Log.e('Error updating product: $e');
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
          Category(id: 1, name: 'Products', children: [
            Category(id: 11, name: 'Vegetables'),
            Category(id: 12, name: 'Livestock and poultry'),
            Category(id: 13, name: 'Spices'),
            Category(id: 14, name: 'Cash Crops'),
            Category(id: 15, name: 'Cereals'),
            Category(id: 16, name: 'Seeds and Seedling'),
            Category(id: 17, name: 'Fruits'),
          ]),
        ];

        // Check both API categories and default categories
        final allCategories = [...categories, ...defaultCategories];
        final categoryExists = allCategories.any((category) {
          if (category.children != null) {
            return category.children!.any((child) => child.id == categoryId);
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

      // Generate slug from name
      final slug = name
          .toLowerCase()
          .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
          .replaceAll(RegExp(r'^-|-$'), '');

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

      // Handle image uploads
      if (kIsWeb) {
        // Web platform
        for (var image in images) {
          final bytes = await image.readAsBytes();
          formData.files.add(MapEntry(
            'images[]',
            MultipartFile.fromBytes(
              bytes,
              filename: image.name,
            ),
          ));
        }
      } else {
        // Mobile platform
        for (var image in images) {
          formData.files.add(MapEntry(
            'images[]',
            await MultipartFile.fromFile(
              image.path,
              filename: image.name,
            ),
          ));
        }
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
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/admin/products/$productId'),
        headers: {
          'Authorization': 'Bearer $_authToken',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Failed to delete product: ${response.body}');
      }
    } catch (e) {
      Log.e('Error deleting product: $e');
      throw Exception('Failed to delete product: $e');
    }
  }

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
        '$baseUrl/api/admin/transports',
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
        '$baseUrl/api/admin/transports/${transport.id}',
        data: transport.toJson(),
      );
      return response.statusCode == 200;
    } catch (e) {
      throw Exception('Failed to update transport: $e');
    }
  }

  Future<bool> deleteTransport(int id) async {
    try {
      final response = await _dio.delete(
        '$baseUrl/api/admin/transports/$id',
      );
      return response.statusCode == 200;
    } catch (e) {
      throw Exception('Failed to delete transport: $e');
    }
  }

  Future<List<OrganicProduct>> getOrganicProducts() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/admin/organic-products'),
        headers: {
          'Authorization': 'Bearer $_authToken',
          'Accept': 'application/json',
        },
      );

      Log.d('Organic Products API Response: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        Log.d('Decoded API Response: $data');

        if (data['data'] is Map) {
          final paginatedData = data['data'];
          final productsList = paginatedData['data'] as List;
          Log.d('Products List: $productsList');
          return productsList
              .map((json) => OrganicProduct.fromJson(json))
              .toList();
        } else {
          final productsList = data['data'] as List;
          Log.d('Products List: $productsList');
          return productsList
              .map((json) => OrganicProduct.fromJson(json))
              .toList();
        }
      } else {
        throw Exception('Failed to load organic products: ${response.body}');
      }
    } catch (e) {
      Log.e('Error loading organic products: $e');
      throw Exception('Error loading organic products: $e');
    }
  }

  Future<void> deleteOrganicProduct(int productId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/admin/organic-products/$productId'),
        headers: {
          'Authorization': 'Bearer $_authToken',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to delete organic product: ${response.body}');
      }
    } catch (e) {
      Log.e('Error deleting organic product: $e');
      throw Exception('Error deleting organic product: $e');
    }
  }

  Future<List<Category>> getCategories() async {
    try {
      Log.d('AdminService: Starting to fetch categories');
      final response = await _dio.get('/admin/categories');
      Log.d(
          'AdminService: Categories response received: ${response.data.toString()}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = response.data;
        if (responseData['success'] == true) {
          final List<dynamic> data = responseData['data'];
          Log.d('AdminService: Parsing ${data.length} categories');

          final categories =
              data.map((item) => Category.fromJson(item)).toList();
          Log.d(
              'AdminService: Successfully parsed ${categories.length} categories');
          return categories;
        } else {
          Log.e(
              'AdminService: Failed to fetch categories: ${responseData['message']}');
          throw Exception(
              responseData['message'] ?? 'Failed to fetch categories');
        }
      } else {
        Log.e(
            'AdminService: Failed to fetch categories: HTTP ${response.statusCode}');
        throw Exception(
            'Failed to fetch categories: HTTP ${response.statusCode}');
      }
    } catch (e, stackTrace) {
      Log.e('AdminService: Error fetching categories: $e\n$stackTrace');
      // Return default categories if API fails
      Log.d('AdminService: Returning default categories');
      return [
        Category(
          id: 1,
          name: 'Products',
          children: [
            Category(id: 11, name: 'Vegetables'),
            Category(id: 12, name: 'Livestock and poultry'),
            Category(id: 13, name: 'Spices'),
            Category(id: 14, name: 'Cash Crops'),
            Category(id: 15, name: 'Cereals'),
            Category(id: 16, name: 'Seeds and Seedling'),
            Category(id: 17, name: 'Fruits'),
          ],
        ),
        Category(
          id: 2,
          name: 'Services',
          children: [
            Category(id: 21, name: 'Transport'),
            Category(id: 22, name: 'Storage'),
            Category(id: 23, name: 'Processing'),
          ],
        ),
        Category(
          id: 3,
          name: 'Transport',
          children: [
            Category(id: 31, name: 'Tandem'),
            Category(id: 32, name: 'Truck'),
            Category(id: 33, name: 'Motorcycle'),
          ],
        ),
      ];
    }
  }

  Future<OrganicProduct> createOrganicProduct(OrganicProduct product) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/admin/organic-products'),
        headers: {
          'Authorization': 'Bearer $_authToken',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: json.encode(product.toJson()),
      );

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        return OrganicProduct.fromJson(data['data']);
      } else {
        throw Exception('Failed to create organic product: ${response.body}');
      }
    } catch (e) {
      Log.e('Error creating organic product: $e');
      throw Exception('Error creating organic product: $e');
    }
  }

  Future<OrganicProduct> updateOrganicProduct(OrganicProduct product) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/admin/organic-products/${product.id}'),
        headers: {
          'Authorization': 'Bearer $_authToken',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: json.encode(product.toJson()),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return OrganicProduct.fromJson(data['data']);
      } else {
        throw Exception('Failed to update organic product: ${response.body}');
      }
    } catch (e) {
      Log.e('Error updating organic product: $e');
      throw Exception('Error updating organic product: $e');
    }
  }
}
