import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/category_provider.dart';
import '../categories/category_list_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/category.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  List<String> _recentSearches = [];
  static const String _recentSearchesKey = 'recent_searches';
  static const int _maxRecentSearches = 5;

  // Define subcategories map with icons
  final Map<String, Map<String, dynamic>> _categorySubcategories = {
    'Products': {
      'subcategories': [
        'Vegetables',
        'Fruits',
        'Spices',
        'Cash Crops',
        'Cereals',
        'Seeds and Seedling',
        'Livestock and poultry'
      ],
      'icon': Icons.shopping_basket,
      'color': Colors.green,
    },
    'Services': {
      'subcategories': [
        'Packaging Materials',
        'Hydroponics',
        'Fertilizer',
        'Organic Manure',
        'Machinery',
        'Behive and Aquatic',
        'Food and Beverage'
      ],
      'icon': Icons.miscellaneous_services,
      'color': Colors.blue,
    },
    'Market Information': {
      'subcategories': [],
      'icon': Icons.trending_up,
      'color': Colors.orange,
    },
    'Transport': {
      'subcategories': [
        'Tandem',
        'Kirikuu',
        'FlatbedTrucks',
        'Tanker',
        'Refrigerator Truck',
        'Box Truck',
        'Liftgate Truck',
        'Van',
        'Container Hauler',
        'Pickups Trucks',
        'Fuso',
        'Semi Trailers',
        'Tracker Trailers'
      ],
      'icon': Icons.local_shipping,
      'color': Colors.purple,
    },
    'Organic Products': {
      'subcategories': [
        'Organic Vegetables',
        'Organic Fruits',
        'Organic Spices',
        'Organic Cash Crops',
        'Organic Cereals',
        'Organic Livestock and Poultry'
      ],
      'icon': Icons.eco,
      'color': Colors.teal,
    },
    'Agricultural Services': {
      'subcategories': [
        'Cold Rooms Services',
        'Machinery and Rental Services',
        'Agronomist Services',
        'Financial Services',
        'Irrigation Services',
        'Branding and Consultation Services'
      ],
      'icon': Icons.agriculture,
      'color': Colors.brown,
    },
  };

  @override
  void initState() {
    super.initState();
    _loadRecentSearches();
    Future.microtask(() {
      context.read<CategoryProvider>().loadMainCategories();
    });
  }

  Future<void> _loadRecentSearches() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _recentSearches = prefs.getStringList(_recentSearchesKey) ?? [];
    });
  }

  Future<void> _saveRecentSearch(String query) async {
    if (query.isEmpty) return;

    setState(() {
      _recentSearches.remove(query);
      _recentSearches.insert(0, query);
      if (_recentSearches.length > _maxRecentSearches) {
        _recentSearches.removeLast();
      }
    });

    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_recentSearchesKey, _recentSearches);
  }

  Future<void> _clearRecentSearches() async {
    setState(() {
      _recentSearches.clear();
    });
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_recentSearchesKey);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        style: const TextStyle(color: Colors.black87),
        decoration: InputDecoration(
          hintText: 'Search categories...',
          hintStyle: TextStyle(color: Colors.grey[600]),
          border: InputBorder.none,
          icon: Icon(Icons.search, color: Theme.of(context).primaryColor),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {
                      _searchQuery = '';
                    });
                  },
                )
              : null,
        ),
        onChanged: (value) {
          setState(() {
            _searchQuery = value.toLowerCase();
          });
        },
        onSubmitted: (value) {
          if (value.isNotEmpty) {
            _saveRecentSearch(value);
          }
        },
      ),
    );
  }

  Widget _buildRecentSearches() {
    if (_recentSearches.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent Searches',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              TextButton.icon(
                onPressed: _clearRecentSearches,
                icon: const Icon(Icons.delete_outline),
                label: const Text('Clear'),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 40,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _recentSearches.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ActionChip(
                  label: Text(_recentSearches[index]),
                  avatar: const Icon(Icons.history, size: 16),
                  onPressed: () {
                    _searchController.text = _recentSearches[index];
                    setState(() {
                      _searchQuery = _recentSearches[index].toLowerCase();
                    });
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _buildSearchBar(),
        elevation: 0,
      ),
      body: Consumer<CategoryProvider>(
        builder: (context, categoryProvider, child) {
          final allCategories = categoryProvider.mainCategories;

          if (categoryProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (categoryProvider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red[300],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error: ${categoryProvider.error}',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.red[700]),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      categoryProvider.loadMainCategories();
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final filteredCategories = allCategories.where((category) {
            return category.name.toLowerCase().contains(_searchQuery);
          }).toList();

          if (_searchQuery.isEmpty) {
            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildRecentSearches(),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      'Browse Categories',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                  ...filteredCategories
                      .map((category) => _buildCategoryCard(category)),
                ],
              ),
            );
          }

          if (filteredCategories.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.search_off,
                    size: 80,
                    color: Theme.of(context).primaryColor.withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No categories found for "$_searchQuery"',
                    style: Theme.of(context).textTheme.titleMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Try different keywords or browse all categories',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: filteredCategories.length,
            itemBuilder: (context, index) {
              return _buildCategoryCard(filteredCategories[index]);
            },
          );
        },
      ),
    );
  }

  Widget _buildCategoryCard(Category category) {
    final categoryInfo = _categorySubcategories[category.name];
    final icon = categoryInfo?['icon'] as IconData? ?? Icons.category;
    final color =
        categoryInfo?['color'] as Color? ?? Theme.of(context).primaryColor;
    final subcategories = categoryInfo?['subcategories'] as List<String>? ?? [];

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CategoryListScreen(
                categoryId: category.id,
                title: category.name,
                subcategories: subcategories,
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      category.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${subcategories.length} subcategories',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: Colors.grey[400],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
