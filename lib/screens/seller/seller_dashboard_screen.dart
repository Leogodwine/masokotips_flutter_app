import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/product.dart';
import '../../services/product_service.dart';
import '../../providers/auth_provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'add_product_screen.dart';
import 'edit_product_screen.dart';
import 'seller_orders_screen.dart';
import 'seller_organic_products_screen.dart';
import 'seller_transport_screen.dart';

class SellerDashboardScreen extends StatefulWidget {
  const SellerDashboardScreen({Key? key}) : super(key: key);

  @override
  State<SellerDashboardScreen> createState() => _SellerDashboardScreenState();
}

class _SellerDashboardScreenState extends State<SellerDashboardScreen> {
  bool _isLoading = false;
  List<Product> _sellerProducts = [];
  final ProductService _productService = ProductService();
  String? _errorMessage;
  String _selectedCategory = 'All';
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
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
      print('Loading seller products...');
      final products = await _productService.getSellerProducts();
      print('Loaded ${products.length} products');
      setState(() {
        _sellerProducts = products;
      });
    } catch (e) {
      print('Error loading seller products: $e');
      setState(() {
        _errorMessage = 'Failed to load products: $e';
      });
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

    // If product was deleted (result is true), refresh the list
    if (result == true) {
      _loadSellerProducts();
    }
  }

  Future<void> _deleteProduct(Product product) async {
    try {
      setState(() {
        _isLoading = true;
      });

      await _productService.deleteProduct(product.id);
      setState(() {
        _sellerProducts.removeWhere((p) => p.id == product.id);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${product.name} deleted successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete product: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Seller Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadSellerProducts,
          ),
        ],
      ),
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
            if (index == 1) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SellerOrdersScreen(),
                ),
              ).then((_) {
                setState(() {
                  _selectedIndex = 0;
                });
              });
            } else if (index == 2) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SellerTransportScreen(),
                ),
              ).then((_) {
                setState(() {
                  _selectedIndex = 0;
                });
              });
            } else if (index == 3) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SellerOrganicProductsScreen(),
                ),
              ).then((_) {
                setState(() {
                  _selectedIndex = 0;
                });
              });
            }
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.inventory),
              label: 'Products',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.shopping_bag),
              label: 'Orders',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.directions_car),
              label: 'Transports',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.eco),
              label: 'Organic',
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
                        print(
                            'Product added callback received: ${product.name}');
                        setState(() {
                          _sellerProducts.add(product);
                          print(
                              'Product added to list. Total products: ${_sellerProducts.length}');
                        });
                      },
                      productService: _productService,
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.add),
              label: const Text('Add Product'),
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
              elevation: 4,
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: _buildProductsSection(),
    );
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
              label: const Text('Add Product'),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // Category Filter
        Container(
          padding: const EdgeInsets.all(16),
          child: DropdownButtonFormField<String>(
            value: _selectedCategory,
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
        // Products Grid
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.65,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: _filteredProducts.length,
            itemBuilder: (context, index) {
              final product = _filteredProducts[index];
              return Card(
                clipBehavior: Clip.antiAlias,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Product Image with slightly reduced height
                    AspectRatio(
                      aspectRatio: 1.1, // Slightly taller than square
                      child: CachedNetworkImage(
                        imageUrl: product.imageUrl,
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
                          child: const Icon(Icons.error, size: 20),
                        ),
                      ),
                    ),
                    // Product Details with adjusted padding
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8.0, vertical: 6.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Product name with tighter line height
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
                          // Price with smaller font
                          Text(
                            'TZS ${product.price.toStringAsFixed(2)}',
                            style: TextStyle(
                              color: Theme.of(context).primaryColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 2), // Reduced spacing
                          // Rating row with tighter spacing
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Icon(Icons.star,
                                  size: 14, color: Colors.amber[700]),
                              const SizedBox(width: 2),
                              Text(
                                product.rating.toStringAsFixed(1),
                                style:
                                    const TextStyle(fontSize: 11, height: 1.2),
                              ),
                              const SizedBox(width: 2),
                              Text(
                                '(${product.ratingCount})',
                                style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey[600],
                                    height: 1.2),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          // Stock and action buttons row
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // Stock status with smaller text and tighter padding
                              Container(
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
                              // Action buttons with reduced size and spacing
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit,
                                        color: Colors.blue, size: 18),
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(
                                      minWidth: 24,
                                      minHeight: 24,
                                    ),
                                    iconSize: 18,
                                    onPressed: () =>
                                        _navigateToEditProduct(product),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete,
                                        color: Colors.red, size: 18),
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(
                                      minWidth: 24,
                                      minHeight: 24,
                                    ),
                                    iconSize: 18,
                                    onPressed: () => _deleteProduct(product),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
