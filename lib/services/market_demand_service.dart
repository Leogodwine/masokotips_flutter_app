import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';
import '../models/buying_request.dart';

class MarketDemandService {
  Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final headers = {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };

    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }

    return headers;
  }

  Future<List<BuyingRequest>> getMarketDemands({String? search, int page = 1}) async {
    try {
      var url = '${ApiConfig.baseUrl}/market-demands?page=$page';
      if (search != null && search.isNotEmpty) {
        url += '&search=${Uri.encodeComponent(search)}';
      }

      final response = await http.get(
        Uri.parse(url),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'success' && data['data'] != null) {
          return (data['data'] as List)
              .map((json) => BuyingRequest.fromJson(json))
              .toList();
        }
        return [];
      } else {
        throw Exception('Failed to load market demands');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<Map<String, dynamic>> getDemandDetails(int id) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/market-demands/$id'),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'request': BuyingRequest.fromJson(data['data']),
          'hasSubscription': data['has_subscription'] ?? false,
        };
      } else {
        throw Exception('Failed to load demand details');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
}
