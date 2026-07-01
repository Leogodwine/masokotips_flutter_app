import 'dart:async';

import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:provider/provider.dart';
import '../../utils/extensions.dart';

import 'package:masoko_tips/screens/cart/cart_screen.dart';
import 'package:masoko_tips/screens/market_info/market_info_detail_screen.dart';
import 'package:masoko_tips/screens/market_info/market_info_screen.dart';
import 'package:masoko_tips/screens/products/product_details_screen.dart';
import 'package:masoko_tips/screens/products/product_list_screen.dart';
import 'package:masoko_tips/screens/search/search_screen.dart';
import 'package:masoko_tips/screens/transport/transport_details_screen.dart';
import 'package:masoko_tips/screens/transport/transport_list_screen.dart';
import 'package:masoko_tips/screens/marketplace/marketplace_screen.dart';
import 'package:masoko_tips/screens/seller/seller_public_profile_screen.dart' as import_profile;

import '../../models/buying_request.dart';
import '../../models/category.dart';
import '../../providers/cart_provider.dart';
import '../../providers/category_provider.dart';
import '../../providers/market_info_provider.dart';
import '../../providers/product_provider.dart';
import '../../providers/transport_provider.dart';
import '../../providers/wishlist_provider.dart';
import '../../utils/image_upload_helper.dart';
import '../../utils/logger.dart';
import '../../widgets/friendly_error_display.dart';
import '../../widgets/market_demand_card.dart';
import '../../widgets/market_info_card.dart';
import '../buyer/market_demand_detail_screen.dart';
import '../categories/subcategories_screen.dart';
import '../../widgets/rating_stars.dart';
import '../../models/service.dart';
import '../../services/api_service.dart';
import '../services/service_detail_screen.dart';

class HomeContentScreen extends StatefulWidget {
  const HomeContentScreen({Key? key}) : super(key: key);

  @override
  State<HomeContentScreen> createState() => _HomeContentScreenState();
}

class _HomeContentScreenState extends State<HomeContentScreen> {
  final TextEditingController _searchController = TextEditingController();

  // Debounce mechanism to prevent notification spam
  DateTime? _lastErrorNotificationTime;
  static const _errorNotificationCooldown = Duration(seconds: 10);

  // Track consecutive failures to only show after multiple attempts
  int _consecutiveLoadFailures = 0;
  static const _failureThreshold = 2;

  List<Service> _featuredServices = [];
  bool _isServicesLoading = false;
  String? _servicesError;

  // Market Demands
  List<BuyingRequest> _marketDemands = [];
  bool _isDemandsLoading = false;
  String? _demandsError;

  bool _shouldShowErrorNotification() {
    final now = DateTime.now();
    if (_lastErrorNotificationTime == null) {
      return true;
    }
    return now.difference(_lastErrorNotificationTime!) >
        _errorNotificationCooldown;
  }

  void _recordErrorNotification() {
    _lastErrorNotificationTime = DateTime.now();
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      
      _loadData();
      _loadMarketInfo();
      _loadTransports();
      _loadFeaturedServices();
      _loadMarketDemands();

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
      // Reset failure counter on success
      _consecutiveLoadFailures = 0;
    } catch (e) {
      Log.e('HomeContentScreen: Error loading featured products: $e');
      _consecutiveLoadFailures++;

      // Only show notification after multiple consecutive failures and with debounce
      if (mounted &&
          _consecutiveLoadFailures >= _failureThreshold &&
          _shouldShowErrorNotification()) {
        _recordErrorNotification();
        final localizations = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text(localizations.errorLoadingFeaturedProducts(e.toFriendlyError)),
            action: SnackBarAction(
              label: localizations.retry.toUpperCase(),
              onPressed: _loadData,
            ),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Future<void> _loadTransports() async {
    if (!mounted) return;

    try {
      final transportProvider = context.read<TransportProvider>();
      await transportProvider.getFeaturedTransports();
      // Reset failure counter on success
      _consecutiveLoadFailures = 0;
    } catch (e) {
      Log.e('HomeContentScreen: Error loading featured transports: $e');
      _consecutiveLoadFailures++;
    }
  }

  Future<void> _loadFeaturedServices() async {
    if (!mounted) return;

    setState(() {
      _isServicesLoading = true;
      _servicesError = null;
    });

    try {
      final apiService = context.read<ApiService>();
      final response = await apiService.getPublicRequest('services/featured');
      
      if (!mounted) return;

      if (response.containsKey('data') && response['data'] is List) {
        final List<dynamic> list = response['data'];
        setState(() {
          _featuredServices = list.map((json) => Service.fromJson(json)).toList();
          _isServicesLoading = false;
        });
      } else {
        setState(() {
          _isServicesLoading = false;
          _servicesError = 'Oops! We couldn\'t find any featured services at the moment.';
        });
      }
    } catch (e) {
      Log.e('HomeContentScreen: Error loading featured services: $e');
      if (mounted) {
        setState(() {
          _isServicesLoading = false;
          _servicesError = e.toFriendlyError;
        });
      }
    }
  }

  Future<void> _loadMarketInfo() async {
    if (!mounted) return;

    try {
      final marketInfoProvider = context.read<MarketInfoProvider>();
      await marketInfoProvider.loadMarketInfo();
      // Reset failure counter on success
      _consecutiveLoadFailures = 0;
    } catch (e) {
      Log.e('HomeContentScreen: Error loading market info: $e');
      _consecutiveLoadFailures++;

      // Only show notification after multiple consecutive failures and with debounce
      if (mounted &&
          _consecutiveLoadFailures >= _failureThreshold &&
          _shouldShowErrorNotification()) {
        _recordErrorNotification();
        final localizations = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(localizations.failedToLoadMarketInformation),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Future<void> _loadMarketDemands() async {
    if (!mounted) return;
    setState(() {
      _isDemandsLoading = true;
      _demandsError = null;
    });
    try {
      final apiService = context.read<ApiService>();
      final response =
          await apiService.getPublicRequest('market-demands?per_page=10');
      if (!mounted) return;
      if (response.containsKey('data') && response['data'] is List) {
        setState(() {
          _marketDemands = (response['data'] as List)
              .map((j) => BuyingRequest.fromJson(j))
              .toList();
          _isDemandsLoading = false;
        });
      } else {
        setState(() {
          _isDemandsLoading = false;
          _demandsError = 'No procurement requests available.';
        });
      }
    } catch (e) {
      Log.e('HomeContentScreen: Error loading market demands: $e');
      if (mounted) {
        setState(() {
          _isDemandsLoading = false;
          _demandsError = e.toFriendlyError;
        });
      }
    }
  }

  Future<void> _refreshAll() async {
    try {
      await context.read<CategoryProvider>().loadMainCategories();
      await _loadData();
      await _loadMarketInfo();
      await _loadTransports();
      await _loadFeaturedServices();
      await _loadMarketDemands();
      _consecutiveLoadFailures = 0;
    } catch (e) {
      Log.e('HomeContentScreen: Error during refresh: $e');
    }
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
                seeAllText: 'View All', // Updated as requested
                onSeeAll: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const MarketplaceScreen(),
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
                  height: 350,
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
                                            fontSize: 14,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            RatingStars(rating: product.rating, size: 14),
                                            const SizedBox(width: 4),
                                            Text(
                                              product.rating.toStringAsFixed(1),
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey[600],
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            if (product.ratingCount > 0)
                                              Text(
                                                ' (${product.ratingCount})',
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  color: Colors.grey[500],
                                                ),
                                              ),
                                          ],
                                        ),
                                        // Seller info
                                        if (product.user != null || product.userId != 0) ...[
                                          const SizedBox(height: 4),
                                          InkWell(
                                            onTap: () {
                                              final String? sellerId = product.user?['id']?.toString() ??
                                                  (product.userId != 0 ? product.userId.toString() : null);
                                              if (sellerId != null) {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) => import_profile
                                                        .SellerPublicProfileScreen(
                                                            sellerId: sellerId),
                                                  ),
                                                );
                                              }
                                            },
                                            child: Row(
                                              children: [
                                                CircleAvatar(
                                                  radius: 10,
                                                  backgroundImage: product.sellerAvatar != null
                                                      ? NetworkImage(
                                                          product.sellerAvatar!)
                                                      : null,
                                                  child: product.sellerAvatar == null
                                                      ? const Icon(Icons.person,
                                                          size: 12)
                                                      : null,
                                                ),
                                                const SizedBox(width: 4),
                                                Expanded(
                                                  child: Text(
                                                    product.sellerName,
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                    style: const TextStyle(
                                                      fontSize: 11,
                                                      color: Colors.grey,
                                                      decoration: TextDecoration.underline,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
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

            // =========================
            // Market Demands Section
            // =========================
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: _sectionHeader(
                icon: Icons.campaign_outlined,
                title: 'Market Demands',
                seeAllText: 'See All',
                onSeeAll: () {},
              ),
            ),
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Text(
                'What buyers are actively looking for',
                style: TextStyle(fontSize: 13, color: Colors.grey[600]),
              ),
            ),
            const SizedBox(height: 12),
            if (_isDemandsLoading)
              const SizedBox(
                height: 230,
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_demandsError != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: FriendlyErrorDisplay(
                  error: _demandsError,
                  onRetry: _loadMarketDemands,
                ),
              )
            else if (_marketDemands.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20.0),
                child: Center(
                  child: Column(
                    children: [
                      Icon(Icons.campaign_outlined,
                          size: 48, color: Colors.grey[400]),
                      const SizedBox(height: 10),
                      Text('No active demands yet',
                          style: TextStyle(
                              fontSize: 14, color: Colors.grey[600])),
                    ],
                  ),
                ),
              )
            else
              SizedBox(
                height: 315,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.only(left: 20, right: 6),
                  itemCount: _marketDemands.length,
                  itemBuilder: (context, index) {
                    final demand = _marketDemands[index];
                    return MarketDemandCard(
                      demand: demand,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              MarketDemandDetailScreen(demand: demand),
                        ),
                      ),
                    );
                  },
                ),
              ),

            const SizedBox(height: 24),

            // =========================
            // Featured Agricultural Services Section
            // =========================
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: _sectionHeader(
                icon: Icons.handyman,
                title: localizations.featuredServices,
                seeAllText: localizations.seeAll,
                onSeeAll: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const MarketplaceScreen(),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),

            if (_isServicesLoading)
              const SizedBox(
                height: 280,
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_servicesError != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: FriendlyErrorDisplay(
                  error: _servicesError,
                  onRetry: _loadFeaturedServices,
                ),
              )
            else if (_featuredServices.isEmpty)
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Center(
                  child: Column(
                    children: [
                      Icon(Icons.handyman_outlined,
                          size: 56, color: Colors.grey[400]),
                      const SizedBox(height: 12),
                      Text(
                        localizations.noFeaturedServicesAvailable,
                        style: TextStyle(
                            fontSize: 15, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              )
            else
              SizedBox(
                height: 340,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: _featuredServices.length,
                  itemBuilder: (context, index) {
                    final service = _featuredServices[index];

                    return Container(
                      width: 220,
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
                                    ServiceDetailScreen(service: service),
                              ),
                            );
                          },
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Image.network(
                                service.imageUrl ??
                                    'https://via.placeholder.com/220x140?text=Service',
                                height: 140,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    height: 140,
                                    color: Colors.grey[200],
                                    child: const Icon(Icons.broken_image,
                                        size: 40),
                                  );
                                },
                              ),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        service.title ?? 'Service',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          RatingStars(rating: service.rating ?? 0.0, size: 14),
                                          const SizedBox(width: 4),
                                          Text(
                                            (service.rating ?? 0.0).toStringAsFixed(1),
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: Colors.grey[600],
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const Spacer(),
                                          Text(
                                            '${service.reviewCount ?? 0} reviews',
                                            style: TextStyle(
                                              fontSize: 10,
                                              color: Colors.grey[500],
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          CircleAvatar(
                                            radius: 10,
                                            backgroundImage: service.sellerAvatar != null
                                                ? NetworkImage(service.sellerAvatar!)
                                                : null,
                                            child: service.sellerAvatar == null
                                                ? const Icon(Icons.person, size: 12)
                                                : null,
                                          ),
                                          const SizedBox(width: 4),
                                            Expanded(
                                              child: Text(
                                                service.sellerName,
                                                maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                fontSize: 11,
                                                color: Colors.grey,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'TZS ${service.price.toStringAsFixed(0)}',
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Theme.of(context).primaryColor,
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
                      ),
                    );
                  },
                ),
              ),

            const SizedBox(height: 24),

            // =========================
            // Featured Transports Section
            // =========================
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      localizations.featuredTransports,
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
                          builder: (_) => const TransportListScreen(
                            category: 'all',
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

            Consumer<TransportProvider>(
              builder: (context, transportProvider, child) {
                final featuredTransports = transportProvider.featuredTransports;

                if (featuredTransports.isEmpty) {
                  if (transportProvider.isLoading) {
                    return const SizedBox(
                      height: 280,
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                  return Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(Icons.local_shipping_outlined,
                              size: 56, color: Colors.grey[400]),
                          const SizedBox(height: 12),
                          Text(
                            localizations.noFeaturedTransportsAvailable,
                            style: TextStyle(
                                fontSize: 15, color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return SizedBox(
                  height: 330,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    itemCount: featuredTransports.length,
                    itemBuilder: (context, index) {
                      final transport = featuredTransports[index];

                      return Container(
                        width: 240,
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
                                  builder: (_) => TransportDetailsScreen(
                                      transport: transport),
                                ),
                              );
                            },
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Hero(
                                  tag: 'home-transport-${transport.id}',
                                  child: Image.network(
                                    transport.processedImageUrl.isNotEmpty
                                        ? transport.processedImageUrl
                                        : 'https://via.placeholder.com/240x140?text=No+Image',
                                    height: 140,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        height: 140,
                                        color: Colors.grey[200],
                                        child: const Icon(Icons.broken_image,
                                            size: 40),
                                      );
                                    },
                                  ),
                                ),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.all(12.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          transport.title,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            RatingStars(rating: transport.driverRating ?? 0.0, size: 14),
                                            const SizedBox(width: 4),
                                            Text(
                                              (transport.driverRating ?? 0.0).toStringAsFixed(1),
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey[600],
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            const Icon(Icons.location_on,
                                                size: 14, color: Colors.grey),
                                            const SizedBox(width: 4),
                                            Expanded(
                                              child: Text(
                                                transport.vehicleLocation,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                  color: Colors.grey[600],
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        // Provider info
                                        if (transport.user != null || transport.userId != null)
                                          InkWell(
                                            onTap: () {
                                              final String? sellerId = transport.user?['id']?.toString() ??
                                                  transport.userId?.toString();
                                              if (sellerId != null) {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) => import_profile
                                                        .SellerPublicProfileScreen(
                                                            sellerId: sellerId),
                                                  ),
                                                );
                                              }
                                            },
                                            child: Row(
                                              children: [
                                                CircleAvatar(
                                                  radius: 10,
                                                  backgroundImage: transport.sellerAvatar != null
                                                      ? NetworkImage(
                                                          transport.sellerAvatar!)
                                                      : null,
                                                  child: transport.sellerAvatar == null
                                                      ? const Icon(Icons.person,
                                                          size: 12)
                                                      : null,
                                                ),
                                                const SizedBox(width: 4),
                                                Expanded(
                                                  child: Text(
                                                    transport.sellerName,
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                    style: const TextStyle(
                                                      fontSize: 11,
                                                      color: Colors.grey,
                                                      decoration: TextDecoration.underline,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        const SizedBox(height: 8),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              'TZS ${transport.price.toStringAsFixed(0)}',
                                              style: TextStyle(
                                                fontSize: 15,
                                                color: Theme.of(context)
                                                    .primaryColor,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 6,
                                                      vertical: 2),
                                              decoration: BoxDecoration(
                                                color: Theme.of(context)
                                                    .primaryColor
                                                    .withAlpha(25),
                                                borderRadius:
                                                    BorderRadius.circular(6),
                                              ),
                                              child: Text(
                                                transport.vehicleType,
                                                style: TextStyle(
                                                  fontSize: 10,
                                                  color: Theme.of(context)
                                                      .primaryColor,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
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

            const SizedBox(height: 32),
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
        return 'assets/images/food_and_beverages.webp';
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
              // Check if category has subcategories
              if (category.subcategoriesCount > 0) {
                // Navigate to subcategories screen
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => SubcategoriesScreen(category: category),
                  ),
                );
              } else {
                // For categories without subcategories, navigate to appropriate screen
                if (category.name
                    .toLowerCase()
                    .contains('market information')) {
                  // Market Information - navigate to Market Info screen
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const MarketInfoScreen(),
                    ),
                  );
                } else if (category.name.toLowerCase().contains('transport')) {
                  // Transport - navigate to dedicated transport list screen
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => TransportListScreen(
                        category: category.name,
                        categoryId: category.id,
                      ),
                    ),
                  );
                } else {
                  // Default - navigate to products screen
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ProductListScreen(
                        title: category.name,
                        categoryId: category.id,
                        subcategory: 'all',
                      ),
                    ),
                  );
                }
              }
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
