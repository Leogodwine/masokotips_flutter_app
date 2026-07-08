import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../l10n/app_localizations.dart';
import '../../models/product.dart';
import '../../services/product_service.dart';
import '../../providers/auth_provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'add_product_screen.dart';
import 'edit_product_screen.dart';
import 'seller_organic_products_screen.dart';
import 'seller_transport_screen.dart';
import 'seller_food_beverages_screen.dart';
import '../../utils/extensions.dart';
import '../../widgets/subscription_guard.dart';

class SellerDashboardScreen extends StatefulWidget {
  final int initialIndex;
  const SellerDashboardScreen({Key? key, this.initialIndex = 0})
      : super(key: key);

  @override
  State<SellerDashboardScreen> createState() => _SellerDashboardScreenState();
}

class _SellerDashboardScreenState extends State<SellerDashboardScreen> {
  bool _isLoading = false;
  List<Product> _sellerProducts = [];
  final ProductService _productService = ProductService();
  String? _errorMessage;
  String _selectedCategory = 'All';
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.token != null) {
      _productService.setAuthToken(authProvider.token!);
    }
    _loadSellerProducts();
  }

  Future<void> _loadSellerProducts() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      debugPrint('Loading seller products...');
      final products = await _productService.getSellerProducts();
      debugPrint('Loaded ${products.length} products');
      setState(() {
        _sellerProducts = products;
      });
    } catch (e) {
      debugPrint('Error loading seller products: $e');

      final errorStr = e.toFriendlyError;
      if (errorStr.contains('subscription_required') ||
          errorStr.contains('SUBSCRIPTION_EXPIRED')) {
        setState(() {
          _errorMessage =
              'Your Seller subscription has expired or is inactive.';
        });
      } else {
        setState(() {
          _errorMessage = errorStr;
        });
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _navigateToEditProduct(Product product) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditProductScreen(
          product: product,
          productService: _productService,
          onProductUpdated: (updatedProduct) {
            setState(() {
              final index =
                  _sellerProducts.indexWhere((p) => p.id == updatedProduct.id);
              if (index != -1) {
                _sellerProducts[index] = updatedProduct;
              }
            });
          },
        ),
      ),
    );

    if (result == true) {
      _loadSellerProducts();
    }
  }

  Future<void> _deleteProduct(Product product) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    try {
      setState(() {
        _isLoading = true;
      });

      await _productService.deleteProduct(product.id);
      setState(() {
        _sellerProducts.removeWhere((p) => p.id == product.id);
      });

      if (mounted) {
        scaffoldMessenger.showSnackBar(
          SnackBar(
              content: Text(AppLocalizations.of(context)!
                  .productDeletedSuccessfully)),
        );
      }
    } catch (e) {
      if (mounted) {
        scaffoldMessenger.showSnackBar(
          SnackBar(content: Text('Failed to delete product: $e')),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _showDeleteDialog(Product product) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.deleteProduct),
        content: Text('Are you sure you want to delete "${product.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(AppLocalizations.of(context)!.delete),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _deleteProduct(product);
    }
  }

  List<String> get _categories {
    final Set<String> categories = {'All'};
    for (var product in _sellerProducts) {
      categories.add(product.categoryId.toString());
    }
    return categories.toList();
  }

  List<Product> get _filteredProducts {
    if (_selectedCategory == 'All') {
      return _sellerProducts;
    }
    return _sellerProducts
        .where((product) => product.categoryId.toString() == _selectedCategory)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    // Hide dashboard AppBar if we are on a tab that provides its own Scaffold/AppBar
    bool showDashboardAppBar = _selectedIndex == 0;

    return Scaffold(
      appBar: showDashboardAppBar
          ? AppBar(
              title: Text(AppLocalizations.of(context)!.sellerDashboardTitle),
              actions: [
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: _loadSellerProducts,
                ),
              ],
            )
          : null,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(color: Colors.grey[300]!, width: 1),
          ),
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: _selectedIndex,
          selectedItemColor: Theme.of(context).primaryColor,
          unselectedItemColor: Colors.grey[600],
          backgroundColor: Colors.white,
          elevation: 8,
          onTap: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          items: [
            BottomNavigationBarItem(
              icon: const Icon(Icons.inventory),
              label: AppLocalizations.of(context)!.productsTab,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.directions_car),
              label: AppLocalizations.of(context)!.transportsTab,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.eco),
              label: AppLocalizations.of(context)!.organicTab,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.restaurant_menu),
              label: AppLocalizations.of(context)!.foodAndBeverages,
            ),
          ],
        ),
      ),
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton.extended(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddProductScreen(
                      onProductAdded: (product) {
                        debugPrint(
                            'Product added callback received: ${product.name}');
                        setState(() {
                          _sellerProducts.add(product);
                          debugPrint(
                              'Product added to list. Total products: ${_sellerProducts.length}');
                        });
                      },
                      productService: _productService,
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.add),
              label: Text(AppLocalizations.of(context)!.addProduct),
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
              elevation: 4,
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: _buildBody(),
    );
  }


  Widget _buildBody() {
    switch (_selectedIndex) {
      case 0:
        return SubscriptionRequired(
          requiredRole: 'seller',
          child: _buildProductsSection(),
        );
      case 1:
        return const SubscriptionRequired(
          requiredRole: 'transporter',
          child: SellerTransportScreen(),
        );
      case 2:
        return const SubscriptionRequired(
          requiredRole: 'seller',
          child: SellerOrganicProductsScreen(),
        );
      case 3:
        return const SubscriptionRequired(
          requiredRole: 'seller',
          child: SellerFoodBeveragesScreen(),
        );
      default:
        return SubscriptionRequired(
          requiredRole: 'seller',
          child: _buildProductsSection(),
        );
    }
  }

  Widget _buildProductsSection() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Text(
          _errorMessage!,
          style: const TextStyle(color: Colors.red),
        ),
      );
    }

    if (_sellerProducts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inventory_2_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No products found',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddProductScreen(
                      onProductAdded: (product) {
                        setState(() {
                          _sellerProducts.add(product);
                        });
                      },
                      productService: _productService,
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.add),
              label: Text(AppLocalizations.of(context)!.addProduct),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          child: DropdownButtonFormField<String>(
            initialValue: _selectedCategory,
            decoration: InputDecoration(
              labelText: 'Filter by Category',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              prefixIcon: const Icon(Icons.category),
            ),
            items: _categories.map((category) {
              return DropdownMenuItem(
                value: category,
                child: Text(category),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedCategory = value!;
              });
            },
          ),
        ),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.5,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: _filteredProducts.length,
            itemBuilder: (context, index) {
              final product = _filteredProducts[index];
              return _buildProductCard(product);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildProductCard(Product product) {
    final imageUrl = product.firstImageUrl.isNotEmpty
        ? product.firstImageUrl
        : product.imageUrl;

    debugPrint(
        'Product: ${product.name}, imageUrl: $imageUrl, images: ${product.images}');

    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          AspectRatio(
            aspectRatio: 1.1,
            child: imageUrl.isNotEmpty
                ? CachedNetworkImage(
                    imageUrl: imageUrl,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: Colors.grey[200],
                      child: const Center(
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: Colors.grey[200],
                      child: const Icon(Icons.image_not_supported, size: 40),
                    ),
                  )
                : Container(
                    color: Colors.grey[200],
                    child: const Icon(Icons.image, size: 40),
                  ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 4.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  product.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'TZS ${product.price.toStringAsFixed(2)}',
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(Icons.star, size: 14, color: Colors.amber[700]),
                    const SizedBox(width: 2),
                    Text(
                      product.rating.toStringAsFixed(1),
                      style: const TextStyle(fontSize: 11, height: 1.2),
                    ),
                    const SizedBox(width: 2),
                    Text(
                      '(${product.ratingCount})',
                      style: TextStyle(
                          fontSize: 11, color: Colors.grey[600], height: 1.2),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Flexible(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: (product.stock ?? 0) > 0
                              ? Colors.green[100]
                              : Colors.red[100],
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          (product.stock ?? 0) > 0
                              ? '${product.stock} in stock'
                              : 'Out of stock',
                          style: TextStyle(
                            color: (product.stock ?? 0) > 0
                                ? Colors.green[700]
                                : Colors.red[700],
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            height: 1.2,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                    ),
                    PopupMenuButton<String>(
                      onSelected: (value) {
                        switch (value) {
                          case 'edit':
                            _navigateToEditProduct(product);
                            break;
                          case 'delete':
                            _showDeleteDialog(product);
                            break;
                        }
                      },
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              const Icon(Icons.edit, color: Colors.blue),
                              const SizedBox(width: 8),
                              Text(AppLocalizations.of(context)!.edit),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete, color: Colors.red),
                              SizedBox(width: 8),
                              Text('Delete',
                                  style: TextStyle(color: Colors.red)),
                            ],
                          ),
                        ),
                      ],
                      icon: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.more_vert, size: 20),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
