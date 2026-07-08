import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/organic_product_provider.dart';
import '../../models/organic_product.dart';
import '../../screens/edit_organic_product_screen.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../l10n/app_localizations.dart';

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
            content: Text(AppLocalizations.of(context)!
                .errorLoadingOrganicProducts(e.toString())),
            action: SnackBarAction(
              label: AppLocalizations.of(context)!.retry,
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
        title: Text(AppLocalizations.of(context)!.sortAndFilter),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                initialValue: _sortBy,
                isExpanded: true,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.sortBy,
                  border: const OutlineInputBorder(),
                ),
                items: [
                  DropdownMenuItem(
                      value: 'name_asc',
                      child: Text(AppLocalizations.of(context)!.nameAZ)),
                  DropdownMenuItem(
                      value: 'name_desc',
                      child: Text(AppLocalizations.of(context)!.nameZA)),
                  DropdownMenuItem(
                      value: 'price_asc',
                      child: Text(AppLocalizations.of(context)!.priceLowHigh)),
                  DropdownMenuItem(
                      value: 'price_desc',
                      child: Text(AppLocalizations.of(context)!.priceHighLow)),
                ],
                onChanged: (value) {
                  setState(() => _sortBy = value!);
                },
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: Text(AppLocalizations.of(context)!.showInStockOnly),
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
            child: Text(AppLocalizations.of(context)!.close),
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
        title: Text(AppLocalizations.of(context)!.organicProducts),
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
                hintText: AppLocalizations.of(context)!.searchOrganicProducts,
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
                          child: Text(AppLocalizations.of(context)!.retry),
                        ),
                      ],
                    ),
                  );
                }

                final filteredProducts = _filterProducts(provider.products);

                if (filteredProducts.isEmpty) {
                  return Center(
                    child: Text(
                        AppLocalizations.of(context)!.noOrganicProductsFound),
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
                                      'TZS ${product.price.toStringAsFixed(2)}',
                                      style: TextStyle(
                                        color: Theme.of(context).primaryColor,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    // Seller info
                                    if (product.user != null) ...[
                                      const SizedBox(height: 2),
                                      Row(
                                        children: [
                                          CircleAvatar(
                                            radius: 8,
                                            backgroundImage:
                                                product.sellerAvatar != null
                                                    ? NetworkImage(
                                                        product.sellerAvatar!)
                                                    : null,
                                            child: product.sellerAvatar == null
                                                ? const Icon(Icons.person,
                                                    size: 8)
                                                : null,
                                          ),
                                          const SizedBox(width: 4),
                                          Expanded(
                                            child: Text(
                                              product.sellerName,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                fontSize: 11, color: Colors.grey),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
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
    final provider = context.read<OrganicProductProvider>();
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final localizations = AppLocalizations.of(context)!;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(localizations.deleteProduct),
        content: Text(localizations.confirmDeleteProduct(product.name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(localizations.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(localizations.delete),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      try {
        await provider.deleteProduct(product.id);
        if (mounted) {
          scaffoldMessenger.showSnackBar(
            SnackBar(
                content: Text(
                    localizations.productDeletedSuccessfully)),
          );
          _loadOrganicProducts();
        }
      } catch (e) {
        if (mounted) {
          scaffoldMessenger.showSnackBar(
            SnackBar(
                content:
                    Text(localizations.errorDeletingProduct(e.toString()))),
          );
        }
      }
    }
  }
}
