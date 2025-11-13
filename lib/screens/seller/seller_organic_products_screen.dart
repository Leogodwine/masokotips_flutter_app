import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/organic_product.dart';
import '../../services/api_service.dart';
import '../../providers/auth_provider.dart';
import '../../config/api_config.dart';
import '../../utils/logger.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'add_organic_product_screen.dart';
import 'edit_organic_product_screen.dart';

class SellerOrganicProductsScreen extends StatefulWidget {
  const SellerOrganicProductsScreen({Key? key}) : super(key: key);

  @override
  State<SellerOrganicProductsScreen> createState() =>
      _SellerOrganicProductsScreenState();
}

class _SellerOrganicProductsScreenState
    extends State<SellerOrganicProductsScreen> {
  bool _isLoading = false;
  List<OrganicProduct> _organicProducts = [];
  ApiService? _apiService;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeApiService();
    _loadOrganicProducts();
  }

  void _initializeApiService() {
    final authProvider = context.read<AuthProvider>();
    if (authProvider.token != null) {
      _apiService = ApiService(
        baseUrl: ApiConfig.baseUrl,
        apiKey: authProvider.token!,
      );
    }
  }

  Future<void> _loadOrganicProducts() async {
    if (_apiService == null) {
      setState(() {
        _errorMessage = 'API service not initialized';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      Log.e('Fetching seller organic products...');
      final response = await _apiService!.getSellerOrganicProducts();

      Log.e('Seller organic products response: $response');

      if (response['success'] == true && response['data'] != null) {
        final List<dynamic> productsData = response['data'];
        _organicProducts =
            productsData.map((json) => OrganicProduct.fromJson(json)).toList();
        Log.e('Loaded ${_organicProducts.length} organic products');
      } else {
        _errorMessage = 'Failed to fetch organic products';
        Log.e('Failed to fetch seller organic products: $response');
      }
    } catch (e) {
      Log.e('Error fetching seller organic products: $e');
      _errorMessage = e.toString();
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteOrganicProduct(OrganicProduct product) async {
    if (_apiService == null) return;

    try {
      Log.e('Deleting organic product: ${product.name}');
      await _apiService!.deleteOrganicProduct(product.id);

      setState(() {
        _organicProducts.removeWhere((p) => p.id == product.id);
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${product.name} deleted successfully')),
        );
      }
    } catch (e) {
      Log.e('Error deleting organic product: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete product: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Organic Products'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadOrganicProducts,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
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
                        _errorMessage!,
                        style: TextStyle(
                          color: Colors.red[700],
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadOrganicProducts,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : _organicProducts.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.eco,
                            size: 64,
                            color: Colors.green[300],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No Organic Products Yet',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[700],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Start by adding your first organic product',
                            style: TextStyle(
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton.icon(
                            onPressed: () => _navigateToAddProduct(),
                            icon: const Icon(Icons.add),
                            label: const Text('Add Organic Product'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadOrganicProducts,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _organicProducts.length,
                        itemBuilder: (context, index) {
                          final product = _organicProducts[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 16),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      // Product Image
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: product.imageUrl != null
                                            ? CachedNetworkImage(
                                                imageUrl: product.imageUrl!,
                                                width: 80,
                                                height: 80,
                                                fit: BoxFit.cover,
                                                placeholder: (context, url) =>
                                                    Container(
                                                  width: 80,
                                                  height: 80,
                                                  color: Colors.grey[200],
                                                  child:
                                                      const Icon(Icons.image),
                                                ),
                                                errorWidget:
                                                    (context, url, error) =>
                                                        Container(
                                                  width: 80,
                                                  height: 80,
                                                  color: Colors.grey[200],
                                                  child:
                                                      const Icon(Icons.error),
                                                ),
                                              )
                                            : Container(
                                                width: 80,
                                                height: 80,
                                                color: Colors.grey[200],
                                                child: const Icon(Icons.eco),
                                              ),
                                      ),
                                      const SizedBox(width: 16),
                                      // Product Details
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              product.name,
                                              style: const TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              'TZS ${product.price.toStringAsFixed(2)}',
                                              style: TextStyle(
                                                color: Theme.of(context)
                                                    .primaryColor,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              'Stock: ${product.stock}',
                                              style: TextStyle(
                                                color: Colors.grey[600],
                                              ),
                                            ),
                                            if (product.certification !=
                                                null) ...[
                                              const SizedBox(height: 4),
                                              Text(
                                                'Certified: ${product.certification}',
                                                style: TextStyle(
                                                  color: Colors.green[700],
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ],
                                          ],
                                        ),
                                      ),
                                      // Action Buttons
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
                                          const PopupMenuItem(
                                            value: 'edit',
                                            child: Row(
                                              children: [
                                                Icon(Icons.edit),
                                                SizedBox(width: 8),
                                                Text('Edit'),
                                              ],
                                            ),
                                          ),
                                          const PopupMenuItem(
                                            value: 'delete',
                                            child: Row(
                                              children: [
                                                Icon(Icons.delete,
                                                    color: Colors.red),
                                                SizedBox(width: 8),
                                                Text('Delete',
                                                    style: TextStyle(
                                                        color: Colors.red)),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  if (product.description != null) ...[
                                    const SizedBox(height: 12),
                                    Text(
                                      product.description!,
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: product.isActive
                                              ? Colors.green[100]
                                              : Colors.red[100],
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          product.isActive
                                              ? 'Active'
                                              : 'Inactive',
                                          style: TextStyle(
                                            color: product.isActive
                                                ? Colors.green[700]
                                                : Colors.red[700],
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      const Spacer(),
                                      if (product.isFeatured)
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.amber[100],
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          child: Text(
                                            'Featured',
                                            style: TextStyle(
                                              color: Colors.amber[700],
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddProduct,
        backgroundColor: Colors.green,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  void _navigateToAddProduct() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddOrganicProductScreen(),
      ),
    );

    if (result == true) {
      _loadOrganicProducts();
    }
  }

  void _navigateToEditProduct(OrganicProduct product) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditOrganicProductScreen(product: product),
      ),
    );

    if (result == true) {
      _loadOrganicProducts();
    }
  }

  void _showDeleteDialog(OrganicProduct product) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Organic Product'),
        content: Text(
            'Are you sure you want to delete "${product.name}"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteOrganicProduct(product);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
