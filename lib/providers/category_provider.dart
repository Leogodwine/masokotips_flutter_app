import 'package:flutter/foundation.dart';
//import 'package:http/http.dart' as http;
//import 'dart:convert';
import '../models/category.dart' as models;
import '../config/api_config.dart';
import '../utils/logger.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';

class CategoryProvider with ChangeNotifier {
  final ApiService _apiService;
  final AuthService _authService;
  List<models.Category> _mainCategories = [];
  List<models.Category> _subcategories = [];
  bool _isLoading = false;
  String? _error;

  CategoryProvider({ApiService? apiService, AuthService? authService})
      : _apiService = apiService ??
            ApiService(
              baseUrl: ApiConfig.baseUrl,
              apiKey: ApiConfig.apiKey,
            ),
        _authService = authService ?? AuthService();

  // Getters
  List<models.Category> get mainCategories => _mainCategories;
  List<models.Category> get subcategories => _subcategories;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Load main categories
  Future<void> loadMainCategories() async {
    Log.i('CategoryProvider: Starting to load categories...');

    if (_isLoading) {
      Log.i('CategoryProvider: Already loading, skipping duplicate request');
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final token = await _authService.getToken();
      Log.i('CategoryProvider: Token available: ${token != null}');

      final response = await _apiService.getCategories();
      Log.i('CategoryProvider: ${response.length} categories fetched');

      if (response.isEmpty) {
        Log.w('CategoryProvider: No categories returned');
        _error = 'No categories available from the server';
        _mainCategories = [];
      } else {
        // The /api/main-categories endpoint already returns only main categories
        // No need to filter by parentId or build hierarchy
        _mainCategories = response;

        Log.i(
            'CategoryProvider: ${_mainCategories.length} main categories loaded');
        for (var category in _mainCategories) {
          Log.d(
              'CategoryProvider: Main category: ${category.name} (ID: ${category.id}) with ${category.subcategoriesCount} subcategories');
        }

        _error = null;
      }
    } catch (e, stackTrace) {
      Log.e('CategoryProvider: Error loading categories: $e');
      Log.e('Stack trace: $stackTrace');
      _error = 'Error loading categories: $e';
      _mainCategories = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load subcategories for a specific category from API
  Future<void> loadSubcategories(int categoryId) async {
    Log.i(
        'CategoryProvider: Starting to load subcategories for category: $categoryId');

    // Don't reload if already loading
    if (_isLoading) {
      Log.i('CategoryProvider: Already loading subcategories, skipping');
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Find the category in our loaded list to check its name/slug
      final category = _mainCategories.firstWhere(
        (c) => c.id == categoryId,
        orElse: () => models.Category(id: categoryId, name: ''),
      );

      final isAgriServices = category.slug == 'agricultural-services' || 
                            category.name.toLowerCase().contains('agricultural services');
      final isTransport = category.slug == 'transport' || 
                         category.name.toLowerCase().contains('transport');

      if (isAgriServices) {
        // Special handling for Agricultural Services
        Log.i(
            'CategoryProvider: Using dedicated endpoint for Agricultural Services');
        final response = await _apiService.getAgriculturalServiceCategories();
        _subcategories = response;
        _error = null;
      } else if (isTransport) {
        // Special handling for Transport
        // Use the dedicated endpoint to avoid 404 issues
        Log.i('CategoryProvider: Using dedicated endpoint for Transport');
        final response = await _apiService.getTransportSubcategories();
        _subcategories = response;
        _error = null;
      } else {
        // For other known categories (Products, Market Info, Organic Products)
        // Try the generic endpoint but handle 404 gracefully
        Log.i(
            'CategoryProvider: Using generic endpoint for category $categoryId');
        try {
          final response = await _apiService.getSubcategories(categoryId);
          _subcategories = response;
          _error = null;
        } catch (e) {
          // If 404, just set empty subcategories
          if (e.toString().contains('404')) {
            Log.w(
                'CategoryProvider: No subcategories found for category $categoryId');
            _subcategories = [];
            _error = null;
          } else {
            rethrow;
          }
        }
      }

      if (_subcategories.isEmpty && _error == null) {
        // Fallback or additional logic if subcategories are still empty
        // Find the category in the loaded mainCategories list from API
        final category = _mainCategories.firstWhere(
          (cat) => cat.id == categoryId,
          orElse: () =>
              throw Exception('Category not found with ID: $categoryId'),
        );

        // If the category already has subcategories loaded, use them
        if (category.subcategories != null &&
            category.subcategories!.isNotEmpty) {
          _subcategories = category.subcategories!;
          Log.i(
              'CategoryProvider: Loaded ${_subcategories.length} subcategories from cached data');
          debugPrint('CategoryProvider: Cached subcategories: $_subcategories');
        } else {
          // Load subcategories from API
          Log.i(
              'CategoryProvider: Making API call to get subcategories for category $categoryId');
          debugPrint(
              'CategoryProvider: Making API call to get subcategories for category $categoryId');
          try {
            final response = await _apiService.getSubcategories(categoryId);
            _subcategories = response;

            // Update the category with loaded subcategories for future use
            category.subcategories = response;

            Log.i(
                'CategoryProvider: Loaded ${_subcategories.length} subcategories from API');
            debugPrint(
                'CategoryProvider: API response subcategories: $_subcategories');
          } catch (e) {
            // Handle 404 gracefully - category might not have subcategories
            if (e.toString().contains('404')) {
              Log.w(
                  'CategoryProvider: No subcategories found for category $categoryId');
              _subcategories = [];
              _error = null;
            } else {
              rethrow;
            }
          }
        }
      }

      for (var subcategory in _subcategories) {
        Log.d(
            'CategoryProvider: Subcategory: ${subcategory.name} (ID: ${subcategory.id})');
      }
      _error = null;
    } catch (e) {
      Log.e('CategoryProvider: Error loading subcategories: $e');
      _error = 'Error: $e';
      _subcategories = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Get subcategories for a specific category
  List<models.Category> getSubcategories(int parentId) {
    try {
      final parentCategory =
          _mainCategories.firstWhere((category) => category.id == parentId);
      return parentCategory.subcategories ?? [];
    } catch (e) {
      Log.e('CategoryProvider: Error getting subcategories: $e');
      return [];
    }
  }

  // Get a category by ID
  models.Category? getCategoryById(int id) {
    try {
      return _mainCategories.firstWhere((category) => category.id == id);
    } catch (e) {
      Log.e('CategoryProvider: Category not found with ID: $id');
      return null;
    }
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Clear subcategories
  void clearSubcategories() {
    _subcategories = [];
    notifyListeners();
  }

  // Load Transport-specific subcategories for Add Transport screen
  Future<void> loadTransportSubcategories() async {
    Log.i('CategoryProvider: Starting to load Transport subcategories...');

    if (_isLoading) {
      Log.i('CategoryProvider: Already loading subcategories, skipping');
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      Log.i('CategoryProvider: Making API call to get Transport subcategories');
      final response = await _apiService.getTransportSubcategories();
      _subcategories = response;

      Log.i('CategoryProvider: Loaded  Transport subcategories from API');
      for (var subcategory in _subcategories) {
        Log.d(
            'CategoryProvider: Transport Subcategory: ${subcategory.name} (ID: ${subcategory.id})');
      }
      _error = null;
    } catch (e) {
      Log.e('CategoryProvider: Error loading Transport subcategories: $e');
      _error = 'Error: $e';
      _subcategories = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load Agricultural Services subcategories
  Future<void> loadAgriculturalServicesSubcategories() async {
    Log.i(
        'CategoryProvider: Starting to load Agricultural Services subcategories...');

    if (_isLoading) {
      Log.i('CategoryProvider: Already loading subcategories, skipping');
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      Log.i(
          'CategoryProvider: Making API call to get Agricultural Services subcategories');
      final response = await _apiService.getAgriculturalServiceCategories();
      _subcategories = response;

      Log.i(
          'CategoryProvider: Loaded Agricultural Services subcategories from API');
      for (var subcategory in _subcategories) {
        Log.d(
            'CategoryProvider: Agricultural Services Subcategory: ${subcategory.name} (ID: ${subcategory.id})');
      }
      _error = null;
    } catch (e) {
      Log.e(
          'CategoryProvider: Error loading Agricultural Services subcategories: $e');
      _error = 'Error: $e';
      _subcategories = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
