import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../models/product.dart';
import '../../providers/auth_provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/product_provider.dart';
import '../../providers/wishlist_provider.dart';
import '../../screens/auth/login_screen.dart';
import '../../utils/logger.dart';
import '../../screens/subscription/subscription_screen.dart';
import '../../l10n/app_localizations.dart';
import '../seller/seller_public_profile_screen.dart' as import_profile;
import '../../screens/reviews/reviews_widget.dart';

class ProductDetailsScreen extends StatefulWidget {
  final Product product;

  const ProductDetailsScreen({Key? key, required this.product})
      : super(key: key);

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  bool _isLoadingRelated = false;
  List<Product> _relatedProducts = [];
  // Removed unused _selectedQuantity field

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (!mounted) return;
      // Skip loading related products for transports, organic, and food/beverages
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!widget.product.isTransport &&
            !widget.product.isOrganic &&
            !widget.product.isFoodBeverage) {
          _loadRelatedProducts();
        }
      });
    });
  }

  Future<void> _loadRelatedProducts() async {
    try {
      setState(() => _isLoadingRelated = true);
      final related = await context
          .read<ProductProvider>()
          .getRelatedProducts(widget.product.id);
      if (mounted) {
        setState(() {
          _relatedProducts = related;
          _isLoadingRelated = false;
        });
      }
    } catch (e) {
      // Silently handle errors - don't show error to user
      // Just show "No related products available" instead
      Log.e(
          'Error loading related products: $e - this is normal for organic products');
      if (mounted) {
        setState(() => _isLoadingRelated = false);
      }
    }
  }

  String _getLocalizedProductName(String productName) {
    // For now, return the product name as-is since product names are dynamic
    // In a full implementation, this could map common product types to localized versions
    return productName;
  }

  void _handleAddToCart() {
    final authProvider = context.read<AuthProvider>();
    if (!authProvider.isAuthenticated) {
      Navigator.push(
          context, MaterialPageRoute(builder: (_) => const LoginScreen()));
      return;
    }

    try {
      final cartProvider = context.read<CartProvider>();
      cartProvider.addToCart(widget.product);

      if (!mounted) return;

      // Simple confirmation message - cart icon in navbar will show the count
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              AppLocalizations.of(context)!.addedToCart),
          backgroundColor: Theme.of(context).primaryColor,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              AppLocalizations.of(context)!.failedToAddToCart(e.toString())),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(_getLocalizedProductName(widget.product.name)),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        leading: Navigator.canPop(context)
            ? IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              )
            : null,
        actions: [
          // Subscribe button for authenticated users
          Consumer<AuthProvider>(
            builder: (context, authProvider, child) {
              if (!authProvider.isAuthenticated) {
                return const SizedBox.shrink();
              }
              return IconButton(
                icon: const Icon(Icons.star, color: Colors.amber),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const SubscriptionScreen(),
                    ),
                  );
                },
                tooltip: 'Subscribe for Premium Features',
              );
            },
          ),
          // Cart icon with badge
          Consumer<CartProvider>(
            builder: (context, cartProvider, child) {
              return Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.shopping_cart),
                    onPressed: () {
                      Navigator.pushNamed(context, '/cart');
                    },
                  ),
                  if (cartProvider.itemCount > 0)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          '${cartProvider.itemCount}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
          Consumer<WishlistProvider>(
            builder: (context, wishlistProvider, child) {
              final isFavorite =
                  wishlistProvider.isInWishlist(widget.product.id);
              return IconButton(
                icon: Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: isFavorite ? Colors.red : Colors.white,
                ),
                onPressed: () =>
                    wishlistProvider.toggleWishlist(widget.product),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Hero(
              tag: 'home-featured-${widget.product.id}',
              child: CachedNetworkImage(
                imageUrl: widget.product.firstImageUrl,
                height: 300,
                width: double.infinity,
                fit: BoxFit.cover,
                placeholder: (context, url) =>
                    const Center(child: CircularProgressIndicator()),
                errorWidget: (context, url, error) => const Icon(Icons.error),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              widget.product.name,
              style: theme.textTheme.headlineSmall
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'TZS ${widget.product.price.toStringAsFixed(2)}',
              style: theme.textTheme.titleLarge?.copyWith(
                  color: theme.primaryColor, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            // Seller info
            if (widget.product.user != null) ...[
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => 
                        import_profile.SellerPublicProfileScreen(sellerId: widget.product.userId.toString()),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundImage: widget.product.sellerAvatar != null
                            ? NetworkImage(widget.product.sellerAvatar!)
                            : null,
                        child: widget.product.sellerAvatar == null
                            ? const Icon(Icons.person)
                            : null,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Seller',
                              style: TextStyle(
                                fontSize: 12, color: Colors.grey),
                            ),
                            Text(
                              widget.product.sellerName,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            if (widget.product.sellerLocation != null)
                              Text(
                                widget.product.sellerLocation!,
                                style: const TextStyle(
                                  fontSize: 12, color: Colors.grey),
                              ),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right, color: Colors.grey),
                    ],
                  ),
                ),
              ),
            ],
            const SizedBox(height: 16),
            Text(AppLocalizations.of(context)!.description,
                style: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(widget.product.description, style: theme.textTheme.bodyMedium),
            const SizedBox(height: 16),

            // ADD TO CART BUTTON
            ElevatedButton.icon(
              onPressed: _handleAddToCart,
              icon: const Icon(Icons.add_shopping_cart),
              label: Text(AppLocalizations.of(context)!.addToCart),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: theme.primaryColor,
              ),
            ),

            const SizedBox(height: 24),

            const Divider(),
            const SizedBox(height: 16),
            ReviewsWidget(
              reviewableId: widget.product.id,
              reviewableType: 'App\\Models\\Product',
            ),
            const SizedBox(height: 16),
            const Divider(),

            const SizedBox(height: 24),

            // RELATED PRODUCTS
            _isLoadingRelated
                ? const Center(child: CircularProgressIndicator())
                : _relatedProducts.isNotEmpty
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppLocalizations.of(context)!.relatedProducts,
                            style: theme.textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            height: 250,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: _relatedProducts.length,
                              itemBuilder: (context, index) {
                                final product = _relatedProducts[index];
                                return InkWell(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            ProductDetailsScreen(
                                                product: product),
                                      ),
                                    );
                                  },
                                  child: Container(
                                    width: 160,
                                    margin: const EdgeInsets.only(right: 12),
                                    child: Card(
                                      clipBehavior: Clip.antiAlias,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          AspectRatio(
                                            aspectRatio: 1,
                                            child: CachedNetworkImage(
                                              imageUrl: product.firstImageUrl,
                                              fit: BoxFit.cover,
                                              placeholder: (context, url) =>
                                                  const Center(
                                                      child:
                                                          CircularProgressIndicator()),
                                              errorWidget:
                                                  (context, url, error) =>
                                                      const Icon(Icons.error),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(8),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  product.name,
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                // Seller info in related
                                                if (product.user != null) ...[
                                                  const SizedBox(height: 4),
                                                  Row(
                                                    children: [
                                                      CircleAvatar(
                                                        radius: 8,
                                                        backgroundImage:
                                                            product.sellerAvatar !=
                                                                    null
                                                                ? NetworkImage(
                                                                    product.sellerAvatar!)
                                                                : null,
                                                        child:
                                                            product.sellerAvatar ==
                                                                    null
                                                                ? const Icon(
                                                                    Icons.person,
                                                                    size: 8)
                                                                : null,
                                                      ),
                                                      const SizedBox(
                                                          width: 4),
                                                      Expanded(
                                                        child: Text(
                                                          product.sellerName,
                                                          maxLines: 1,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          style:
                                                              const TextStyle(
                                                            fontSize: 10,
                                                            color: Colors.grey,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                                const SizedBox(height: 4),
                                                Text(
                                                  'TZS ${product.price.toStringAsFixed(2)}',
                                                  style: TextStyle(
                                                    color: theme.primaryColor,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      )
                    : Center(
                        child: Text(
                            AppLocalizations.of(context)!.noRelatedProducts))
          ],
        ),
      ),
    );
  }
}

