import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:http/http.dart' as http;
import '../models/market_info.dart';
import '../utils/logger.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
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
      final endpoint = '$apiBaseUrl/api/admin/market-info-list';

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

          if (data is List) {
            Log.d('Market info JSON array length: ${data.length}');
            final List<MarketInfo> result = [];
            for (var item in data) {
              try {
                if (item is Map<String, dynamic>) {
                  // Map the API response fields to the MarketInfo model fields
                  final marketInfoData = {
                    'id': item['id'],
                    'title': item['title'],
                    'content':
                        item['description'], // Map description to content
                    'imageUrl': item['image_url'],
                    'location': item['location'],
                    'createdAt': item['created_at'],
                    'updatedAt': item['updated_at'],
                    'userId': item['user_id'],
                    'isActive': item['is_active'],
                    'isFeatured': item['is_featured'],
                  };
                  result.add(MarketInfo.fromJson(marketInfoData));
                } else {
                  Log.e('Invalid item format: $item');
                }
              } catch (e) {
                Log.e('Error parsing market info item: $e');
              }
            }
            return result;
          } else {
            Log.d('Response is not a list, returning empty array');
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
    required String description,
    required String contact,
    String? imageUrl,
    String? location,
    bool isActive = true,
    bool isFeatured = false,
  }) async {
    try {
      Log.d('Adding new market information with title: $title');

      final requestBody = {
        'title': title,
        'description': description,
        'contact': contact,
        if (imageUrl != null) 'image': imageUrl,
        if (location != null) 'location': location,
        'is_active': isActive,
        'is_featured': isFeatured,
      };

      Log.d('Request body: ${json.encode(requestBody)}');

      final apiBaseUrl = baseUrl.replaceAll('/api', '');
      final endpoint = '$apiBaseUrl/api/admin/market-info';

      Log.d('Adding market info at endpoint: $endpoint');

      final response = await http.post(
        Uri.parse(endpoint),
        headers: {
          'Authorization': 'Bearer $_authToken',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: json.encode(requestBody),
      );

      Log.d('Add market info response status: ${response.statusCode}');
      Log.d('Add market info response body: ${response.body}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData is Map<String, dynamic>) {
          // Create a proper MarketInfo object from the response
          final marketInfoData = {
            'id': responseData['id'],
            'title': responseData['title'] ?? title,
            'content': responseData['description'] ?? description,
            'imageUrl': responseData['image'] ?? imageUrl,
            'location': responseData['location'] ?? location,
            'createdAt':
                responseData['created_at'] ?? DateTime.now().toIso8601String(),
            'updatedAt':
                responseData['updated_at'] ?? DateTime.now().toIso8601String(),
            'userId': responseData['user_id'] ?? 0,
            'isActive': responseData['is_active'] ?? isActive,
            'isFeatured': responseData['is_featured'] ?? isFeatured,
          };
          Log.d('Successfully created market information (direct response)');
          return MarketInfo.fromJson(marketInfoData);
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
      Uri.parse('$apiBaseUrl/api/admin/market-info-update/$id'),
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
      Uri.parse('$apiBaseUrl/api/admin/market-info-delete/$id'),
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

      final apiBaseUrl = baseUrl.replaceAll('/api', '');
      final endpoint = '$apiBaseUrl/api/admin/market-info/$marketInfoId/image';

      Log.d('Upload endpoint: $endpoint');

      if (kIsWeb) {
        // For web platform, we need to convert the image path to a File object
        final bytes = await http.get(Uri.parse(imagePath));
        final file = http.MultipartFile.fromBytes(
          'image',
          bytes.bodyBytes,
          filename: 'market_info_$marketInfoId.jpg',
        );

        final request = http.MultipartRequest('POST', Uri.parse(endpoint))
          ..headers.addAll({
            'Authorization': 'Bearer $_authToken',
            'Accept': 'application/json',
          })
          ..files.add(file);

        final response = await request.send();
        final responseBody = await response.stream.bytesToString();

        if (response.statusCode == 200) {
          final data = json.decode(responseBody);
          return data['image_url'] ?? data['image'];
        } else {
          throw Exception('Failed to upload image: $responseBody');
        }
      } else {
        // For non-web platforms
        final file = File(imagePath);
        final request = http.MultipartRequest('POST', Uri.parse(endpoint))
          ..headers.addAll({
            'Authorization': 'Bearer $_authToken',
            'Accept': 'application/json',
          })
          ..files.add(await http.MultipartFile.fromPath('image', file.path));

        final response = await request.send();
        final responseBody = await response.stream.bytesToString();

        if (response.statusCode == 200) {
          final data = json.decode(responseBody);
          return data['image_url'] ?? data['image'];
        } else {
          throw Exception('Failed to upload image: $responseBody');
        }
      }
    } catch (e) {
      Log.e('Error uploading market info image: $e');
      throw Exception('Failed to upload market info image: $e');
    }
  }
}
