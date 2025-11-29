import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/organic_product.dart';
import '../utils/logger.dart';
import 'network_service.dart';

class OrganicProductService {
  String? _authToken;
  String baseUrl = ApiConfig.baseUrl;
  final NetworkService _networkService = NetworkService.instance;

  void setAuthToken(String token) {
    _authToken = token;
    _networkService.setAuthToken(token);
    Log.d(
        'Auth token set in OrganicProductService: ${token.substring(0, 10)}...');
  }

  void _checkAuthToken() {
    if (_authToken == null) {
      throw Exception('Auth token not set');
    }
  }

  // User-Agent header to identify as legitimate mobile app
  static const String _userAgent =
      'Mozilla/5.0 (Linux; Android 10; SM-G975F) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.120 Mobile Safari/537.36';

  // Enhanced headers to bypass bot detection and match admin service
  Map<String, String> get _enhancedHeaders => {
        'Content-Type': 'application/json',
        'Accept': 'application/json, text/plain, */*',
        'Accept-Language': 'en-US,en;q=0.9',
        'User-Agent': _userAgent,
        'Origin': baseUrl.replaceAll('/api', ''),
        'Referer': baseUrl.replaceAll('/api', ''),
        if (_authToken != null) 'Authorization': 'Bearer $_authToken',
      };

  // Get all organic products
  Future<List<OrganicProduct>> getOrganicProducts() async {
    _checkAuthToken();
    try {
      Log.d('Loading organic products from: $baseUrl/admin/organic-products');
      Log.d('Using enhanced headers: $_enhancedHeaders');

      final response = await http.get(
        Uri.parse('$baseUrl/admin/organic-products'),
        headers: _enhancedHeaders,
      );

      Log.d('Organic products response status: ${response.statusCode}');
      Log.d('Organic products response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Handle admin response format (not paginated)
        if (data['success'] == true && data['data'] is List) {
          final productsList = data['data'] as List;
          Log.d(
              'Loaded ${productsList.length} organic products (admin endpoint)');
          return productsList
              .map((json) => OrganicProduct.fromJson(json))
              .toList();
        } else if (data['data'] is List) {
          // Fallback for other response formats
          final productsList = data['data'] as List;
          Log.d('Loaded ${productsList.length} organic products (fallback)');
          return productsList
              .map((json) => OrganicProduct.fromJson(json))
              .toList();
        } else {
          Log.e('Unexpected response format: $data');
          return [];
        }
      } else {
        Log.e('Failed to load organic products: HTTP ${response.statusCode}');
        Log.e('Response body: ${response.body}');
        throw Exception('Failed to load organic products: ${response.body}');
      }
    } catch (e) {
      Log.e('Error loading organic products: $e');
      throw Exception('Error loading organic products: $e');
    }
  }

  // Get organic product by ID
  Future<OrganicProduct> getOrganicProduct(int id) async {
    _checkAuthToken();
    try {
      Log.d('Loading organic product $id from: $baseUrl/organic-products/$id');

      final response = await http.get(
        Uri.parse('$baseUrl/organic-products/$id'),
        headers: _enhancedHeaders,
      );

      Log.d('Product response status: ${response.statusCode}');
      Log.d('Product response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return OrganicProduct.fromJson(data['data']);
      } else {
        Log.e('Failed to load organic product: HTTP ${response.statusCode}');
        Log.e('Response body: ${response.body}');
        throw Exception('Failed to load organic product: ${response.body}');
      }
    } catch (e) {
      Log.e('Error loading organic product: $e');
      throw Exception('Error loading organic product: $e');
    }
  }

  // Create new organic product
  Future<OrganicProduct> createOrganicProduct(OrganicProduct product) async {
    _checkAuthToken();
    try {
      // Create a multipart request for creating the product (admin endpoint)
      final url = '$baseUrl/admin/organic-products';
      final request = http.MultipartRequest('POST', Uri.parse(url));

      // Add enhanced headers to bypass bot detection
      request.headers.addAll(_enhancedHeaders);

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

      Log.d('Sending create request to: $url');
      Log.d('Create fields: ${request.fields}');
      Log.d('Number of image files: ${request.files.length}');

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      Log.d('Response status: ${response.statusCode}');
      Log.d('Response body: ${response.body}');

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        Log.d('Organic product created successfully');
        return OrganicProduct.fromJson(data['data']);
      } else {
        Log.e('Failed to create organic product: HTTP ${response.statusCode}');
        Log.e('Response body: ${response.body}');

        try {
          final errorBody = jsonDecode(response.body);
          final errorMessage =
              errorBody['message'] ?? errorBody['error'] ?? 'Unknown error';
          throw Exception(
              'Failed to create organic product. Status code: ${response.statusCode}. Error: $errorMessage');
        } catch (parseError) {
          throw Exception(
              'Failed to create organic product. Status code: ${response.statusCode}. Response: ${response.body}');
        }
      }
    } catch (e) {
      Log.e('Error creating organic product: $e');
      throw Exception('Error creating organic product: $e');
    }
  }

  // Update organic product
  Future<OrganicProduct> updateOrganicProduct(OrganicProduct product) async {
    _checkAuthToken();
    try {
      // Create a multipart request for updating the product (admin endpoint)
      final url = '$baseUrl/admin/organic-products/${product.id}';
      final request = http.MultipartRequest('POST', Uri.parse(url));

      // Add the _method field to simulate PUT request
      request.fields['_method'] = 'PUT';

      // Add enhanced headers to bypass bot detection
      request.headers.addAll(_enhancedHeaders);

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

      Log.d('Sending update request to: $url');
      Log.d('Update fields: ${request.fields}');
      Log.d('Number of image files: ${request.files.length}');

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      Log.d('Response status: ${response.statusCode}');
      Log.d('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        Log.d('Organic product updated successfully');
        return OrganicProduct.fromJson(data['data']);
      } else {
        Log.e('Failed to update organic product: HTTP ${response.statusCode}');
        Log.e('Response body: ${response.body}');

        try {
          final errorBody = jsonDecode(response.body);
          final errorMessage =
              errorBody['message'] ?? errorBody['error'] ?? 'Unknown error';
          throw Exception(
              'Failed to update organic product. Status code: ${response.statusCode}. Error: $errorMessage');
        } catch (parseError) {
          throw Exception(
              'Failed to update organic product. Status code: ${response.statusCode}. Response: ${response.body}');
        }
      }
    } catch (e) {
      Log.e('Error updating organic product: $e');
      throw Exception('Error updating organic product: $e');
    }
  }

  // Delete organic product
  Future<void> deleteOrganicProduct(int id) async {
    _checkAuthToken();
    try {
      Log.d(
          'Deleting organic product $id from: $baseUrl/admin/organic-products/$id');

      final response = await http.delete(
        Uri.parse('$baseUrl/admin/organic-products/$id'),
        headers: _enhancedHeaders,
      );

      Log.d('Delete response status: ${response.statusCode}');
      Log.d('Delete response body: ${response.body}');

      if (response.statusCode == 200) {
        Log.d('Organic product $id deleted successfully');
      } else {
        Log.e('Failed to delete organic product: HTTP ${response.statusCode}');
        Log.e('Response body: ${response.body}');

        try {
          final errorBody = jsonDecode(response.body);
          final errorMessage =
              errorBody['message'] ?? errorBody['error'] ?? 'Unknown error';
          throw Exception(
              'Failed to delete organic product. Status code: ${response.statusCode}. Error: $errorMessage');
        } catch (parseError) {
          throw Exception(
              'Failed to delete organic product. Status code: ${response.statusCode}. Response: ${response.body}');
        }
      }
    } catch (e) {
      Log.e('Error deleting organic product: $e');
      throw Exception('Error deleting organic product: $e');
    }
  }

  // Upload organic product image
  Future<String> uploadOrganicProductImage(String imagePath) async {
    _checkAuthToken();
    try {
      final url = '$baseUrl/admin/organic-products/upload-image';
      final request = http.MultipartRequest('POST', Uri.parse(url));

      // Add enhanced headers to bypass bot detection
      request.headers.addAll(_enhancedHeaders);

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
      Log.d('Uploading image to: $url');
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      Log.d('Upload response status: ${response.statusCode}');
      Log.d('Upload response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        Log.d('Image uploaded successfully: ${data['url']}');
        return data['url'];
      } else {
        Log.e('Failed to upload image: HTTP ${response.statusCode}');
        Log.e('Response body: ${response.body}');

        try {
          final errorBody = jsonDecode(response.body);
          final errorMessage =
              errorBody['message'] ?? errorBody['error'] ?? 'Unknown error';
          throw Exception(
              'Failed to upload image. Status code: ${response.statusCode}. Error: $errorMessage');
        } catch (parseError) {
          throw Exception(
              'Failed to upload image. Status code: ${response.statusCode}. Response: ${response.body}');
        }
      }
    } catch (e) {
      Log.e('Error uploading organic product image: $e');
      throw Exception('Error uploading organic product image: $e');
    }
  }
}
