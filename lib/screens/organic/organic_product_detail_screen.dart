import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../providers/auth_provider.dart';
import '../../providers/cart_provider.dart';
import '../../screens/auth/login_screen.dart';
import '../seller/seller_public_profile_screen.dart' as import_profile;

class OrganicProductDetailScreen extends StatefulWidget {
  final dynamic product;

  const OrganicProductDetailScreen({super.key, required this.product});

  @override
  State<OrganicProductDetailScreen> createState() => _OrganicProductDetailScreenState();
}

class _OrganicProductDetailScreenState extends State<OrganicProductDetailScreen> {
  void _handleAddToCart() {
    final authProvider = context.read<AuthProvider>();
    if (!authProvider.isAuthenticated) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
      return;
    }

    try {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${widget.product.name ?? "Product"} added to cart'),
          backgroundColor: Theme.of(context).primaryColor,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to add: $e'),
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
        title: Text(widget.product.name ?? 'Organic Product'),
        backgroundColor: theme.primaryColor,
        foregroundColor: Colors.white,
        leading: Navigator.canPop(context)
            ? IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              )
            : null,
        actions: [
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
          IconButton(
            icon: const Icon(
              Icons.favorite_border,
              color: Colors.white,
            ),
            onPressed: () {
              if (!context.read<AuthProvider>().isAuthenticated) {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
                return;
              }
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Added to wishlist')),
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
              tag: 'organic-${widget.product.id}',
              child: CachedNetworkImage(
                imageUrl: widget.product.imageUrl ?? '',
                height: 300,
                width: double.infinity,
                fit: BoxFit.cover,
                placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                errorWidget: (context, url, error) => Container(
                  color: Colors.grey[200],
                  child: const Icon(Icons.eco, size: 80, color: Colors.green),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                'Organic Product',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.product.name ?? '',
              style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'TZS ${(widget.product.price ?? 0).toStringAsFixed(2)}',
              style: theme.textTheme.titleLarge?.copyWith(
                color: theme.primaryColor, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            if (widget.product.description != null) ...[
              Text('Description',
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(widget.product.description ?? '', style: theme.textTheme.bodyMedium),
              const SizedBox(height: 16),
            ],

            // Seller info
            if (widget.product.sellerId != null) ...[
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => 
                        import_profile.SellerPublicProfileScreen(sellerId: widget.product.sellerId.toString()),
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
                              widget.product.sellerName ?? 'Seller',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right, color: Colors.grey),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            const SizedBox(height: 16),
            _buildInfoSection('Origin', widget.product.origin),
            _buildInfoSection('Certification', widget.product.certification),
            _buildInfoSection('Shelf Life', widget.product.shelfLife),
            _buildInfoSection('Storage', widget.product.storageConditions),
            if (widget.product.stock != null)
              _buildInfoSection('Stock', '${widget.product.stock}'),

            const SizedBox(height: 24),

            ElevatedButton.icon(
              onPressed: _handleAddToCart,
              icon: const Icon(Icons.add_shopping_cart),
              label: const Text('Add to Cart'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: theme.primaryColor,
              ),
            ),

            const SizedBox(height: 24),

            const Divider(),
            const SizedBox(height: 16),
            Text(
              'Related Products',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Center(
              child: Text(
                'No related products available',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection(String label, String? value) {
    if (value == null || value.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(color: Colors.grey),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}