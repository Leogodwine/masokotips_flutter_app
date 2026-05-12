import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/product.dart';
import '../models/organic_product.dart';
import '../models/transport.dart';
import '../models/service.dart';
import '../services/api_service.dart';
import '../config/api_config.dart';
import '../utils/api_response.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SearchResult {
  final List<Product> products;
  final List<OrganicProduct> organicProducts;
  final List<Transport> transports;
  final List<Service> services;

  SearchResult({
    this.products = const [],
    this.organicProducts = const [],
    this.transports = const [],
    this.services = const [],
  });

  static SearchResult fromMultipleJson(
    List<dynamic> productsJson,
    List<dynamic> organicJson,
    List<dynamic> transportsJson,
    List<dynamic> servicesJson,
  ) {
    return SearchResult(
      products: productsJson.map((p) => Product.fromJson(p)).toList(),
      organicProducts:
          organicJson.map((p) => OrganicProduct.fromJson(p)).toList(),
      transports: transportsJson.map((t) => Transport.fromJson(t)).toList(),
      services: servicesJson.map((s) => Service.fromJson(s)).toList(),
    );
  }

  int get totalCount =>
      products.length +
      organicProducts.length +
      transports.length +
      services.length;

  bool get isEmpty => totalCount == 0;

  double get minPrice {
    double min = double.infinity;
    for (var p in products) {
      if (p.price < min) min = p.price;
    }
    for (var p in organicProducts) {
      if (p.price < min) min = p.price;
    }
    for (var t in transports) {
      final price = t.price;
      if (price > 0 && price < min) min = price;
    }
    for (var s in services) {
      if (s.price < min) min = s.price;
    }
    return min == double.infinity ? 0 : min;
  }

  double get maxPrice {
    double max = 0;
    for (var p in products) {
      if (p.price > max) max = p.price;
    }
    for (var p in organicProducts) {
      if (p.price > max) max = p.price;
    }
    for (var t in transports) {
      final price = t.price;
      if (price > max) max = price;
    }
    for (var s in services) {
      if (s.price > max) max = s.price;
    }
    return max;
  }
}

class SearchProvider with ChangeNotifier {
  final ApiService _apiService;
  SearchResult? _searchResult;
  bool _isLoading = false;
  String? _error;
  List<String> _searchHistory = [];
  static const int _maxHistoryItems = 10;
  static const String _historyKey = 'search_history';

  SearchProvider({ApiService? apiService})
      : _apiService = apiService ??
            ApiService(
              baseUrl: ApiConfig.baseUrl,
              apiKey: ApiConfig.apiKey,
            ) {
    _loadHistory();
  }

  static String get baseUrl => ApiConfig.baseUrl;

  SearchResult? get searchResult => _searchResult;
  bool get isLoading => _isLoading;
  String? get error => _error;
  List<String> get searchHistory => _searchHistory;

  Future<void> _loadHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final history = prefs.getStringList(_historyKey);
      if (history != null) {
        _searchHistory = history;
      }
    } catch (e) {
      // Ignore history loading errors
    }
  }

  Future<void> _saveHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_historyKey, _searchHistory);
    } catch (e) {
      // Ignore history saving errors
    }
  }

  Future<void> addToHistory(String query) async {
    if (query.isEmpty) return;

    _searchHistory.remove(query);
    _searchHistory.insert(0, query);

    if (_searchHistory.length > _maxHistoryItems) {
      _searchHistory = _searchHistory.sublist(0, _maxHistoryItems);
    }

    await _saveHistory();
    notifyListeners();
  }

  Future<void> removeFromHistory(String query) async {
    _searchHistory.remove(query);
    await _saveHistory();
    notifyListeners();
  }

  Future<void> clearHistory() async {
    _searchHistory = [];
    await _saveHistory();
    notifyListeners();
  }

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
      final headers = _apiService.headers;
      final encodedQuery = Uri.encodeComponent(query);

      final responses = [
        await http.get(Uri.parse('$baseUrl/products?search=$encodedQuery&per_page=20'), headers: headers),
        await http.get(Uri.parse('$baseUrl/public/organic-products?search=$encodedQuery&per_page=20'), headers: headers),
        await http.get(Uri.parse('$baseUrl/public/transports?search=$encodedQuery&per_page=20'), headers: headers),
        await http.get(Uri.parse('$baseUrl/services/featured'), headers: headers),
      ];

      List<dynamic> products = [];
      List<dynamic> organicProducts = [];
      List<dynamic> transports = [];
      List<dynamic> services = [];

      for (var i = 0; i < responses.length; i++) {
        if (responses[i].statusCode == 200) {
          try {
            final data = ApiResponse.decodeJson(responses[i].body);
            List<dynamic> items = [];

            if (data['data'] is List) {
              items = data['data'];
            } else if (data['data'] is Map && data['data']['data'] is List) {
              items = data['data']['data'];
            }

            if (data['success'] == false &&
                data['data'] is Map &&
                data['data']['data'] is List) {
              items = data['data']['data'];
            }

            switch (i) {
              case 0:
                products = items;
                break;
              case 1:
                organicProducts = items;
                break;
              case 2:
                transports = items;
                break;
              case 3:
                services = items.where((s) {
                  final title = s['title']?.toString().toLowerCase() ?? '';
                  final desc = s['description']?.toString().toLowerCase() ?? '';
                  return title.contains(encodedQuery.toLowerCase()) ||
                      desc.contains(encodedQuery.toLowerCase());
                }).toList();
                break;
            }
          } catch (e) {
            // Skip parsing errors for individual endpoints
          }
        }
      }

      _searchResult = SearchResult.fromMultipleJson(
        products,
        organicProducts,
        transports,
        services,
      );
      _error = null;

      await addToHistory(query);
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
