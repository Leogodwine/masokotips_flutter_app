import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:http/http.dart' as http;
import '../models/market_info.dart';
import '../utils/logger.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../utils/image_upload_helper.dart';
import '../config/api_config.dart';

class MarketInfoService {
  String? _authToken;
  String baseUrl = ApiConfig.baseUrl;

  void setAuthToken(String token) {
    _authToken = token;
    Log.d('Auth token set in MarketInfoService: ${token.substring(0, 10)}...');
  }

  Future<List<MarketInfo>> getAllMarketInfo() async {
    try {
      final apiBaseUrl = baseUrl.replaceAll('/api', '');
      final endpoint = '${apiBaseUrl}/api/admin/market-info-list';

      Log.d('Base URL: $baseUrl');
      Log.d('API Base URL: $apiBaseUrl');
      Log.d('Full endpoint: $endpoint');
      Log.d('Auth token present: ${_authToken != null}');
      if (_authToken != null) {
        Log.d('Auth token length: ${_authToken!.length}');
      }

      final headers = {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        if (_authToken != null) 'Authorization': 'Bearer $_authToken',
      };

      Log.d('Request headers: $headers');

      final response = await http.get(
        Uri.parse(endpoint),
        headers: headers,
      );

      Log.d('Market info API response status: ${response.statusCode}');
      Log.d('Market info API response headers: ${response.headers}');
      Log.d('Market info API response body: ${response.body}');

      if (response.statusCode == 200) {
        try {
          final data = json.decode(response.body);
          Log.d('Decoded response data: $data');

          if (data is Map<String, dynamic>) {
            if (data.containsKey('data')) {
              final dynamic dataField = data['data'];
              if (dataField is List) {
                Log.d('Market info JSON array length: ${dataField.length}');
                final List<MarketInfo> result = [];
                for (var item in dataField) {
                  try {
                    if (item is Map<String, dynamic>) {
                      result.add(MarketInfo.fromJson(item));
                    } else {
                      Log.e('Invalid item format: $item');
                    }
                  } catch (e) {
                    Log.e('Error parsing market info item: $e');
                  }
                }
                return result;
              } else {
                Log.d('Data field is not a list, returning empty array');
                return [];
              }
            } else {
              Log.d('Response missing data field, returning empty array');
              return [];
            }
          } else {
            Log.d('Response is not a map, returning empty array');
            return [];
          }
        } catch (e) {
          Log.e('Error parsing response JSON: $e');
          return [];
        }
      } else if (response.statusCode == 404) {
        Log.d('No market information found (404)');
        return [];
      } else if (response.statusCode == 401) {
        Log.e('Unauthorized access. Please check your authentication token.');
        throw Exception(
            'Unauthorized access. Please check your authentication token.');
      } else {
        Log.e(
            'Failed to load market information. Status code: ${response.statusCode}, Body: ${response.body}');
        throw Exception('Failed to load market information: ${response.body}');
      }
    } catch (e, stackTrace) {
      Log.e('Error loading market information: $e');
      Log.e('Stack trace: $stackTrace');
      throw Exception('Error loading market information: $e');
    }
  }

  Future<MarketInfo> addMarketInfo({
    required String title,
    required String content,
    String? imageUrl,
    String? location,
    String? category,
    bool isActive = true,
    bool isFeatured = false,
  }) async {
    try {
      Log.d('Adding new market information with title: $title');

      final requestBody = {
        'title': title,
        'content': content,
        if (imageUrl != null) 'image_url': imageUrl,
        if (location != null) 'location': location,
        if (category != null) 'category': category,
        'is_active': isActive,
        'is_featured': isFeatured,
      };

      Log.d('Request body: ${json.encode(requestBody)}');

      final apiBaseUrl = baseUrl.replaceAll('/api', '');
      final endpoint = '${apiBaseUrl}/api/admin/market-info-create';

      Log.d('Adding market info at endpoint: $endpoint');

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

      Log.d('Add market info response status: ${response.statusCode}');
      Log.d('Add market info response body: ${response.body}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData is Map<String, dynamic>) {
          if (responseData.containsKey('data')) {
            Log.d('Successfully created market information');
            return MarketInfo.fromJson(responseData['data']);
          } else if (responseData.containsKey('id')) {
            Log.d('Successfully created market information (direct response)');
            return MarketInfo(
              id: responseData['id'],
              title: responseData['title'] ?? title,
              content: responseData['content'] ?? content,
              imageUrl: responseData['image_url'] ?? imageUrl,
              location: responseData['location'] ?? location,
              category: responseData['category'] ?? category,
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
              userId: responseData['user_id'] ?? 0,
              isActive: responseData['is_active'] ?? isActive,
              isFeatured: responseData['is_featured'] ?? isFeatured,
            );
          }
        }
        Log.e('Unexpected API response format: $responseData');
        throw Exception('Unexpected API response format');
      } else {
        Log.e(
            'Failed to add market information. Status code: ${response.statusCode}, Body: ${response.body}');
        throw Exception('Failed to add market information: ${response.body}');
      }
    } catch (e) {
      Log.e('Error in addMarketInfo: $e');
      throw Exception('Failed to add market information: $e');
    }
  }

  Future<MarketInfo> updateMarketInfo({
    required String id,
    required String title,
    required String content,
    String? imageUrl,
    String? location,
    String? category,
    bool? isActive,
    bool? isFeatured,
  }) async {
    final apiBaseUrl = baseUrl.replaceAll('/api', '');

    final requestBody = {
      'title': title,
      'content': content,
      if (imageUrl != null) 'image_url': imageUrl,
      if (location != null) 'location': location,
      if (category != null) 'category': category,
      if (isActive != null) 'is_active': isActive,
      if (isFeatured != null) 'is_featured': isFeatured,
    };

    final response = await http.put(
      Uri.parse('${apiBaseUrl}/api/admin/market-info-update/$id'),
      headers: {
        'Authorization': 'Bearer $_authToken',
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: json.encode(requestBody),
    );

    if (response.statusCode == 200) {
      return MarketInfo.fromJson(json.decode(response.body)['data']);
    } else {
      throw Exception('Failed to update market information');
    }
  }

  Future<void> deleteMarketInfo(String id) async {
    final apiBaseUrl = baseUrl.replaceAll('/api', '');

    final response = await http.delete(
      Uri.parse('${apiBaseUrl}/api/admin/market-info-delete/$id'),
      headers: {
        'Authorization': 'Bearer $_authToken',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to delete market information');
    }
  }

  Future<String> uploadMarketInfoImage(
      String marketInfoId, String imagePath) async {
    try {
      Log.d('Uploading market info image for ID: $marketInfoId');
      Log.d('Image path: $imagePath');

      if (imagePath.startsWith('blob:') && kIsWeb) {
        Log.d(
            'Blob URL detected in web environment - special handling required');
      }

      final apiBaseUrl = baseUrl.replaceAll('/api', '');
      final endpoint = '${apiBaseUrl}/api/admin/market-info-upload-image';

      Log.d('Uploading image to endpoint: $endpoint');

      final request = http.MultipartRequest(
        'POST',
        Uri.parse(endpoint),
      );

      request.headers.addAll({
        'Authorization': 'Bearer $_authToken',
        'Accept': 'application/json',
      });

      if (marketInfoId.isEmpty || marketInfoId == 'null') {
        throw Exception('Invalid market info ID: Cannot be empty or null');
      }

      if (marketInfoId == 'temp' ||
          marketInfoId == '0' ||
          marketInfoId == '-1') {
        Log.d(
            'Using default market info ID as placeholder for temporary upload');
        request.fields['market_info_id'] = '1';
        request.fields['is_temp'] = 'true';
      } else {
        try {
          int.parse(marketInfoId);
          request.fields['market_info_id'] = marketInfoId;
          Log.d('Using market info ID: $marketInfoId');
        } catch (e) {
          Log.e('Invalid market info ID format: $marketInfoId, error: $e');
          throw Exception('Invalid market info ID format: $marketInfoId');
        }
      }

      final imageFile = File(imagePath);

      try {
        final multipartFile =
            await ImageUploadHelper.prepareImageForUpload(imageFile);
        Log.d(
            'Image prepared successfully, content type: ${multipartFile.contentType}');
        Log.d('Image filename: ${multipartFile.filename}');

        request.files.add(multipartFile);
        request.fields['_method'] = 'POST';
      } catch (e) {
        Log.e('Error preparing image: $e');
        throw Exception('Failed to prepare image for upload: $e');
      }

      Log.d('Uploading image to: ${request.url}');
      Log.d('Request headers: ${request.headers}');

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      Log.d('Upload response status: ${response.statusCode}');
      Log.d('Upload response headers: ${response.headers}');
      Log.d('Upload response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);

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
      Log.e('Error uploading market info image: $e');
      Log.e('Stack trace: $stackTrace');
      throw Exception('Error uploading market info image: $e');
    }
  }
}
