import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product.dart';
import '../config/api_config.dart';

class ProductService {
  String? _authToken;

  // Set the authentication token
  void setAuthToken(String token) {
    _authToken = token;
  }

  // Ensure the auth token is set before making API calls
  void _checkAuthToken() {
    if (_authToken == null) {
      throw Exception('Authentication token is not set');
    }
  }

  // Get seller products
  Future<List<Product>> getSellerProducts() async {
    _checkAuthToken(); // Ensure auth token is set
    try {
      final url = '${ApiConfig.baseUrl}/seller/products';
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $_authToken',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body)['data'];
        return data.map((product) => Product.fromJson(product)).toList();
      } else {
        throw Exception(
            'Failed to fetch seller products. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching seller products: $e');
      throw Exception('Error fetching seller products: $e');
    }
  }

  // Add a new product
  Future<Map<String, dynamic>> addProduct(Product product) async {
    _checkAuthToken(); // Ensure auth token is set
    try {
      final url = '${ApiConfig.baseUrl}/seller/products';
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $_authToken',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(product.toJson()),
      );

      if (response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        throw Exception(
            'Failed to add product. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error adding product: $e');
      throw Exception('Error adding product: $e');
    }
  }

  // Update a product
  Future<void> updateProduct(Product product) async {
    _checkAuthToken(); // Ensure auth token is set
    try {
      final url = '${ApiConfig.baseUrl}/seller/products/${product.id}';
      final response = await http.put(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $_authToken',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(product.toJson()),
      );

      if (response.statusCode != 200) {
        throw Exception(
            'Failed to update product. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error updating product: $e');
      throw Exception('Error updating product: $e');
    }
  }

  // Delete a product
  Future<void> deleteProduct(int productId) async {
    _checkAuthToken(); // Ensure auth token is set
    try {
      final url = '${ApiConfig.baseUrl}/seller/products/$productId';
      final response = await http.delete(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $_authToken',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode != 200) {
        throw Exception(
            'Failed to delete product. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error deleting product: $e');
      throw Exception('Error deleting product: $e');
    }
  }

  // Upload product image
  Future<String> uploadProductImage(String imagePath) async {
    _checkAuthToken(); // Ensure auth token is set
    try {
      final url = '${ApiConfig.baseUrl}/seller/products/upload-image';
      final request = http.MultipartRequest('POST', Uri.parse(url));

      // Add headers
      request.headers.addAll({
        'Authorization': 'Bearer $_authToken',
        'Accept': 'application/json',
      });

      // Add the image file
      request.files.add(await http.MultipartFile.fromPath('image', imagePath));

      // Send the request
      final response = await request.send();
      final responseBody = await http.Response.fromStream(response);

      if (response.statusCode == 200) {
        final data = jsonDecode(responseBody.body);
        return data['url'];
      } else {
        throw Exception(
            'Failed to upload image. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error uploading product image: $e');
      throw Exception('Error uploading product image: $e');
    }
  }
}
