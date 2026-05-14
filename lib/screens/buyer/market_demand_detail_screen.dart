import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/buying_request.dart';
import '../../providers/auth_provider.dart';
import '../../utils/image_upload_helper.dart';
import '../chat/chat_screen.dart';

class MarketDemandDetailScreen extends StatefulWidget {
  final BuyingRequest demand;
  const MarketDemandDetailScreen({super.key, required this.demand});

  @override
  State<MarketDemandDetailScreen> createState() =>
      _MarketDemandDetailScreenState();
}

class _MarketDemandDetailScreenState extends State<MarketDemandDetailScreen> {
  Timer? _timer;
  Duration _remaining = Duration.zero;

  @override
  void initState() {
    super.initState();
    _updateRemaining();
    if (widget.demand.expiresAt != null) {
      // Tick every second so the countdown stays live
      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (mounted) _updateRemaining();
      });
    }
  }

  void _updateRemaining() {
    final exp = widget.demand.expiresAt;
    if (exp == null) return;
    final diff = exp.difference(DateTime.now());
    setState(() => _remaining = diff.isNegative ? Duration.zero : diff);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  // ── Phone call ──────────────────────────────────────────────────
  Future<void> _callPhone(BuildContext ctx, String phone) async {
    final cleaned = phone.replaceAll(RegExp(r'[^\d+]'), '');
    final uri = Uri(scheme: 'tel', path: cleaned);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else if (ctx.mounted) {
      ScaffoldMessenger.of(ctx).showSnackBar(
        SnackBar(content: Text('Cannot open dialer for $phone')),
      );
    }
  }

  // ── Open chat ───────────────────────────────────────────────────
  void _openChat(BuildContext ctx, String buyerName, String? buyerAvatar) {
    final buyerId = widget.demand.userId;
    final currentUserId = ctx.read<AuthProvider>().user?.id;
    if (currentUserId == null) {
      Navigator.pushNamed(ctx, '/login');
      return;
    }
    if (currentUserId == buyerId) {
      ScaffoldMessenger.of(ctx).showSnackBar(
        const SnackBar(content: Text('You cannot chat with yourself.')),
      );
      return;
    }
    final avatarUrl = buyerAvatar != null
        ? ImageUploadHelper.constructFullImageUrl(buyerAvatar)
        : '';
    Navigator.push(
      ctx,
      MaterialPageRoute(
        builder: (_) => ChatScreen(
          receiverId: buyerId,
          receiverName: buyerName,
          receiverImage: avatarUrl,
        ),
      ),
    );
  }

  // ── Countdown label ─────────────────────────────────────────────
  String _countdownLabel() {
    if (widget.demand.expiresAt == null) return '';
    if (_remaining == Duration.zero) return 'Expired';

    final d = _remaining.inDays;
    final h = _remaining.inHours % 24;
    final m = _remaining.inMinutes % 60;
    final s = _remaining.inSeconds % 60;

    if (d > 0) {
      return '${d}d ${h}h left';
    } else if (h > 0) {
      return '${h}h ${m}m left';
    } else {
      return '${m}m ${s.toString().padLeft(2, '0')}s left';
    }
  }

  Color _countdownColor() {
    final hours = _remaining.inHours;
    if (hours < 6) return Colors.red;
    if (hours < 24) return Colors.orange;
    return const Color(0xFF1A8C4E);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isAuthenticated = context.read<AuthProvider>().isAuthenticated;
    final buyer = widget.demand.user;
    final buyerName = buyer?['name'] ?? 'Anonymous Buyer';
    final buyerUsername = buyer?['username'] ?? buyerName;
    final buyerPhone = buyer?['phone'];
    final buyerAvatar = buyer?['avatar'];
    final hasImage =
        widget.demand.imageUrl != null && widget.demand.imageUrl!.isNotEmpty;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          // ── Hero App Bar ──
          SliverAppBar(
            expandedHeight: 260,
            pinned: true,
            backgroundColor: const Color(0xFF1A8C4E),
            flexibleSpace: FlexibleSpaceBar(
              background: hasImage
                  ? Image.network(
                      ImageUploadHelper.constructFullImageUrl(
                          widget.demand.imageUrl!),
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
                  // ── Badge + status + countdown ──
                  Row(
                    children: [
                      _badge(Icons.shopping_bag_outlined, 'PROCUREMENT REQUEST',
                          const Color(0xFF1A8C4E)),
                      const Spacer(),
                      _statusChip(widget.demand.status),
                    ],
                  ),

                  // Countdown timer row (below status)
                  if (widget.demand.expiresAt != null) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          _remaining.inHours < 6
                              ? Icons.timer_outlined
                              : Icons.access_time_outlined,
                          size: 14,
                          color: _countdownColor(),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          _countdownLabel(),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: _countdownColor(),
                          ),
                        ),
                      ],
                    ),
                  ],

                  const SizedBox(height: 14),

                  // ── Title ──
                  Text(
                    widget.demand.title,
                    style: theme.textTheme.headlineSmall
                        ?.copyWith(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 10),

                  // ── Description ──
                  Text(
                    widget.demand.description,
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(color: Colors.grey[700], height: 1.6),
                  ),
                  const SizedBox(height: 20),

                  // ── Key Details ──
                  _detailsCard(theme),
                  const SizedBox(height: 20),

                  // ── Buyer / Contact ──
                  _buyerCard(context, theme, isAuthenticated, buyerName,
                      buyerUsername, buyerPhone, buyerAvatar),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Helper Widgets ───────────────────────────────────────────────

  Widget _heroBanner() => Container(
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

  Widget _detailsCard(ThemeData theme) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _detailRow(Icons.scale_outlined, 'Quantity',
                '${widget.demand.quantity} ${widget.demand.unit}', theme),
            _divider(),
            _detailRow(Icons.location_on_outlined, 'Delivery Location',
                widget.demand.deliveryLocation, theme),
            _divider(),
            _detailRow(Icons.calendar_today_outlined, 'Posted',
                _formatDate(widget.demand.createdAt), theme),
            if (widget.demand.expiresAt != null) ...[
              _divider(),
              _detailRow(Icons.event_busy_outlined, 'Post Expires',
                  _formatDate(widget.demand.expiresAt!), theme),
            ],
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
              color: const Color(0xFF1A8C4E).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: const Color(0xFF1A8C4E)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: TextStyle(fontSize: 11, color: Colors.grey[500])),
                Text(value,
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w700)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider() =>
      Divider(height: 1, color: Colors.grey.withValues(alpha: 0.2));

  Widget _buyerCard(
    BuildContext ctx,
    ThemeData theme,
    bool isAuthenticated,
    String buyerName,
    String buyerUsername,
    String? buyerPhone,
    String? buyerAvatar,
  ) {
    final hasRealPhone =
        buyerPhone != null && buyerPhone.isNotEmpty && buyerPhone != '****';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Posted By',
            style:
                theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Card(
          elevation: 0,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 26,
                      backgroundColor:
                          const Color(0xFF1A8C4E).withValues(alpha: 0.15),
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
                          Text('@$buyerUsername',
                              style: TextStyle(
                                  fontSize: 12, color: Colors.grey[600])),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                if (isAuthenticated && hasRealPhone) ...[
                  // Call button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _callPhone(ctx, buyerPhone),
                      icon: const Icon(Icons.phone_outlined),
                      label: Text(buyerPhone),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1A8C4E),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Chat button
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () =>
                          _openChat(ctx, buyerName, buyerAvatar),
                      icon: const Icon(Icons.chat_bubble_outline, size: 18),
                      label: Text('Chat with @$buyerUsername'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF1A8C4E),
                        side: const BorderSide(
                            color: Color(0xFF1A8C4E), width: 1.5),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ] else if (isAuthenticated) ...[
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () =>
                          _openChat(ctx, buyerName, buyerAvatar),
                      icon: const Icon(Icons.chat_bubble_outline, size: 18),
                      label: Text('Chat with @$buyerUsername'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF1A8C4E),
                        side: const BorderSide(color: Color(0xFF1A8C4E)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ] else ...[
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () =>
                          Navigator.pushNamed(ctx, '/subscription'),
                      icon: const Icon(Icons.lock_outline, size: 18),
                      label: const Text('Subscribe to view contact & chat'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF1A8C4E),
                        side: const BorderSide(color: Color(0xFF1A8C4E)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _badge(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
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
        color: (isOpen ? Colors.green : Colors.orange).withValues(alpha: 0.1),
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
