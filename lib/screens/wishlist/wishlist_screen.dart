import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/wishlist_provider.dart';
import '../../providers/cart_provider.dart';
import '../products/product_details_screen.dart';
import '../../widgets/error_handler.dart';
import 'package:cached_network_image/cached_network_image.dart';

class WishlistScreen extends StatelessWidget {
  const WishlistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Wishlist'),
        actions: [
          Consumer<WishlistProvider>(
            builder: (context, wishlistProvider, _) {
              if (wishlistProvider.wishlistItems.isEmpty)
                return const SizedBox();
              return IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Clear Wishlist'),
                      content: const Text(
                          'Are you sure you want to clear your wishlist?'),
                      actions: [
                        TextButton(
                          child: const Text('Cancel'),
                          onPressed: () => Navigator.pop(context),
                        ),
                        TextButton(
                          child: const Text('Clear'),
                          onPressed: () {
                            wishlistProvider.clearWishlist();
                            Navigator.pop(context);
                          },
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
      body: Consumer<WishlistProvider>(
        builder: (context, wishlistProvider, _) {
          final wishlistItems = wishlistProvider.wishlistItems;

          if (wishlistItems.isEmpty) {
            return EmptyStateHandler(
              title: 'Your Wishlist is Empty',
              message: 'Items you save to your wishlist will appear here',
              icon: Icons.favorite_border,
              buttonText: 'Browse Products',
              onAction: () => Navigator.pop(context),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: wishlistItems.length,
            itemBuilder: (context, index) {
              final product = wishlistItems[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(8),
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: CachedNetworkImage(
                      imageUrl: product.imageUrl,
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                      errorWidget: (context, url, error) => Container(
                        width: 80,
                        height: 80,
                        color: Colors.grey[300],
                        child: const Icon(Icons.image_not_supported),
                      ),
                    ),
                  ),
                  title: Text(
                    product.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'TZS ${product.price.toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (product.stock == 0)
                        const Text(
                          'Out of Stock',
                          style: TextStyle(color: Colors.red),
                        ),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if ((product.stock ?? 0) > 0)
                        Consumer<CartProvider>(
                          builder: (context, cartProvider, _) {
                            final isInCart = cartProvider.isInCart(product.id);
                            return IconButton(
                              icon: Icon(
                                isInCart
                                    ? Icons.shopping_cart
                                    : Icons.add_shopping_cart,
                                color: isInCart ? Colors.green : null,
                              ),
                              onPressed: () {
                                if (!isInCart) {
                                  cartProvider.addToCart(product);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Added to cart'),
                                      duration: Duration(seconds: 2),
                                    ),
                                  );
                                } else {
                                  Navigator.pushNamed(context, '/cart');
                                }
                              },
                            );
                          },
                        ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () {
                          wishlistProvider.removeFromWishlist(product.id);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Removed from wishlist'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            ProductDetailsScreen(product: product),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
