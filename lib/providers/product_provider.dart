import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/product.dart';
import '../services/api_service.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/logger.dart';
import '../config/api_config.dart';

class ProductProvider with ChangeNotifier {
  final ApiService _apiService;
  List<Product> _products = [];
  List<Product> _featuredProducts = [];
  List<Product> _relatedProducts = [];
  List<Product> _searchResults = [];
  bool _isLoading = false;
  String? _error;

  ProductProvider({ApiService? apiService})
      : _apiService = apiService ??
            ApiService(
              baseUrl: ApiConfig.baseUrl,
              apiKey: ApiConfig.apiKey,
            );

  // API Base URL
  static String get baseUrl => ApiConfig.baseUrl;

  // Cache key
  static const String _productsKey = 'cached_products';

  // Getters
  List<Product> get products => _products;
  List<Product> get featuredProducts => _featuredProducts;
  List<Product> get relatedProducts => _relatedProducts;
  List<Product> get searchResults => _searchResults;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Set auth token
  void setAuthToken(String token) {
    _apiService.setAuthToken(token);
  }

  // Get featured products
  Future<void> getFeaturedProducts() async {
    try {
      _setLoadingState(true);

      Log.e('ProductProvider: Fetching featured products...');
      _featuredProducts = await _apiService.getFeaturedProducts();

      // Log each product's image URL
      for (var product in _featuredProducts) {
        Log.e(
            'ProductProvider: Featured product image URL: ${product.imageUrl}');
      }

      Log.e(
          'ProductProvider: Successfully fetched ${_featuredProducts.length} featured products');
    } catch (e, stackTrace) {
      Log.e('ProductProvider: Error loading featured products: $e');
      Log.e('ProductProvider: Stack trace: $stackTrace');
      _setErrorState('Failed to load featured products: $e');
    } finally {
      _setLoadingState(false);
    }
  }

  // Get related products
  Future<List<Product>> getRelatedProducts(int productId) async {
    try {
      Log.e(
          'ProductProvider: Starting to fetch related products for product: $productId');
      _setLoadingState(true);

      _relatedProducts = await _apiService.getRelatedProducts(productId);
      Log.e(
          'ProductProvider: Successfully fetched ${_relatedProducts.length} related products');

      // Log details of each related product
      for (var product in _relatedProducts) {
        Log.e(
            'ProductProvider: Related product - ID: ${product.id}, Name: ${product.name}');
      }

      return _relatedProducts;
    } catch (e, stackTrace) {
      Log.e('ProductProvider: Error fetching related products: $e');
      Log.e('ProductProvider: Stack trace: $stackTrace');
      _setErrorState(e.toString());
      throw Exception('Failed to fetch related products: $e');
    } finally {
      _setLoadingState(false);
    }
  }

  // Load products by category
  Future<void> loadProductsByCategory(int categoryId, String subcategory,
      {String? categoryName}) async {
    _setLoadingState(true);

    try {
      Log.e(
          'Loading products for category: $categoryId, subcategory: $subcategory, categoryName: $categoryName');

      if (categoryName?.toLowerCase() == 'organic products') {
        // Load organic products for organic categories
        final organicProductsData = await _apiService
            .getOrganicProductsByCategory(categoryId, subcategory);
        Log.e('Loaded ${organicProductsData.length} organic products');

        // Convert organic products data to Product objects for display
        _products =
            organicProductsData.map((data) => Product.fromJson(data)).toList();
      } else {
        // Load regular products for other categories
        final products =
            await _apiService.getProductsByCategory(categoryId, subcategory);
        _products = products;
        Log.e('Loaded ${products.length} regular products');
      }
    } catch (e) {
      Log.e('Error loading products: $e');
      _setErrorState(e.toString());
    } finally {
      _setLoadingState(false);
    }
  }

  // Load all products
  Future<void> loadProducts() async {
    try {
      _setLoadingState(true);

      _products = await _apiService.getProducts();
      await _cacheProducts();
    } catch (e) {
      _setErrorState('Failed to load products: $e');
      debugPrint(_error);
    } finally {
      _setLoadingState(false);
    }
  }

  // Helper to set loading state
  void _setLoadingState(bool isLoading) {
    _isLoading = isLoading;
    if (!kDebugMode) {
      notifyListeners();
    } else {
      Future.microtask(() => notifyListeners());
    }
  }

  // Helper to set error state
  void _setErrorState(String error) {
    _error = error;
    if (!kDebugMode) {
      notifyListeners();
    } else {
      Future.microtask(() => notifyListeners());
    }
  }

  // Get product details by ID
  Future<Product?> getProductDetails(int productId) async {
    try {
      return await _apiService.getProductDetails(productId);
    } catch (e) {
      _error = 'Failed to fetch product details: $e';
      debugPrint(_error);
      return null;
    }
  }

  // Search products
  Future<List<Product>> searchProducts(String query) async {
    try {
      final url = Uri.parse('$baseUrl/products/search?q=$query');
      final response = await http.get(
        url,
        headers: await _getAuthHeaders(),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        _searchResults = data.map((json) => Product.fromJson(json)).toList();
        return _searchResults;
      } else {
        throw Exception(
            'Failed to search products. Status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error searching products: $e');
    }
  }

  // Cache products locally
  Future<void> _cacheProducts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final productsJson = _products.map((p) => p.toJson()).toList();
      await prefs.setString(_productsKey, json.encode(productsJson));
    } catch (e) {
      debugPrint('Error caching products: $e');
    }
  }

  // Load cached products
  Future<void> loadCachedProducts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final productsJson = prefs.getString(_productsKey);

      if (productsJson != null) {
        final List<dynamic> decodedProducts = json.decode(productsJson);
        _products = decodedProducts.map((p) => Product.fromJson(p)).toList();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading cached products: $e');
    }
  }

  // Generate authentication headers
  Future<Map<String, String>> _getAuthHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // Clear errors
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Add a new product
  Future<void> addProduct(Product product) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _apiService.addProduct(product);
      _products.add(product);
    } catch (e) {
      _error = 'Failed to add product: $e';
      debugPrint(_error);
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadFeaturedProducts() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      Log.e('Loading featured products');
      final products = await _apiService.getFeaturedProducts();
      _featuredProducts = products;
      Log.e('Loaded ${products.length} featured products');
    } catch (e) {
      Log.e('Error loading featured products: $e');
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadRelatedProducts(int productId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      Log.e('Loading related products for product: $productId');
      final products = await _apiService.getRelatedProducts(productId);
      _relatedProducts = products;
      Log.e('Loaded ${products.length} related products');
    } catch (e) {
      Log.e('Error loading related products: $e');
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearProducts() {
    _products = [];
    _error = null;
    notifyListeners();
  }
}
