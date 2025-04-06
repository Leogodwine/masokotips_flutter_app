import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import '../models/service.dart';
import '../utils/logger.dart';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../utils/image_upload_helper.dart';
import '../config/api_config.dart';

class AgricultureService {
  String? _authToken;
  String baseUrl = ApiConfig.baseUrl;

  String get getBaseUrl => baseUrl;

  void setBaseUrl(String url) {
    baseUrl = url;
    Log.d('API base URL set to: $baseUrl');
  }

  void setAuthToken(String token) {
    _authToken = token;
    Log.d('Auth token set in AgricultureService: ${token.substring(0, 10)}...');
  }

  // Ensure the auth token is set before making API calls
  void _checkAuthToken() {
    if (_authToken == null) {
      throw Exception('Authentication token is not set');
    }
  }

  Future<bool> checkConnection() async {
    try {
      // Ensure URL ends with a trailing slash
      final apiBaseUrl = baseUrl.endsWith('/') ? baseUrl : '$baseUrl/';
      Log.d('Trying to connect to: $apiBaseUrl');

      final response = await http.get(
        Uri.parse(apiBaseUrl),
        headers: {
          'Accept': 'application/json',
          if (_authToken != null) 'Authorization': 'Bearer $_authToken',
        },
      ).timeout(
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

  // Get all agricultural services
  Future<List<Service>> getAgriculturalServices() async {
    _checkAuthToken();
    try {
      // Ensure baseUrl ends with a trailing slash
      final apiBaseUrl = baseUrl.endsWith('/') ? baseUrl : '$baseUrl/';
      Log.d('Fetching agricultural services from: ${apiBaseUrl}services');

      final response = await http.get(
        Uri.parse('${apiBaseUrl}services'),
        headers: {
          'Authorization': 'Bearer $_authToken',
          'Accept': 'application/json',
        },
      );

      Log.d(
          'Agricultural services API response status: ${response.statusCode}');
      Log.d('Agricultural services API response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Check if the response has the expected structure
        if (data is Map<String, dynamic>) {
          if (data.containsKey('data')) {
            final List<dynamic> servicesJson = data['data'];
            // Filter for agricultural services (category_id = 6)
            return servicesJson
                .map((json) => Service.fromJson(json))
                .where((service) => service.categoryId == 6)
                .toList();
          } else if (data.containsKey('services')) {
            final List<dynamic> servicesJson = data['services'];
            // Filter for agricultural services (category_id = 6)
            return servicesJson
                .map((json) => Service.fromJson(json))
                .where((service) => service.categoryId == 6)
                .toList();
          }
        }
        Log.e('Unexpected API response structure: $data');
        return [];
      } else if (response.statusCode == 404) {
        // No services found
        Log.d('No agricultural services found');
        return [];
      } else {
        Log.e(
            'Failed to load agricultural services. Status code: ${response.statusCode}, Body: ${response.body}');
        throw Exception(
            'Failed to load agricultural services: ${response.body}');
      }
    } catch (e) {
      Log.e('Error loading agricultural services: $e');
      throw Exception('Error loading agricultural services: $e');
    }
  }

  // Get my agricultural services
  Future<List<Service>> getMyAgriculturalServices() async {
    _checkAuthToken();
    try {
      // Ensure baseUrl ends with a trailing slash
      final apiBaseUrl = baseUrl.endsWith('/') ? baseUrl : '$baseUrl/';
      Log.d('Fetching user services from: ${apiBaseUrl}my-services');
      Log.d('Auth token: ${_authToken?.substring(0, 10)}...');

      final response = await http.get(
        Uri.parse('${apiBaseUrl}my-services'),
        headers: {
          'Authorization': 'Bearer $_authToken',
          'Accept': 'application/json',
        },
      );

      Log.d('User services API response status: ${response.statusCode}');
      Log.d('User services API response headers: ${response.headers}');
      Log.d('User services API response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        Log.d('Parsed response data: $data');

        // Check if the response has the expected structure
        if (data is Map<String, dynamic>) {
          if (data.containsKey('data')) {
            final List<dynamic> servicesJson = data['data'];
            Log.d('Found ${servicesJson.length} services in data field');
            // Filter for agricultural services (category_id = 6)
            final filteredServices = servicesJson
                .map((json) => Service.fromJson(json))
                .where((service) => service.categoryId == 6)
                .toList();
            Log.d(
                'Filtered to ${filteredServices.length} agricultural services');
            return filteredServices;
          } else if (data.containsKey('services')) {
            final List<dynamic> servicesJson = data['services'];
            Log.d('Found ${servicesJson.length} services in services field');
            // Filter for agricultural services (category_id = 6)
            final filteredServices = servicesJson
                .map((json) => Service.fromJson(json))
                .where((service) => service.categoryId == 6)
                .toList();
            Log.d(
                'Filtered to ${filteredServices.length} agricultural services');
            return filteredServices;
          }
        }
        Log.e('Unexpected API response structure: $data');
        return [];
      } else if (response.statusCode == 404) {
        // No services found
        Log.d('No services found for the current user');
        return [];
      } else {
        Log.e(
            'Failed to load user services. Status code: ${response.statusCode}, Body: ${response.body}');
        throw Exception('Failed to load user services: ${response.body}');
      }
    } catch (e) {
      Log.e('Error loading user services: $e');
      throw Exception('Error loading user services: $e');
    }
  }

  // Add a new agricultural service
  Future<Service> addAgriculturalService({
    required String title,
    required String description,
    required double price,
    String? imageUrl,
    String? subcategory,
  }) async {
    _checkAuthToken();
    try {
      Log.d('Adding new agricultural service with title: $title');
      Log.d('Category ID: 6 (Agricultural Services)');
      Log.d('Auth token: ${_authToken?.substring(0, 10)}...');

      final requestBody = {
        'title': title,
        'description': description,
        'price': price,
        'category_id': 6,
        if (imageUrl != null) 'image_url': imageUrl,
        if (subcategory != null) 'subcategory': subcategory,
      };

      Log.d('Request body: ${json.encode(requestBody)}');

      // Ensure baseUrl ends with a trailing slash
      final apiBaseUrl = baseUrl.endsWith('/') ? baseUrl : '$baseUrl/';

      // Use the correct endpoint
      final endpoint = '${apiBaseUrl}services';

      Log.d('Adding agricultural service at endpoint: $endpoint');
      Log.d(
          'Request headers: Authorization: Bearer ${_authToken?.substring(0, 10)}...');

      final response = await http
          .post(
        Uri.parse(endpoint),
        headers: {
          'Authorization': 'Bearer $_authToken',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: json.encode(requestBody),
      )
          .timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          Log.d('Request to $endpoint timed out');
          throw TimeoutException('Request timed out');
        },
      );

      Log.d('Add agricultural service response status: ${response.statusCode}');
      Log.d('Add agricultural service response headers: ${response.headers}');
      Log.d('Add agricultural service response body: ${response.body}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData is Map<String, dynamic>) {
          if (responseData.containsKey('data')) {
            Log.d('Successfully created agricultural service');
            return Service.fromJson(responseData['data']);
          } else if (responseData.containsKey('id')) {
            // Alternative response format
            Log.d(
                'Successfully created agricultural service (direct response)');
            return Service(
              id: responseData['id'],
              title: responseData['title'] ?? title,
              description: responseData['description'] ?? description,
              price: responseData['price'] ?? price,
              categoryId: responseData['category_id'] ?? 6,
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
            'Failed to add agricultural service. Status code: ${response.statusCode}, Body: ${response.body}');
        throw Exception('Failed to add agricultural service: ${response.body}');
      }
    } catch (e) {
      Log.e('Error in addAgriculturalService: $e');
      throw Exception('Failed to add agricultural service: $e');
    }
  }

  // Update an agricultural service
  Future<Service> updateAgriculturalService({
    required String id,
    required String title,
    required String description,
    required double price,
    required int categoryId,
    String? imageUrl,
    String? subcategory,
  }) async {
    _checkAuthToken();
    // Ensure baseUrl ends with a trailing slash
    final apiBaseUrl = baseUrl.endsWith('/') ? baseUrl : '$baseUrl/';

    final response = await http.put(
      Uri.parse('${apiBaseUrl}services/$id'),
      headers: {
        'Authorization': 'Bearer $_authToken',
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'title': title,
        'description': description,
        'price': price,
        'category_id': categoryId,
        'image_url': imageUrl,
        'subcategory': subcategory,
      }),
    );

    if (response.statusCode == 200) {
      return Service.fromJson(json.decode(response.body)['data']);
    } else {
      throw Exception('Failed to update agricultural service');
    }
  }

  // Delete an agricultural service
  Future<void> deleteAgriculturalService(String id) async {
    _checkAuthToken();
    // Ensure baseUrl ends with a trailing slash
    final apiBaseUrl = baseUrl.endsWith('/') ? baseUrl : '$baseUrl/';

    final response = await http.delete(
      Uri.parse('${apiBaseUrl}services/$id'),
      headers: {
        'Authorization': 'Bearer $_authToken',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to delete agricultural service');
    }
  }

  // Upload agricultural service image
  Future<String> uploadAgriculturalServiceImage(
      String serviceId, String imagePath) async {
    _checkAuthToken();
    try {
      Log.d('Uploading agricultural service image for service ID: $serviceId');
      Log.d('Image path: $imagePath');

      if (imagePath.startsWith('blob:') && kIsWeb) {
        Log.d(
            'Blob URL detected in web environment - special handling required');
      }

      // Ensure baseUrl ends with a trailing slash
      final apiBaseUrl = baseUrl.endsWith('/') ? baseUrl : '$baseUrl/';

      // Try multiple upload endpoints that Laravel might use
      final uploadEndpoints = [
        '${apiBaseUrl}services/upload-image',
        '${apiBaseUrl}upload-image',
        '${apiBaseUrl}services/$serviceId/image',
        '${apiBaseUrl}services/$serviceId/upload',
      ];

      // Create a multipart request
      final request = http.MultipartRequest(
        'POST',
        Uri.parse(uploadEndpoints[0]), // Start with the first endpoint
      );

      // Add headers
      request.headers.addAll({
        'Authorization': 'Bearer $_authToken',
        'Accept': 'application/json',
      });

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
        final multipartFile =
            await ImageUploadHelper.prepareImageForUpload(imageFile);
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

      Exception? lastException;

      // Try each endpoint until one works
      for (final endpoint in uploadEndpoints) {
        try {
          // Create a new request for each endpoint
          final endpointRequest = http.MultipartRequest(
            'POST',
            Uri.parse(endpoint),
          );

          // Copy headers and fields from the original request
          endpointRequest.headers.addAll(request.headers);
          endpointRequest.fields.addAll(request.fields);

          // Add the file
          final multipartFile =
              await ImageUploadHelper.prepareImageForUpload(imageFile);
          endpointRequest.files.add(multipartFile);

          Log.d('Trying upload endpoint: $endpoint');

          final streamedResponse = await endpointRequest.send();
          final response = await http.Response.fromStream(streamedResponse);

          Log.d('Upload response status: ${response.statusCode}');
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
          }
        } catch (e) {
          Log.d('Error with endpoint $endpoint: $e');
          lastException = Exception('Failed with endpoint $endpoint: $e');
        }
      }

      // If we get here, all endpoints failed
      throw lastException ?? Exception('All upload endpoints failed');
    } catch (e, stackTrace) {
      Log.e('Error uploading agricultural service image: $e');
      Log.e('Stack trace: $stackTrace');
      throw Exception('Error uploading agricultural service image: $e');
    }
  }
}
