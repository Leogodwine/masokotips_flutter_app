import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/product.dart';
import '../../providers/product_provider.dart';
import '../../providers/wishlist_provider.dart';
import '../../providers/cart_provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../utils/logger.dart';

class ProductDetailsScreen extends StatefulWidget {
  final Product product;

  const ProductDetailsScreen({
    Key? key,
    required this.product,
  }) : super(key: key);

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  bool _isLoadingRelated = false;
  List<Product> _relatedProducts = [];

  @override
  void initState() {
    super.initState();
    // Use Future.microtask to ensure we're not in the build phase
    Future.microtask(() {
      if (!mounted) return;
      _loadRelatedProducts();
    });
  }

  /// Fetch related products from the API
  Future<List<Product>> getRelatedProducts(int productId) async {
    try {
      // Fetch related products from the ProductProvider
      return await context
          .read<ProductProvider>()
          .getRelatedProducts(productId);
    } catch (e) {
      throw Exception('Failed to fetch related products: $e');
    }
  }

  /// Load related products and update the state
  Future<void> _loadRelatedProducts() async {
    if (widget.product.id <= 0) {
      Log.e('ProductDetailsScreen: Invalid product ID: ${widget.product.id}');
      return;
    }

    if (!mounted) return;

    setState(() {
      _isLoadingRelated = true;
    });

    try {
      Log.e(
          'ProductDetailsScreen: Loading related products for product ID: ${widget.product.id}');
      final relatedProducts = await getRelatedProducts(widget.product.id);

      if (!mounted) return;

      setState(() {
        _relatedProducts = relatedProducts;
        _isLoadingRelated = false;
      });
    } catch (e) {
      Log.e('ProductDetailsScreen: Error loading related products: $e');
      if (!mounted) return;

      setState(() {
        _isLoadingRelated = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load related products: $e'),
            action: SnackBarAction(
              label: 'RETRY',
              onPressed: _loadRelatedProducts,
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.product.name),
        actions: [
          Consumer<WishlistProvider>(
            builder: (context, wishlistProvider, child) {
              final isInWishlist =
                  wishlistProvider.isInWishlist(widget.product.id);
              return IconButton(
                icon: Icon(
                  isInWishlist ? Icons.favorite : Icons.favorite_border,
                  color: isInWishlist ? Colors.red : Colors.white,
                ),
                onPressed: () {
                  wishlistProvider.toggleWishlist(widget.product);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        isInWishlist
                            ? 'Removed from wishlist'
                            : 'Added to wishlist',
                      ),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image with Hero Animation
            Hero(
              tag: 'home-featured-${widget.product.id}',
              child: CachedNetworkImage(
                imageUrl: widget.product.firstImageUrl.isNotEmpty
                    ? widget.product.firstImageUrl
                    : 'https://via.placeholder.com/300',
                height: 300,
                width: double.infinity,
                fit: BoxFit.cover,
                placeholder: (context, url) {
                  return Container(
                    height: 300,
                    color: Colors.grey[300],
                    child: const Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                },
                errorWidget: (context, url, error) {
                  return Container(
                    height: 300,
                    color: Colors.grey[300],
                    child: const Icon(
                      Icons.error_outline,
                      color: Colors.grey,
                      size: 48,
                    ),
                  );
                },
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product Name and Price Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          widget.product.name,
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                          maxLines: 2, // Limit to 2 lines
                          overflow: TextOverflow
                              .ellipsis, // Add ellipsis if text overflows
                        ),
                      ),
                      const SizedBox(
                          width: 8), // Add spacing between name and price
                      Text(
                        'TZS ${widget.product.price.toStringAsFixed(2)}',
                        style:
                            Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  color: Theme.of(context).primaryColor,
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Rating and Stock Row
                  Row(
                    children: [
                      Icon(
                        Icons.star_rounded,
                        size: 20,
                        color: Colors.amber[700],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        widget.product.rating.toStringAsFixed(1),
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '(${widget.product.ratingCount})',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: (widget.product.stock ?? 0) > 0
                              ? Colors.green[100]
                              : Colors.red[100],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          (widget.product.stock ?? 0) > 0
                              ? 'In Stock (${widget.product.stock})'
                              : 'Out of Stock',
                          style: TextStyle(
                            color: (widget.product.stock ?? 0) > 0
                                ? Colors.green[700]
                                : Colors.red[700],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Description Section
                  Text(
                    'Description',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.product.description,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),

                  // Related Products Section
                  if (_isLoadingRelated)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: CircularProgressIndicator(),
                      ),
                    )
                  else if (_relatedProducts.isEmpty)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text(
                          'No related products found',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    )
                  else
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Related Products',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                        const SizedBox(height: 4),
                        SizedBox(
                          height: 220, // Constrain the height of the ListView
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: _relatedProducts.length,
                            itemBuilder: (context, index) {
                              final product = _relatedProducts[index];
                              return SizedBox(
                                width: 160,
                                child: Card(
                                  clipBehavior: Clip.antiAlias,
                                  child: InkWell(
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
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        AspectRatio(
                                          aspectRatio: 1,
                                          child: CachedNetworkImage(
                                            imageUrl: product.imageUrl,
                                            fit: BoxFit.cover,
                                            placeholder: (context, url) =>
                                                Container(
                                              color: Colors.grey[200],
                                              child: const Center(
                                                child:
                                                    CircularProgressIndicator(),
                                              ),
                                            ),
                                            errorWidget:
                                                (context, url, error) =>
                                                    Container(
                                              color: Colors.grey[200],
                                              child: const Icon(
                                                Icons.error_outline,
                                                color: Colors.grey,
                                              ),
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                product.name,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(
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
