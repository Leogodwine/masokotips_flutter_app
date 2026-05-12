import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import '../models/service.dart';
import '../models/category.dart';
import '../utils/logger.dart';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../utils/image_upload_helper.dart';
import '../config/api_config.dart';
import 'package:image_picker/image_picker.dart';

class ServiceService {
  String? _authToken;
  String baseUrl = ApiConfig.baseUrl;

  String get getBaseUrl => baseUrl;

  void setBaseUrl(String url) {
    baseUrl = url;
    Log.d('API base URL set to: $baseUrl');
  }

  void setAuthToken(String token) {
    _authToken = token;
    Log.d('Auth token set in ServiceService: ${token.substring(0, 10)}...');
  }

  // Centralized method for API headers
  Map<String, String> _getHeaders() {
    return ApiConfig.getHeaders(_authToken);
  }

  Future<bool> checkConnection() async {
    try {
      // Ensure URL ends with a trailing slash
      final apiBaseUrl = baseUrl.endsWith('/') ? baseUrl : '$baseUrl/';
      Log.d('Trying to connect to: $apiBaseUrl');

      final response = await http
          .get(
        Uri.parse(apiBaseUrl),
        headers: _getHeaders(),
      )
          .timeout(
        const Duration(seconds: 3),
        onTimeout: () {
          Log.d('Connection to $apiBaseUrl timed out');
          throw TimeoutException('Connection timed out');
        },
      );

      Log.d('$apiBaseUrl health check status: ${response.statusCode}');

      // Laravel might return 200, 204, or even 401 (if auth is required)
      if (response.statusCode >= 200 && response.statusCode < 300) {
        Log.d('$apiBaseUrl is responsive');
        return true;
      }

      // If we get a 401, it might mean the server is up but requires auth
      if (response.statusCode == 401) {
        Log.d('$apiBaseUrl is responsive but requires authentication');
        return true;
      }

      Log.d('$apiBaseUrl returned non-success status code');
      return false;
    } catch (e) {
      Log.d('Connection to $baseUrl failed: $e');
      return false;
    }
  }

  Future<List<Service>> getMyServices() async {
    try {
      // Ensure baseUrl ends with a trailing slash
      final apiBaseUrl = baseUrl.endsWith('/') ? baseUrl : '$baseUrl/';
      Log.d(
          'Fetching user services from: ${apiBaseUrl}service-provider/my-services');
      Log.d(
          'Using auth token: ${_authToken != null ? 'Token is set' : 'No token set'}');

      final response = await http.get(
        Uri.parse('${apiBaseUrl}service-provider/my-services'),
        headers: _getHeaders(),
      );

      Log.d('User services API response status: ${response.statusCode}');
      Log.d('User services API response body: ${response.body}');

      if (response.statusCode == 200) {
        // Defensive check to prevent JSON decode crashes on HTML pages
        if (response.body.trim().startsWith('<!DOCTYPE') ||
            response.body.trim().startsWith('<html')) {
          throw const FormatException(
              'Server returned HTML instead of JSON. Bot protection might be blocking the request.');
        }

        final data = json.decode(response.body);
        Log.d('Decoded response data type: ${data.runtimeType}');

        // Check if the response has the expected structure
        if (data is Map<String, dynamic>) {
          Log.d('Response keys: ${data.keys.join(', ')}');

          // Check if data contains 'data' key
          if (data.containsKey('data')) {
            final List<dynamic> servicesJson = data['data'];
            Log.d('Found ${servicesJson.length} services in data.data');
            return servicesJson.map((json) => Service.fromJson(json)).toList();
          }
          // Check if data contains 'services' key
          else if (data.containsKey('services')) {
            final List<dynamic> servicesJson = data['services'];
            Log.d('Found ${servicesJson.length} services in data.services');
            return servicesJson.map((json) => Service.fromJson(json)).toList();
          } else {
            Log.e('Unexpected API response structure: $data');
            return [];
          }
        } else if (data is List) {
          // Direct list of services
          Log.d('Response is a direct list with ${data.length} items');
          return data.map((json) => Service.fromJson(json)).toList();
        } else {
          Log.e('Unexpected API response structure: $data');
          return [];
        }
      } else if (response.statusCode == 404) {
        // No services found
        Log.d('No services found for the current user');
        return [];
      } else if (response.statusCode == 401) {
        // Unauthorized
        Log.e('Unauthorized access. Token might be invalid or expired.');
        throw Exception('Unauthorized access. Please log in again.');
      } else {
        Log.e(
            'Failed to load services. Status code: ${response.statusCode}, Body: ${response.body}');
        throw Exception('Failed to load services: ${response.body}');
      }
    } catch (e, stackTrace) {
      Log.e('Error loading services: $e');
      Log.e('Stack trace: $stackTrace');
      throw Exception('Error loading services: $e');
    }
  }

  Future<List<Service>> getServicesByCategory(int categoryId) async {
    try {
      // Ensure baseUrl ends with a trailing slash
      final apiBaseUrl = baseUrl.endsWith('/') ? baseUrl : '$baseUrl/';
      Log.d('Fetching services for category ID: $categoryId');

      final response = await http.get(
        Uri.parse('${apiBaseUrl}services/category/$categoryId'),
        headers: _getHeaders(),
      );

      Log.d('Category services API response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data is Map<String, dynamic> && data.containsKey('data')) {
          final List<dynamic> servicesJson = data['data'];
          return servicesJson.map((json) => Service.fromJson(json)).toList();
        } else {
          Log.e('Unexpected API response structure: $data');
          return [];
        }
      } else if (response.statusCode == 404) {
        Log.d('No services found for category ID: $categoryId');
        return [];
      } else {
        Log.e(
            'Failed to load category services. Status code: ${response.statusCode}, Body: ${response.body}');
        throw Exception('Failed to load category services: ${response.body}');
      }
    } catch (e) {
      Log.e('Error loading category services: $e');
      throw Exception('Error loading category services: $e');
    }
  }

  Future<Service> addService({
    required String title,
    required String description,
    required double price,
    required int categoryId,
    required String categoryName,
    String? imageUrl,
    String? subcategory,
  }) async {
    try {
      Log.d('Adding new service with title: $title, category: $categoryId');

      final requestBody = {
        'title': title,
        'description': description,
        'price': price,
        'category': categoryName,
        'category_id': categoryId,
        if (imageUrl != null) 'image_url': imageUrl,
        if (subcategory != null) 'subcategory': subcategory,
      };

      Log.d('Request body: ${json.encode(requestBody)}');

      // Ensure baseUrl ends with a trailing slash
      final apiBaseUrl = baseUrl.endsWith('/') ? baseUrl : '$baseUrl/';

      // Use the correct endpoint for service providers
      final endpoint = '${apiBaseUrl}service-provider/services';

      Log.d('Adding service at endpoint: $endpoint');
      Log.d(
          'Request headers: Authorization: Bearer ${_authToken?.substring(0, 10)}...');

      final response = await http
          .post(
        Uri.parse(endpoint),
        headers: _getHeaders(),
        body: json.encode(requestBody),
      )
          .timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          Log.d('Request to $endpoint timed out');
          throw TimeoutException('Request timed out');
        },
      );

      Log.d('Add service response status: ${response.statusCode}');
      Log.d('Add service response headers: ${response.headers}');
      Log.d('Add service response body: ${response.body}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData is Map<String, dynamic>) {
          if (responseData.containsKey('data')) {
            Log.d('Successfully created service');
            return Service.fromJson(responseData['data']);
          } else if (responseData.containsKey('service')) {
            Log.d('Successfully created service (service field)');
            return Service.fromJson(responseData['service']);
          } else if (responseData.containsKey('id')) {
            // Alternative response format
            Log.d('Successfully created service (direct response)');
            return Service(
              id: responseData['id'],
              title: responseData['title'] ?? title,
              description: responseData['description'] ?? description,
              price: responseData['price'] ?? price,
              categoryId: responseData['category_id'] ?? categoryId,
              userId: responseData['user_id'] ?? 0,
              imageUrl: responseData['image_url'] ?? imageUrl,
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
              subcategory: responseData['subcategory'] ?? subcategory,
            );
          }
        }
        Log.e('Unexpected API response format: $responseData');
        throw Exception('Unexpected API response format');
      } else {
        Log.e(
            'Failed to add service. Status code: ${response.statusCode}, Body: ${response.body}');
        throw Exception('Failed to add service: ${response.body}');
      }
    } catch (e) {
      Log.e('Error in addService: $e');
      throw Exception('Failed to add service: $e');
    }
  }

  Future<Service> updateService({
    required String id,
    required String title,
    required String description,
    required double price,
    required int categoryId,
    required String categoryName,
    String? imageUrl,
    String? subcategory,
  }) async {
    // Ensure baseUrl ends with a trailing slash
    final apiBaseUrl = baseUrl.endsWith('/') ? baseUrl : '$baseUrl/';

    final response = await http.put(
      Uri.parse('${apiBaseUrl}service-provider/services/$id'),
      headers: _getHeaders(),
      body: json.encode({
        'title': title,
        'description': description,
        'price': price,
        'category': categoryName,
        'category_id': categoryId,
        'image_url': imageUrl,
        'subcategory': subcategory,
      }),
    );

    Log.d('Update service response status: ${response.statusCode}');
    Log.d('Update service response body: ${response.body}');

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      if (responseData is Map<String, dynamic>) {
        if (responseData.containsKey('data')) {
          return Service.fromJson(responseData['data']);
        } else if (responseData.containsKey('service')) {
          return Service.fromJson(responseData['service']);
        } else {
          throw Exception('Unexpected API response format: $responseData');
        }
      } else {
        throw Exception('Invalid response format');
      }
    } else {
      final errorBody = response.body;
      Log.e('Update service failed: $errorBody');
      throw Exception(
          'Failed to update service: ${response.statusCode} - $errorBody');
    }
  }

  Future<void> deleteService(String id) async {
    // Ensure baseUrl ends with a trailing slash
    final apiBaseUrl = baseUrl.endsWith('/') ? baseUrl : '$baseUrl/';

    final response = await http.delete(
      Uri.parse('${apiBaseUrl}service-provider/services/$id'),
      headers: _getHeaders(),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to delete service');
    }
  }

  Future<String> uploadServiceImage(String serviceId, String imagePath) async {
    try {
      Log.d('Uploading service image for service ID: $serviceId');
      Log.d('Image path: $imagePath');

      if (imagePath.startsWith('blob:') && kIsWeb) {
        Log.d(
            'Blob URL detected in web environment - special handling required');
      }

      // Ensure baseUrl ends with a trailing slash
      final apiBaseUrl = baseUrl.endsWith('/') ? baseUrl : '$baseUrl/';

      // Use the correct endpoint for service providers
      final endpoint =
          '${apiBaseUrl}service-provider/services/upload-image';

      Log.d('Uploading image to endpoint: $endpoint');

      // Create a multipart request
      final request = http.MultipartRequest(
        'POST',
        Uri.parse(endpoint),
      );

      // Add headers
      request.headers.addAll(_getHeaders());

      // IMPORTANT: Remove the JSON Content-Type header so the http package
      // can automatically set the correct multipart/form-data Content-Type with the boundary.
      request.headers.remove('Content-Type');

      // Validate service ID
      if (serviceId.isEmpty || serviceId == 'null') {
        throw Exception('Invalid service ID: Cannot be empty or null');
      }

      // For web blob URLs, directly set the service_id field without parsing
      if (serviceId == 'temp' || serviceId == '0' || serviceId == '-1') {
        Log.d('Using default service ID as placeholder for temporary service');
        // Use ID 1 as default for temporary uploads if needed by your API
        request.fields['service_id'] = '1';
        request.fields['is_temp'] = 'true';
      } else {
        try {
          // Parse the service ID to ensure it's a valid integer
          int.parse(serviceId); // Just to validate it's a number
          request.fields['service_id'] = serviceId;
          Log.d('Using service ID: $serviceId');
        } catch (e) {
          Log.e('Invalid service ID format: $serviceId, error: $e');
          throw Exception('Invalid service ID format: $serviceId');
        }
      }

      // Create a File object from the image path
      final imageFile = File(imagePath);

      // Use the ImageUploadHelper to prepare the image for upload
      Log.d('Preparing image for upload...');

      try {
        final xFile = XFile(imageFile.path);
        final multipartFile =
            await ImageUploadHelper.prepareImageForUpload(xFile);
        Log.d(
            'Image prepared successfully, content type: ${multipartFile.contentType}');
        Log.d('Image filename: ${multipartFile.filename}');

        // Laravel typically expects 'image' as the field name, but some APIs might use different names
        request.files.add(multipartFile);

        // Add additional fields that Laravel might expect
        request.fields['_method'] =
            'POST'; // For Laravel's form method spoofing
      } catch (e) {
        Log.e('Error preparing image: $e');
        throw Exception('Failed to prepare image for upload: $e');
      }

      // Send the request
      Log.d('Uploading image to: ${request.url}');
      Log.d('Request headers: ${request.headers}');

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      Log.d('Upload response status: ${response.statusCode}');
      Log.d('Upload response headers: ${response.headers}');
      Log.d('Upload response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);

        // Handle different Laravel response formats
        if (data is Map<String, dynamic>) {
          if (data.containsKey('image_url')) {
            Log.d('Image uploaded successfully, URL: ${data['image_url']}');
            return data['image_url'];
          } else if (data.containsKey('data') &&
              data['data'] is Map<String, dynamic>) {
            final imageData = data['data'];
            if (imageData.containsKey('image_url')) {
              Log.d(
                  'Image uploaded successfully, URL: ${imageData['image_url']}');
              return imageData['image_url'];
            }
          } else if (data.containsKey('url')) {
            Log.d('Image uploaded successfully, URL: ${data['url']}');
            return data['url'];
          }
        }

        Log.e('Unexpected response format: $data');
        throw Exception('Unexpected response format: missing image URL');
      } else {
        Log.e(
            'Failed to upload image. Status code: ${response.statusCode}, Body: ${response.body}');
        throw Exception('Failed to upload image: ${response.body}');
      }
    } catch (e, stackTrace) {
      Log.e('Error uploading service image: $e');
      Log.e('Stack trace: $stackTrace');
      throw Exception('Error uploading service image: $e');
    }
  }

  // Add methods to match ApiService interface
  Future<Map<String, dynamic>> getRequest(String endpoint) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/$endpoint'),
        headers: _getHeaders(),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        // Provide user-friendly error messages based on status code
        String friendlyMessage;
        if (response.statusCode == 500) {
          friendlyMessage =
              'No services yet. Start by adding your first service!';
        } else if (response.statusCode == 404) {
          friendlyMessage = 'The requested information was not found.';
        } else if (response.statusCode == 401) {
          friendlyMessage = 'Your session has expired. Please log in again.';
        } else if (response.statusCode == 403) {
          friendlyMessage =
              'You do not have permission to access this resource.';
        } else {
          friendlyMessage = 'Unable to load data. Please try again.';
        }
        throw Exception(friendlyMessage);
      }
    } catch (e) {
      Log.e('Error in GET request: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> deleteRequest(String endpoint) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/$endpoint'),
        headers: _getHeaders(),
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        return response.statusCode == 200 ? json.decode(response.body) : {};
      } else {
        throw Exception('Failed to delete data: ${response.statusCode}');
      }
    } catch (e) {
      Log.e('Error in DELETE request: $e');
      rethrow;
    }
  }

  Future<List<Category>> getAgriculturalServiceCategories() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/services/agricultural-categories'),
        headers: _getHeaders(),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);

        // Handle different response formats
        List<dynamic> categoriesJson;
        if (responseData is List) {
          categoriesJson = responseData;
        } else if (responseData is Map<String, dynamic> &&
            responseData.containsKey('data')) {
          categoriesJson = responseData['data'] as List<dynamic>;
        } else {
          throw Exception(
              'Unexpected response format for agricultural service categories');
        }

        return categoriesJson
            .map<Category>(
                (json) => Category.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception('Failed to fetch categories: ${response.statusCode}');
      }
    } catch (e) {
      Log.e('Error fetching agricultural service categories: $e');
      rethrow;
    }
  }
}
