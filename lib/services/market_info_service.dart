import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/market_info.dart';
import 'api_service.dart';
import '../utils/logger.dart';

class MarketInfoService {
  final ApiService _apiService;

  MarketInfoService(this._apiService);

  Future<List<MarketInfo>> getMarketInfo() async {
    try {
      final uri = Uri.parse('${_apiService.baseUrl}/market-info');
      Log.d('MarketInfoService: Fetching market info from: $uri');

      final response = await http.get(
        uri,
        headers: _apiService.headers,
      );

      Log.d('MarketInfoService: Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body)['data'];
        final marketInfoList =
            data.map((json) => MarketInfo.fromJson(json)).toList();
        Log.d(
            'MarketInfoService: Successfully parsed ${marketInfoList.length} market info items');
        return marketInfoList;
      } else {
        // If the user is not authenticated, the API will return a 401.
        // In this case, we should return an empty list instead of throwing an error.
        if (response.statusCode == 401) {
          return [];
        }
        Log.e(
            'MarketInfoService: Failed to load market info. Status code: ${response.statusCode}, Body: ${response.body}');
        throw Exception('Failed to load market information');
      }
    } catch (e) {
      Log.e('MarketInfoService: Error fetching market info: $e');
      rethrow;
    }
  }

  Future<MarketInfo> addMarketInfo({
    required String title,
    required String description,
    required String content,
    required String contact,
    String? location,
    String? category,
    String? imageUrl,
  }) async {
    try {
      final url = Uri.parse('${_apiService.baseUrl}/market-info');
      final response = await http.post(
        url,
        headers: _apiService.headers,
        body: jsonEncode({
          'title': title,
          'description': description,
          'content': content,
          'contact': contact,
          'location': location,
          'category': category,
          'image_url': imageUrl,
        }),
      );

      if (response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        // The API might return the created object inside a 'data' key
        final marketInfoJson = responseData.containsKey('data')
            ? responseData['data']
            : responseData;
        return MarketInfo.fromJson(marketInfoJson);
      } else {
        Log.e(
            'Failed to add market info. Status: ${response.statusCode}, Body: ${response.body}');
        throw Exception('Failed to add market information');
      }
    } catch (e) {
      Log.e('Error adding market info: $e');
      rethrow;
    }
  }

  Future<MarketInfo> updateMarketInfo({
    required String id,
    required String title,
    required String description,
    required String content,
    String? imageUrl,
    String? location,
    String? category,
  }) async {
    try {
      final url = Uri.parse('${_apiService.baseUrl}/market-info/$id');
      final response = await http.put(
        url,
        headers: _apiService.headers,
        body: jsonEncode({
          'title': title,
          'description': description,
          'content': content,
          'image_url': imageUrl,
          'location': location,
          'category': category,
        }),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final marketInfoJson = responseData.containsKey('data')
            ? responseData['data']
            : responseData;
        return MarketInfo.fromJson(marketInfoJson);
      } else {
        Log.e(
            'Failed to update market info. Status: ${response.statusCode}, Body: ${response.body}');
        throw Exception('Failed to update market information');
      }
    } catch (e) {
      Log.e('Error updating market info: $e');
      rethrow;
    }
  }

  Future<void> deleteMarketInfo(String id) async {
    try {
      final url = Uri.parse('${_apiService.baseUrl}/market-info/$id');
      final response = await http.delete(url, headers: _apiService.headers);

      if (response.statusCode != 200 && response.statusCode != 204) {
        Log.e(
            'Failed to delete market info. Status: ${response.statusCode}, Body: ${response.body}');
        throw Exception('Failed to delete market information');
      }
    } catch (e) {
      Log.e('Error deleting market info: $e');
      rethrow;
    }
  }

  Future<String> uploadMarketInfoImage(String id, String imagePath) async {
    final url =
        Uri.parse('${_apiService.baseUrl}/market-info/$id/upload-image');
    final request = http.MultipartRequest('POST', url);
    request.headers.addAll(_apiService.headers);
    request.files.add(await http.MultipartFile.fromPath('image', imagePath));

    final response = await request.send();
    if (response.statusCode == 200) {
      final responseBody = await response.stream.bytesToString();
      return jsonDecode(responseBody)['image_url'];
    } else {
      throw Exception('Failed to upload image');
    }
  }
}
