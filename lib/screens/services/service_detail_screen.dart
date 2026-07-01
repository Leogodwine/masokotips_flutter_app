import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/service.dart';
import '../../providers/favorites_provider.dart';
import '../../providers/auth_provider.dart';
import '../chat/chat_screen.dart';
import '../../widgets/cached_network_image_with_cors.dart';
import '../seller/seller_public_profile_screen.dart' as import_profile;
import '../../providers/subscription_provider.dart';
import '../subscription/subscription_screen.dart';

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
  Widget _buildDetailTile({
    required IconData icon,
    required String label,
    required String value,
    required ThemeData theme,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: theme.primaryColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: theme.primaryColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final favorites = Provider.of<FavoritesProvider>(context);
    final isFavorite = favorites.isFavorite(widget.service.id.toString());

    final statusLower = (widget.service.status ?? 'active').toLowerCase();
    final isActive = statusLower == 'active' || statusLower == 'available';

    // Build lists of details dynamically
    final List<Map<String, dynamic>> detailItems = [];
    if (widget.service.serviceType != null && widget.service.serviceType!.isNotEmpty) {
      detailItems.add({
        'icon': Icons.category,
        'label': 'Service Type',
        'value': widget.service.serviceType,
      });
    }
    if (widget.service.experienceYears != null) {
      detailItems.add({
        'icon': Icons.work_history,
        'label': 'Experience',
        'value': '${widget.service.experienceYears} Years',
      });
    }
    if (widget.service.expertise != null && widget.service.expertise!.isNotEmpty) {
      detailItems.add({
        'icon': Icons.psychology,
        'label': 'Expertise',
        'value': widget.service.expertise,
      });
    }
    if (widget.service.certifications != null && widget.service.certifications!.isNotEmpty) {
      detailItems.add({
        'icon': Icons.verified,
        'label': 'Certifications',
        'value': widget.service.certifications,
      });
    }
    if (widget.service.location != null && widget.service.location!.isNotEmpty) {
      detailItems.add({
        'icon': Icons.location_on,
        'label': 'Location',
        'value': widget.service.location,
      });
    }
    if (widget.service.subcategory != null && widget.service.subcategory!.isNotEmpty) {
      detailItems.add({
        'icon': Icons.subdirectory_arrow_right,
        'label': 'Subcategory',
        'value': widget.service.subcategory,
      });
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Hero(
                    tag: 'service-${widget.service.id}',
                    child: CachedNetworkImageWithCors(
                      imageUrl: widget.service.imageUrl ??
                          'https://via.placeholder.com/250',
                      fit: BoxFit.cover,
                      height: 300,
                      width: double.infinity,
                    ),
                  ),
                  // Gradient Overlay
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.3),
                          Colors.transparent,
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.6),
                        ],
                      ),
                    ),
                  ),
                  // Status/Availability Badge
                  Positioned(
                    top: 16,
                    right: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: isActive ? Colors.green : Colors.orange,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        (widget.service.availability ?? widget.service.status ?? 'ACTIVE')
                            .toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            leading: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(12),
              ),
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
            actions: [
              Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  icon: Icon(
                    isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: isFavorite ? Colors.red : Colors.white,
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
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Service Title & Price
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          widget.service.title ?? 'No Title',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'TZS ${widget.service.price.toStringAsFixed(2)}',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: theme.primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Rating & Reviews row if available
                  if (widget.service.rating != null && widget.service.rating! > 0) ...[
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 18),
                        const SizedBox(width: 4),
                        Text(
                          widget.service.rating!.toStringAsFixed(1),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        if (widget.service.reviewCount != null && widget.service.reviewCount! > 0) ...[
                          const SizedBox(width: 4),
                          Text(
                            '(${widget.service.reviewCount} ${widget.service.reviewCount == 1 ? 'review' : 'reviews'})',
                            style: TextStyle(color: Colors.grey[600], fontSize: 12),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Details Grid
                  if (detailItems.isNotEmpty) ...[
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        childAspectRatio: 2.8,
                      ),
                      itemCount: detailItems.length,
                      itemBuilder: (context, index) {
                        final item = detailItems[index];
                        return _buildDetailTile(
                          icon: item['icon'],
                          label: item['label'],
                          value: item['value'],
                          theme: theme,
                        );
                      },
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Description Card
                  if (widget.service.description != null &&
                      widget.service.description!.isNotEmpty) ...[
                    Text(
                      'Description',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[200]!),
                      ),
                      child: Text(
                        widget.service.description!,
                        style: TextStyle(
                          fontSize: 14,
                          height: 1.5,
                          color: Colors.grey[800],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Provider card
                  Text(
                    'Service Provider',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              import_profile.SellerPublicProfileScreen(
                            sellerId: widget.service.userId.toString(),
                          ),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[200]!),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 28,
                            backgroundImage: widget.service.providerImage != null
                                ? NetworkImage(widget.service.providerImage!)
                                : null,
                            child: widget.service.providerImage == null
                                ? const Icon(Icons.person, size: 28)
                                : null,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.service.sellerName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                if (widget.service.location != null &&
                                    widget.service.location!.isNotEmpty) ...[
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Icon(Icons.location_on,
                                          size: 14, color: Colors.grey[600]),
                                      const SizedBox(width: 4),
                                      Text(
                                        widget.service.location!,
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ],
                            ),
                          ),
                          const Icon(Icons.chevron_right, color: Colors.grey),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 80), // extra padding for bottom bar
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    final authProvider = context.read<AuthProvider>();
                    if (authProvider.user == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please login to send a message.'),
                          backgroundColor: Colors.orange,
                        ),
                      );
                      return;
                    }
                    _handleProtectedAction(context, () {
                      final currentUserId = authProvider.user!.id;
                      final receiverId = widget.service.userId;

                      if (receiverId == currentUserId) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('You cannot chat with yourself.'),
                            backgroundColor: Colors.orange,
                          ),
                        );
                        return;
                      }

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ChatScreen(
                            receiverId: receiverId,
                            receiverName: widget.service.sellerName,
                            receiverImage: widget.service.providerImage ?? '',
                          ),
                        ),
                      );
                    });
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: BorderSide(color: theme.primaryColor),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: Icon(Icons.message, color: theme.primaryColor),
                  label: Text(
                    'Message',
                    style: TextStyle(
                      color: theme.primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: isActive
                      ? () {
                          final authProvider = context.read<AuthProvider>();
                          if (authProvider.user == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Please login to call.'),
                                backgroundColor: Colors.orange,
                              ),
                            );
                            return;
                          }
                          _handleProtectedAction(context, () async {
                            final phone = widget.service.contactPhone ??
                                widget.service.sellerPhone ??
                                '0799711705';
                            final messenger = ScaffoldMessenger.of(context);
                            final Uri url = Uri.parse('tel:$phone');
                            if (await canLaunchUrl(url)) {
                              await launchUrl(url);
                            } else {
                              messenger.showSnackBar(
                                const SnackBar(
                                  content: Text('Could not launch phone dialer.'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          });
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: isActive ? theme.primaryColor : Colors.grey,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Book Now',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSubscriptionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Subscription Required'),
        content: const Text(
          'Chat and Contact features are available for active subscribers only. Subscribe now to connect directly!',
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

  void _handleProtectedAction(BuildContext context, VoidCallback action) {
    final subProvider = context.read<SubscriptionProvider>();
    if (subProvider.hasActiveSubscription) {
      action();
    } else {
      _showSubscriptionDialog(context);
    }
  }
}
