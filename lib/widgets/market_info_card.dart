import 'package:flutter/material.dart';
import '../models/market_info.dart';
import '../screens/market_info/market_info_detail_screen.dart';
import 'cached_network_image_with_cors.dart';

class MarketInfoCard extends StatelessWidget {
  final MarketInfo marketInfo;
  final double? width;
  final double? height;

  const MarketInfoCard({
    super.key,
    required this.marketInfo,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width ?? 320,
      height: height ?? 175, // Final adjustment to eliminate 3px overflow
      margin: const EdgeInsets.only(right: 16),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: InkWell(
          onTap: () {
            // Add safety check to ensure context is still valid
            if (context.mounted) {
              debugPrint(
                  'MarketInfoCard: Navigating to detail screen for: ${marketInfo.title}');
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MarketInfoDetailScreen(
                    marketInfo: marketInfo,
                  ),
                ),
              );
            } else {
              debugPrint(
                  'MarketInfoCard: Context not mounted, skipping navigation');
            }
          },
          borderRadius: BorderRadius.circular(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image with overlay
              _buildImageSection(context),
              // Content
              _buildContentSection(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageSection(BuildContext context) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(20),
          ),
          child: marketInfo.imageUrl.isNotEmpty
              ? CachedNetworkImageWithCors(
                  imageUrl: marketInfo.imageUrl,
                  height: 140,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorWidget: (context, url, error) =>
                      _buildImagePlaceholder(context),
                )
              : _buildImagePlaceholder(context),
        ),
        // Status badge
        Positioned(
          top: 12,
          right: 12,
          child: _buildStatusBadge(),
        ),
        // Gradient overlay for better text readability
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            height: 40,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.3),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImagePlaceholder(BuildContext context) {
    return Container(
      height: 140,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).primaryColor.withValues(alpha: 0.3),
            Theme.of(context).primaryColor.withValues(alpha: 0.1),
          ],
        ),
      ),
      child: const Center(
        child: Icon(
          Icons.newspaper,
          size: 48,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildStatusBadge() {
    Color badgeColor;
    String badgeText;

    if (marketInfo.isActive) {
      badgeColor = Colors.green;
      badgeText = 'LIVE';
    } else if (marketInfo.isFeatured) {
      badgeColor = Colors.amber;
      badgeText = 'FEATURED';
    } else {
      badgeColor = Colors.grey;
      badgeText = 'ARCHIVED';
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: badgeColor.withValues(alpha: 0.9),
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
        badgeText,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildContentSection(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(10), // Reduced padding
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Text(
              marketInfo.title,
              style: const TextStyle(
                fontSize: 13, // Reduced font size
                fontWeight: FontWeight.bold,
                height: 1.0, // Minimal line height
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 6), // Minimal spacing after title
            // Location & Category
            Row(
              children: [
                Icon(
                  Icons.location_on,
                  size: 12, // Smaller icon
                  color: Colors.grey[500],
                ),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    marketInfo.location.isNotEmpty
                        ? marketInfo.location
                        : 'Market News',
                    style: TextStyle(
                      fontSize: 11, // Smaller font
                      color: Colors.grey[600],
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (marketInfo.category.isNotEmpty) ...[
                  const SizedBox(width: 6), // Reduced spacing
                  Icon(
                    Icons.category,
                    size: 12, // Smaller icon
                    color: Colors.grey[500],
                  ),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      marketInfo.category,
                      style: TextStyle(
                        fontSize: 11, // Smaller font
                        color: Colors.grey[600],
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 4), // Minimal spacing before read more
            // Read more indicator
            const Row(
              children: [
                Text(
                  'Read more',
                  style: TextStyle(
                    fontSize: 11, // Smaller font
                    color: Color(0xFF1C592B), // Dark green
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(width: 4),
                Icon(
                  Icons.arrow_forward,
                  size: 11, // Smaller icon
                  color: Color(0xFF1C592B), // Dark green
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
