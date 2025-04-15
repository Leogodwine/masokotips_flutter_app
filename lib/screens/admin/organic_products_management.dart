import 'package:flutter/material.dart';
import 'package:masoko_tips/models/organic_product.dart';
import 'package:masoko_tips/providers/admin_provider.dart';
import 'package:masoko_tips/screens/organic/edit_organic_product_screen.dart';
import 'package:masoko_tips/widgets/loading_indicator.dart';
import 'package:masoko_tips/widgets/cached_network_image_with_cors.dart';
import 'package:provider/provider.dart';

class OrganicProductsManagement extends StatefulWidget {
  const OrganicProductsManagement({super.key});

  @override
  State<OrganicProductsManagement> createState() =>
      _OrganicProductsManagementState();
}

class _OrganicProductsManagementState extends State<OrganicProductsManagement> {
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    try {
      final adminProvider = Provider.of<AdminProvider>(context, listen: false);
      await adminProvider.loadOrganicProducts();
      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load products: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final adminProvider = Provider.of<AdminProvider>(context);
    final products = adminProvider.organicProducts;
    final isLoading = adminProvider.isLoading;
    final error = adminProvider.error;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Organic Products Management'),
        backgroundColor: theme.primaryColor,
        foregroundColor: theme.colorScheme.onPrimary,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadProducts,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _navigateToEditProduct(context),
        icon: const Icon(Icons.add),
        label: const Text('Add Product'),
        backgroundColor: theme.primaryColor,
        foregroundColor: theme.colorScheme.onPrimary,
        elevation: 4,
      ),
      body: !_isInitialized
          ? const Center(child: LoadingIndicator())
          : isLoading
              ? const Center(child: LoadingIndicator())
              : error != null
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            color: theme.colorScheme.error,
                            size: 48,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            error,
                            style: TextStyle(color: theme.colorScheme.error),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _loadProducts,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: theme.primaryColor,
                              foregroundColor: theme.colorScheme.onPrimary,
                            ),
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    )
                  : products.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.eco_outlined,
                                size: 64,
                                color: theme.primaryColor.withAlpha(128),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No organic products available',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                              const SizedBox(height: 24),
                              ElevatedButton.icon(
                                onPressed: () =>
                                    _navigateToEditProduct(context),
                                icon: const Icon(Icons.add),
                                label: const Text('Add Product'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: theme.primaryColor,
                                  foregroundColor: theme.colorScheme.onPrimary,
                                ),
                              ),
                            ],
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: _loadProducts,
                          child: ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: products.length,
                            itemBuilder: (context, index) {
                              final product = products[index];
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
                                    onTap: () => _navigateToEditProduct(context,
                                        product: product),
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
                                                    color: theme.primaryColor,
                                                  ),
                                                ),
                                              ),
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                  horizontal: 8,
                                                  vertical: 4,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: product.isActive
                                                      ? theme
                                                          .colorScheme.primary
                                                          .withOpacity(0.1)
                                                      : theme.colorScheme.error
                                                          .withOpacity(0.1),
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                ),
                                                child: Text(
                                                  product.isActive
                                                      ? 'ACTIVE'
                                                      : 'INACTIVE',
                                                  style: TextStyle(
                                                    color: product.isActive
                                                        ? theme
                                                            .colorScheme.primary
                                                        : theme
                                                            .colorScheme.error,
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                              if (product.isFeatured)
                                                Container(
                                                  margin: const EdgeInsets.only(
                                                      left: 8),
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                    horizontal: 8,
                                                    vertical: 4,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: theme
                                                        .colorScheme.secondary
                                                        .withOpacity(0.1),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            12),
                                                  ),
                                                  child: Text(
                                                    'FEATURED',
                                                    style: TextStyle(
                                                      color: theme.colorScheme
                                                          .secondary,
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                            ],
                                          ),
                                          const SizedBox(height: 8),
                                          if (product.imageUrl != null)
                                            ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              child: CachedNetworkImageWithCors(
                                                imageUrl: product.imageUrl!,
                                                height: 200,
                                                width: double.infinity,
                                                fit: BoxFit.cover,
                                                errorWidget:
                                                    (context, url, error) {
                                                  return Container(
                                                    height: 200,
                                                    color: theme.colorScheme
                                                        .surfaceVariant,
                                                    child: Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        Icon(
                                                          Icons.error_outline,
                                                          size: 48,
                                                          color: theme
                                                              .colorScheme
                                                              .onSurfaceVariant,
                                                        ),
                                                        const SizedBox(
                                                            height: 8),
                                                        Text(
                                                          'Failed to load image',
                                                          style: TextStyle(
                                                            color: theme
                                                                .colorScheme
                                                                .onSurfaceVariant,
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
                                            product.description ?? '',
                                            style:
                                                const TextStyle(fontSize: 16),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 16),
                                          Row(
                                            children: [
                                              Icon(Icons.category,
                                                  size: 16,
                                                  color: theme.primaryColor),
                                              const SizedBox(width: 4),
                                              Expanded(
                                                child: Text(
                                                  'Category: ${product.category?['name'] ?? 'No Category'}',
                                                  style: const TextStyle(
                                                      fontSize: 16),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 8),
                                          Row(
                                            children: [
                                              Icon(Icons.inventory,
                                                  size: 16,
                                                  color: theme.primaryColor),
                                              const SizedBox(width: 4),
                                              Text(
                                                'Stock: ${product.stock}',
                                                style: const TextStyle(
                                                    fontSize: 16),
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
                                                      color:
                                                          theme.primaryColor),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    product.price
                                                        .toStringAsFixed(2),
                                                    style: TextStyle(
                                                      color: theme.primaryColor,
                                                      fontSize: 18,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              Row(
                                                children: [
                                                  IconButton(
                                                    icon:
                                                        const Icon(Icons.edit),
                                                    color: theme.primaryColor,
                                                    onPressed: () =>
                                                        _navigateToEditProduct(
                                                            context,
                                                            product: product),
                                                  ),
                                                  IconButton(
                                                    icon: const Icon(
                                                        Icons.delete),
                                                    color:
                                                        theme.colorScheme.error,
                                                    onPressed: () =>
                                                        _showDeleteConfirmation(
                                                            context, product),
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

  void _navigateToEditProduct(BuildContext context, {OrganicProduct? product}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditOrganicProductScreen(
          product: product,
        ),
      ),
    ).then((_) => _loadProducts());
  }

  void _showDeleteConfirmation(BuildContext context, OrganicProduct product) {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Organic Product'),
        content: Text('Are you sure you want to delete ${product.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
            ),
          ),
          TextButton(
            onPressed: () async {
              final success = await context
                  .read<AdminProvider>()
                  .deleteOrganicProduct(product.id);
              if (success && mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Organic product deleted successfully'),
                    backgroundColor: theme.primaryColor,
                  ),
                );
                _loadProducts();
              }
            },
            child: Text(
              'Delete',
              style: TextStyle(color: theme.colorScheme.error),
            ),
          ),
        ],
      ),
    );
  }
}
