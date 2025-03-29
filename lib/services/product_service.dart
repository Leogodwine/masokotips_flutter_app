import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product.dart';
import '../config/api_config.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';

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
      const url = '${ApiConfig.baseUrl}/seller/products';
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
  Future<Product> addProduct(Product product) async {
    _checkAuthToken(); // Ensure auth token is set
    try {
      // First, upload all images and get their URLs
      List<String> imageUrls = [];
      for (var i = 0; i < product.images.length; i++) {
        final imageUrl = await uploadProductImage(product.images[i]);
        imageUrls.add(imageUrl);
      }

      // Now create the product with the uploaded image URLs
      final url = '${ApiConfig.baseUrl}/seller/products';
      final request = http.MultipartRequest('POST', Uri.parse(url));

      // Add headers
      request.headers.addAll({
        'Authorization': 'Bearer $_authToken',
        'Accept': 'application/json',
      });

      // Add product fields
      request.fields.addAll({
        'name': product.name,
        'description': product.description,
        'price': product.price.toString(),
        'stock': product.stock.toString(),
        'is_active': product.isActive ? '1' : '0',
        'is_featured': product.isFeatured ? '1' : '0',
        'category_id': product.categoryId.toString(),
        'slug': product.slug ?? '',
      });

      // Add each image URL as a separate field
      for (var i = 0; i < imageUrls.length; i++) {
        request.fields['images[$i]'] = imageUrls[i];
      }

      // Send the request
      final response = await request.send();
      final responseBody = await http.Response.fromStream(response);

      if (response.statusCode == 201) {
        final data = jsonDecode(responseBody.body);
        return Product.fromJson(data);
      } else {
        final errorBody = jsonDecode(responseBody.body);
        throw Exception(
            'Failed to add product. Status code: ${response.statusCode}. Error: ${errorBody['message'] ?? 'Unknown error'}');
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
      if (kIsWeb) {
        // For web, we need to convert the image path to bytes
        final response = await http.get(Uri.parse(imagePath));
        final bytes = response.bodyBytes;
        request.files.add(
          http.MultipartFile.fromBytes(
            'image',
            bytes,
            filename: 'image.jpg',
          ),
        );
      } else {
        // For mobile/desktop, we can use the file directly
        final file = File(imagePath);
        request.files.add(
          await http.MultipartFile.fromPath(
            'image',
            file.path,
          ),
        );
      }

      // Send the request
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['url'];
      } else {
        throw Exception(
            'Failed to upload image. Status code: ${response.statusCode}. Error: ${response.body}');
      }
    } catch (e) {
      print('Error uploading product image: $e');
      throw Exception('Error uploading product image: $e');
    }
  }
}
