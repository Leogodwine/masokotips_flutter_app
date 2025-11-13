import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/category.dart';
import 'api_service.dart';
import '../utils/logger.dart';

class CategoryService {
  late final ApiService _apiService;
  String? _authToken;

  CategoryService() {
    _apiService = ApiService(
      baseUrl: 'https://masokotips.com', // This should be configurable
      apiKey: 'your-api-key', // This should be configurable
    );
  }

  void setAuthToken(String token) {
    _authToken = token;
    _apiService.setAuthToken(token);
  }

  Future<List<Category>> getCategories() async {
    try {
      final url = Uri.parse('${_apiService.baseUrl}/api/categories');
      Log.d('Fetching categories from: $url');

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          if (_authToken != null) 'Authorization': 'Bearer $_authToken',
        },
      );

      Log.d('Categories API response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body)['data'];
        return data.map((json) => Category.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load categories: ${response.statusCode}');
      }
    } catch (e) {
      Log.e('Error loading categories: $e');
      throw Exception('Error loading categories: $e');
    }
  }

  Future<Category> getCategory(int id) async {
    try {
      final url = Uri.parse('${_apiService.baseUrl}/api/categories/$id');
      Log.d('Fetching category from: $url');

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          if (_authToken != null) 'Authorization': 'Bearer $_authToken',
        },
      );

      Log.d('Category API response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body)['data'];
        return Category.fromJson(data);
      } else {
        throw Exception('Failed to load category: ${response.statusCode}');
      }
    } catch (e) {
      Log.e('Error loading category: $e');
      throw Exception('Error loading category: $e');
    }
  }
}
