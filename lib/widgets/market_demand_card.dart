import 'dart:async';
import 'package:flutter/material.dart';
import '../models/buying_request.dart';
import '../utils/image_upload_helper.dart';

class MarketDemandCard extends StatelessWidget {
  final BuyingRequest demand;
  final VoidCallback onTap;

  const MarketDemandCard({
    super.key,
    required this.demand,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final buyerName = demand.user?['name'] ?? 'Anonymous Buyer';
    final buyerAvatar = demand.user?['avatar'];
    final hasImage = demand.imageUrl != null && demand.imageUrl!.isNotEmpty;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 270,
        margin: const EdgeInsets.only(right: 14),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.07),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(
            color: const Color(0xFF1A8C4E).withOpacity(0.18),
            width: 1.2,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          clipBehavior: Clip.hardEdge,
          children: [
            // ── Top: image OR placeholder banner ──
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(18)),
              child: hasImage
                  ? Image.network(
                      ImageUploadHelper.constructFullImageUrl(demand.imageUrl!),
                      height: 130,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _placeholderBanner(),
                    )
                  : _placeholderBanner(),
            ),

            // ── Content ──
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Badge + quantity row
                  Row(
                    children: [
                      _badge(
                        Icons.shopping_bag_outlined,
                        'WANTED',
                        const Color(0xFF1A8C4E),
                      ),
                      const Spacer(),
                      Text(
                        '${demand.quantity} ${demand.unit}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Title
                  Text(
                    demand.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),

                  // Delivery location
                  Row(
                    children: [
                      Icon(Icons.location_on_outlined,
                          size: 13, color: Colors.grey[500]),
                      const SizedBox(width: 3),
                      Expanded(
                        child: Text(
                          demand.deliveryLocation,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style:
                              TextStyle(fontSize: 12, color: Colors.grey[600]),
                        ),
                      ),
                    ],
                  ),

                  // Expiry indicator
                  if (demand.expiresAt != null) ...[
                    const SizedBox(height: 4),
                    _ExpiryIndicator(expiresAt: demand.expiresAt!),
                  ],
                  const SizedBox(height: 10),

                  // Divider
                  Divider(height: 1, color: Colors.grey[200]),
                  const SizedBox(height: 8),

                  // Buyer row
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 13,
                        backgroundColor: const Color(0xFF1A8C4E).withOpacity(0.12),
                        backgroundImage: buyerAvatar != null
                            ? NetworkImage(ImageUploadHelper
                                .constructFullImageUrl(buyerAvatar))
                            : null,
                        child: buyerAvatar == null
                            ? Text(
                                buyerName.isNotEmpty
                                    ? buyerName[0].toUpperCase()
                                    : 'B',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1A8C4E),
                                ),
                              )
                            : null,
                      ),
                      const SizedBox(width: 7),
                      Expanded(
                        child: Text(
                          buyerName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontSize: 12, fontWeight: FontWeight.w600),
                        ),
                      ),
                      Text(
                        _timeAgo(demand.createdAt),
                        style:
                            TextStyle(fontSize: 11, color: Colors.grey[500]),
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

  Widget _placeholderBanner() {
    return Container(
      height: 130,
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1A8C4E), Color(0xFF2ECC71)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: const Center(
        child: Icon(Icons.shopping_basket_outlined,
            size: 48, color: Colors.white54),
      ),
    );
  }

  Widget _badge(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: color),
          const SizedBox(width: 3),
          Text(
            label,
            style: TextStyle(
                fontSize: 10, fontWeight: FontWeight.w800, color: color),
          ),
        ],
      ),
    );
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}

// ── Compact expiry indicator (self-updating) ────────────────────────────────
class _ExpiryIndicator extends StatefulWidget {
  final DateTime expiresAt;
  const _ExpiryIndicator({required this.expiresAt});

  @override
  State<_ExpiryIndicator> createState() => _ExpiryIndicatorState();
}

class _ExpiryIndicatorState extends State<_ExpiryIndicator> {
  late Timer _timer;
  late Duration _remaining;

  @override
  void initState() {
    super.initState();
    _updateRemaining();
    _timer = Timer.periodic(const Duration(minutes: 1), (_) {
      if (mounted) _updateRemaining();
    });
  }

  void _updateRemaining() {
    final diff = widget.expiresAt.difference(DateTime.now());
    setState(() => _remaining = diff.isNegative ? Duration.zero : diff);
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  Color get _color {
    if (_remaining.inHours < 6) return Colors.red;
    if (_remaining.inHours < 24) return Colors.orange;
    return const Color(0xFF1A8C4E);
  }

  String get _label {
    if (_remaining == Duration.zero) return 'Expired';
    final d = _remaining.inDays;
    final h = _remaining.inHours % 24;
    if (d > 0) return '${d}d ${h}h left';
    final m = _remaining.inMinutes % 60;
    return '${_remaining.inHours}h ${m}m left';
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(Icons.access_time_outlined, size: 11, color: _color),
        const SizedBox(width: 3),
        Text(
          _label,
          style: TextStyle(
              fontSize: 11, fontWeight: FontWeight.w700, color: _color),
        ),
      ],
    );
  }
}
