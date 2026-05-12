import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

import '../../models/seller_public_profile.dart';
import '../../services/api_service.dart';
import '../../models/product.dart';
import '../../models/organic_product.dart';
import '../../models/service.dart';
import '../../models/transport.dart';
import '../../providers/subscription_provider.dart';
import '../../utils/image_upload_helper.dart';
import '../../widgets/cached_network_image_with_cors.dart';
import '../chat/chat_screen.dart';
import '../subscription/subscription_screen.dart';
import 'package:url_launcher/url_launcher.dart';

import '../products/product_details_screen.dart';
import '../organic/organic_product_detail_screen.dart';
import '../services/service_detail_screen.dart';
import '../transport/transport_details_screen.dart';
import '../../widgets/rating_stars.dart';

class SellerPublicProfileScreen extends StatefulWidget {
  final String sellerId;

  const SellerPublicProfileScreen({Key? key, required this.sellerId})
      : super(key: key);

  @override
  State<SellerPublicProfileScreen> createState() =>
      _SellerPublicProfileScreenState();
}

class _SellerPublicProfileScreenState extends State<SellerPublicProfileScreen> {
  bool _isLoading = true;
  SellerPublicProfile? _profile;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final apiService = context.read<ApiService>();
      final response = await apiService
          .getPublicRequest('public/sellers/${widget.sellerId}/profile');

      if (!mounted) return;
      setState(() {
        _profile = SellerPublicProfile.fromJson(response);
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  void _showSubscriptionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Subscription Required'),
        content: const Text(
          'Chat and Contact features are available for active subscribers only. Subscribe now to connect directly with sellers!',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SubscriptionScreen()),
              );
            },
            child: const Text('SUBSCRIBE NOW'),
          ),
        ],
      ),
    );
  }

  void _handleProtectedAction(VoidCallback action) {
    final subProvider = context.read<SubscriptionProvider>();
    if (subProvider.hasActiveSubscription) {
      action();
    } else {
      _showSubscriptionDialog();
    }
  }

  void _initiateChat() {
    if (_profile == null) return;
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChatScreen(
          receiverId: int.tryParse(_profile!.id) ?? 0,
          receiverName: _profile!.name,
          receiverImage: _profile!.avatar ?? '',
        ),
      ),
    );
  }

  Future<void> _initiateCall() async {
    if (_profile == null || _profile!.phone == null || _profile!.phone!.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Phone number not available')),
      );
      return;
    }
    final Uri url = Uri.parse('tel:${_profile!.phone}');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not launch dialer')),
      );
    }
  }

  List<dynamic> _getAllItems() {
    if (_profile == null) return [];
    List<dynamic> items = [];
    items.addAll(_profile!.products);
    items.addAll(_profile!.organicProducts);
    items.addAll(_profile!.services);
    items.addAll(_profile!.transports);
    return items;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: theme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Failed to load profile',
                          style: TextStyle(color: Colors.red, fontSize: 16)),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: _loadProfile,
                        child: const Text('Retry'),
                      )
                    ],
                  ),
                )
              : _buildProfileContent(theme),
      bottomNavigationBar: _profile != null ? _buildBottomBar(theme) : null,
    );
  }

  Widget _buildProfileContent(ThemeData theme) {
    final items = _getAllItems();

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: _buildHeader(theme),
        ),
        if (items.isEmpty)
          SliverFillRemaining(
            hasScrollBody: false,
            child: Center(
              child: Text(
                'No products or services available yet.',
                style: TextStyle(color: Colors.grey[600], fontSize: 16),
              ),
            ),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.60,
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
                        child: _buildItemCard(item),
                      ),
                    ),
                  );
                },
                childCount: items.length,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          )
        ],
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: theme.primaryColor.withValues(alpha: 0.2),
            backgroundImage: _profile!.avatar != null && _profile!.avatar!.isNotEmpty
                ? NetworkImage(ImageUploadHelper.constructFullImageUrl(_profile!.avatar!))
                : null,
            child: _profile!.avatar == null || _profile!.avatar!.isEmpty
                ? Icon(Icons.person, size: 50, color: theme.primaryColor)
                : null,
          ),
          const SizedBox(height: 16),
          Text(
            "${_profile!.name.toUpperCase()} (Seller)",
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Rate:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(width: 8),
              _buildRatingStars(_profile!.rating),
              const SizedBox(width: 8),
              Text('(${_profile!.rating.toStringAsFixed(1)})', 
                style: const TextStyle(color: Colors.grey)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRatingStars(double rating) {
    int fullStars = rating.floor();
    bool hasHalfStar = (rating - fullStars) >= 0.5;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        if (index < fullStars) {
          return const Icon(Icons.star, color: Colors.amber, size: 20);
        } else if (index == fullStars && hasHalfStar) {
          return const Icon(Icons.star_half, color: Colors.amber, size: 20);
        } else {
          return const Icon(Icons.star_border, color: Colors.amber, size: 20);
        }
      }),
    );
  }

  Widget _buildBottomBar(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _handleProtectedAction(_initiateCall),
                icon: const Icon(Icons.phone),
                label: const Text('Contacts'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: BorderSide(color: theme.primaryColor),
                  foregroundColor: theme.primaryColor,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _handleProtectedAction(_initiateChat),
                icon: const Icon(Icons.chat),
                label: const Text('Message'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: theme.primaryColor,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemCard(dynamic item) {
    String title = '';
    String imageUrl = '';
    String price = '';
    double rating = 0.0;
    VoidCallback? onTap;

    if (item is Product) {
      title = item.name;
      imageUrl = ImageUploadHelper.constructFullImageUrl(item.firstImageUrl);
      price = 'TZS ${item.price.toStringAsFixed(0)}';
      rating = item.rating;
      onTap = () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => ProductDetailsScreen(product: item)),
          );
    } else if (item is OrganicProduct) {
      title = item.name;
      imageUrl = item.imageUrl ?? '';
      price = 'TZS ${item.price.toStringAsFixed(0)}';
      rating = item.rating;
      onTap = () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => OrganicProductDetailScreen(product: item)),
          );
    } else if (item is Service) {
      title = item.title ?? 'Service';
      imageUrl = item.imageUrl ?? '';
      price = 'TZS ${item.price.toStringAsFixed(0)}';
      rating = item.rating ?? 0.0;
      onTap = () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => ServiceDetailScreen(service: item)),
          );
    } else if (item is Transport) {
      title = item.title;
      imageUrl = item.processedImageUrl;
      price = 'TZS ${item.price.toStringAsFixed(0)}';
      rating = item.driverRating ?? 0.0;
      onTap = () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => TransportDetailsScreen(transport: item)),
          );
    }

    final priceRow = Text(
      price,
      style: TextStyle(
        color: Theme.of(context).primaryColor,
        fontWeight: FontWeight.bold,
        fontSize: 12,
      ),
    );

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: CachedNetworkImageWithCors(
                imageUrl: imageUrl,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 4),
                    Text(
                      title.toUpperCase(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 4),
                    priceRow,
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        RatingStars(rating: rating, size: 12),
                        const SizedBox(width: 4),
                        Text(
                          rating.toStringAsFixed(1),
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
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
