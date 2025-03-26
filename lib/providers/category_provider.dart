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

      try {
        _categories = await _apiService.getCategories(parentId: parentId);
      } catch (e) {
        Log.e('Exception in getCategories: $e');
        // If API call fails, use mock data
        _categories = _getMockCategories(parentId);
      }

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

  // Force the use of mock data
  void useMockData() {
    try {
      _isLoading = true;
      notifyListeners();

      // Load mock categories
      _categories = _getMockCategories(null);

      _isLoading = false;
      _error = null;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  // Mock categories data for when API fails
  List<models.Category> _getMockCategories(int? parentId) {
    // Main categories
    final List<models.Category> mockMainCategories = [
      models.Category(
        id: 1,
        name: 'Products',
        icon: 'shopping_basket',
        subcategories: [],
      ),
      models.Category(
        id: 2,
        name: 'Services',
        icon: 'miscellaneous_services',
        subcategories: [],
      ),
      models.Category(
        id: 3,
        name: 'Market Information',
        icon: 'trending_up',
        subcategories: [],
      ),
      models.Category(
        id: 4,
        name: 'Transport',
        icon: 'local_shipping',
        subcategories: [],
      ),
      models.Category(
        id: 5,
        name: 'Organic Products',
        icon: 'eco',
        subcategories: [],
      ),
      models.Category(
        id: 6,
        name: 'Other Services',
        icon: 'more_horiz',
        subcategories: [],
      ),
    ];

    // Subcategories
    final Map<int, List<models.Category>> mockSubcategories = {
      1: [
        models.Category(
          id: 101,
          name: 'Vegetables',
          icon: 'eco_outlined',
          subcategories: [],
        ),
        models.Category(
          id: 102,
          name: 'Fruits',
          icon: 'apple',
          subcategories: [],
        ),
        models.Category(
          id: 103,
          name: 'Spices',
          icon: 'spa',
          subcategories: [],
        ),
        models.Category(
          id: 104,
          name: 'Cash Crops',
          icon: 'agriculture',
          subcategories: [],
        ),
        models.Category(
          id: 105,
          name: 'Cereals',
          icon: 'grain',
          subcategories: [],
        ),
        models.Category(
          id: 106,
          name: 'Seeds and Seedling',
          icon: 'grass',
          subcategories: [],
        ),
        models.Category(
          id: 107,
          name: 'Livestock and poultry',
          icon: 'pets',
          subcategories: [],
        ),
      ],
      4: [
        models.Category(
          id: 401,
          name: 'Tandem',
          icon: 'local_shipping',
          subcategories: [],
        ),
        models.Category(
          id: 402,
          name: 'Kirikuu',
          icon: 'local_shipping',
          subcategories: [],
        ),
        models.Category(
          id: 403,
          name: 'FlatbedTrucks',
          icon: 'local_shipping',
          subcategories: [],
        ),
        models.Category(
          id: 404,
          name: 'Tanker',
          icon: 'local_shipping',
          subcategories: [],
        ),
        models.Category(
          id: 405,
          name: 'Refrigerator Truck',
          icon: 'local_shipping',
          subcategories: [],
        ),
        models.Category(
          id: 406,
          name: 'Box Truck',
          icon: 'local_shipping',
          subcategories: [],
        ),
        models.Category(
          id: 407,
          name: 'Liftgate Truck',
          icon: 'local_shipping',
          subcategories: [],
        ),
        models.Category(
          id: 408,
          name: 'Van',
          icon: 'local_shipping',
          subcategories: [],
        ),
        models.Category(
          id: 409,
          name: 'Container Hauler',
          icon: 'local_shipping',
          subcategories: [],
        ),
        models.Category(
          id: 410,
          name: 'Pickups Trucks',
          icon: 'local_shipping',
          subcategories: [],
        ),
        models.Category(
          id: 411,
          name: 'Fuso',
          icon: 'local_shipping',
          subcategories: [],
        ),
        models.Category(
          id: 412,
          name: 'Semi Trailers',
          icon: 'local_shipping',
          subcategories: [],
        ),
        models.Category(
          id: 413,
          name: 'Tracker Trailers',
          icon: 'local_shipping',
          subcategories: [],
        ),
      ],
      5: [
        models.Category(
          id: 501,
          name: 'Organic Vegetables',
          icon: 'eco',
          subcategories: [],
        ),
        models.Category(
          id: 502,
          name: 'Organic Fruits',
          icon: 'eco',
          subcategories: [],
        ),
        models.Category(
          id: 503,
          name: 'Organic Spices',
          icon: 'eco',
          subcategories: [],
        ),
        models.Category(
          id: 504,
          name: 'Organic Cash Crops',
          icon: 'eco',
          subcategories: [],
        ),
        models.Category(
          id: 505,
          name: 'Organic Cereals',
          icon: 'eco',
          subcategories: [],
        ),
        models.Category(
          id: 506,
          name: 'Organic Livestock and Poultry',
          icon: 'eco',
          subcategories: [],
        ),
      ],
      6: [
        models.Category(
          id: 601,
          name: 'Packaging Materials',
          icon: 'inventory',
          subcategories: [],
        ),
        models.Category(
          id: 602,
          name: 'Hydroponics',
          icon: 'water_drop',
          subcategories: [],
        ),
        models.Category(
          id: 603,
          name: 'Fertilizer',
          icon: 'grass',
          subcategories: [],
        ),
        models.Category(
          id: 604,
          name: 'Organic Manure',
          icon: 'recycling',
          subcategories: [],
        ),
        models.Category(
          id: 605,
          name: 'Machinery',
          icon: 'build',
          subcategories: [],
        ),
        models.Category(
          id: 606,
          name: 'Behive and Aquatic',
          icon: 'water',
          subcategories: [],
        ),
        models.Category(
          id: 607,
          name: 'Food and Beverage',
          icon: 'restaurant',
          subcategories: [],
        ),
      ],
    };

    // Return main categories or subcategories based on parentId
    if (parentId == null) {
      return mockMainCategories;
    } else {
      return mockSubcategories[parentId] ?? [];
    }
  }
}
