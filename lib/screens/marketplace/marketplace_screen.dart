import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../../providers/product_provider.dart';
import '../../providers/transport_provider.dart';
import '../../providers/organic_product_provider.dart';
import '../../models/organic_product.dart';
import '../../models/service.dart';
import '../../models/product.dart';
import '../../models/transport.dart';
import '../../widgets/cached_network_image_with_cors.dart';
import '../../l10n/app_localizations.dart';
import 'package:masoko_tips/screens/products/product_details_screen.dart';
import 'package:masoko_tips/screens/transport/transport_details_screen.dart';
import 'package:masoko_tips/screens/organic/organic_product_detail_screen.dart';
import 'package:masoko_tips/screens/services/service_detail_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../providers/subscription_provider.dart';
import '../chat/chat_screen.dart';
import '../subscription/subscription_screen.dart';
import '../../providers/auth_provider.dart';
import '../../utils/image_upload_helper.dart';
import '../../services/api_service.dart';
import '../../widgets/rating_stars.dart';

class MarketplaceScreen extends StatefulWidget {
  const MarketplaceScreen({Key? key}) : super(key: key);

  @override
  State<MarketplaceScreen> createState() => _MarketplaceScreenState();
}

class _MarketplaceScreenState extends State<MarketplaceScreen> {
  String _selectedCategory = 'All';
  final String _searchQuery = '';

  void _showSubscriptionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.subscriptionRequired),
        content: const Text(
          'Chat and Contact features are available for active subscribers only. Subscribe now to connect directly with sellers!',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.cancelCaps),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SubscriptionScreen()),
              );
            },
            child: Text(AppLocalizations.of(context)!.subscribeNowCaps),
          ),
        ],
      ),
    );
  }

  void _handleProtectedAction(VoidCallback action) {
    final subProvider = context.read<SubscriptionProvider>();
    final authProvider = context.read<AuthProvider>();
    
    // Buyers don't need a subscription to contact
    if (authProvider.user?.role == 'buyer' || subProvider.hasActiveSubscription) {
      action();
    } else {
      _showSubscriptionDialog();
    }
  }

  void _initiateChat(dynamic item) {
    String sellerId = '';
    String sellerName = '';
    String sellerImage = '';

    if (item is Product) {
      sellerId = item.userId.toString();
      sellerName = item.sellerName;
      sellerImage = item.sellerAvatar ?? '';
    } else if (item is OrganicProduct) {
      sellerId = item.sellerId.toString();
      sellerName = item.sellerName;
      sellerImage = item.sellerAvatar ?? '';
    } else if (item is Service) {
      sellerId = item.userId.toString();
      sellerName = item.sellerName;
      sellerImage = item.providerImage ?? '';
    } else if (item is Transport) {
      sellerId = item.user?['id']?.toString() ?? item.userId?.toString() ?? '0';
      sellerName = item.sellerName;
      sellerImage = item.sellerAvatar ?? '';
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChatScreen(
          receiverId: int.tryParse(sellerId) ?? 0,
          receiverName: sellerName,
          receiverImage: sellerImage,
        ),
      ),
    );
  }

  Future<void> _initiateCall(String? phone) async {
    if (phone == null || phone.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.phoneNumberNotAvailable)),
      );
      return;
    }
    final Uri url = Uri.parse('tel:$phone');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.couldNotLaunchDialer)),
      );
    }
  }

  bool _isLoading = false;
  List<Service> _featuredServices = [];

  @override
  void initState() {
    super.initState();
    _loadAllData();
  }

  Future<void> _loadAllData() async {
    setState(() => _isLoading = true);
    try {
      final apiService = context.read<ApiService>();
      final productProvider = context.read<ProductProvider>();
      final transportProvider = context.read<TransportProvider>();
      final organicProvider = context.read<OrganicProductProvider>();

      await productProvider.loadProducts();
      await transportProvider.loadTransports();
      await organicProvider.loadPublicProducts();
      final servicesData =
          await apiService.getPublicRequest('services/featured');

      if (!mounted) return;

      // Handle services data
      if (servicesData.containsKey('data') && servicesData['data'] is List) {
        final List<dynamic> list = servicesData['data'];
        setState(() {
          _featuredServices =
              list.map((json) => Service.fromJson(json)).toList();
        });
      }

      // Final count check for debugging
      debugPrint(
          '⛔ Marketplace loaded ${organicProvider.products.length} organic products');
    } catch (e) {
      debugPrint('⛔ Error loading marketplace data: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildAppBar(theme, localizations),
          SliverToBoxAdapter(child: _buildFilters(theme)),
          _isLoading
              ? const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()))
              : _buildItemsGrid(localizations),
        ],
      ),
    );
  }

  Widget _buildAppBar(ThemeData theme, AppLocalizations localizations) {
    return SliverAppBar(
      expandedHeight: 160.0,
      floating: false,
      pinned: true,
      backgroundColor: theme.primaryColor,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(AppLocalizations.of(context)!.marketplace,
            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                theme.primaryColor,
                theme.primaryColor.withValues(alpha: 0.8),
                theme.primaryColor.withValues(alpha: 0.6),
              ],
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                right: -20,
                bottom: -20,
                child: Icon(Icons.storefront,
                    size: 150, color: Colors.white.withValues(alpha: 0.1)),
              ),
            ],
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh, color: Colors.white),
          onPressed: _loadAllData,
        ),
      ],
    );
  }

  Widget _buildFilters(ThemeData theme) {
    final categories = [
      'All',
      'Products',
      'Transport',
      'Organic',
      'Services',
      'Food'
    ];

    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = _selectedCategory == category;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(category),
              selected: isSelected,
              onSelected: (selected) {
                setState(() => _selectedCategory = category);
              },
              backgroundColor: Colors.grey[200],
              selectedColor: theme.primaryColor.withValues(alpha: 0.2),
              labelStyle: TextStyle(
                color: isSelected ? theme.primaryColor : Colors.black87,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              checkmarkColor: theme.primaryColor,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
            ),
          );
        },
      ),
    );
  }

  Widget _buildItemsGrid(AppLocalizations localizations) {
    return Consumer3<ProductProvider, TransportProvider,
        OrganicProductProvider>(
      builder: (context, productProvider, transportProvider, organicProvider,
          child) {
        // Combine data
        List<dynamic> items = [];

        // Products (Regular, Food, Services from ProductProvider)
        if (_selectedCategory == 'All' ||
            _selectedCategory == 'Products' ||
            _selectedCategory == 'Services' ||
            _selectedCategory == 'Food') {
          items.addAll(productProvider.products.where((p) {
            if (_selectedCategory == 'Services') {
              return p.categoryName.toLowerCase().contains('service');
            }
            if (_selectedCategory == 'Food') {
              return p.categoryName.toLowerCase().contains('food');
            }
            return true;
          }));
        }

        // Organic Products
        if (_selectedCategory == 'All' || _selectedCategory == 'Organic') {
          items.addAll(organicProvider.products);
        }

        // Transport
        if (_selectedCategory == 'All' || _selectedCategory == 'Transport') {
          items.addAll(transportProvider.transports);
        }

        // Featured Agricultural Services (from Service model)
        if (_selectedCategory == 'All' || _selectedCategory == 'Services') {
          items.addAll(_featuredServices);
        }

        // Apply search filter if query is present
        if (_searchQuery.isNotEmpty) {
          items = items.where((item) {
            if (item is Product) {
              return item.name
                  .toLowerCase()
                  .contains(_searchQuery.toLowerCase());
            }
            if (item is Transport) {
              return item.title
                  .toLowerCase()
                  .contains(_searchQuery.toLowerCase());
            }
            if (item is OrganicProduct) {
              return item.name
                  .toLowerCase()
                  .contains(_searchQuery.toLowerCase());
            }
            if (item is Service) {
              return (item.title ?? '')
                  .toLowerCase()
                  .contains(_searchQuery.toLowerCase());
            }
            return false;
          }).toList();
        }

        if (items.isEmpty) {
          return SliverFillRemaining(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(AppLocalizations.of(context)!.noItemsFound,
                      style: TextStyle(color: Colors.grey[600], fontSize: 18)),
                ],
              ),
            ),
          );
        }

        return SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.68,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final item = items[index];
                return AnimationConfiguration.staggeredGrid(
                  position: index,
                  duration: const Duration(milliseconds: 375),
                  columnCount: 2,
                  child: ScaleAnimation(
                    child: FadeInAnimation(
                      child: _buildItemCard(item, localizations),
                    ),
                  ),
                );
              },
              childCount: items.length,
            ),
          ),
        );
      },
    );
  }

  Widget _buildItemCard(dynamic item, AppLocalizations localizations) {
    if (item is Product) {
      return _buildProductCard(item, localizations);
    } else if (item is Transport) {
      return _buildTransportCard(item, localizations);
    } else if (item is OrganicProduct) {
      return _buildOrganicProductCard(item, localizations);
    } else if (item is Service) {
      return _buildServiceCard(item, localizations);
    }
    return const SizedBox.shrink();
  }

  Widget _buildOrganicProductCard(
      OrganicProduct product, AppLocalizations localizations) {
    return _buildUnifiedCard(
      item: product,
      title: product.name.toUpperCase(),
      subtitle: 'Seller: ${product.origin ?? product.sellerName}',
      description: product.description ?? '',
      imageUrl: product.imageUrl ?? '',
      price: 'TZS ${product.price.toStringAsFixed(0)}',
      badge: 'ORGANIC',
      badgeColor: Colors.green,
      rating: product.rating,
      reviewCount: product.reviewsCount,
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => OrganicProductDetailScreen(product: product),
        ),
      ),
      phoneNumber: product.sellerPhone,
    );
  }

  Widget _buildServiceCard(Service service, AppLocalizations localizations) {
    return _buildUnifiedCard(
      item: service,
      title: (service.title ?? 'Service').toUpperCase(),
      subtitle: 'Provider: ${service.sellerName}',
      description: service.description ?? '',
      imageUrl: service.imageUrl ??
          'https://via.placeholder.com/200x140?text=Service',
      price: 'TZS ${service.price.toStringAsFixed(0)}',
      badge: 'SERVICE',
      badgeColor: Colors.orange,
      rating: service.rating ?? 0.0,
      reviewCount: service.reviewCount ?? 0,
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ServiceDetailScreen(service: service),
        ),
      ),
      phoneNumber: service.contactPhone ?? service.sellerPhone,
    );
  }

  Widget _buildProductCard(Product product, AppLocalizations localizations) {
    return _buildUnifiedCard(
      item: product,
      title: product.name.toUpperCase(),
      subtitle: 'Seller: ${product.sellerName}',
      description: product.description,
      imageUrl: ImageUploadHelper.constructFullImageUrl(product.firstImageUrl),
      price: 'TZS ${product.price.toStringAsFixed(0)}',
      badge: product.categoryName.toUpperCase(),
      badgeColor: Theme.of(context).primaryColor,
      rating: product.rating,
      reviewCount: product.ratingCount,
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => ProductDetailsScreen(product: product)),
      ),
      phoneNumber: product.sellerPhone,
    );
  }

  Widget _buildTransportCard(
      Transport transport, AppLocalizations localizations) {
    return _buildUnifiedCard(
      item: transport,
      title: transport.title.toUpperCase(),
      subtitle: 'Location: ${transport.vehicleLocation}',
      description: transport.description ?? '',
      imageUrl: transport.processedImageUrl.isNotEmpty
          ? transport.processedImageUrl
          : 'https://via.placeholder.com/200x140?text=Transport',
      price: 'TZS ${transport.price.toStringAsFixed(0)}',
      badge: 'TRANSPORT',
      badgeColor: Colors.blueAccent.withValues(alpha: 0.8),
      rating: transport.driverRating ?? 0.0,
      reviewCount: 0, // Transport doesn't have review count yet
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => TransportDetailsScreen(transport: transport)),
      ),
      phoneNumber: transport.sellerPhone,
    );
  }

  Widget _buildUnifiedCard({
    required dynamic item,
    required String title,
    required String subtitle,
    required String description,
    required String imageUrl,
    required String price,
    required String badge,
    required Color badgeColor,
    required double rating,
    required int reviewCount,
    required VoidCallback onTap,
    required String? phoneNumber,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                CachedNetworkImageWithCors(
                  imageUrl: imageUrl,
                  height: 120,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: badgeColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      badge,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 11,
                        color: Colors.grey,
                        fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    price,
                    style: TextStyle(
                      color: badgeColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 11, color: Colors.black87),
                  ),
                  if (description.length > 30)
                    InkWell(
                      onTap: onTap,
                      child: const Text(
                        'read more...',
                        style: TextStyle(
                            fontSize: 10,
                            color: Colors.blue,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      RatingStars(rating: rating, size: 14, activeColor: badgeColor),
                      const SizedBox(width: 4),
                      Text(
                        rating.toStringAsFixed(1),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (reviewCount > 0)
                        Text(
                          ' ($reviewCount)',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[600],
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () =>
                              _handleProtectedAction(() => _initiateChat(item)),
                          icon: const Icon(Icons.chat_bubble_outline, size: 14),
                          label: Text(AppLocalizations.of(context)!.chat,
                              style: const TextStyle(fontSize: 11)),
                          style: OutlinedButton.styleFrom(
                            padding: EdgeInsets.zero,
                            side: BorderSide(
                                color: badgeColor.withValues(alpha: 0.5)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _handleProtectedAction(
                              () => _initiateCall(phoneNumber)),
                          icon: const Icon(Icons.phone, size: 14),
                          label: Text(AppLocalizations.of(context)!.contacts,
                              style: const TextStyle(fontSize: 10)),
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.zero,
                            backgroundColor: badgeColor,
                            foregroundColor: Colors.white,
                          ),
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
