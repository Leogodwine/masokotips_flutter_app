import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/category_provider.dart';
import '../categories/category_list_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // Define subcategories map
  final Map<String, List<String>> _categorySubcategories = {
    'Products': [
      'Vegetables',
      'Fruits',
      'Spices',
      'Cash Crops',
      'Cereals',
      'Seeds and Seedling',
      'Livestock and poultry'
    ],
    'Services': [],
    'Market Information': [],
    'Transport': [
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
    'Organic Products': [
      'Organic Vegetables',
      'Organic Fruits',
      'Organic Spices',
      'Organic Cash Crops',
      'Organic Cereals',
      'Organic Livestock and Poultry'
    ],
    'Other Services': [
      'Packaging Materials',
      'Hydroponics',
      'Fertilizer',
      'Organic Manure',
      'Machinery',
      'Behive and Aquatic',
      'Food and Beverage'
    ],
  };

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      print('Initializing SearchScreen...');
      context.read<CategoryProvider>().loadCategories();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: 'Search categories...',
            hintStyle: TextStyle(color: Colors.white70),
            border: InputBorder.none,
          ),
          onChanged: (value) {
            setState(() {
              _searchQuery = value.toLowerCase();
            });
          },
        ),
      ),
      body: Consumer<CategoryProvider>(
        builder: (context, categoryProvider, child) {
          final allCategories = categoryProvider.categories;

          if (categoryProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (categoryProvider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Error: ${categoryProvider.error}',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      categoryProvider.loadCategories();
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final filteredCategories = allCategories.where((category) {
            return category.name.toLowerCase().contains(_searchQuery);
          }).toList();

          if (filteredCategories.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.search_off,
                    size: 64,
                    color: Theme.of(context).primaryColor.withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _searchQuery.isEmpty
                        ? 'Start typing to search categories'
                        : 'No categories found for "$_searchQuery"',
                    style: Theme.of(context).textTheme.titleMedium,
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
              final category = filteredCategories[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: ListTile(
                  leading: Icon(
                    Icons.category,
                    color: Theme.of(context).primaryColor,
                  ),
                  title: Text(
                    category.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    '${category.subcategories.length} subcategories',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CategoryListScreen(
                          categoryId: category.id,
                          title: category.name,
                          subcategories:
                              _categorySubcategories[category.name] ?? [],
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
