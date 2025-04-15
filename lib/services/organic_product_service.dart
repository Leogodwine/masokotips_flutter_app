import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/organic_product.dart';

class OrganicProductService {
  String? _authToken;

  void setAuthToken(String token) {
    _authToken = token;
  }

  void _checkAuthToken() {
    if (_authToken == null) {
      throw Exception('Auth token not set');
    }
  }

  // Get all organic products
  Future<List<OrganicProduct>> getOrganicProducts() async {
    _checkAuthToken();
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/public/organic-products'),
        headers: {
          'Authorization': 'Bearer $_authToken',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // Handle paginated response
        if (data['data'] is Map) {
          final paginatedData = data['data'];
          final productsList = paginatedData['data'] as List;
          return productsList
              .map((json) => OrganicProduct.fromJson(json))
              .toList();
        } else {
          // Handle non-paginated response
          return (data['data'] as List)
              .map((json) => OrganicProduct.fromJson(json))
              .toList();
        }
      } else {
        throw Exception('Failed to load organic products');
      }
    } catch (e) {
      throw Exception('Error loading organic products: $e');
    }
  }

  // Get organic product by ID
  Future<OrganicProduct> getOrganicProduct(int id) async {
    _checkAuthToken();
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/organic-products/$id'),
        headers: {
          'Authorization': 'Bearer $_authToken',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return OrganicProduct.fromJson(data['data']);
      } else {
        throw Exception('Failed to load organic product');
      }
    } catch (e) {
      throw Exception('Error loading organic product: $e');
    }
  }

  // Create new organic product
  Future<OrganicProduct> createOrganicProduct(OrganicProduct product) async {
    _checkAuthToken();
    try {
      // Create a multipart request for creating the product
      final url = '${ApiConfig.baseUrl}/organic-products';
      final request = http.MultipartRequest('POST', Uri.parse(url));

      // Add headers
      request.headers.addAll({
        'Authorization': 'Bearer $_authToken',
        'Accept': 'application/json',
      });

      // Add product fields
      request.fields.addAll({
        'name': product.name,
        'description': product.description ?? '',
        'price': product.price.toString(),
        'stock': product.stock.toString(),
        'is_active': product.isActive ? '1' : '0',
        'is_featured': product.isFeatured ? '1' : '0',
        'category_id': product.categoryId.toString(),
        'certification': product.certification ?? '',
        'origin': product.origin ?? '',
        'harvest_date': product.harvestDate?.toIso8601String() ?? '',
        'storage_conditions': product.storageConditions ?? '',
        'shelf_life': product.shelfLife ?? '',
      });

      // Handle image uploads
      final images = product.images ?? [];
      for (var i = 0; i < images.length; i++) {
        final imagePath = images[i];
        if (imagePath.startsWith('blob:')) {
          // For blob URLs, we need to convert them to actual files
          // This will be handled by the image picker's internal mechanism
          continue;
        } else if (!imagePath.startsWith('http')) {
          // For local file paths, add them as files
          final file = File(imagePath);
          if (await file.exists()) {
            request.files.add(
              await http.MultipartFile.fromPath(
                'images[$i]',
                file.path,
              ),
            );
          }
        }
      }

      print('Sending create request to: $url');
      print('Create fields: ${request.fields}');

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return OrganicProduct.fromJson(data['data']);
      } else {
        final errorBody = jsonDecode(response.body);
        throw Exception(
            'Failed to create organic product. Status code: ${response.statusCode}. Error: ${errorBody['message'] ?? 'Unknown error'}');
      }
    } catch (e) {
      throw Exception('Error creating organic product: $e');
    }
  }

  // Update organic product
  Future<OrganicProduct> updateOrganicProduct(OrganicProduct product) async {
    _checkAuthToken();
    try {
      // Create a multipart request for updating the product
      final url = '${ApiConfig.baseUrl}/organic-products/${product.id}';
      final request = http.MultipartRequest('POST', Uri.parse(url));

      // Add the _method field to simulate PUT request
      request.fields['_method'] = 'PUT';

      // Add headers
      request.headers.addAll({
        'Authorization': 'Bearer $_authToken',
        'Accept': 'application/json',
      });

      // Add product fields
      request.fields.addAll({
        'name': product.name,
        'description': product.description ?? '',
        'price': product.price.toString(),
        'stock': product.stock.toString(),
        'is_active': product.isActive ? '1' : '0',
        'is_featured': product.isFeatured ? '1' : '0',
        'category_id': product.categoryId.toString(),
        'certification': product.certification ?? '',
        'origin': product.origin ?? '',
        'harvest_date': product.harvestDate?.toIso8601String() ?? '',
        'storage_conditions': product.storageConditions ?? '',
        'shelf_life': product.shelfLife ?? '',
      });

      // Handle image uploads
      final images = product.images ?? [];
      for (var i = 0; i < images.length; i++) {
        final imagePath = images[i];
        if (imagePath.startsWith('blob:')) {
          // For blob URLs, we need to convert them to actual files
          // This will be handled by the image picker's internal mechanism
          continue;
        } else if (!imagePath.startsWith('http')) {
          // For local file paths, add them as files
          final file = File(imagePath);
          if (await file.exists()) {
            request.files.add(
              await http.MultipartFile.fromPath(
                'images[$i]',
                file.path,
              ),
            );
          }
        }
      }

      print('Sending update request to: $url');
      print('Update fields: ${request.fields}');

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return OrganicProduct.fromJson(data['data']);
      } else {
        final errorBody = jsonDecode(response.body);
        throw Exception(
            'Failed to update organic product. Status code: ${response.statusCode}. Error: ${errorBody['message'] ?? 'Unknown error'}');
      }
    } catch (e) {
      throw Exception('Error updating organic product: $e');
    }
  }

  // Delete organic product
  Future<void> deleteOrganicProduct(int id) async {
    _checkAuthToken();
    try {
      final response = await http.delete(
        Uri.parse('${ApiConfig.baseUrl}/organic-products/$id'),
        headers: {
          'Authorization': 'Bearer $_authToken',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode != 200) {
        final errorBody = jsonDecode(response.body);
        throw Exception(
            'Failed to delete organic product. Status code: ${response.statusCode}. Error: ${errorBody['message'] ?? 'Unknown error'}');
      }
    } catch (e) {
      throw Exception('Error deleting organic product: $e');
    }
  }

  // Upload organic product image
  Future<String> uploadOrganicProductImage(String imagePath) async {
    _checkAuthToken();
    try {
      final url = '${ApiConfig.baseUrl}/organic-products/upload-image';
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
        if (!await file.exists()) {
          throw Exception('Image file does not exist: $imagePath');
        }
        request.files.add(
          await http.MultipartFile.fromPath(
            'image',
            file.path,
          ),
        );
      }

      // Send the request
      print('Uploading image to: $url');
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print('Upload response status: ${response.statusCode}');
      print('Upload response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['url'];
      } else {
        final errorBody = jsonDecode(response.body);
        throw Exception(
            'Failed to upload image. Status code: ${response.statusCode}. Error: ${errorBody['message'] ?? 'Unknown error'}');
      }
    } catch (e) {
      print('Error uploading organic product image: $e');
      throw Exception('Error uploading organic product image: $e');
    }
  }
}
