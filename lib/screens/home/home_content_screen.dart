import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/product_provider.dart';
import '../../providers/category_provider.dart';
import '../products/product_list_screen.dart';
import '../products/product_details_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../search/search_screen.dart';
import 'dart:async';
import '../../utils/logger.dart';
import '../products/category_products_screen.dart';
import '../categories/subcategories_screen.dart';

class HomeContentScreen extends StatefulWidget {
  const HomeContentScreen({Key? key}) : super(key: key);

  @override
  State<HomeContentScreen> createState() => _HomeContentScreenState();
}

class _HomeContentScreenState extends State<HomeContentScreen> {
  bool _isLoading = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadData();
    // Load categories
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Log.e('HomeContentScreen: Starting to load categories...');
      context.read<CategoryProvider>().loadMainCategories().then((_) {
        Log.e('HomeContentScreen: Categories loaded successfully');
        Log.e(
            'HomeContentScreen: Categories count: ${context.read<CategoryProvider>().mainCategories.length}');
      }).catchError((error) {
        Log.e('HomeContentScreen: Error loading categories: $error');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error loading categories: $error'),
              action: SnackBarAction(
                label: 'RETRY',
                onPressed: () {
                  Log.e(
                      'HomeContentScreen: Retrying category load after error');
                  context.read<CategoryProvider>().loadMainCategories();
                },
              ),
            ),
          );
        }
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    if (!mounted) return;

    setState(() => _isLoading = true);

    try {
      Log.e('HomeContentScreen: Loading featured products...');
      final productProvider = context.read<ProductProvider>();
      await productProvider.getFeaturedProducts();
      Log.e('HomeContentScreen: Featured products loaded successfully');
    } catch (e) {
      Log.e('HomeContentScreen: Error loading featured products: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading featured products: $e'),
            action: SnackBarAction(
              label: 'RETRY',
              onPressed: _loadData,
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _loadData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Section
            Container(
              padding: const EdgeInsets.all(24.0),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome to',
                    style: TextStyle(
                      fontSize: 24,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'maSOKOtips',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search products...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SearchScreen(),
                        ),
                      );
                    },
                    readOnly: true,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Categories Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Categories',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ProductListScreen(
                            title: 'All Products',
                            categoryId: 0,
                            subcategory: '',
                          ),
                        ),
                      );
                    },
                    child: const Text('See All'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Consumer<CategoryProvider>(
              builder: (context, categoryProvider, child) {
                Log.e('HomeContentScreen: Building categories section');
                Log.e(
                    'HomeContentScreen: isLoading: ${categoryProvider.isLoading}');
                Log.e('HomeContentScreen: error: ${categoryProvider.error}');
                Log.e(
                    'HomeContentScreen: categories count: ${categoryProvider.mainCategories.length}');

                if (categoryProvider.isLoading) {
                  Log.e('HomeContentScreen: Showing loading indicator');
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text('Loading categories...'),
                      ],
                    ),
                  );
                }

                if (categoryProvider.error != null) {
                  Log.e(
                      'HomeContentScreen: Showing error: ${categoryProvider.error}');
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 48,
                          color: Colors.red[300],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          categoryProvider.error!,
                          style: TextStyle(
                            color: Colors.red[700],
                            fontSize: 16,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: () {
                            Log.e('HomeContentScreen: Retrying category load');
                            categoryProvider.loadMainCategories();
                          },
                          icon: const Icon(Icons.refresh),
                          label: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                final categories = categoryProvider.mainCategories;
                if (categories.isEmpty) {
                  Log.e('HomeContentScreen: No categories found');
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.category_outlined,
                          size: 48,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No categories available',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Please check back later',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  );
                }

                Log.e(
                    'HomeContentScreen: Building category grid with ${categories.length} items');
                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    childAspectRatio: 1,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    final category = categories[index];
                    Log.e(
                        'HomeContentScreen: Building category: ${category.name}');
                    return InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SubcategoriesScreen(
                              category: category,
                            ),
                          ),
                        );
                      },
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Theme.of(context)
                                      .primaryColor
                                      .withOpacity(0.1),
                                  Theme.of(context)
                                      .primaryColor
                                      .withOpacity(0.2),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
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
                            child: Icon(
                              _getCategoryIcon(category.icon ?? ''),
                              size: 28,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            category.name,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
            const SizedBox(height: 24),

            // Featured Products Section
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Featured Products',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ProductListScreen(
                                title: 'Featured Products',
                                categoryId: 0,
                                subcategory: 'featured',
                              ),
                            ),
                          );
                        },
                        child: const Text('See All'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (_isLoading)
                    const Center(child: CircularProgressIndicator())
                  else
                    Consumer<ProductProvider>(
                      builder: (context, productProvider, child) {
                        final featuredProducts =
                            productProvider.featuredProducts;

                        if (featuredProducts.isEmpty) {
                          return Center(
                            child: Padding(
                              padding: const EdgeInsets.all(24.0),
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.inventory_2_outlined,
                                    size: 64,
                                    color: Colors.grey[400],
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'No featured products available',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }

                        return SizedBox(
                          height: 280,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: featuredProducts.length,
                            itemBuilder: (context, index) {
                              final product = featuredProducts[index];
                              return Container(
                                width: 200,
                                margin: const EdgeInsets.only(right: 16),
                                child: Card(
                                  elevation: 2,
                                  clipBehavior: Clip.antiAlias,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: InkWell(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              ProductDetailsScreen(
                                                  product: product),
                                        ),
                                      );
                                    },
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Hero(
                                          tag: 'home-featured-${product.id}',
                                          child: CachedNetworkImage(
                                            imageUrl: product.imageUrl,
                                            height: 160,
                                            width: double.infinity,
                                            fit: BoxFit.cover,
                                            placeholder: (context, url) =>
                                                Container(
                                              height: 160,
                                              color: Colors.grey[100],
                                              child: const Center(
                                                child:
                                                    CircularProgressIndicator(),
                                              ),
                                            ),
                                            errorWidget:
                                                (context, url, error) =>
                                                    Container(
                                              height: 160,
                                              color: Colors.grey[100],
                                              child: const Icon(Icons.error),
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(12.0),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                product.name,
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
                                                ),
                                              ),
                                              const SizedBox(height: 8),
                                              Text(
                                                '\$${product.price.toStringAsFixed(2)}',
                                                style: TextStyle(
                                                  color: Theme.of(context)
                                                      .primaryColor,
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String iconName) {
    switch (iconName.toLowerCase()) {
      case 'shopping_basket':
        return Icons.shopping_basket;
      case 'miscellaneous_services':
        return Icons.miscellaneous_services;
      case 'trending_up':
        return Icons.trending_up;
      case 'local_shipping':
        return Icons.local_shipping;
      case 'eco':
        return Icons.eco;
      case 'more_horiz':
        return Icons.more_horiz;
      case 'vegetables':
        return Icons.eco;
      case 'fruits':
        return Icons.apple;
      case 'spices':
        return Icons.spa;
      case 'cash crops':
        return Icons.monetization_on;
      case 'cereals':
        return Icons.grain;
      case 'seeds and seedling':
        return Icons.local_florist;
      case 'livestock and poultry':
        return Icons.pets;
      case 'organic vegetables':
        return Icons.eco;
      case 'organic fruits':
        return Icons.apple;
      case 'organic spices':
        return Icons.spa;
      case 'organic cash crops':
        return Icons.monetization_on;
      case 'organic cereals':
        return Icons.grain;
      case 'organic livestock and poultry':
        return Icons.pets;
      case 'packaging materials':
        return Icons.inventory_2;
      case 'hydroponics':
        return Icons.water_drop;
      case 'fertilizer':
        return Icons.agriculture;
      case 'organic manure':
        return Icons.recycling;
      case 'machinery':
        return Icons.construction;
      case 'behive and aquatic':
        return Icons.water;
      case 'food and beverage':
        return Icons.restaurant;
      default:
        return Icons.category;
    }
  }
}
