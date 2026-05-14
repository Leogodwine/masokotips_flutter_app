import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/buying_request.dart';
import '../../providers/auth_provider.dart';
import '../../utils/image_upload_helper.dart';

class MarketDemandDetailScreen extends StatelessWidget {
  final BuyingRequest demand;

  const MarketDemandDetailScreen({super.key, required this.demand});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isAuthenticated =
        context.read<AuthProvider>().isAuthenticated;
    final buyer = demand.user;
    final buyerName = buyer?['name'] ?? 'Anonymous Buyer';
    final buyerPhone = buyer?['phone'];
    final buyerAvatar = buyer?['avatar'];
    final hasImage =
        demand.imageUrl != null && demand.imageUrl!.isNotEmpty;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          // ── App Bar with hero image ──
          SliverAppBar(
            expandedHeight: 260,
            pinned: true,
            backgroundColor: const Color(0xFF1A8C4E),
            flexibleSpace: FlexibleSpaceBar(
              background: hasImage
                  ? Image.network(
                      ImageUploadHelper.constructFullImageUrl(
                          demand.imageUrl!),
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _heroBanner(),
                    )
                  : _heroBanner(),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── WANTED badge + status ──
                  Row(
                    children: [
                      _badge(
                          Icons.shopping_bag_outlined,
                          'PROCUREMENT REQUEST',
                          const Color(0xFF1A8C4E)),
                      const Spacer(),
                      _statusChip(demand.status),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // ── Title ──
                  Text(
                    demand.title,
                    style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 10),

                  // ── Description ──
                  Text(
                    demand.description,
                    style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[700], height: 1.6),
                  ),
                  const SizedBox(height: 20),

                  // ── Key Details ──
                  _detailsCard(theme, context),

                  const SizedBox(height: 20),

                  // ── Buyer / Contact Info ──
                  _buyerCard(context, theme, isAuthenticated,
                      buyerName, buyerPhone, buyerAvatar),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Helper Widgets ──────────────────────────────────────────────

  Widget _heroBanner() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1A8C4E), Color(0xFF0D5C32)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: const Center(
        child: Icon(Icons.shopping_basket_outlined,
            size: 80, color: Colors.white24),
      ),
    );
  }

  Widget _detailsCard(ThemeData theme, BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.4),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _detailRow(Icons.scale_outlined, 'Quantity',
                '${demand.quantity} ${demand.unit}', theme),
            _divider(),
            _detailRow(Icons.location_on_outlined, 'Delivery Location',
                demand.deliveryLocation, theme),
            _divider(),
            _detailRow(
                Icons.calendar_today_outlined,
                'Posted',
                _formatDate(demand.createdAt),
                theme),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(
      IconData icon, String label, String value, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF1A8C4E).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: const Color(0xFF1A8C4E)),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: TextStyle(fontSize: 11, color: Colors.grey[500])),
              Text(value,
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w700)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _divider() =>
      Divider(height: 1, color: Colors.grey.withOpacity(0.2));

  Widget _buyerCard(
      BuildContext context,
      ThemeData theme,
      bool isAuthenticated,
      String buyerName,
      String? buyerPhone,
      String? buyerAvatar) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Posted By',
            style: theme.textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Card(
          elevation: 0,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.4),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 26,
                      backgroundColor:
                          const Color(0xFF1A8C4E).withOpacity(0.15),
                      backgroundImage: buyerAvatar != null
                          ? NetworkImage(
                              ImageUploadHelper.constructFullImageUrl(
                                  buyerAvatar))
                          : null,
                      child: buyerAvatar == null
                          ? Text(
                              buyerName.isNotEmpty
                                  ? buyerName[0].toUpperCase()
                                  : 'B',
                              style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1A8C4E)),
                            )
                          : null,
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(buyerName,
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w700)),
                          const SizedBox(height: 2),
                          Text('Verified Buyer',
                              style: TextStyle(
                                  fontSize: 12, color: Colors.grey[600])),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Phone — shown only to subscribers, masked otherwise
                if (isAuthenticated && buyerPhone != null &&
                    buyerPhone != '****')
                  _contactButton(context, buyerPhone)
                else
                  _subscribeToContact(context),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _contactButton(BuildContext context, String phone) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Contact: $phone')),
          );
        },
        icon: const Icon(Icons.phone_outlined),
        label: Text(phone),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1A8C4E),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  Widget _subscribeToContact(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () => Navigator.pushNamed(context, '/subscription'),
        icon: const Icon(Icons.lock_outline, size: 18),
        label: const Text('Subscribe to view contact'),
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFF1A8C4E),
          side: const BorderSide(color: Color(0xFF1A8C4E)),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  Widget _badge(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 5),
          Text(label,
              style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: color,
                  letterSpacing: 0.5)),
        ],
      ),
    );
  }

  Widget _statusChip(String status) {
    final isOpen = status == 'open';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: (isOpen ? Colors.green : Colors.orange).withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
            color: isOpen ? Colors.green : Colors.orange, width: 0.8),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: isOpen ? Colors.green : Colors.orange,
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[dt.month - 1]} ${dt.day}, ${dt.year}';
  }
}
