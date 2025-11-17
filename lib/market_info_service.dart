import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:masoko_tips/services/api_service.dart';
import '../models/market_info.dart';
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
        throw Exception('Failed to load market information');
      }
    } catch (e) {
      Log.e('MarketInfoService: Error fetching market info: $e');
      rethrow;
    }
  }
}
