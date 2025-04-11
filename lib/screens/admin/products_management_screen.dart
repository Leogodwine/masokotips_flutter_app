import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/product.dart';
import '../../providers/admin_provider.dart';
import 'admin_product_form_screen.dart';
import 'package:masoko_tips/widgets/cached_network_image_with_cors.dart';

class AdminProductsManagementScreen extends StatefulWidget {
  const AdminProductsManagementScreen({Key? key}) : super(key: key);

  @override
  State<AdminProductsManagementScreen> createState() =>
      _AdminProductsManagementScreenState();
}

class _AdminProductsManagementScreenState
    extends State<AdminProductsManagementScreen> {
  bool _isLoading = false;
  List<Product> _products = [];
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final adminProvider = context.read<AdminProvider>();
      await adminProvider.loadProducts();
      setState(() {
        _products = adminProvider.products;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteProduct(int productId) async {
    try {
      final adminProvider = context.read<AdminProvider>();
      final success = await adminProvider.deleteProduct(productId);
      if (success) {
        setState(() {
          _products.removeWhere((product) => product.id == productId);
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Product deleted successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting product: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showDeleteConfirmationDialog(int productId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Product'),
        content: const Text('Are you sure you want to delete this product?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteProduct(productId);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Products Management'),
        elevation: 0,
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadProducts,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AdminProductFormScreen(),
            ),
          );
          _loadProducts();
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Product'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        elevation: 4,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text('Error: $_error'))
              : _products.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.shopping_bag_outlined,
                            size: 64,
                            color:
                                Theme.of(context).primaryColor.withOpacity(0.5),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No products available',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton.icon(
                            onPressed: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const AdminProductFormScreen(),
                                ),
                              );
                              _loadProducts();
                            },
                            icon: const Icon(Icons.add),
                            label: const Text('Add Product'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context).primaryColor,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadProducts,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _products.length,
                        itemBuilder: (context, index) {
                          final product = _products[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 16),
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(12),
                                onTap: () async {
                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          AdminProductFormScreen(
                                              product: product),
                                    ),
                                  );
                                  _loadProducts();
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              product.name,
                                              style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                                color: Theme.of(context)
                                                    .primaryColor,
                                              ),
                                            ),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: product.isActive
                                                  ? Colors.green[100]
                                                  : Colors.grey[100],
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: Text(
                                              product.isActive
                                                  ? 'ACTIVE'
                                                  : 'INACTIVE',
                                              style: TextStyle(
                                                color: product.isActive
                                                    ? Colors.green[700]
                                                    : Colors.grey[700],
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          if (product.isFeatured)
                                            Container(
                                              margin: const EdgeInsets.only(
                                                  left: 8),
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                horizontal: 8,
                                                vertical: 4,
                                              ),
                                              decoration: BoxDecoration(
                                                color: Colors.amber[100],
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              child: const Text(
                                                'FEATURED',
                                                style: TextStyle(
                                                  color: Colors.amber,
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      if (product.images != null &&
                                          product.images!.isNotEmpty)
                                        ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          child: CachedNetworkImageWithCors(
                                            imageUrl: product.images![0],
                                            height: 200,
                                            width: double.infinity,
                                            fit: BoxFit.cover,
                                            errorWidget: (context, url, error) {
                                              return Container(
                                                height: 200,
                                                color: Colors.grey[300],
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Icon(Icons.error_outline,
                                                        size: 48,
                                                        color:
                                                            Colors.grey[600]),
                                                    const SizedBox(height: 8),
                                                    Text(
                                                      'Failed to load image',
                                                      style: TextStyle(
                                                        color: Colors.grey[600],
                                                        fontSize: 14,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                      const SizedBox(height: 16),
                                      Text(
                                        product.description,
                                        style: const TextStyle(fontSize: 16),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 16),
                                      Row(
                                        children: [
                                          Icon(Icons.category,
                                              size: 16,
                                              color: Theme.of(context)
                                                  .primaryColor),
                                          const SizedBox(width: 4),
                                          Expanded(
                                            child: Text(
                                              'Category: ${product.categoryName ?? 'Uncategorized'}',
                                              style:
                                                  const TextStyle(fontSize: 16),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          Icon(Icons.inventory,
                                              size: 16,
                                              color: Theme.of(context)
                                                  .primaryColor),
                                          const SizedBox(width: 4),
                                          Text(
                                            'Stock: ${product.stock} ${product.unit ?? ''}',
                                            style:
                                                const TextStyle(fontSize: 16),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            children: [
                                              Icon(Icons.attach_money,
                                                  size: 16,
                                                  color: Theme.of(context)
                                                      .primaryColor),
                                              const SizedBox(width: 4),
                                              Text(
                                                product.price
                                                    .toStringAsFixed(2),
                                                style: TextStyle(
                                                  color: Theme.of(context)
                                                      .primaryColor,
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                          Row(
                                            children: [
                                              IconButton(
                                                icon: const Icon(Icons.edit),
                                                color: Theme.of(context)
                                                    .primaryColor,
                                                onPressed: () async {
                                                  await Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          AdminProductFormScreen(
                                                              product: product),
                                                    ),
                                                  );
                                                  _loadProducts();
                                                },
                                              ),
                                              IconButton(
                                                icon: const Icon(Icons.delete),
                                                color: Colors.red,
                                                onPressed: () =>
                                                    _showDeleteConfirmationDialog(
                                                        product.id),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
    );
  }
}
