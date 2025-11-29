import 'package:flutter/material.dart';
import 'package:masoko_tips/models/organic_product.dart';
import 'package:masoko_tips/providers/admin_provider.dart';
import 'package:masoko_tips/screens/organic/edit_organic_product_screen.dart';
import 'package:masoko_tips/widgets/loading_indicator.dart';
import 'package:masoko_tips/widgets/cached_network_image_with_cors.dart';
import 'package:provider/provider.dart';
import '../../utils/image_upload_helper.dart';

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

      // Check if user is authenticated before loading admin data
      if (!adminProvider.isAdmin) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please login as admin to access organic products'),
              backgroundColor: Colors.orange,
            ),
          );
          setState(() {
            _isInitialized = true;
          });
        }
        return;
      }

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
        setState(() {
          _isInitialized = true;
        });
      }
    }
  }

  void _navigateToEditProduct(BuildContext context, {OrganicProduct? product}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditOrganicProductScreen(product: product),
      ),
    ).then((_) => _loadProducts());
  }

  String _getProductImageUrl(OrganicProduct product) {
    // Try image_url first, then fallback to images array
    String? imageUrl;
    if (product.imageUrl != null && product.imageUrl!.isNotEmpty) {
      imageUrl = product.imageUrl!;
    } else if (product.images != null && product.images!.isNotEmpty) {
      imageUrl = product.images!.first;
    }

    // Use the same URL construction as the home screen
    if (imageUrl != null && imageUrl.isNotEmpty) {
      return ImageUploadHelper.constructFullImageUrl(imageUrl);
    }

    return '';
  }

  String _getImageErrorMessage(dynamic error) {
    final errorString = error.toString().toLowerCase();
    if (errorString.contains('404') || errorString.contains('not found')) {
      return 'Image not found on server';
    } else if (errorString.contains('403') ||
        errorString.contains('unauthorized')) {
      return 'Access denied to image';
    } else if (errorString.contains('timeout')) {
      return 'Image loading timed out';
    } else if (errorString.contains('network')) {
      return 'Network error - check connection';
    } else if (errorString.contains('500') || errorString.contains('server')) {
      return 'Server error - try again later';
    } else {
      return 'Failed to load image';
    }
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
              final adminProvider = context.read<AdminProvider>();
              final navigator = Navigator.of(context);
              final scaffoldMessenger = ScaffoldMessenger.of(context);
              final success =
                  await adminProvider.deleteOrganicProduct(product.id);
              if (success && context.mounted) {
                navigator.pop(context);
                scaffoldMessenger.showSnackBar(
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
          : !adminProvider.isAdmin
              ? Center(
                  child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.lock_outline,
                      size: 64,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Admin Authentication Required',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Please login as an administrator to manage organic products',
                      style: TextStyle(
                        fontSize: 14,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () {
                        // Navigate to admin login
                        Navigator.pushReplacementNamed(context, '/admin-login');
                      },
                      icon: const Icon(Icons.login),
                      label: const Text('Login as Admin'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.primaryColor,
                        foregroundColor: theme.colorScheme.onPrimary,
                      ),
                    ),
                  ],
                ))
              : isLoading
                  ? const Center(child: LoadingIndicator())
                  : error != null
                      ? Center(
                          child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.error_outline,
                              size: 48,
                              color: theme.colorScheme.error,
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
                        ))
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
                                    foregroundColor:
                                        theme.colorScheme.onPrimary,
                                  ),
                                ),
                              ],
                            ))
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
                                        onTap: () => _navigateToEditProduct(
                                            context,
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
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color:
                                                            theme.primaryColor,
                                                      ),
                                                    ),
                                                  ),
                                                  Container(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                      horizontal: 8,
                                                      vertical: 4,
                                                    ),
                                                    decoration: BoxDecoration(
                                                      color: product.isActive
                                                          ? theme.colorScheme
                                                              .primary
                                                              .withValues(
                                                                  alpha: 0.1)
                                                          : theme
                                                              .colorScheme.error
                                                              .withValues(
                                                                  alpha: 0.1),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              12),
                                                    ),
                                                    child: Text(
                                                      product.isActive
                                                          ? 'ACTIVE'
                                                          : 'INACTIVE',
                                                      style: TextStyle(
                                                        color: product.isActive
                                                            ? theme.colorScheme
                                                                .primary
                                                            : theme.colorScheme
                                                                .error,
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                  ),
                                                  // ✅ Use collection-if here
                                                  if (product.isFeatured)
                                                    Container(
                                                      margin:
                                                          const EdgeInsets.only(
                                                              left: 8),
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                        horizontal: 8,
                                                        vertical: 4,
                                                      ),
                                                      decoration: BoxDecoration(
                                                        color: theme.colorScheme
                                                            .secondary
                                                            .withValues(
                                                                alpha: 0.1),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(12),
                                                      ),
                                                      child: Text(
                                                        'FEATURED',
                                                        style: TextStyle(
                                                          color: theme
                                                              .colorScheme
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

                                              // 🧱 Image Section with Badges
                                              Stack(
                                                children: [
                                                  ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
                                                    child:
                                                        CachedNetworkImageWithCors(
                                                      imageUrl:
                                                          _getProductImageUrl(
                                                              product),
                                                      height: 200,
                                                      width: double.infinity,
                                                      fit: BoxFit.cover,
                                                      errorWidget: (context,
                                                          url, error) {
                                                        debugPrint(
                                                            '❌ Image load failed for product ${product.id}: $url');
                                                        debugPrint(
                                                            '❌ Error type: ${error.runtimeType}');
                                                        debugPrint(
                                                            '❌ Error details: $error');

                                                        // Check if it's a decode error (corrupted image)
                                                        if (error
                                                                .toString()
                                                                .contains(
                                                                    'decode') ||
                                                            error
                                                                .toString()
                                                                .contains(
                                                                    'unimplemented')) {
                                                          return Container(
                                                            height: 200,
                                                            color: theme
                                                                .colorScheme
                                                                .surfaceContainerHighest,
                                                            child: Column(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .center,
                                                              children: [
                                                                Icon(
                                                                  Icons
                                                                      .broken_image,
                                                                  size: 48,
                                                                  color: theme
                                                                      .colorScheme
                                                                      .error,
                                                                ),
                                                                const SizedBox(
                                                                    height: 8),
                                                                Text(
                                                                  'Corrupted image file',
                                                                  style:
                                                                      TextStyle(
                                                                    fontSize:
                                                                        12,
                                                                    color: theme
                                                                        .colorScheme
                                                                        .error,
                                                                  ),
                                                                  textAlign:
                                                                      TextAlign
                                                                          .center,
                                                                ),
                                                                const SizedBox(
                                                                    height: 4),
                                                                Text(
                                                                  'Please re-upload this image',
                                                                  style:
                                                                      TextStyle(
                                                                    fontSize:
                                                                        10,
                                                                    color: theme
                                                                        .colorScheme
                                                                        .onSurfaceVariant,
                                                                  ),
                                                                  textAlign:
                                                                      TextAlign
                                                                          .center,
                                                                ),
                                                              ],
                                                            ),
                                                          );
                                                        }

                                                        // Handle other types of errors
                                                        return Container(
                                                          height: 200,
                                                          color: theme
                                                              .colorScheme
                                                              .surfaceContainerHighest,
                                                          child: Column(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .center,
                                                            children: [
                                                              Image.asset(
                                                                'assets/images/logo.webp',
                                                                width: 80,
                                                                height: 80,
                                                                fit: BoxFit
                                                                    .contain,
                                                                errorBuilder:
                                                                    (context,
                                                                        error,
                                                                        stackTrace) {
                                                                  return Icon(
                                                                    Icons
                                                                        .eco_outlined,
                                                                    size: 48,
                                                                    color: theme
                                                                        .colorScheme
                                                                        .primary,
                                                                  );
                                                                },
                                                              ),
                                                              const SizedBox(
                                                                  height: 8),
                                                              Text(
                                                                _getImageErrorMessage(
                                                                    error),
                                                                style:
                                                                    TextStyle(
                                                                  fontSize: 14,
                                                                  color: theme
                                                                      .colorScheme
                                                                      .onSurfaceVariant,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        );
                                                      },
                                                    ),
                                                  ),

                                                  // ✅ Status Badge - Top Right
                                                  Positioned(
                                                    top: 8,
                                                    right: 8,
                                                    child: Container(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                        horizontal: 8,
                                                        vertical: 4,
                                                      ),
                                                      decoration: BoxDecoration(
                                                        color: product.isActive
                                                            ? theme.colorScheme
                                                                .primary
                                                            : theme.colorScheme
                                                                .error,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(12),
                                                      ),
                                                      child: Text(
                                                        product.isActive
                                                            ? 'ACTIVE'
                                                            : 'INACTIVE',
                                                        style: const TextStyle(
                                                          fontSize: 10,
                                                          color: Colors.white,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                    ),
                                                  ),

                                                  // ✅ Featured Badge - Bottom Right
                                                  if (product.isFeatured)
                                                    Positioned(
                                                      bottom: 8,
                                                      right: 8,
                                                      child: Container(
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                          horizontal: 8,
                                                          vertical: 4,
                                                        ),
                                                        decoration:
                                                            BoxDecoration(
                                                          color: theme
                                                              .colorScheme
                                                              .secondary,
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(12),
                                                        ),
                                                        child: const Text(
                                                          'FEATURED',
                                                          style: TextStyle(
                                                            fontSize: 10,
                                                            color: Colors.white,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                ],
                                              ),

                                              const SizedBox(height: 16),

                                              // Description
                                              Text(
                                                product.description ?? '',
                                                style: const TextStyle(
                                                    fontSize: 16),
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              const SizedBox(height: 16),

                                              // Category
                                              Row(
                                                children: [
                                                  Icon(Icons.category,
                                                      size: 16,
                                                      color:
                                                          theme.primaryColor),
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

                                              // Stock
                                              Row(
                                                children: [
                                                  Icon(Icons.inventory,
                                                      size: 16,
                                                      color:
                                                          theme.primaryColor),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    'Stock: ${product.stock}',
                                                    style: const TextStyle(
                                                        fontSize: 16),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 8),

                                              // Price + Actions
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Row(
                                                    children: [
                                                      Icon(Icons.attach_money,
                                                          size: 16,
                                                          color: theme
                                                              .primaryColor),
                                                      const SizedBox(width: 4),
                                                      Text(
                                                        product.price
                                                            .toStringAsFixed(2),
                                                        style: TextStyle(
                                                          color: theme
                                                              .primaryColor,
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
                                                        icon: const Icon(
                                                            Icons.edit),
                                                        color:
                                                            theme.primaryColor,
                                                        onPressed: () =>
                                                            _navigateToEditProduct(
                                                          context,
                                                          product: product,
                                                        ),
                                                      ),
                                                      IconButton(
                                                        icon: const Icon(
                                                            Icons.delete),
                                                        color: theme
                                                            .colorScheme.error,
                                                        onPressed: () =>
                                                            _showDeleteConfirmation(
                                                                context,
                                                                product),
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
