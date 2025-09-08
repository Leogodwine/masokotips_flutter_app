import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/service.dart';
import '../../providers/cart_provider.dart';
import '../cart/cart_screen.dart';
import '../../providers/favorites_provider.dart';
import '../../models/product.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ServiceDetailScreen extends StatefulWidget {
  final Service service;

  const ServiceDetailScreen({
    super.key,
    required this.service,
  });

  @override
  State<ServiceDetailScreen> createState() => _ServiceDetailScreenState();
}

class _ServiceDetailScreenState extends State<ServiceDetailScreen> {
  @override
  Widget build(BuildContext context) {
    final favorites = Provider.of<FavoritesProvider>(context);
    final isFavorite = favorites.isFavorite(widget.service.id.toString());

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.service.title ?? 'Service Details'),
        actions: [
          IconButton(
            icon: Icon(
              isFavorite ? Icons.favorite : Icons.favorite_border,
              color: isFavorite ? Colors.red : null,
            ),
            onPressed: () {
              favorites.toggleFavorite(widget.service);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    isFavorite
                        ? '${widget.service.title} removed from favorites'
                        : '${widget.service.title} added to favorites',
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Service Image
            Hero(
              tag: 'service-${widget.service.id}',
              child: CachedNetworkImage(
                imageUrl: widget.service.imageUrl ??
                    'https://via.placeholder.com/250',
                height: 250,
                width: double.infinity,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  height: 250,
                  color: Colors.grey[300],
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  height: 250,
                  color: Colors.grey[300],
                  child: const Icon(
                    Icons.error,
                    color: Colors.grey,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Service Title and Price
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          widget.service.title ?? 'No Title',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                      ),
                      Text(
                        'TZS ${widget.service.price.toStringAsFixed(2)}',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: Theme.of(context).primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Add to Cart Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // Create a Product object from the service
                        final product = Product(
                          id: widget.service.id,
                          name: widget.service.title ?? 'Service',
                          description:
                              widget.service.description ?? 'No description',
                          price: widget.service.price,
                          stock: 1,
                          isActive: true,
                          isFeatured: false,
                          categoryId: widget.service.categoryId,
                          userId: 0,
                          images: [widget.service.imageUrl ?? ''],
                          rating: 0.0,
                          ratingCount: 0,
                          createdAt: DateTime.now(),
                          updatedAt: DateTime.now(),
                          slug: (widget.service.title ?? 'service')
                              .toLowerCase()
                              .replaceAll(' ', '-'),
                          imageUrl: widget.service.imageUrl ?? '',
                        );

                        // Add the product to the cart
                        context.read<CartProvider>().addToCart(product);

                        // Show a SnackBar
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content:
                                Text('${widget.service.title} added to cart'),
                            action: SnackBarAction(
                              label: 'VIEW CART',
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const CartScreen(),
                                  ),
                                );
                              },
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.shopping_cart),
                      label: const Text('Add to Cart'),
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
}
