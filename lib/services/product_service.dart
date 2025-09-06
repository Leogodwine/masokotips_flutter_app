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
      final url = '${ApiConfig.baseUrl}/seller/products';
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $_authToken',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        print('Seller products response: $responseData');
        final List<dynamic> data = responseData['data'];
        print('Found ${data.length} products');
        if (data.isNotEmpty) {
          print('First product data: ${data[0]}');
        }
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
      print('Adding product: ${product.name}');
      // First, upload all images and get their URLs
      List<String> imageUrls = [];
      final images = product.images ?? [];
      for (var i = 0; i < images.length; i++) {
        print('Uploading image ${i + 1}/${images.length}');
        final imageUrl = await uploadProductImage(images[i]);
        imageUrls.add(imageUrl);
      }

      // Now create the product with the uploaded image URLs
      final url = '${ApiConfig.baseUrl}/seller/products';
      print('Sending request to: $url');
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
        'stock': product.stock?.toString() ?? '0',
        'is_active': product.isActive ? '1' : '0',
        'is_featured': product.isFeatured ? '1' : '0',
        'category_id': product.categoryId.toString(),
        'slug': product.slug,
      });

      print('Request fields: ${request.fields}');

      // Add each image URL as a separate field
      if (imageUrls.isNotEmpty) {
        // Set the first image as the main image_url
        request.fields['image_url'] = imageUrls[0];

        // Add all images to the images array
        for (var i = 0; i < imageUrls.length; i++) {
          request.fields['images[$i]'] = imageUrls[i];
        }
      }

      // Send the request
      print('Sending request...');
      final response = await request.send();
      final responseBody = await http.Response.fromStream(response);
      print('Response status: ${response.statusCode}');
      print('Response body: ${responseBody.body}');

      if (response.statusCode == 201) {
        final responseData = jsonDecode(responseBody.body);
        final data = responseData['data']; // Get the actual product data
        print('Successfully created product: ${data['name']}');
        print('Raw response data: $responseData');
        print('Product data: $data');
        print(
            'Price in response: ${data['price']} (type: ${data['price'].runtimeType})');

        // Ensure the response data has all required fields
        final productData = {
          'id': data['id'] ?? 0,
          'name': data['name'] ?? '',
          'slug': data['slug'] ?? '',
          'description': data['description'] ?? '',
          'price': data['price']?.toString() ?? '0',
          'stock': data['stock']?.toString(),
          'unit': data['unit'],
          'is_active': data['is_active'] ?? true,
          'is_featured': data['is_featured'] ?? false,
          'image_url': data['image_url'] ?? '',
          'images': data['images'] ?? [],
          'category_id': data['category_id']?.toString() ?? '0',
          'user_id': data['user_id']?.toString() ?? '0',
          'rating': data['rating']?.toString() ?? '0',
          'rating_count': data['rating_count']?.toString() ?? '0',
          'created_at': data['created_at'] ?? DateTime.now().toIso8601String(),
          'updated_at': data['updated_at'] ?? DateTime.now().toIso8601String(),
          'deleted_at': data['deleted_at'],
          'category': data['category'],
        };

        print('Constructed productData: $productData');
        print(
            'ProductData price: ${productData['price']} (type: ${productData['price'].runtimeType})');

        return Product.fromJson(productData);
      } else {
        final errorBody = jsonDecode(responseBody.body);
        print(
            'Failed to add product. Error: ${errorBody['message'] ?? 'Unknown error'}');
        throw Exception(
            'Failed to add product. Status code: ${response.statusCode}. Error: ${errorBody['message'] ?? 'Unknown error'}');
      }
    } catch (e) {
      print('Error adding product: $e');
      throw Exception('Error adding product: $e');
    }
  }

  // Update a product
  Future<Product> updateProduct(Product product) async {
    _checkAuthToken(); // Ensure auth token is set
    try {
      print('Updating product: ${product.name}');

      // First, upload any new images if they exist
      List<String> imageUrls = [];
      final images = product.images ?? [];
      for (var i = 0; i < images.length; i++) {
        // Only upload if it's a local file path (not a URL)
        if (!images[i].startsWith('http')) {
          print('Uploading new image ${i + 1}/${images.length}');
          try {
            final imageUrl = await uploadProductImage(images[i]);
            imageUrls.add(imageUrl);
          } catch (e) {
            print('Error uploading image ${i + 1}: $e');
            continue; // Skip this image if upload fails
          }
        } else {
          imageUrls.add(images[i]);
        }
      }

      // Create a multipart request for updating the product
      final url = '${ApiConfig.baseUrl}/seller/products/${product.id}';
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
        'description': product.description,
        'price': product.price.toString(),
        'stock': product.stock?.toString() ?? '0',
        'is_active': product.isActive ? '1' : '0',
        'is_featured': product.isFeatured ? '1' : '0',
        'category_id': product.categoryId.toString(),
      });

      // Add image URLs
      if (imageUrls.isNotEmpty) {
        for (var i = 0; i < imageUrls.length; i++) {
          request.fields['images[$i]'] = imageUrls[i];
        }
        request.fields['image_url'] = imageUrls[0];
      }

      print('Sending update request to: $url');
      print('Update fields: ${request.fields}');

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Product.fromJson(data['data']);
      } else {
        final errorBody = jsonDecode(response.body);
        throw Exception(
            'Failed to update product. Status code: ${response.statusCode}. Error: ${errorBody['message'] ?? 'Unknown error'}');
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
      if (kDebugMode) {
        // ignore: avoid_print
        print('Attempting to delete product at URL: $url');
      }

      final response = await http.delete(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $_authToken',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      );

      print('Delete response status code: ${response.statusCode}');
      print('Delete response body: ${response.body}');

      if (response.statusCode != 200) {
        final errorBody = response.body.isNotEmpty
            ? response.body
            : 'No error details available';
        throw Exception(
            'Failed to delete product. Status code: ${response.statusCode}. Error: $errorBody');
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
        final data = json.decode(response.body);
        return data['url'];
      } else {
        final errorBody = json.decode(response.body);
        throw Exception(
            'Failed to upload image. Status code: ${response.statusCode}. Error: ${errorBody['message'] ?? 'Unknown error'}');
      }
    } catch (e) {
      print('Error uploading product image: $e');
      throw Exception('Error uploading product image: $e');
    }
  }
}
