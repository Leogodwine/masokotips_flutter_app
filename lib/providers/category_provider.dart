import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/category.dart' as models;
import '../config/api_config.dart';
import '../utils/logger.dart';
import '../services/api_service.dart';

class CategoryProvider with ChangeNotifier {
  final ApiService _apiService;
  List<models.Category> _mainCategories = [];
  List<models.Category> _subcategories = [];
  bool _isLoading = false;
  String? _error;

  CategoryProvider({ApiService? apiService})
      : _apiService = apiService ??
            ApiService(
              baseUrl: ApiConfig.baseUrl,
              apiKey: ApiConfig.apiKey,
            );

  // Getters
  List<models.Category> get mainCategories => _mainCategories;
  List<models.Category> get subcategories => _subcategories;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Load categories
  Future<void> loadMainCategories() async {
    Log.e('CategoryProvider: Starting to load categories...');
    Log.e(
        'CategoryProvider: Current state - isLoading: $_isLoading, categories count: ${_mainCategories.length}');

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Try to load categories from API first
      Log.e('CategoryProvider: Fetching categories from API...');
      final response = await _apiService.getCategories();
      Log.e(
          'CategoryProvider: API Response: ${response.length} categories received');

      if (response.isEmpty) {
        Log.e(
            'CategoryProvider: No categories received from API, using fallback data');
        _mainCategories = models.mainCategories;
        _error = 'Using offline data';
        notifyListeners();
        return;
      }

      // Create a map of all categories
      final Map<int, models.Category> categoryMap = {};
      for (var category in response) {
        categoryMap[category.id] = category;
        Log.e(
            'CategoryProvider: Category: ${category.name} (ID: ${category.id}, Parent: ${category.parentId})');
      }

      // Build the hierarchy
      for (var category in response) {
        if (category.parentId != null) {
          final parent = categoryMap[category.parentId];
          if (parent != null) {
            parent.children ??= [];
            parent.children!.add(category);
            Log.e(
                'CategoryProvider: Added ${category.name} as child to ${parent.name}');
          }
        }
      }

      // Get only main categories (those without parent)
      _mainCategories =
          response.where((category) => category.parentId == null).toList();
      Log.e(
          'CategoryProvider: Main categories count: ${_mainCategories.length}');

      // Sort main categories by sortOrder
      _mainCategories.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

      // Sort children of each category by sortOrder
      for (var category in _mainCategories) {
        if (category.children != null) {
          category.children!.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
        }
      }

      _error = null;
    } catch (e, stackTrace) {
      Log.e('CategoryProvider: Error loading categories from API: $e');
      Log.e('CategoryProvider: Stack trace: $stackTrace');
      // Use predefined categories as fallback only if API fails
      _mainCategories = models.mainCategories;
      _error = 'Using offline data: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadSubcategories(int categoryId) async {
    Log.e(
        'CategoryProvider: Starting to load subcategories for category: $categoryId');
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final category = getCategoryById(categoryId);
      Log.e('CategoryProvider: Found category: ${category?.name ?? 'null'}');

      if (category != null) {
        _subcategories = category.children ?? [];
        Log.e(
            'CategoryProvider: Loaded ${_subcategories.length} subcategories');
        for (var subcategory in _subcategories) {
          Log.e(
              'CategoryProvider: Subcategory: ${subcategory.name} (ID: ${subcategory.id})');
        }
        _error = null;
      } else {
        Log.e('CategoryProvider: Category not found with ID: $categoryId');
        _error = 'Category not found';
      }
    } catch (e) {
      Log.e('CategoryProvider: Error loading subcategories: $e');
      _error = 'Error: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadCategoryDetails(int categoryId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/categories/$categoryId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final category = models.Category.fromJson(data);
        if (category.children != null) {
          _subcategories = category.children!;
        }
      } else {
        _error = 'Failed to load category details';
      }
    } catch (e) {
      _error = 'Error: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Get subcategories for a specific category
  List<models.Category> getSubcategories(int parentId) {
    final parentCategory =
        _mainCategories.firstWhere((category) => category.id == parentId);
    return parentCategory.children ?? [];
  }

  // Get a category by ID
  models.Category? getCategoryById(int id) {
    try {
      return _mainCategories.firstWhere((category) => category.id == id);
    } catch (e) {
      return null;
    }
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  void clearSubcategories() {
    _subcategories = [];
    notifyListeners();
  }
}
