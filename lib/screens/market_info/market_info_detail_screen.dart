import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../screens/reviews/reviews_widget.dart';
import 'package:masoko_tips/models/market_info.dart';
import 'package:masoko_tips/utils/date_utils.dart';
import 'package:masoko_tips/widgets/cached_network_image_with_cors.dart';

import 'package:masoko_tips/utils/image_upload_helper.dart';
import 'package:masoko_tips/l10n/app_localizations.dart';

class MarketInfoDetailScreen extends StatefulWidget {
  final MarketInfo marketInfo;

  const MarketInfoDetailScreen({
    super.key,
    required this.marketInfo,
  });

  @override
  State<MarketInfoDetailScreen> createState() => _MarketInfoDetailScreenState();
}

class _MarketInfoDetailScreenState extends State<MarketInfoDetailScreen> {
  bool _isImageExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Market News',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        backgroundColor:
            const Color(0xFF1C592B), // Dark green to match app theme
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            if (mounted && Navigator.canPop(context)) {
              Navigator.of(context).pop();
            }
          },
          tooltip: 'Back',
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share, color: Colors.white),
            onPressed: _shareNews,
            tooltip: 'Share News',
          ),
          IconButton(
            icon: const Icon(Icons.bookmark_border, color: Colors.white),
            onPressed: _bookmarkNews,
            tooltip: 'Bookmark',
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero Image Section
            _buildHeroImage(),

            // Content Card
            Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title and Featured Badge
                    _buildTitleSection(),

                    const SizedBox(height: 16),

                    // Description
                    if (widget.marketInfo.description.isNotEmpty)
                      _buildDescription(),

                    const SizedBox(height: 20),

                    // Content
                    _buildContent(),

                    const SizedBox(height: 24),

                    // Meta Information
                    _buildMetaInfo(),

                    const SizedBox(height: 20),

                    // Action Buttons
                    _buildActionButtons(),

                    const SizedBox(height: 24),
                    const Divider(),
                    const SizedBox(height: 16),
                    ReviewsWidget(
                      reviewableId: widget.marketInfo.id,
                      reviewableType: 'App\\Models\\MarketDemand',
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroImage() {
    return GestureDetector(
      onTap: () {
        setState(() {
          _isImageExpanded = !_isImageExpanded;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        height: _isImageExpanded ? 300 : 250,
        width: double.infinity,
        child: Stack(
          children: [
            // Image
            widget.marketInfo.imageUrl.isNotEmpty
                ? CachedNetworkImageWithCors(
                    imageUrl: ImageUploadHelper.constructFullImageUrl(widget.marketInfo.imageUrl),
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                    errorWidget: (context, url, error) =>
                        _buildImagePlaceholder(),
                  )
                : _buildImagePlaceholder(),

            // Gradient Overlay
            Container(
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

            // Featured Badge
            if (widget.marketInfo.isFeatured)
              Positioned(
                top: 16,
                right: 16,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.amber,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.star, color: Colors.white, size: 16),
                      SizedBox(width: 4),
                      Text(
                        'FEATURED',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // Expand/Collapse Icon
            Positioned(
              bottom: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  _isImageExpanded ? Icons.zoom_out : Icons.zoom_in,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      color: Colors.grey[200],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.newspaper,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 8),
          Text(
            'Market News',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTitleSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.marketInfo.title,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            height: 1.3,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Icon(
              Icons.schedule,
              size: 16,
              color: Colors.grey[600],
            ),
            const SizedBox(width: 4),
            Text(
              formatDate(widget.marketInfo.createdAt),
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
            const SizedBox(width: 16),
            Icon(
              Icons.visibility,
              size: 16,
              color: Colors.grey[600],
            ),
            const SizedBox(width: 4),
            Text(
              'Market News',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDescription() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: Colors.blue[700], size: 20),
              const SizedBox(width: 8),
              Text(
                'Summary',
                style: TextStyle(
                  color: Colors.blue[700],
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            widget.marketInfo.description,
            style: TextStyle(
              color: Colors.blue[800],
              fontSize: 15,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Full Article',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          widget.marketInfo.content.isNotEmpty
              ? widget.marketInfo.content
              : 'No detailed content available for this news item.',
          style: const TextStyle(
            fontSize: 16,
            height: 1.6,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildMetaInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          if (widget.marketInfo.location.isNotEmpty)
            _buildMetaItem(
              icon: Icons.location_on,
              label: 'Location',
              value: widget.marketInfo.location,
            ),
          if (widget.marketInfo.category.isNotEmpty)
            _buildMetaItem(
              icon: Icons.category,
              label: 'Category',
              value: widget.marketInfo.category,
            ),
          if (widget.marketInfo.contact.isNotEmpty)
            _buildMetaItem(
              icon: Icons.contact_phone,
              label: 'Contact',
              value: widget.marketInfo.contact,
            ),
        ],
      ),
    );
  }

  Widget _buildMetaItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Text(
            '$label: ',
            style: TextStyle(
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _shareNews,
            icon: const Icon(Icons.share, size: 18),
            label: Text(AppLocalizations.of(context)!.share),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1C592B), // Dark green
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton.icon(
            onPressed:
                widget.marketInfo.contact.isNotEmpty ? _contactProvider : null,
            icon: const Icon(Icons.phone, size: 18),
            label: Text(AppLocalizations.of(context)!.contact),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF1C592B), // Dark green
              side: const BorderSide(color: Color(0xFF1C592B), width: 1.5),
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _shareNews() {
    final text =
        '${widget.marketInfo.title}\n\n${widget.marketInfo.description}';
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context)!.newsCopiedToClipboard),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _bookmarkNews() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context)!.bookmarkFeatureComingSoon),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _contactProvider() {
    if (widget.marketInfo.contact.isNotEmpty) {
      final Uri phoneUri = Uri(scheme: 'tel', path: widget.marketInfo.contact);
      final scaffoldMessenger = ScaffoldMessenger.of(context);
      launchUrl(phoneUri).catchError((error) {
        if (mounted) {
          scaffoldMessenger.showSnackBar(
            SnackBar(
              content: Text('Could not launch phone app: $error'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return false;
      });
    }
  }
}
