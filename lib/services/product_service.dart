import 'package:http/http.dart' as http;
import '../models/product.dart';
import '../config/api_config.dart';
import '../utils/api_response.dart';
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

  // Centralized method for API headers
  Map<String, String> _getHeaders() {
    return ApiConfig.getHeaders(_authToken);
  }

  // Get seller products
  Future<List<Product>> getSellerProducts() async {
    _checkAuthToken(); // Ensure auth token is set
    try {
      const url = '${ApiConfig.baseUrl}/seller/products';
      final response = await http.get(
        Uri.parse(url),
        headers: _getHeaders(),
      );

      if (response.statusCode == 200) {
        // Defensive check for HTML response (e.g., bot protection)
        if (response.body.trim().startsWith('<!DOCTYPE') ||
            response.body.trim().startsWith('<html')) {
          throw const FormatException(
              'Server returned HTML instead of JSON. Bot protection might be blocking the request.');
        }
        final responseData = ApiResponse.decodeJson(response.body);
        debugPrint('Seller products response: $responseData');
        final List<dynamic> data = responseData['data'] ?? [];
        debugPrint('Found ${data.length} products');
        if (data.isNotEmpty) {
          debugPrint('First product data: ${data[0]}');
        }
        return data.map((product) => Product.fromJson(product)).toList();
      } else if (response.statusCode == 403) {
        // User doesn't have seller role - return empty list instead of throwing error
        debugPrint(
            'User does not have seller role - returning empty products list');
        return [];
      } else {
        throw Exception(
            'Failed to fetch seller products. Status code: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error fetching seller products: $e');
      // Return empty list instead of throwing error for better UX
      return [];
    }
  }

  // Add a new product
  Future<Product> addProduct(Product product) async {
    _checkAuthToken(); // Ensure auth token is set
    try {
      debugPrint('Adding product: ${product.name}');

      const url = '${ApiConfig.baseUrl}/seller/products';
      debugPrint('Sending request to: $url');
      final request = http.MultipartRequest('POST', Uri.parse(url));

      // Add headers
      request.headers.addAll(_getHeaders());

      // Add product fields
      final slugBase = product.name
          .toLowerCase()
          .replaceAll(RegExp(r'[^a-z0-9\s-]'), '')
          .replaceAll(RegExp(r'[\s-]+'), '-')
          .trim();

      // Append a unique suffix to the slug to prevent "Duplicate entry" errors.
      // This is a client-side workaround. Ideally, the backend should handle slug uniqueness.
      final uniqueSuffix =
          DateTime.now().millisecondsSinceEpoch.toString().substring(7);
      final slug = '$slugBase-$uniqueSuffix';
      request.fields.addAll({
        'name': product.name,
        'description': product.description,
        'price': product.price.toString(),
        'stock': product.stock?.toString() ?? '0',
        'is_active': product.isActive ? '1' : '0',
        'is_featured': product.isFeatured ? '1' : '0',
        'category_id': product.categoryId.toString(),
        'slug': slug,
      });

      debugPrint('Request fields: ${request.fields}');
      debugPrint('Request headers: ${request.headers}');
      debugPrint('Request files: ${request.files.length} files');

      // Add image files
      final images = product.images ?? [];
      for (var i = 0; i < images.length; i++) {
        final imagePath = images[i];
        if (kIsWeb && imagePath.startsWith('blob:')) {
          // Blob URLs on web are temporary and cannot be uploaded directly from path.
          // Assuming the image picker provides a file path for non-web,
          // and web uploads are handled differently if needed.
          continue;
        }
        if (imagePath.isNotEmpty && !imagePath.startsWith('http')) {
          debugPrint('Attaching image file: $imagePath');
          final file = File(imagePath);
          if (await file.exists()) {
            final fileSize = await file.length();
            debugPrint('Image file exists, size: $fileSize bytes');
            request.files.add(await http.MultipartFile.fromPath(
              'images[$i]', // Use indexed keys for the array of files
              imagePath,
            ));
          } else {
            debugPrint(
                'WARNING: Image file does not exist or was cleaned up: $imagePath');
          }
        }
      }

      // Send the request
      debugPrint('Sending request...');
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      debugPrint('Response status: ${response.statusCode}');
      debugPrint('Response headers: ${response.headers}');
      debugPrint('Response body: ${response.body}');

      if (response.statusCode == 201) {
        final responseData = ApiResponse.decodeJson(response.body);
        final data = responseData['data']; // Get the actual product data
        debugPrint('Successfully created product: ${data['name']}');
        return Product.fromJson(
            data); // Directly use fromJson on the returned data
      } else {
        final errorBody = ApiResponse.decodeJson(response.body);
        debugPrint(
            'Failed to add product. Error: ${errorBody['message'] ?? 'Unknown error'}');
        throw Exception(
            'Failed to add product. Status code: ${response.statusCode}. Error: ${errorBody['message'] ?? 'Unknown error'}');
      }
    } catch (e) {
      debugPrint('Error adding product: $e');
      throw Exception('Error adding product: $e');
    }
  }

  // Update a product
  Future<Product> updateProduct(Product product) async {
    _checkAuthToken(); // Ensure auth token is set
    try {
      debugPrint('Updating product: ${product.name}');

      // Create a multipart request for updating the product
      final url = '${ApiConfig.baseUrl}/seller/products/${product.id}';
      final request = http.MultipartRequest('POST', Uri.parse(url));

      // Add the _method field to simulate PUT request
      request.fields['_method'] = 'PUT';

      // Add headers
      request.headers.addAll(_getHeaders());

      // Add product fields
      request.fields.addAll({
        'name': product.name,
        'description': product.description,
        'price': product.price.toString(),
        'stock': product.stock?.toString() ?? '0',
        'is_active': product.isActive ? '1' : '0',
        'is_featured': product.isFeatured ? '1' : '0',
        'category_id': product.categoryId.toString(),
        // On update, it's best practice to preserve the existing slug to avoid breaking URLs.
        // We use the slug from the product object, which should have been fetched from the server.
        // A fallback to generating from the name is included, but may cause issues if the name
        // results in a slug that is already in use by another product. The analyzer indicates
        // product.slug is non-nullable, so the fallback is removed.
        'slug': product.slug,
      });

      // The backend validation requires images to be strings (URLs) during an update
      // ("The images.0 field must be a string"). We must pre-upload any new files
      // and then pass all resulting URLs as string fields.
      final images = product.images ?? [];
      int fieldIndex = 0;
      for (final imagePath in images) {
        if (kIsWeb && imagePath.startsWith('blob:')) {
          // Blob URLs on web are temporary and cannot be uploaded directly from path.
          continue;
        }

        if (imagePath.startsWith('http')) {
          // It's an existing URL, pass it as a string
          request.fields['images[$fieldIndex]'] = imagePath;
          fieldIndex++;
        } else if (imagePath.isNotEmpty) {
          // It's a new local file, pre-upload it to get a URL
          debugPrint('Pre-uploading new image for update: $imagePath');
          final file = File(imagePath);
          if (await file.exists()) {
            try {
              final uploadedUrl = await uploadProductImage(imagePath);
              request.fields['images[$fieldIndex]'] = uploadedUrl;
              fieldIndex++;
              debugPrint('Successfully pre-uploaded: $uploadedUrl');
            } catch (e) {
              throw Exception('Failed to pre-upload image before updating: $e');
            }
          } else {
            debugPrint(
                'WARNING: Image file for update does not exist: $imagePath');
          }
        }
      }

      debugPrint('Sending update request to: $url');
      debugPrint('Update fields: ${request.fields}');
      debugPrint('Update files: ${request.files.length}');

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      debugPrint('Response status: ${response.statusCode}');
      debugPrint('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = ApiResponse.decodeJson(response.body);
        return Product.fromJson(data['data']);
      } else {
        final errorBody = ApiResponse.decodeJson(response.body);
        throw Exception(
            'Failed to update product. Status code: ${response.statusCode}. Error: ${errorBody['message'] ?? 'Unknown error'}');
      }
    } catch (e) {
      debugPrint('Error updating product: $e');
      throw Exception('Error updating product: $e');
    }
  }

  // Delete a product
  Future<void> deleteProduct(int productId) async {
    _checkAuthToken(); // Ensure auth token is set
    try {
      final url = '${ApiConfig.baseUrl}/seller/products/$productId';
      if (kDebugMode) {
        // ignore: avoid_print
        debugPrint('Attempting to delete product at URL: $url');
      }

      final response = await http.delete(
        Uri.parse(url),
        headers:
            _getHeaders(), // Use centralized headers to bypass bot protection
      );

      debugPrint('Delete response status code: ${response.statusCode}');
      debugPrint('Delete response body: ${response.body}');

      if (response.statusCode != 200 && response.statusCode != 204) {
        // Accept 204 No Content as a success code
        final errorBody = response.body.isNotEmpty
            ? response.body
            : 'No error details available';
        throw Exception(
            'Failed to delete product. Status code: ${response.statusCode}. Error: $errorBody');
      }
    } catch (e) {
      debugPrint('Error deleting product: $e');
      throw Exception('Error deleting product: $e');
    }
  }

  // Upload product image
  Future<String> uploadProductImage(String imagePath) async {
    _checkAuthToken(); // Ensure auth token is set
    try {
      const url = '${ApiConfig.baseUrl}/seller/products/upload-image';
      final request = http.MultipartRequest('POST', Uri.parse(url));

      // Add headers
      request.headers.addAll(_getHeaders());

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
      debugPrint('Uploading image to: $url');
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      debugPrint('Upload response status: ${response.statusCode}');
      debugPrint('Upload response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = ApiResponse.decodeJson(response.body);
        return data['url'];
      } else {
        final errorBody = ApiResponse.decodeJson(response.body);
        throw Exception(
            'Failed to upload image. Status code: ${response.statusCode}. Error: ${errorBody['message'] ?? 'Unknown error'}');
      }
    } catch (e) {
      debugPrint('Error uploading product image: $e');
      throw Exception('Error uploading product image: $e');
    }
  }
}
