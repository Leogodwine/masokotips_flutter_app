import 'package:flutter/foundation.dart';
import '../models/category.dart' as models;
import '../services/api_service.dart';
import '../utils/logger.dart';

class CategoryProvider with ChangeNotifier {
  final ApiService _apiService;
  List<models.Category> _categories = [];
  bool _isLoading = false;
  String? _error;

  CategoryProvider({ApiService? apiService})
      : _apiService = apiService ?? ApiService();

  // Getters
  List<models.Category> get categories => _categories;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Load categories
  Future<void> loadCategories({int? parentId}) async {
    Log.e('CategoryProvider: Starting to load categories...');
    Log.e(
        'Current state - isLoading: $_isLoading, categories count: ${_categories.length}');

    Log.e('Loading categories with parentId: $parentId');

    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _categories = await _apiService.getCategories(parentId: parentId);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      Log.e('Error loading categories: $e');
      notifyListeners();
    }
  }

  // Get subcategories for a specific category
  List<models.Category> getSubcategories(int parentId) {
    final parentCategory =
        _categories.firstWhere((category) => category.id == parentId);
    return parentCategory.subcategories;
  }

  // Get a category by ID
  models.Category? getCategoryById(int id) {
    try {
      return _categories.firstWhere((category) => category.id == id);
    } catch (e) {
      return null;
    }
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
