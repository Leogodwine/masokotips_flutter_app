import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../providers/organic_product_provider.dart';
import '../models/organic_product.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../widgets/loading_indicator.dart';
import '../widgets/error_view.dart';
import '../widgets/empty_state_view.dart';
import '../widgets/cached_network_image_with_cors.dart';
import 'package:masoko_tips/l10n/app_localizations.dart';

class OrganicProductsScreen extends StatefulWidget {
  const OrganicProductsScreen({Key? key}) : super(key: key);

  @override
  State<OrganicProductsScreen> createState() => _OrganicProductsScreenState();
}

class _OrganicProductsScreenState extends State<OrganicProductsScreen> {
  @override
  void initState() {
    super.initState();
    // Load products when the screen is first shown
    _loadProducts();

    // Listen for auth state changes
    final authProvider = context.read<AuthProvider>();
    authProvider.addListener(_onAuthStateChanged);
  }

  @override
  void dispose() {
    // Remove the auth state listener when the widget is disposed
    final authProvider = context.read<AuthProvider>();
    authProvider.removeListener(_onAuthStateChanged);
    super.dispose();
  }

  void _onAuthStateChanged() {
    // Reload products when auth state changes (e.g., after login)
    if (mounted) {
      _loadProducts();
    }
  }

  Future<void> _loadProducts() async {
    if (!mounted) return;
    final provider = context.read<OrganicProductProvider>();
    await provider.loadProducts();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Organic Products',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onPrimary,
          ),
        ),
        backgroundColor: theme.primaryColor,
        elevation: 0,
        iconTheme: IconThemeData(color: theme.colorScheme.onPrimary),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () =>
                context.read<OrganicProductProvider>().loadProducts(),
            color: theme.colorScheme.onPrimary,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'organic_product_add_button',
        onPressed: () {
          // Capture service_provider before async operation
          final provider = context.read<OrganicProductProvider>();
          Navigator.pushNamed(context, '/organic-products/add').then((_) {
            if (mounted) {
              provider.loadProducts();
            }
          });
        },
        icon: const Icon(Icons.add),
        label: Text(AppLocalizations.of(context)!.addProduct),
        backgroundColor: theme.primaryColor,
        foregroundColor: theme.colorScheme.onPrimary,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      body: Consumer<OrganicProductProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const LoadingIndicator();
          }

          if (provider.error != null) {
            return ErrorView(
              error: provider.error!,
              onRetry: () => provider.loadProducts(),
            );
          }

          if (provider.products.isEmpty) {
            return EmptyStateView(
              icon: Icons.eco_outlined,
              title: 'No Organic Products',
              message: 'Add your first organic product to get started',
              actionLabel: 'Add Product',
              onAction: () {
                // Capture service_provider before async operation
                final provider = context.read<OrganicProductProvider>();
                Navigator.pushNamed(context, '/organic-products/add').then((_) {
                  if (mounted) {
                    provider.loadProducts();
                  }
                });
              },
            );
          }

          return RefreshIndicator(
            onRefresh: () => provider.loadProducts(),
            child: AnimationLimiter(
              child: GridView.builder(
                padding: const EdgeInsets.all(12),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.7, // Adjusted to be more compact
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: provider.products.length,
                itemBuilder: (context, index) {
                  final product = provider.products[index];
                  return AnimationConfiguration.staggeredGrid(
                    position: index,
                    duration: const Duration(milliseconds: 375),
                    columnCount: 2,
                    child: ScaleAnimation(
                      child: FadeInAnimation(
                        child: _buildProductCard(context, product),
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProductCard(BuildContext context, OrganicProduct product) {
    final theme = Theme.of(context);
    final isOutOfStock = product.stock <= 0;
    final priceText = 'TZS ${product.price.toStringAsFixed(2)}';
    final stockText =
        isOutOfStock ? 'Out of Stock' : '${product.stock} in stock';

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          // Capture service_provider before async operation
          final provider = context.read<OrganicProductProvider>();
          Navigator.pushNamed(
            context,
            '/organic-products/edit',
            arguments: product,
          ).then((_) {
            if (mounted) {
              provider.loadProducts();
            }
          });
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Product Image - Even more compact
            AspectRatio(
              aspectRatio: 0.9, // More compact aspect ratio
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CachedNetworkImageWithCors(
                    imageUrl: product.imageUrl ?? '',
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                    placeholder: (context, url) => Container(
                      color: Colors.grey[200],
                      child: const Center(
                        child: SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 1.5),
                        ),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: Colors.grey[200],
                      child: const Icon(Icons.error, size: 20),
                    ),
                  ),
                  if (product.isFeatured)
                    Positioned(
                      top: 4,
                      right: 4,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 1,
                        ),
                        decoration: BoxDecoration(
                          color: theme.primaryColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.star,
                              size: 8,
                              color: Colors.white,
                            ),
                            SizedBox(width: 1),
                            Text(
                              'Featured',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 7,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
            // Product Details - Even more compact
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  4.0, 2.0, 4.0, 2.0), // Reduced padding
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Product name with tighter constraints
                  ConstrainedBox(
                    constraints:
                        const BoxConstraints(maxHeight: 34), // Reduced from 40
                    child: Text(
                      product.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11, // Reduced from 12
                        height: 1.1,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 1), // Reduced from 2
                  // Price with smaller font and tighter line height
                  Text(
                    priceText,
                    style: TextStyle(
                      color: theme.primaryColor,
                      fontSize: 12, // Reduced from 14
                      fontWeight: FontWeight.bold,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 4), // Reduced from 6
                  // Stock and actions row - minimal height
                  SizedBox(
                    height: 22, // Fixed height to prevent overflow
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Stock status - minimal
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 3,
                            vertical: 0,
                          ),
                          decoration: BoxDecoration(
                            color: isOutOfStock
                                ? Colors.red[100]
                                : Colors.green[100],
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            stockText,
                            style: TextStyle(
                              color: isOutOfStock
                                  ? Colors.red[700]
                                  : Colors.green[700],
                              fontSize: 7,
                              fontWeight: FontWeight.w500,
                              height: 1.0,
                            ),
                          ),
                        ),
                        // Action buttons - minimal
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Edit button - minimal
                            GestureDetector(
                              onTap: () {
                                // Capture provider before async operation
                                final provider =
                                    context.read<OrganicProductProvider>();
                                Navigator.pushNamed(
                                  context,
                                  '/organic-products/edit',
                                  arguments: product,
                                ).then((_) {
                                  if (mounted) {
                                    provider.loadProducts();
                                  }
                                });
                              },
                              child: const Padding(
                                padding: EdgeInsets.all(2.0),
                                child: Icon(Icons.edit,
                                    size: 12, color: Colors.blue),
                              ),
                            ),
                            // Delete button - minimal
                            GestureDetector(
                              onTap: () =>
                                  _showDeleteConfirmation(context, product),
                              child: const Padding(
                                padding: EdgeInsets.all(2.0),
                                child: Icon(Icons.delete,
                                    size: 12, color: Colors.red),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showDeleteConfirmation(
      BuildContext context, OrganicProduct product) async {
    final provider = context.read<OrganicProductProvider>();
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.deleteProduct),
        content: Text(
            'Are you sure you want to delete "${product.name}"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: Text(AppLocalizations.of(context)!.delete),
          ),
        ],
      ),
    );

    final successMessage = AppLocalizations.of(context)!.productDeletedSuccessfully;
    
    if (confirmed == true && mounted) {
      try {
        await provider.deleteProduct(product.id);
        if (mounted) {
          scaffoldMessenger.showSnackBar(
            SnackBar(
              content: Text(successMessage),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          scaffoldMessenger.showSnackBar(
            SnackBar(
              content: Text('Error deleting product: $e'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 5),
            ),
          );
        }
      }
    }
  }
}
