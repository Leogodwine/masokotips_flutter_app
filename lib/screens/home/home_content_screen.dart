import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../providers/product_provider.dart';
import '../../providers/category_provider.dart';
import '../../providers/market_info_provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/wishlist_provider.dart';
// Removed auth provider and register screen imports as CTA was removed
import 'package:masoko_tips/screens/cart/cart_screen.dart';
import '../../models/category.dart';
import 'package:masoko_tips/screens/products/product_list_screen.dart';
import 'package:masoko_tips/screens/products/product_details_screen.dart';
import '../search/search_screen.dart';
import 'dart:async';
import '../../utils/logger.dart';
import '../categories/subcategories_screen.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:masoko_tips/screens/market_info/market_info_screen.dart';
import '../../widgets/market_info_card.dart';
import 'package:masoko_tips/screens/market_info/market_info_detail_screen.dart';
import '../../widgets/friendly_error_display.dart';
import '../../utils/image_upload_helper.dart';

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

    // Start async calls
    _loadData(); // Load featured products
    _loadMarketInfo(); // Load market info

    // Load categories after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Log.e('HomeContentScreen: Starting to load categories...');
      if (!mounted) return;

      final provider = context.read<CategoryProvider>();

      provider.loadMainCategories().whenComplete(() {
        if (!mounted) return;

        final error = provider.error;
        final count = provider.mainCategories.length;

        if (error != null) {
          Log.e('HomeContentScreen: Failed to load categories: $error');

          // Removed SnackBar to prevent showing raw error to user
          // The FriendlyErrorDisplay widget handles user-friendly error display
        } else {
          Log.e('HomeContentScreen: Categories loaded successfully');
          Log.e('HomeContentScreen: Categories count: $count');
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
      Log.e('HomeContentScreen: Loading featured products...');
      final productProvider = context.read<ProductProvider>();
      await productProvider.getFeaturedProducts();
      Log.e('HomeContentScreen: Featured products loaded successfully');
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
          SnackBar(
            content: Text(localizations.failedToLoadMarketInformation),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _buildContent(),
        ],
      ),
    );
  }

  Widget _buildContent() {
    final localizations = AppLocalizations.of(context)!;
    return RefreshIndicator(
      onRefresh: _loadData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Section
            Container(
              padding: const EdgeInsets.all(24.0),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF1B5E20), // Deep forest green
                    Color(0xFF2E7D32), // Green
                    Color(0xFF4CAF50), // Light green
                  ],
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 15,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha(38),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.eco,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        localizations.welcomeTo,
                        style: const TextStyle(
                          fontSize: 24,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'maSOKO',
                            style: TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              height: 1.1,
                            ),
                          ),
                          SizedBox(width: 4),
                          Text(
                            'tips',
                            style: TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFD0FFD6),
                              height: 1.1,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.9,
                        child: Text(
                          localizations.agricultureDescription,
                          style: TextStyle(
                            fontSize: 18,
                            height: 1.4,
                            fontWeight: FontWeight.w400,
                            color: Colors.white.withValues(),
                          ),
                          textAlign: TextAlign.start,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16), // <-- This comma was missing
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 10,
                          offset: Offset(0, 5),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: localizations.searchProducts,
                        prefixIcon:
                            const Icon(Icons.search, color: Colors.grey),
                        suffixIcon: const Icon(Icons.tune,
                            color: Colors.grey, size: 20),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SearchScreen(),
                          ),
                        );
                      },
                      readOnly: true,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Categories Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor.withValues(),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.category,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        localizations.categories,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                  TextButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ProductListScreen(
                            title: 'All Products',
                            categoryId: 0,
                            subcategory: '',
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.arrow_forward),
                    label: Text(localizations.seeAll),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Consumer<CategoryProvider>(
              builder: (context, categoryProvider, child) {
                Log.e('HomeContentScreen: Building categories section');
                Log.e(
                    'HomeContentScreen: isLoading: ${categoryProvider.isLoading}');
                Log.e('HomeContentScreen: error: ${categoryProvider.error}');
                Log.e(
                    'HomeContentScreen: categories count: ${categoryProvider.mainCategories.length}');

                if (categoryProvider.isLoading) {
                  Log.e('HomeContentScreen: Showing loading indicator');
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const CircularProgressIndicator(),
                        const SizedBox(height: 16),
                        Text(localizations.loadingCategories),
                      ],
                    ),
                  );
                }

                /// A user-friendly error display widget with retry support.
                /// This widget is designed to replace technical error messages
                /// with clear, helpful text for end users. It also provides
                /// a retry button for easy recovery from errors like failed API calls.
                if (categoryProvider.error != null) {
                  return FriendlyErrorDisplay(
                    error: categoryProvider.error,
                    onRetry: () {
                      Log.e('HomeContentScreen: Retrying category load');
                      categoryProvider.loadMainCategories();
                    },
                  );
                }

                // Display all 5 main categories from the new API
                final categories = categoryProvider.mainCategories;

                if (categories.isEmpty) {
                  Log.e('HomeContentScreen: No categories found');
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.category_outlined,
                          size: 48,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          localizations.noCategoriesAvailable,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          localizations.checkBackLater,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  );
                }

                Log.e(
                    'HomeContentScreen: Building category grid with ${categories.length} items');
                return AnimationLimiter(
                  child: SizedBox(
                    //height: 400,
                    child: GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        // Line 409
                        crossAxisCount: 2,
                        childAspectRatio: 0.85,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                      ),
                      itemCount: categories.length,
                      itemBuilder: (context, index) {
                        final category = categories[index];
                        Log.e(
                            'HomeContentScreen: Building category: ${category.name}');
                        return AnimationConfiguration.staggeredGrid(
                          position: index,
                          duration: const Duration(milliseconds: 375),
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
            const SizedBox(height: 24),

            // Market Information Section
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor.withValues(),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.trending_up,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          localizations.marketNews,
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const MarketInfoScreen(),
                            ),
                          );
                        },
                        icon: const Icon(Icons.arrow_forward, size: 16),
                        label: Text(localizations.seeAll),
                        style: TextButton.styleFrom(
                          foregroundColor: Theme.of(context).primaryColor,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Consumer<MarketInfoProvider>(
                    builder: (context, marketInfoProvider, child) {
                      if (marketInfoProvider.isLoading) {
                        return SizedBox(
                          height: 240,
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const CircularProgressIndicator(),
                                const SizedBox(height: 16),
                                Text(localizations.loadingMarketNews),
                              ],
                            ),
                          ),
                        );
                      }

                      if (marketInfoProvider.error != null) {
                        return Container(
                          height: 220,
                          decoration: BoxDecoration(
                            color: Colors.red[50],
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.red[200]!,
                              width: 1,
                            ),
                          ),
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.error_outline,
                                  size: 48,
                                  color: Colors.red[400],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  localizations.failedToLoadMarketNews,
                                  style: TextStyle(
                                    color: Colors.red[700],
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  localizations.tapToRetry,
                                  style: TextStyle(
                                    color: Colors.red[500],
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }
                      //Market News Card

                      final marketInfoList = marketInfoProvider.marketInfoList;

                      if (marketInfoList.isEmpty) {
                        return Center(
                            child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            children: [
                              Icon(
                                Icons.newspaper_outlined,
                                size: 64,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                localizations.noMarketNewsAvailable,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ));
                      }

                      return SizedBox(
                        height: 260,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 8),
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
                                      builder: (context) =>
                                          MarketInfoDetailScreen(
                                        marketInfo: marketInfo,
                                      ),
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
                ],
              ),
            ),

            const SizedBox(height: 24),
            // Featured Products Section
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          localizations.featuredProducts,
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
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
                              builder: (context) => const ProductListScreen(
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
                  const SizedBox(height: 16),
                  Consumer<ProductProvider>(
                    builder: (context, productProvider, child) {
                      final featuredProducts = productProvider.featuredProducts;

                      if (featuredProducts.isEmpty) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.inventory_2_outlined,
                                  size: 64,
                                  color: Colors.grey[400],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  localizations.noFeaturedProductsAvailable,
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }

                      return SizedBox(
                        height: 350,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 8),
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
                                      Stack(
                                        children: [
                                          Hero(
                                            tag: 'home-featured-${product.id}',
                                            child: Image.network(
                                              ImageUploadHelper
                                                  .constructFullImageUrl(
                                                      product.firstImageUrl),
                                              height: 160,
                                              width: double.infinity,
                                              fit: BoxFit.cover,
                                              loadingBuilder: (context, child,
                                                  loadingProgress) {
                                                if (loadingProgress == null) {
                                                  return child;
                                                }
                                                return Container(
                                                  height: 160,
                                                  color: Colors.grey[200],
                                                  child: const Center(
                                                      child:
                                                          CircularProgressIndicator()),
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
                                            builder:
                                                (context, wishlistProvider, _) {
                                              final isInWishlist =
                                                  wishlistProvider
                                                      .isInWishlist(product.id);
                                              return Positioned(
                                                top: 8,
                                                right: 8,
                                                child: Material(
                                                  color: Colors.transparent,
                                                  child: InkWell(
                                                    onTap: () {
                                                      wishlistProvider
                                                          .toggleWishlist(
                                                              product);
                                                      ScaffoldMessenger.of(
                                                              context)
                                                          .showSnackBar(
                                                        SnackBar(
                                                          content: Text(
                                                            isInWishlist
                                                                ? localizations
                                                                    .removedFromWishlist
                                                                : localizations
                                                                    .addedToWishlist,
                                                          ),
                                                          duration:
                                                              const Duration(
                                                                  seconds: 2),
                                                        ),
                                                      );
                                                    },
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            20),
                                                    child: Container(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              6),
                                                      decoration:
                                                          const BoxDecoration(
                                                        color: Colors.white,
                                                        shape: BoxShape.circle,
                                                      ),
                                                      child: Icon(
                                                        isInWishlist
                                                            ? Icons.favorite
                                                            : Icons
                                                                .favorite_border,
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
                                                  color: Theme.of(context)
                                                      .primaryColor,
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
                                            heroTag:
                                                'add-to-cart-${product.id}',
                                            onPressed: () {
                                              final cartProvider =
                                                  context.read<CartProvider>();
                                              cartProvider.addToCart(product);

                                              // Show success message
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                SnackBar(
                                                  content: Text(localizations
                                                      .productAddedToCart(
                                                          product.name)),
                                                  duration: const Duration(
                                                      seconds: 2),
                                                  action: SnackBarAction(
                                                    label:
                                                        localizations.viewCart,
                                                    onPressed: () {
                                                      Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                          builder: (context) =>
                                                              const CartScreen(),
                                                        ),
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
                                            child: const Icon(
                                                Icons.add_shopping_cart,
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
                ],
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
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

      default:
        return 'assets/images/consultation.webp'; // fallback image
    }
  }

  // This method builds a category card with a gradient background, icon, and text.
  // It uses the Category model to populate the card with relevant data.
  // The card is wrapped in an InkWell widget to make it tappable, leading to a

  Widget _buildCategoryCard(Category category) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double imageSize =
            constraints.maxWidth * 0.35; // Increased from 0.25 to 0.5

        return Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SubcategoriesScreen(category: category),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(12), // Only one padding
              child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Center(
                      child: Container(
                        width: imageSize, // Adjusted size
                        height: imageSize,
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: category.imageUrl != null &&
                                  category.imageUrl!.isNotEmpty
                              ? Image.network(
                                  ImageUploadHelper.constructFullImageUrl(
                                      category.imageUrl!),
                                  fit: BoxFit.cover,
                                  loadingBuilder:
                                      (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
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
                    ),
                    const SizedBox(height: 8), // Less space
                    Text(
                      category.name,
                      style: TextStyle(
                        fontSize: constraints.maxWidth > 200 ? 16 : 14,
                        fontWeight: FontWeight.bold,
                        height: 1.2, // Add line height for better readability
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    // Display subcategory count
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor.withAlpha(25),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${category.subcategoriesCount} ${category.subcategoriesCount == 1 ? 'subcategory' : 'subcategories'}',
                        style: TextStyle(
                          fontSize: 10,
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ]),
            ),
          ),
        );
      },
    );
  }
}
