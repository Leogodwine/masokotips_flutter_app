import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/organic_product_provider.dart';
import '../../models/organic_product.dart';
import '../../screens/edit_organic_product_screen.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:cached_network_image/cached_network_image.dart';

class OrganicProductsScreen extends StatefulWidget {
  const OrganicProductsScreen({Key? key}) : super(key: key);

  @override
  State<OrganicProductsScreen> createState() => _OrganicProductsScreenState();
}

class _OrganicProductsScreenState extends State<OrganicProductsScreen> {
  String _selectedSubcategory = 'All';
  String _sortBy = 'name_asc';
  bool _showInStock = false;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  final List<String> _subcategories = [
    'All',
    'Organic Vegetables',
    'Organic Fruits',
    'Organic Spices',
    'Organic Cash Crops',
    'Organic Cereals',
    'Organic Livestock and Poultry'
  ];

  @override
  void initState() {
    super.initState();
    _loadOrganicProducts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadOrganicProducts() async {
    if (!mounted) return;

    try {
      await context.read<OrganicProductProvider>().loadProducts();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading organic products: $e'),
            action: SnackBarAction(
              label: 'RETRY',
              onPressed: _loadOrganicProducts,
            ),
          ),
        );
      }
    }
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sort & Filter'),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: _sortBy,
                isExpanded: true,
                decoration: const InputDecoration(
                  labelText: 'Sort By',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(
                      value: 'name_asc', child: Text('Name (A-Z)')),
                  DropdownMenuItem(
                      value: 'name_desc', child: Text('Name (Z-A)')),
                  DropdownMenuItem(
                      value: 'price_asc', child: Text('Price (Low-High)')),
                  DropdownMenuItem(
                      value: 'price_desc', child: Text('Price (High-Low)')),
                ],
                onChanged: (value) {
                  setState(() => _sortBy = value!);
                },
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Show In Stock Only'),
                value: _showInStock,
                onChanged: (value) {
                  setState(() => _showInStock = value);
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  List<OrganicProduct> _filterProducts(List<OrganicProduct> products) {
    var filtered = products;

    // Apply subcategory filter
    if (_selectedSubcategory != 'All') {
      filtered = filtered.where((product) {
        // Map category names to their corresponding IDs
        final categoryMap = {
          'Organic Vegetables': 1,
          'Organic Fruits': 2,
          'Organic Spices': 3,
          'Organic Cash Crops': 4,
          'Organic Cereals': 5,
          'Organic Livestock and Poultry': 6,
        };

        return product.categoryId == categoryMap[_selectedSubcategory];
      }).toList();
    }

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filtered = filtered
          .where((product) =>
              product.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              (product.description
                      ?.toLowerCase()
                      .contains(_searchQuery.toLowerCase()) ??
                  false))
          .toList();
    }

    // Apply in-stock filter
    if (_showInStock) {
      filtered = filtered.where((product) => product.stock > 0).toList();
    }

    // Apply sorting
    filtered.sort((a, b) {
      switch (_sortBy) {
        case 'name_asc':
          return a.name.compareTo(b.name);
        case 'name_desc':
          return b.name.compareTo(a.name);
        case 'price_asc':
          return a.price.compareTo(b.price);
        case 'price_desc':
          return b.price.compareTo(a.price);
        default:
          return 0;
      }
    });

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Organic Products'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const EditOrganicProductScreen(),
                ),
              ).then((_) => _loadOrganicProducts());
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search organic products...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                          _loadOrganicProducts();
                        },
                      )
                    : null,
              ),
              onChanged: (value) {
                setState(() => _searchQuery = value);
                _loadOrganicProducts();
              },
            ),
          ),
          // Subcategory selector
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: _subcategories.map((category) {
                final isSelected = category == _selectedSubcategory;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(category),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() => _selectedSubcategory = category);
                      _loadOrganicProducts();
                    },
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 16),
          // Products list
          Expanded(
            child: Consumer<OrganicProductProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (provider.error != null) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Error: ${provider.error}',
                          style: const TextStyle(color: Colors.red),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _loadOrganicProducts,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                final filteredProducts = _filterProducts(provider.products);

                if (filteredProducts.isEmpty) {
                  return const Center(
                    child: Text('No organic products found'),
                  );
                }

                return AnimationLimiter(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredProducts.length,
                    itemBuilder: (context, index) {
                      final product = filteredProducts[index];
                      return AnimationConfiguration.staggeredList(
                        position: index,
                        duration: const Duration(milliseconds: 375),
                        child: SlideAnimation(
                          verticalOffset: 50.0,
                          child: FadeInAnimation(
                            child: Card(
                              margin: const EdgeInsets.only(bottom: 16),
                              child: ListTile(
                                leading: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: CachedNetworkImage(
                                    imageUrl: product.imageUrl ?? '',
                                    width: 60,
                                    height: 60,
                                    fit: BoxFit.cover,
                                    placeholder: (context, url) => Container(
                                      color: Colors.grey[200],
                                      child: const Icon(Icons.image),
                                    ),
                                    errorWidget: (context, url, error) =>
                                        Container(
                                      color: Colors.grey[200],
                                      child: const Icon(Icons.error),
                                    ),
                                  ),
                                ),
                                title: Text(
                                  product.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '\$${product.price.toStringAsFixed(2)}',
                                      style: TextStyle(
                                        color: Theme.of(context).primaryColor,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      'Stock: ${product.stock}',
                                      style: TextStyle(
                                        color: product.stock > 0
                                            ? Colors.green
                                            : Colors.red,
                                      ),
                                    ),
                                  ],
                                ),
                                trailing: SizedBox(
                                  width: 100,
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.edit),
                                        onPressed: () async {
                                          final result = await Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  EditOrganicProductScreen(
                                                product: product,
                                              ),
                                            ),
                                          );
                                          if (result == true && mounted) {
                                            _loadOrganicProducts();
                                          }
                                        },
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete),
                                        onPressed: () =>
                                            _showDeleteConfirmation(
                                                context, product),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showDeleteConfirmation(
    BuildContext context,
    OrganicProduct product,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Product'),
        content: Text('Are you sure you want to delete ${product.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      try {
        await context.read<OrganicProductProvider>().deleteProduct(product.id);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Product deleted successfully')),
          );
          _loadOrganicProducts();
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error deleting product: $e')),
          );
        }
      }
    }
  }
}
