import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/transport.dart';
import '../../providers/auth_provider.dart';
import '../chat/chat_screen.dart';
import '../../screens/reviews/reviews_widget.dart';
import 'package:masoko_tips/widgets/cached_network_image_with_cors.dart';
import '../seller/seller_public_profile_screen.dart' as import_profile;
import '../../providers/subscription_provider.dart';
import '../subscription/subscription_screen.dart';
import 'package:masoko_tips/l10n/app_localizations.dart';

class TransportDetailsScreen extends StatelessWidget {
  final Transport transport;

  const TransportDetailsScreen({
    Key? key,
    required this.transport,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final statusLower = transport.status.toLowerCase();
    final isActive = statusLower == 'active' || statusLower == 'available';
    final receiverId = int.tryParse(transport.user?['id']?.toString() ?? '') ??
        transport.userId ??
        0;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Main Image
                  if (transport.processedImageUrl.isNotEmpty)
                    Hero(
                      tag: 'transport-image-${transport.id}',
                      child: CachedNetworkImageWithCors(
                        imageUrl: transport.processedImageUrl,
                        fit: BoxFit.cover,
                        height: 300,
                        width: double.infinity,
                        placeholder: (context, url) => Container(
                          color: Colors.grey[200],
                          child:
                              const Center(child: CircularProgressIndicator()),
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: Colors.grey[200],
                          child: const Icon(
                            Icons.directions_car,
                            size: 64,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    )
                  else
                    Container(
                      color: Colors.grey[200],
                      child: const Icon(
                        Icons.directions_car,
                        size: 64,
                        color: Colors.grey,
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

                  // Status Badge
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
                            color: Colors.black.withValues(alpha: 0.3),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        transport.status.toUpperCase(),
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
              // Subscribe Button
              Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  icon: const Icon(Icons.star, color: Colors.white),
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      '/subscription',
                    );
                  },
                ),
              ),
              // Edit Button
              Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  icon: const Icon(Icons.edit, color: Colors.white),
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      '/transport/edit',
                      arguments: transport,
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
                  // Title and Price Row
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              transport.title,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                height: 1.2,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              transport.vehicleType,
                              style: TextStyle(
                                fontSize: 16,
                                color: theme.hintColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: theme.primaryColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            Text(
                              transport.price == 0
                                  ? 'Negotiable'
                                  : 'TZS ${transport.price.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: theme.primaryColor,
                              ),
                            ),
                            if (transport.pricePerKg != null) ...[
                              const SizedBox(height: 2),
                              Text(
                                '${transport.pricePerKg!.toStringAsFixed(2)}/kg',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: theme.hintColor,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Description
                  if (transport.description != null &&
                      transport.description!.isNotEmpty) ...[
                    _buildSection(
                      context,
                      title: 'Description',
                      child: Text(
                        transport.description!,
                        style: const TextStyle(
                          fontSize: 15,
                          height: 1.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Key Features
                  _buildSection(
                    context,
                    title: 'Key Features',
                    child: Column(
                      children: [
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _buildFeatureChip(
                              context,
                              icon: Icons.scale,
                              label: '${transport.capacity} tons',
                            ),
                            _buildFeatureChip(
                              context,
                              icon: Icons.thermostat,
                              label: transport.isTemperatureControlled
                                  ? 'Temp Controlled'
                                  : 'No Temp Control',
                            ),
                          ],
                        ),
                        if (transport.temperatureRange != null) ...[
                          const SizedBox(height: 8),
                          _buildFeatureChip(
                            context,
                            icon: Icons.thermostat_outlined,
                            label: 'Range: ${transport.temperatureRange}°C',
                            fullWidth: true,
                          ),
                        ],
                        const SizedBox(height: 8),
                        _buildFeatureChip(
                          context,
                          icon: Icons.location_on,
                          label: transport.vehicleLocation,
                          fullWidth: true,
                        ),
                        if (transport.latitude != null &&
                            transport.longitude != null) ...[
                          const SizedBox(height: 8),
                          _buildFeatureChip(
                            context,
                            icon: Icons.gps_fixed,
                            label:
                                'GPS: ${transport.latitude!.toStringAsFixed(4)}, ${transport.longitude!.toStringAsFixed(4)}',
                            fullWidth: true,
                            color: Colors.green,
                          ),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Contact Information
                  _buildSection(
                    context,
                    title: 'Contact Information',
                    child: Column(
                      children: [
                        if (transport.user != null || transport.userId != null)
                          InkWell(
                            onTap: () {
                              final String? sellerId =
                                  transport.user?['id']?.toString() ??
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
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 24,
                                    backgroundImage: transport.sellerAvatar !=
                                            null
                                        ? NetworkImage(transport.sellerAvatar!)
                                        : null,
                                    child: transport.sellerAvatar == null
                                        ? const Icon(Icons.person)
                                        : null,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Provider',
                                          style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey,
                                              fontWeight: FontWeight.w500),
                                        ),
                                        Text(
                                          transport.sellerName,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                        if (transport.sellerLocation != null)
                                          Text(
                                            transport.sellerLocation!,
                                            style: const TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey),
                                          ),
                                      ],
                                    ),
                                  ),
                                  const Icon(Icons.chevron_right,
                                      color: Colors.grey),
                                ],
                              ),
                            ),
                          )
                        else
                          _buildContactInfoRow(
                            context,
                            icon: Icons.person,
                            label: 'Provider',
                            value: transport.sellerName,
                          ),
                        const SizedBox(height: 12),
                        _buildContactInfoRow(
                          context,
                          icon: Icons.drive_eta,
                          label: 'Driver',
                          value: transport.driverName ?? 'Not assigned',
                        ),
                        if (transport.driverPhone != null) ...[
                          const SizedBox(height: 12),
                          _buildContactInfoRow(
                            context,
                            icon: Icons.phone,
                            label: 'Contact',
                            value: transport.driverPhone!,
                            isPhone: true,
                          ),
                        ],
                      ],
                    ),
                  ),

                  // Insurance Information
                  if (transport.hasInsurance) ...[
                    const SizedBox(height: 24),
                    _buildSection(
                      context,
                      title: 'Insurance',
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(
                                Icons.verified_user,
                                color: Colors.green,
                                size: 20,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Fully Insured',
                                style: TextStyle(
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          if (transport.insuranceDetails != null) ...[
                            const SizedBox(height: 8),
                            Text(
                              transport.insuranceDetails!,
                              style: TextStyle(
                                color: theme.hintColor,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],

                  // Amenities
                  if (transport.amenities != null &&
                      transport.amenities!.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    _buildSection(
                      context,
                      title: 'Amenities',
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: transport.amenities!
                            .map((amenity) => Chip(
                                  label: Text(amenity),
                                  backgroundColor:
                                      theme.primaryColor.withValues(alpha: 0.1),
                                  labelStyle:
                                      TextStyle(color: theme.primaryColor),
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 8),
                                  materialTapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ))
                            .toList(),
                      ),
                    ),
                  ],

                  // Certifications
                  if (transport.certifications != null &&
                      transport.certifications!.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    _buildSection(
                      context,
                      title: 'Certifications',
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: transport.certifications!
                            .map((cert) => Chip(
                                  label: Text(cert),
                                  backgroundColor:
                                      Colors.green.withValues(alpha: 0.1),
                                  labelStyle:
                                      const TextStyle(color: Colors.green),
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 8),
                                  materialTapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ))
                            .toList(),
                      ),
                    ),
                  ],

                  // Supported Products
                  if (transport.supportedProductTypes?.isNotEmpty == true) ...[
                    const SizedBox(height: 24),
                    _buildSection(
                      context,
                      title: 'Supported Products',
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: transport.supportedProductTypes!
                            .map((type) => Chip(
                                  label: Text(type),
                                  backgroundColor:
                                      Colors.blue.withValues(alpha: 0.1),
                                  labelStyle:
                                      const TextStyle(color: Colors.blue),
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 8),
                                  materialTapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ))
                            .toList(),
                      ),
                    ),
                  ],

                  const SizedBox(height: 24),

                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            final authProvider = context.read<AuthProvider>();
                            if (authProvider.user == null) {
                              Navigator.pushNamed(context, '/login');
                              return;
                            }
                            _handleProtectedAction(context, () {
                              if (receiverId == 0) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(AppLocalizations.of(context)!
                                        .providerContactInfoIsNotAvailable),
                                    backgroundColor: Colors.orange,
                                  ),
                                );
                                return;
                              }
                              final currentUserId = authProvider.user!.id;
                              if (currentUserId == receiverId) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(AppLocalizations.of(context)!
                                        .youCannotChatWithYourself),
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
                                    receiverName: transport.sellerName,
                                    receiverImage: transport.sellerAvatar ?? '',
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
                                  final authProvider =
                                      context.read<AuthProvider>();
                                  if (authProvider.user == null) {
                                    Navigator.pushNamed(context, '/login');
                                    return;
                                  }
                                  _handleProtectedAction(context, () async {
                                    final phone = transport.driverPhone ??
                                        transport.sellerPhone ??
                                        '0799711705';
                                    final messenger =
                                        ScaffoldMessenger.of(context);
                                    final errorMsg =
                                        AppLocalizations.of(context)!
                                            .couldNotLaunchPhoneDialer;
                                    final Uri url = Uri.parse('tel:$phone');
                                    if (await canLaunchUrl(url)) {
                                      await launchUrl(url);
                                    } else {
                                      messenger.showSnackBar(
                                        SnackBar(
                                          content: Text(errorMsg),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                    }
                                  });
                                }
                              : null,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            backgroundColor:
                                isActive ? theme.primaryColor : Colors.grey,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Book Now',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  const Divider(),
                  const SizedBox(height: 16),
                  ReviewsWidget(
                    reviewableId: transport.id ?? 0,
                    reviewableType: 'App\\Models\\Transport',
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: Colors.grey.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: child,
          ),
        ),
      ],
    );
  }

  Widget _buildContactInfoRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    bool isPhone = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 20,
              color: Theme.of(context).primaryColor,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          if (isPhone)
            IconButton(
              icon: const Icon(Icons.phone, color: Colors.green),
              onPressed: () async {
                final Uri url = Uri.parse('tel:$value');
                final messenger = ScaffoldMessenger.of(context);
                final errorMsg =
                    AppLocalizations.of(context)!.couldNotLaunchPhoneDialer;
                if (await canLaunchUrl(url)) {
                  await launchUrl(url);
                } else {
                  messenger.showSnackBar(
                    SnackBar(
                      content: Text(errorMsg),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
            ),
        ],
      ),
    );
  }

  Widget _buildFeatureChip(
    BuildContext context, {
    required IconData icon,
    required String label,
    bool fullWidth = false,
    Color? color,
  }) {
    final chipColor = color ?? Theme.of(context).primaryColor;
    return Container(
      width: fullWidth ? double.infinity : null,
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: color != null ? color.withValues(alpha: 0.08) : Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color:
              color != null ? color.withValues(alpha: 0.3) : Colors.grey[200]!,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: fullWidth ? MainAxisSize.max : MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: chipColor,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: chipColor,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  void _showSubscriptionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.subscriptionRequired),
        content: const Text(
          'Chat and Contact features are available for active subscribers only. Subscribe now to connect directly!',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.cancelAlt),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SubscriptionScreen()),
              );
            },
            child: Text(AppLocalizations.of(context)!.subscribeNowAlt),
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
