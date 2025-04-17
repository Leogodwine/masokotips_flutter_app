import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:http/http.dart' as http;
import '../models/market_info.dart';
import '../utils/logger.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../config/api_config.dart';
import 'package:masoko_tips/services/api_service.dart';

class MarketInfoService {
  final ApiService _apiService;
  String? _authToken;

  MarketInfoService({ApiService? apiService})
      : _apiService = apiService ??
            ApiService(
              baseUrl: ApiConfig.baseUrl,
              apiKey: ApiConfig.apiKey,
            );

  void setAuthToken(String token) {
    _authToken = token;
    Log.d('Auth token set in MarketInfoService: ${token.substring(0, 10)}...');
  }

  Future<List<MarketInfo>> getAllMarketInfo() async {
    final response = await _apiService.get(
      '/market-info',
      headers: {'Authorization': 'Bearer $_authToken'},
    );
    return (response as List).map((json) => MarketInfo.fromJson(json)).toList();
  }

  Future<MarketInfo> addMarketInfo({
    required String title,
    required String description,
    required String content,
    String? imageUrl,
    String? location,
    String? category,
    String? contact,
    String? userId,
    bool isActive = true,
    bool isFeatured = false,
  }) async {
    final response = await _apiService.post(
      '/market-info',
      headers: {'Authorization': 'Bearer $_authToken'},
      body: {
        'title': title,
        'description': description,
        'content': content,
        'image_url': imageUrl,
        'location': location,
        'category': category,
        'contact': contact,
        'user_id': userId,
        'is_active': isActive,
        'is_featured': isFeatured,
      },
    );
    return MarketInfo.fromJson(response);
  }

  Future<MarketInfo> updateMarketInfo({
    required String id,
    required String title,
    required String description,
    required String content,
    String? imageUrl,
    String? location,
    String? category,
    String? contact,
    String? userId,
    bool? isActive,
    bool? isFeatured,
  }) async {
    final response = await _apiService.put(
      '/market-info/$id',
      headers: {'Authorization': 'Bearer $_authToken'},
      body: {
        'title': title,
        'description': description,
        'content': content,
        'image_url': imageUrl,
        'location': location,
        'category': category,
        'contact': contact,
        'user_id': userId,
        'is_active': isActive,
        'is_featured': isFeatured,
      },
    );
    return MarketInfo.fromJson(response);
  }

  Future<void> deleteMarketInfo(String id) async {
    await _apiService.delete(
      '/market-info/$id',
      headers: {'Authorization': 'Bearer $_authToken'},
    );
  }

  Future<String> uploadMarketInfoImage(
      String marketInfoId, String imagePath) async {
    try {
      Log.d('Uploading market info image for ID: $marketInfoId');
      Log.d('Image path: $imagePath');

      final apiBaseUrl = ApiConfig.baseUrl.replaceAll('/api', '');
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
