import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/product.dart';
import '../models/organic_product.dart';
import '../models/service.dart';
import '../models/transport.dart';
import '../models/market_info.dart';
import '../services/api_service.dart';
import 'dart:convert';
import '../config/api_config.dart';

class SearchResult {
  final List<Product> products;
  final List<OrganicProduct> organicProducts;
  final List<Service> services;
  final List<Transport> transports;
  final List<MarketInfo> marketInfo;

  SearchResult({
    this.products = const [],
    this.organicProducts = const [],
    this.services = const [],
    this.transports = const [],
    this.marketInfo = const [],
  });

  factory SearchResult.fromJson(Map<String, dynamic> json) {
    return SearchResult(
      products: (json['products'] as List<dynamic>?)
          ?.map((p) => Product.fromJson(p))
          .toList() ?? [],
      organicProducts: (json['organic_products'] as List<dynamic>?)
          ?.map((p) => OrganicProduct.fromJson(p))
          .toList() ?? [],
      services: (json['services'] as List<dynamic>?)
          ?.map((s) => Service.fromJson(s))
          .toList() ?? [],
      transports: (json['transports'] as List<dynamic>?)
          ?.map((t) => Transport.fromJson(t))
          .toList() ?? [],
      marketInfo: (json['market_info'] as List<dynamic>?)
          ?.map((m) => MarketInfo.fromJson(m))
          .toList() ?? [],
    );
  }

  int get totalCount =>
      products.length +
      organicProducts.length +
      services.length +
      transports.length +
      marketInfo.length;

  bool get isEmpty => totalCount == 0;
}

class SearchProvider with ChangeNotifier {
  final ApiService _apiService;
  SearchResult? _searchResult;
  bool _isLoading = false;
  String? _error;

  SearchProvider({ApiService? apiService})
      : _apiService = apiService ??
            ApiService(
              baseUrl: ApiConfig.baseUrl,
              apiKey: ApiConfig.apiKey,
            );

  static String get baseUrl => ApiConfig.baseUrl;

  SearchResult? get searchResult => _searchResult;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<SearchResult> search(String query) async {
    if (query.isEmpty) {
      _searchResult = SearchResult();
      notifyListeners();
      return _searchResult!;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final url = Uri.parse('$baseUrl/api/search?q=${Uri.encodeComponent(query)}');
      final response = await http.get(
        url,
        headers: _apiService.headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _searchResult = SearchResult.fromJson(data['data']);
        _error = null;
      } else {
        _error = 'Failed to search. Status code: ${response.statusCode}';
        _searchResult = SearchResult();
      }
    } catch (e) {
      _error = 'Error searching: $e';
      _searchResult = SearchResult();
    }

    _isLoading = false;
    notifyListeners();
    return _searchResult!;
  }

  void clear() {
    _searchResult = null;
    _error = null;
    notifyListeners();
  }
}