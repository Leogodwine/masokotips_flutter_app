import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user.dart';
import '../models/service.dart';
import '../models/market_info.dart';
import '../utils/logger.dart';
import '../config/api_config.dart';

class AdminService {
  String? _authToken;
  String baseUrl = ApiConfig.baseUrl;

  void setAuthToken(String token) {
    _authToken = token;
    Log.d('Auth token set in AdminService: ${token.substring(0, 10)}...');
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
}
