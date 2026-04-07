import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/product_provider.dart';
import '../products/product_details_screen.dart';
import 'package:masoko_tips/widgets/cached_network_image_with_cors.dart';
import '../../utils/logger.dart';
import '../../l10n/app_localizations.dart';

class ProductListScreen extends StatefulWidget {
  final String title;
  final int categoryId;
  final String subcategory;

  const ProductListScreen({
    Key? key,
    required this.title,
    required this.categoryId,
    required this.subcategory,
  }) : super(key: key);

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    if (!mounted) return;

    // Capture the service_provider before async gap to avoid BuildContext issues
    final productProvider = context.read<ProductProvider>();

    setState(() {
      _isLoading = true;
    });

    try {
      Log.e(
          'Loading products for category: ${widget.categoryId}, subcategory: ${widget.subcategory}');

      // Check if this is a "featured" request
      if (widget.subcategory.toLowerCase() == 'featured') {
        // Load featured products
        await productProvider.loadFeaturedProducts();
        // Copy featured products to products list for display
        if (!mounted) return;
        final featuredProducts = productProvider.featuredProducts;
        productProvider.setProducts(featuredProducts);
      } else if (widget.subcategory.toLowerCase() == 'all') {
        // Load all products from all categories
        await productProvider.loadProducts();
      } else {
        await productProvider.loadProductsByCategory(
            widget.categoryId, widget.subcategory);
      }
    } catch (e) {
      Log.e('Error loading products: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.errorLoadingProducts),
            action: SnackBarAction(
              label: AppLocalizations.of(context)!.retry,
              onPressed: _loadProducts,
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadProducts,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadProducts,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Consumer<ProductProvider>(
                builder: (context, productProvider, child) {
                  final products = productProvider.products;

                  if (products.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.inventory_2_outlined,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            AppLocalizations.of(context)!.noProductsInCategory,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            AppLocalizations.of(context)!.checkBackLater,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.7,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      final product = products[index];
                      return GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                ProductDetailsScreen(product: product),
                          ),
                        ),
                        child: Card(
                          elevation: 2,
                          clipBehavior: Clip.antiAlias,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CachedNetworkImageWithCors(
                                //imageUrl: product.imageUrl,
                                imageUrl: product.firstImageUrl,
                                height: 140,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => Container(
                                  height: 140,
                                  color: Colors.grey[100],
                                  child: const Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                ),
                                errorWidget: (context, url, error) => Container(
                                  height: 140,
                                  color: Colors.grey[100],
                                  child: const Icon(
                                    Icons.image_not_supported_outlined,
                                    size: 32,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Flexible(
                                        child: Text(
                                          product.name,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                            height: 1.2,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'TZS ${product.price.toStringAsFixed(2)}',
                                        style: TextStyle(
                                          color: Theme.of(context).primaryColor,
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      if ((product.stock ?? 0) > 0) ...[
                                        const SizedBox(height: 2),
                                        Text(
                                          AppLocalizations.of(context)!
                                              .inStock(product.stock ?? 0),
                                          style: TextStyle(
                                            color: Colors.green[700],
                                            fontSize: 11,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
      ),
    );
  }
}
