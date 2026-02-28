import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:provider/provider.dart';

import 'package:masoko_tips/screens/cart/cart_screen.dart';
import 'package:masoko_tips/screens/market_info/market_info_detail_screen.dart';
import 'package:masoko_tips/screens/market_info/market_info_screen.dart';
import 'package:masoko_tips/screens/products/product_details_screen.dart';
import 'package:masoko_tips/screens/products/product_list_screen.dart';
import 'package:masoko_tips/screens/search/search_screen.dart';

import '../../models/category.dart';
import '../../providers/cart_provider.dart';
import '../../providers/category_provider.dart';
import '../../providers/market_info_provider.dart';
import '../../providers/product_provider.dart';
import '../../providers/wishlist_provider.dart';
import '../../utils/image_upload_helper.dart';
import '../../utils/logger.dart';
import '../../widgets/friendly_error_display.dart';
import '../../widgets/market_info_card.dart';
import '../categories/subcategories_screen.dart';

class HomeContentScreen extends StatefulWidget {
  const HomeContentScreen({Key? key}) : super(key: key);

  @override
  State<HomeContentScreen> createState() => _HomeContentScreenState();
}

class _HomeContentScreenState extends State<HomeContentScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();

    _loadData();
    _loadMarketInfo();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final provider = context.read<CategoryProvider>();
      provider.loadMainCategories().whenComplete(() {
        if (!mounted) return;
        final error = provider.error;
        if (error != null) {
          Log.e('HomeContentScreen: Failed to load categories: $error');
        }
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    if (!mounted) return;

    try {
      final productProvider = context.read<ProductProvider>();
      await productProvider.getFeaturedProducts();
    } catch (e) {
      Log.e('HomeContentScreen: Error loading featured products: $e');
      if (mounted) {
        final localizations = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text(localizations.errorLoadingFeaturedProducts(e.toString())),
            action: SnackBarAction(
              label: localizations.retry.toUpperCase(),
              onPressed: _loadData,
            ),
          ),
        );
      }
    }
  }

  Future<void> _loadMarketInfo() async {
    if (!mounted) return;

    try {
      final marketInfoProvider = context.read<MarketInfoProvider>();
      await marketInfoProvider.loadMarketInfo();
    } catch (e) {
      Log.e('HomeContentScreen: Error loading market info: $e');
      if (mounted) {
        final localizations = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(localizations.failedToLoadMarketInformation)),
        );
      }
    }
  }

  Future<void> _refreshAll() async {
    await Future.wait([
      _loadData(),
      _loadMarketInfo(),
      context.read<CategoryProvider>().loadMainCategories(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(children: [_buildContent()]),
    );
  }

  Widget _buildContent() {
    final localizations = AppLocalizations.of(context)!;

    return RefreshIndicator(
      onRefresh: _refreshAll,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCompactHeader(localizations),
            const SizedBox(height: 18),

            // =========================
            // Categories Section
            // =========================
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: _sectionHeader(
                icon: Icons.category,
                title: localizations.categories,
                seeAllText: localizations.seeAll,
                onSeeAll: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ProductListScreen(
                        title: 'All Products',
                        categoryId: 0,
                        subcategory: 'all',
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),

            Consumer<CategoryProvider>(
              builder: (context, categoryProvider, child) {
                if (categoryProvider.isLoading) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Center(
                      child: Column(
                        children: [
                          const CircularProgressIndicator(),
                          const SizedBox(height: 12),
                          Text(localizations.loadingCategories),
                        ],
                      ),
                    ),
                  );
                }

                if (categoryProvider.error != null) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: FriendlyErrorDisplay(
                      error: categoryProvider.error,
                      onRetry: () => categoryProvider.loadMainCategories(),
                    ),
                  );
                }

                final categories =
                    categoryProvider.mainCategories.take(6).toList();

                // Sort categories in specific order: Products, Organic Products, Agricultural Services, Transport, Food And Beverages, Market Information
                categories.sort((a, b) {
                  const order = [
                    'Products',
                    'Organic Products',
                    'Agricultural Services',
                    'Transport',
                    'Food And Beverages',
                    'Market Information',
                  ];
                  final indexA = order.indexWhere((name) =>
                      a.name.toLowerCase().contains(name.toLowerCase()));
                  final indexB = order.indexWhere((name) =>
                      b.name.toLowerCase().contains(name.toLowerCase()));
                  // If category not in our list, put it at the end
                  final finalA = indexA >= 0 ? indexA : 999;
                  final finalB = indexB >= 0 ? indexB : 999;
                  return finalA.compareTo(finalB);
                });

                if (categories.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(Icons.category_outlined,
                              size: 48, color: Colors.grey[400]),
                          const SizedBox(height: 12),
                          Text(
                            localizations.noCategoriesAvailable,
                            style: TextStyle(
                                fontSize: 16, color: Colors.grey[600]),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            localizations.checkBackLater,
                            style: TextStyle(
                                fontSize: 13, color: Colors.grey[500]),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return AnimationLimiter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        // More compact than your original 0.85
                        childAspectRatio: 1.08,
                        crossAxisSpacing: 14,
                        mainAxisSpacing: 14,
                      ),
                      itemCount: categories.length,
                      itemBuilder: (context, index) {
                        final category = categories[index];
                        return AnimationConfiguration.staggeredGrid(
                          position: index,
                          duration: const Duration(milliseconds: 260),
                          columnCount: 2,
                          child: ScaleAnimation(
                            child: FadeInAnimation(
                              child: _buildCategoryCard(category),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 22),

            // =========================
            // Market Information Section
            // =========================
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: _sectionHeader(
                icon: Icons.trending_up,
                title: localizations.marketNews,
                seeAllText: localizations.seeAll,
                onSeeAll: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const MarketInfoScreen()),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Consumer<MarketInfoProvider>(
                builder: (context, marketInfoProvider, child) {
                  if (marketInfoProvider.isLoading) {
                    return SizedBox(
                      height: 220,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const CircularProgressIndicator(),
                            const SizedBox(height: 12),
                            Text(localizations.loadingMarketNews),
                          ],
                        ),
                      ),
                    );
                  }

                  if (marketInfoProvider.error != null) {
                    return Container(
                      height: 190,
                      decoration: BoxDecoration(
                        color: Colors.red[50],
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.red[200]!, width: 1),
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.error_outline,
                                size: 44, color: Colors.red[400]),
                            const SizedBox(height: 12),
                            Text(
                              localizations.failedToLoadMarketNews,
                              style: TextStyle(
                                color: Colors.red[700],
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              localizations.tapToRetry,
                              style: TextStyle(
                                  color: Colors.red[500], fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  final marketInfoList = marketInfoProvider.marketInfoList;

                  if (marketInfoList.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Center(
                        child: Column(
                          children: [
                            Icon(Icons.newspaper_outlined,
                                size: 56, color: Colors.grey[400]),
                            const SizedBox(height: 12),
                            Text(
                              localizations.noMarketNewsAvailable,
                              style: TextStyle(
                                  fontSize: 15, color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return SizedBox(
                    height: 240,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      itemCount: marketInfoList.length,
                      itemBuilder: (context, index) {
                        final marketInfo = marketInfoList[index];
                        return Container(
                          width: 300,
                          margin: const EdgeInsets.symmetric(horizontal: 8),
                          child: MarketInfoCard(
                            marketInfo: marketInfo,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => MarketInfoDetailScreen(
                                      marketInfo: marketInfo),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 22),

            // =========================
            // Featured Products Section
            // =========================
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      localizations.featuredProducts,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ProductListScreen(
                            title: 'Featured Products',
                            categoryId: 0,
                            subcategory: 'featured',
                          ),
                        ),
                      );
                    },
                    child: Text(localizations.seeAll),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            Consumer<ProductProvider>(
              builder: (context, productProvider, child) {
                final featuredProducts = productProvider.featuredProducts;

                if (featuredProducts.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(Icons.inventory_2_outlined,
                              size: 56, color: Colors.grey[400]),
                          const SizedBox(height: 12),
                          Text(
                            localizations.noFeaturedProductsAvailable,
                            style: TextStyle(
                                fontSize: 15, color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return SizedBox(
                  height: 340,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    itemCount: featuredProducts.length,
                    itemBuilder: (context, index) {
                      final product = featuredProducts[index];

                      return Container(
                        width: 200,
                        margin: const EdgeInsets.symmetric(horizontal: 8),
                        child: Card(
                          elevation: 2,
                          clipBehavior: Clip.antiAlias,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      ProductDetailsScreen(product: product),
                                ),
                              );
                            },
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Stack(
                                  children: [
                                    Hero(
                                      tag: 'home-featured-${product.id}',
                                      child: Image.network(
                                        ImageUploadHelper.constructFullImageUrl(
                                            product.firstImageUrl),
                                        height: 160,
                                        width: double.infinity,
                                        fit: BoxFit.cover,
                                        loadingBuilder:
                                            (context, child, progress) {
                                          if (progress == null) return child;
                                          return Container(
                                            height: 160,
                                            color: Colors.grey[200],
                                            child: const Center(
                                              child:
                                                  CircularProgressIndicator(),
                                            ),
                                          );
                                        },
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                          return Container(
                                            height: 160,
                                            color: Colors.grey[200],
                                            child: const Icon(
                                                Icons.broken_image,
                                                size: 40),
                                          );
                                        },
                                      ),
                                    ),
                                    Consumer<WishlistProvider>(
                                      builder: (context, wishlistProvider, _) {
                                        final isInWishlist = wishlistProvider
                                            .isInWishlist(product.id);
                                        return Positioned(
                                          top: 8,
                                          right: 8,
                                          child: Material(
                                            color: Colors.transparent,
                                            child: InkWell(
                                              onTap: () {
                                                wishlistProvider
                                                    .toggleWishlist(product);
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                  SnackBar(
                                                    content: Text(
                                                      isInWishlist
                                                          ? localizations
                                                              .removedFromWishlist
                                                          : localizations
                                                              .addedToWishlist,
                                                    ),
                                                    duration: const Duration(
                                                        seconds: 2),
                                                  ),
                                                );
                                              },
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.all(6),
                                                decoration: const BoxDecoration(
                                                  color: Colors.white,
                                                  shape: BoxShape.circle,
                                                ),
                                                child: Icon(
                                                  isInWishlist
                                                      ? Icons.favorite
                                                      : Icons.favorite_border,
                                                  color: isInWishlist
                                                      ? Colors.red
                                                      : Colors.grey[700],
                                                  size: 20,
                                                ),
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          product.name,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 15,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'TZS ${product.price.toStringAsFixed(2)}',
                                          style: TextStyle(
                                            fontSize: 16,
                                            color:
                                                Theme.of(context).primaryColor,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      right: 8.0, bottom: 8.0),
                                  child: Align(
                                    alignment: Alignment.bottomRight,
                                    child: FloatingActionButton.small(
                                      heroTag: 'add-to-cart-${product.id}',
                                      onPressed: () {
                                        final cartProvider =
                                            context.read<CartProvider>();
                                        cartProvider.addToCart(product);

                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              localizations.productAddedToCart(
                                                  product.name),
                                            ),
                                            duration:
                                                const Duration(seconds: 2),
                                            action: SnackBarAction(
                                              label: localizations.viewCart,
                                              onPressed: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (_) =>
                                                          const CartScreen()),
                                                );
                                              },
                                            ),
                                          ),
                                        );
                                      },
                                      backgroundColor:
                                          Theme.of(context).primaryColor,
                                      foregroundColor: Colors.white,
                                      elevation: 2,
                                      child: const Icon(Icons.add_shopping_cart,
                                          size: 20),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // start of _buildCompactHeader
  Widget _buildCompactHeader(AppLocalizations localizations) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF1B5E20),
            Color(0xFF2E7D32),
            Color(0xFF4CAF50),
          ],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(18),
          bottomRight: Radius.circular(18),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Brand row ONLY (no cart, no home)
            const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'maSOKO',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    height: 1.0,
                    letterSpacing: 0.2,
                  ),
                ),
                SizedBox(width: 3),
                Text(
                  'tips',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFFD0FFD6),
                    height: 1.0,
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 6),

            // 🔥 Bigger, clearer tagline
            Text(
              localizations.agricultureDescription,
              maxLines: 2, // ✅ allow wrap
              overflow: TextOverflow.fade, // smoother than ellipsis
              softWrap: true,
              style: TextStyle(
                fontSize: 16.5,
                color: Colors.white.withAlpha(235),
                fontWeight: FontWeight.w500,
                height: 1.19, // 🔥 tighter lines
              ),
            ),

            const SizedBox(height: 8),

            // Slim search pill
            Container(
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(999),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                readOnly: true,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SearchScreen()),
                  );
                },
                decoration: InputDecoration(
                  hintText: localizations.searchProducts,
                  prefixIcon:
                      const Icon(Icons.search, color: Colors.grey, size: 20),
                  suffixIcon:
                      const Icon(Icons.tune, color: Colors.grey, size: 18),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(999),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  // end of _buildCompactHeader

  Widget _sectionHeader({
    required IconData icon,
    required String title,
    required String seeAllText,
    required VoidCallback onSeeAll,
  }) {
    final theme = Theme.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: theme.primaryColor.withAlpha(25),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: theme.primaryColor, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        TextButton.icon(
          onPressed: onSeeAll,
          icon: const Icon(Icons.arrow_forward, size: 16),
          label: Text(seeAllText),
        ),
      ],
    );
  }

  String _getCategoryImage(String categoryName) {
    switch (categoryName.toLowerCase()) {
      case 'products':
        return 'assets/images/cereals.webp';
      case 'market information':
        return 'assets/images/market_information.webp';
      case 'transport':
        return 'assets/images/transport.webp';
      case 'organic products':
        return 'assets/images/vegetables.webp';
      case 'agricultural services':
        return 'assets/images/consultation.webp';
      case 'food and beverages':
        return 'assets/images/food_and_beverages.png';
      default:
        return 'assets/images/consultation.webp';
    }
  }

  Widget _buildCategoryCard(Category category) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final theme = Theme.of(context);

        final double imageSize =
            constraints.maxWidth * 0.30; // smaller -> shorter card
        final int count = category.subcategoriesCount;

        return Card(
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => SubcategoriesScreen(category: category),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: imageSize,
                    height: imageSize,
                    decoration: BoxDecoration(
                      color: theme.primaryColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: (category.imageUrl != null &&
                              category.imageUrl!.isNotEmpty)
                          ? Image.network(
                              ImageUploadHelper.constructFullImageUrl(
                                  category.imageUrl!),
                              fit: BoxFit.cover,
                              loadingBuilder: (context, child, progress) {
                                if (progress == null) return child;
                                return Container(
                                  color: Colors.grey[200],
                                  child: const Center(
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2),
                                  ),
                                );
                              },
                              errorBuilder: (context, error, stackTrace) {
                                return Image.asset(
                                  _getCategoryImage(category.name),
                                  fit: BoxFit.cover,
                                );
                              },
                            )
                          : Image.asset(
                              _getCategoryImage(category.name),
                              fit: BoxFit.cover,
                            ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    category.name,
                    style: TextStyle(
                      fontSize: constraints.maxWidth > 200 ? 15 : 13,
                      fontWeight: FontWeight.w700,
                      height: 1.15,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                  if (count > 0) ...[
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: theme.primaryColor.withAlpha(25),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '$count ${count == 1 ? 'item' : 'items'}',
                        style: TextStyle(
                          fontSize: 10,
                          color: theme.primaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
