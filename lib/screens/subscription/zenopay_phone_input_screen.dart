import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/subscription.dart';
import '../../providers/subscription_provider.dart';
import '../../utils/logger.dart';
import 'zenopay_payment_screen.dart';

// ── Tanzanian network detection ──────────────────────────────────────────────
enum _TzNetwork { mpesa, airtel, tigo, halotel, yas, unknown }

class _NetworkInfo {
  final _TzNetwork network;
  final String name;
  final Color color;
  final IconData icon;
  final bool supported; // supported by Zenopay

  const _NetworkInfo({
    required this.network,
    required this.name,
    required this.color,
    required this.icon,
    required this.supported,
  });
}

_NetworkInfo _detectNetwork(String phone) {
  final digits = phone.replaceAll(RegExp(r'\D'), '');

  // Normalize to local 10-digit for prefix matching
  String local;
  if (digits.length == 12 && digits.startsWith('255')) {
    local = '0${digits.substring(3)}';
  } else if (digits.length == 9 &&
      (digits.startsWith('7') || digits.startsWith('6'))) {
    local = '0$digits';
  } else {
    local = digits;
  }

  if (local.length < 4) {
    return const _NetworkInfo(
      network: _TzNetwork.unknown,
      name: '',
      color: Colors.grey,
      icon: Icons.phone,
      supported: true,
    );
  }

  // Vodacom / M-Pesa: 074X, 075X, 076X
  if (RegExp(r'^07[456]').hasMatch(local)) {
    return const _NetworkInfo(
      network: _TzNetwork.mpesa,
      name: 'M-Pesa (Vodacom)',
      color: Color(0xFF4CAF50),
      icon: Icons.check_circle,
      supported: true,
    );
  }

  // Airtel: 078X, 068X, 069X (some)
  if (RegExp(r'^07[89]|^068').hasMatch(local)) {
    return const _NetworkInfo(
      network: _TzNetwork.airtel,
      name: 'Airtel Money',
      color: Color(0xFFE53935),
      icon: Icons.check_circle,
      supported: true,
    );
  }

  // Tigo / MIC: 065X, 071X, 067X
  if (RegExp(r'^06[57]|^071').hasMatch(local)) {
    return const _NetworkInfo(
      network: _TzNetwork.tigo,
      name: 'Tigo Pesa',
      color: Color(0xFF1565C0),
      icon: Icons.warning_amber_rounded,
      supported: false, // ← gateway issues reported
    );
  }

  // Halotel: 062X
  if (local.startsWith('062')) {
    return const _NetworkInfo(
      network: _TzNetwork.halotel,
      name: 'Halo Pesa (Halotel)',
      color: Color(0xFFFF6F00),
      icon: Icons.warning_amber_rounded,
      supported: false, // ← gateway issues reported
    );
  }

  // Yas (Mixx by YAS / MIC Tanzania): 069X, 066X, 077X
  if (RegExp(r'^06[69]|^077').hasMatch(local)) {
    return const _NetworkInfo(
      network: _TzNetwork.yas,
      name: 'Mixx by YAS',
      color: Color(0xFF9C27B0),
      icon: Icons.warning_amber_rounded,
      supported: false, // ← NOT supported by Zenopay
    );
  }

  return const _NetworkInfo(
    network: _TzNetwork.unknown,
    name: '',
    color: Colors.grey,
    icon: Icons.phone,
    supported: true,
  );
}
// ─────────────────────────────────────────────────────────────────────────────

class ZenopayPhoneInputScreen extends StatefulWidget {
  final SubscriptionPackage package;
  final SubscriptionPlan plan;

  const ZenopayPhoneInputScreen({
    super.key,
    required this.package,
    required this.plan,
  });

  @override
  State<ZenopayPhoneInputScreen> createState() =>
      _ZenopayPhoneInputScreenState();
}

class _ZenopayPhoneInputScreenState extends State<ZenopayPhoneInputScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  _NetworkInfo? _detectedNetwork;

  @override
  void initState() {
    super.initState();
    _phoneController.addListener(_onPhoneChanged);
  }

  @override
  void dispose() {
    _phoneController.removeListener(_onPhoneChanged);
    _phoneController.dispose();
    super.dispose();
  }

  void _onPhoneChanged() {
    final raw = _phoneController.text.trim();
    final digits = raw.replaceAll(RegExp(r'\D'), '');
    if (digits.length >= 4) {
      final info = _detectNetwork(raw);
      setState(() => _detectedNetwork = info);
    } else {
      setState(() => _detectedNetwork = null);
    }
  }

  String _normalizePhone(String phone) {
    final digits = phone.replaceAll(RegExp(r'\D'), '');

    // E.164: 255XXXXXXXXX (12 digits)
    if (digits.startsWith('255') && digits.length == 12) return digits;

    // Local with leading 0: 0XXXXXXXXX (10 digits)  — handles 07X AND 06X
    if (digits.startsWith('0') && digits.length == 10) {
      return '255${digits.substring(1)}';
    }

    // 9 digits starting with 7 or 6
    if (digits.length == 9 &&
        (digits.startsWith('7') || digits.startsWith('6'))) {
      return '255$digits';
    }

    return digits;
  }

  Future<void> _proceedToPayment() async {
    if (!_formKey.currentState!.validate()) return;

    // Block Yas — not supported
    if (_detectedNetwork?.supported == false) {
      _showUnsupportedNetworkDialog(_detectedNetwork!);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final provider = context.read<SubscriptionProvider>();
      final phone = _normalizePhone(_phoneController.text.trim());

      if (phone.isEmpty || phone.length < 9) {
        _showSnack('Please enter a valid phone number');
        setState(() => _isLoading = false);
        return;
      }

      Log.i('Creating subscription — phone: $phone '
          'network: ${_detectedNetwork?.name}');

      final subscription = await provider.createSubscription(
        subscriptionType: widget.package.id,
        duration: widget.plan.duration,
        paymentMethod: 'zenopay',
        phone: phone,
      );

      if (!mounted) return;

      if (subscription != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => ZenopayPaymentScreen(subscription: subscription),
          ),
        );
      } else {
        _showSnack(provider.errorMessage ?? 'Failed to create subscription');
      }
    } catch (e) {
      Log.e('Subscription creation error: $e');
      _showSnack('Unexpected error occurred');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  void _showUnsupportedNetworkDialog(_NetworkInfo info) {
    final isTempIssue = info.network == _TzNetwork.tigo ||
        info.network == _TzNetwork.halotel;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(
              isTempIssue ? Icons.construction : Icons.warning_amber_rounded,
              color: isTempIssue ? Colors.orange : Colors.red,
              size: 28,
            ),
            const SizedBox(width: 10),
            Text(isTempIssue ? 'Temporarily Unavailable' : 'Network Not Supported'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isTempIssue
                  ? '${info.name} payments are temporarily experiencing issues. Please try again later or use a different network.'
                  : '${info.name} is currently not supported by our payment provider (Zenopay).',
              style: const TextStyle(fontSize: 15),
            ),
            const SizedBox(height: 12),
            const Text(
              'Currently working:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            _supportedNetworkChip('M-Pesa (Vodacom)', const Color(0xFF4CAF50)),
            _supportedNetworkChip('Airtel Money', const Color(0xFFE53935)),
            const SizedBox(height: 6),
            const Text(
              'Alternatively, you can pay by Card (Visa/Mastercard) — tap Go Back and choose Card Payment.',
              style: TextStyle(color: Colors.grey, fontSize: 13),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK, Change Number'),
          ),
        ],
      ),
    );
  }

  Widget _supportedNetworkChip(String name, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(Icons.check_circle, color: color, size: 16),
          const SizedBox(width: 8),
          Text(name),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final price = widget.plan.price?.toStringAsFixed(0) ?? '0';
    final network = _detectedNetwork;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Enter Payment Number'),
        backgroundColor: theme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Package summary card
              Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.package.name,
                          style: theme.textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text(widget.package.description,
                          style: TextStyle(color: Colors.grey[600])),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(widget.plan.durationLabel,
                              style: theme.textTheme.bodyLarge),
                          Text(
                            'TZS $price',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: theme.primaryColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              const Text(
                'Payment Phone Number',
                style:
                    TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 6),
              const Text(
                'Enter the mobile money number that will receive the payment prompt.',
                style: TextStyle(color: Colors.grey, fontSize: 13),
              ),
              const SizedBox(height: 12),

              // Phone input
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                style: const TextStyle(fontSize: 18, letterSpacing: 1),
                decoration: InputDecoration(
                  hintText: '07XXXXXXXX or 06XXXXXXXX',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.phone),
                  // Live network badge
                  suffixIcon: network != null && network.name.isNotEmpty
                      ? Padding(
                          padding: const EdgeInsets.only(right: 10),
                          child: Chip(
                            label: Text(
                              network.name,
                              style: TextStyle(
                                fontSize: 11,
                                color: network.supported
                                    ? Colors.white
                                    : Colors.white,
                              ),
                            ),
                            backgroundColor: network.supported
                                ? network.color
                                : Colors.orange,
                            padding: EdgeInsets.zero,
                            avatar: Icon(
                              network.icon,
                              size: 14,
                              color: Colors.white,
                            ),
                          ),
                        )
                      : null,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a phone number';
                  }
                  final digits =
                      value.trim().replaceAll(RegExp(r'\D'), '');
                  if (digits.length < 9) {
                    return 'Invalid phone number format';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 8),

              // Unsupported / temporary issue warning
              if (network != null && !network.supported)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                        color: Colors.orange.withValues(alpha: 0.4)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.warning_amber_rounded,
                          color: Colors.orange, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          (network.network == _TzNetwork.tigo ||
                                  network.network == _TzNetwork.halotel)
                              ? '${network.name} payments are temporarily unavailable. Use M-Pesa, Airtel, or Card Payment.'
                              : '${network.name} is not supported. Use M-Pesa, Airtel, or Card Payment.',
                          style: const TextStyle(
                              color: Colors.orange, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                )
              else
                // Supported networks info
                Wrap(
                  spacing: 6,
                  children: [
                    _networkBadge('M-Pesa', const Color(0xFF4CAF50)),
                    _networkBadge('Airtel', const Color(0xFFE53935)),
                    _networkBadge('Tigo', const Color(0xFF1565C0)),
                    _networkBadge('Halopesa', const Color(0xFFFF6F00)),
                  ],
                ),

              const SizedBox(height: 28),

              // Pay button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: (_isLoading ||
                          (network != null && !network.supported))
                      ? null
                      : _proceedToPayment,
                  icon: _isLoading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : const Icon(Icons.lock_outline),
                  label: Text(
                    _isLoading ? 'Please wait...' : 'Pay TZS $price',
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _networkBadge(String name, Color color) {
    return Chip(
      label: Text(name,
          style: const TextStyle(fontSize: 11, color: Colors.white)),
      backgroundColor: color,
      padding: EdgeInsets.zero,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }
}
