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
        final Map<int, models.Category> categoryMap = {
          for (var category in response) category.id: category
        };

        for (var category in response) {
          if (category.parentId != null) {
            final parent = categoryMap[category.parentId];
            if (parent != null) {
              parent.subcategories ??= [];
              parent.subcategories!.add(category);
              Log.d('Added subcategory ${category.name} under ${parent.name}');
            }
          }
        }

        _mainCategories = response.where((c) => c.parentId == null).toList()
          ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

        for (var category in _mainCategories) {
          category.subcategories
              ?.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
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

  // Load subcategories for a specific category
  Future<void> loadSubcategories(int categoryId) async {
    Log.i(
        'CategoryProvider: Starting to load subcategories for category: $categoryId');

    // Don't reload if already loading
    if (_isLoading) {
      Log.i('CategoryProvider: Already loading categories, skipping');
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final category = getCategoryById(categoryId);
      Log.i('CategoryProvider: Found category: ${category?.name ?? 'null'}');

      if (category != null) {
        _subcategories = category.subcategories ?? [];
        Log.i(
            'CategoryProvider: Loaded ${_subcategories.length} subcategories');
        for (var subcategory in _subcategories) {
          Log.d(
              'CategoryProvider: Subcategory: ${subcategory.name} (ID: ${subcategory.id})');
        }
        _error = null;
      } else {
        Log.w('CategoryProvider: Category not found with ID: $categoryId');
        _error = 'Category not found';
        _subcategories = [];
      }
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
}
