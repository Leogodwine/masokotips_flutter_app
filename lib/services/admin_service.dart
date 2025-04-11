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
import 'dart:io';
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
      request.fields.addAll({
        '_method': 'PUT',
        'name': productData['name'],
        'description': productData['description'],
        'price': productData['price'].toString(),
        'stock': productData['stock'].toString(),
        'unit': productData['unit'],
        'category_id': productData['category_id'].toString(),
        'is_active': productData['is_active'].toString(),
        'is_featured': productData['is_featured'].toString(),
      });

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
        if (data['success'] == true && data['data'] != null) {
          return Product.fromJson(data['data']);
        } else {
          throw Exception('Failed to update product: ${data['message']}');
        }
      } else {
        throw Exception('Failed to update product: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error updating product: $e');
    }
  }

  Future<Product> createProduct(Map<String, dynamic> productData) async {
    try {
      final formData = FormData();

      // Add all product data fields
      productData.forEach((key, value) {
        if (key != 'images' && value != null) {
          formData.fields.add(MapEntry(key, value.toString()));
        }
      });

      // Handle images differently for web and mobile
      if (productData['images'] != null) {
        final List<XFile> images = productData['images'];
        for (var i = 0; i < images.length; i++) {
          final image = images[i];
          if (kIsWeb) {
            // For web, read the file bytes
            final bytes = await image.readAsBytes();
            formData.files.add(MapEntry(
              'images[]',
              MultipartFile.fromBytes(
                bytes,
                filename: image.name,
              ),
            ));
          } else {
            // For mobile, use the file path
            formData.files.add(MapEntry(
              'images[]',
              await MultipartFile.fromFile(
                image.path,
                filename: image.name,
              ),
            ));
          }
        }
      }

      final response = await _dio.post(
        '/admin/products',
        data: formData,
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return Product.fromJson(response.data['data']);
      } else {
        throw Exception('Failed to create product: ${response.data}');
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
      final response = await _dio.get('/api/admin/transports');
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

  Future<void> deleteTransport(int transportId) async {
    try {
      final response = await _dio.delete('/api/admin/transports/$transportId');
      if (response.statusCode != 200) {
        throw Exception('Failed to delete transport');
      }
    } catch (e) {
      Log.e('Error deleting transport: $e');
      rethrow;
    }
  }

  Future<List<OrganicProduct>> getOrganicProducts() async {
    try {
      final response = await _dio.get('/api/admin/organic-products');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'];
        return data.map((json) => OrganicProduct.fromJson(json)).toList();
      }
      throw Exception('Failed to load organic products');
    } catch (e) {
      throw Exception('Error loading organic products: $e');
    }
  }

  Future<void> deleteOrganicProduct(int productId) async {
    try {
      final response =
          await _dio.delete('/api/admin/organic-products/$productId');
      if (response.statusCode != 200) {
        throw Exception('Failed to delete organic product');
      }
    } catch (e) {
      throw Exception('Error deleting organic product: $e');
    }
  }

  Future<List<Category>> getCategories() async {
    try {
      final response = await _dio.get('/categories');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'];
        return data.map((json) => Category.fromJson(json)).toList();
      }
      throw Exception('Failed to load categories');
    } catch (e) {
      throw Exception('Failed to load categories: $e');
    }
  }
}
