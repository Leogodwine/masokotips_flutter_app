import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/product.dart';
import '../../services/product_service.dart';
import '../../providers/auth_provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'add_product_screen.dart';
import '../transport/transport_list_screen.dart';

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
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
          if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    const TransportListScreen(category: 'seller'),
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
            icon: Icon(Icons.directions_car),
            label: 'Transports',
          ),
        ],
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
      body: _buildProductsSection(),
    );
  }

  Widget _buildProductsSection() {
    return _isLoading
        ? const Center(child: CircularProgressIndicator())
        : _errorMessage != null
            ? Center(
                child: Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.red),
                ),
              )
            : _sellerProducts.isEmpty
                ? Center(
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
                  )
                : Column(
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
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
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
                                children: [
                                  // Product Image
                                  AspectRatio(
                                    aspectRatio: 1,
                                    child: CachedNetworkImage(
                                      imageUrl: product.imageUrl,
                                      fit: BoxFit.cover,
                                      placeholder: (context, url) => Container(
                                        color: Colors.grey[200],
                                        child: const Center(
                                          child: CircularProgressIndicator(),
                                        ),
                                      ),
                                      errorWidget: (context, url, error) =>
                                          Container(
                                        color: Colors.grey[200],
                                        child: const Icon(Icons.error),
                                      ),
                                    ),
                                  ),
                                  // Product Details
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Flexible(
                                            child: Text(
                                              product.name,
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            '\$${product.price.toStringAsFixed(2)}',
                                            style: TextStyle(
                                              color: Theme.of(context)
                                                  .primaryColor,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                Icons.star,
                                                size: 16,
                                                color: Colors.amber[700],
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                product.rating
                                                    .toStringAsFixed(1),
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                ),
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                '(${product.ratingCount})',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.grey[600],
                                                ),
                                              ),
                                            ],
                                          ),
                                          const Spacer(),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Flexible(
                                                child: Container(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                    horizontal: 8,
                                                    vertical: 4,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color:
                                                        (product.stock ?? 0) > 0
                                                            ? Colors.green[100]
                                                            : Colors.red[100],
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            12),
                                                  ),
                                                  child: Text(
                                                    (product.stock ?? 0) > 0
                                                        ? 'In Stock (${product.stock})'
                                                        : 'Out of Stock',
                                                    style: TextStyle(
                                                      color: (product.stock ??
                                                                  0) >
                                                              0
                                                          ? Colors.green[700]
                                                          : Colors.red[700],
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              ),
                                              IconButton(
                                                icon: const Icon(
                                                  Icons.delete,
                                                  color: Colors.red,
                                                ),
                                                onPressed: () =>
                                                    _deleteProduct(product),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
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
