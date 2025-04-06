import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/product_provider.dart';
import '../categories/category_list_screen.dart';
import '../products/organic_products_screen.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

class ServiceCategoriesScreen extends StatefulWidget {
  const ServiceCategoriesScreen({Key? key}) : super(key: key);

  @override
  State<ServiceCategoriesScreen> createState() =>
      _ServiceCategoriesScreenState();
}

class _ServiceCategoriesScreenState extends State<ServiceCategoriesScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  final List<Map<String, dynamic>> mainCategories = [
    {
      'id': 1,
      'name': 'Products',
      'icon': Icons.shopping_basket,
      'description':
          'Agricultural products including vegetables, fruits, and more',
      'subcategories': [
        'Vegetables',
        'Fruits',
        'Spices',
        'Cash Crops',
        'Cereals',
        'Seeds and Seedling',
        'Livestock and poultry'
      ],
      'color': Colors.green[700],
    },
    {
      'id': 2,
      'name': 'Services',
      'icon': Icons.miscellaneous_services,
      'description': 'Various agricultural services',
      'subcategories': [
        'Packaging Materials',
        'Hydroponics',
        'Fertilizer',
        'Organic Manure',
        'Machinery',
        'Behive and Aquatic',
        'Food and Beverage'
      ],
      'color': Colors.blue[700],
    },
    {
      'id': 3,
      'name': 'Market Information',
      'icon': Icons.info,
      'description': 'Latest market trends and information',
      'subcategories': [],
      'color': Colors.orange[700],
    },
    {
      'id': 4,
      'name': 'Transport',
      'icon': Icons.local_shipping,
      'description': 'Transportation services for agricultural products',
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
      'color': Colors.purple[700],
    },
    {
      'id': 5,
      'name': 'Organic Products',
      'icon': Icons.eco,
      'description': 'Certified organic agricultural products',
      'subcategories': [
        'Organic Vegetables',
        'Organic Fruits',
        'Organic Spices',
        'Organic Cash Crops',
        'Organic Cereals',
        'Organic Livestock and Poultry'
      ],
      'color': Colors.teal[700],
    },
    {
      'id': 6,
      'name': 'Agricultural Services',
      'icon': Icons.agriculture,
      'description': 'Specialized agricultural services',
      'subcategories': [
        'Cold Rooms Services',
        'Machinery and Rental Services',
        'Agronomist Services',
        'Financial Services',
        'Irrigation Services',
        'Branding and Consultation Services'
      ],
      'color': Colors.brown[700],
    },
  ];

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Categories',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.85,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final category = mainCategories[index];
                    return AnimationConfiguration.staggeredGrid(
                      position: index,
                      duration: const Duration(milliseconds: 375),
                      columnCount: 2,
                      child: ScaleAnimation(
                        child: FadeInAnimation(
                          child: Card(
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(16),
                              onTap: () {
                                if (category['name'] == 'Organic Products') {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const OrganicProductsScreen(),
                                    ),
                                  );
                                } else {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => CategoryListScreen(
                                        categoryId: category['id'],
                                        title: category['name'],
                                        subcategories:
                                            category['subcategories'],
                                      ),
                                    ),
                                  );
                                }
                              },
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: category['color'] ??
                                          Theme.of(context).primaryColor,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      category['icon'] as IconData,
                                      size: 40,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    category['name'],
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 8),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12),
                                    child: Text(
                                      category['description'],
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  if ((category['subcategories'] as List)
                                      .isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12),
                                      child: Text(
                                        '${(category['subcategories'] as List).length} subcategories',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Theme.of(context).primaryColor,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                  childCount: mainCategories.length,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    try {
      await context.read<ProductProvider>().getFeaturedProducts();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading data: $e')),
        );
      }
    }
  }
}
