import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/subscription.dart';
import '../../providers/subscription_provider.dart';
import '../../utils/logger.dart';
import 'zenopay_payment_screen.dart';
import '../../config/phone_countries.dart';
import '../../widgets/phone_input_field.dart';
import 'package:masoko_tips/l10n/app_localizations.dart';

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
      icon: Icons.check_circle,
      supported: true,
    );
  }

  // Halotel: 062X
  if (local.startsWith('062')) {
    return const _NetworkInfo(
      network: _TzNetwork.halotel,
      name: 'Halo Pesa (Halotel)',
      color: Color(0xFFFF6F00),
      icon: Icons.check_circle,
      supported: true,
    );
  }

  // Yas (Mixx by YAS / MIC Tanzania): 069X, 066X, 077X
  if (RegExp(r'^06[69]|^077').hasMatch(local)) {
    return const _NetworkInfo(
      network: _TzNetwork.yas,
      name: 'Mixx by YAS',
      color: Color(0xFF9C27B0),
      icon: Icons.check_circle,
      supported: true,
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
    return PhoneCountries.byIso('TZ').composeE164(phone);
  }

  Future<void> _proceedToPayment() async {
    if (!_formKey.currentState!.validate()) return;

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
        months: widget.plan.months,
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final price = widget.plan.price?.toStringAsFixed(0) ?? '0';

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.enterPaymentNumber),
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

              // Phone input (Tanzania mobile money)
              PhoneInputField(
                nationalController: _phoneController,
                lockIso: true,
                lockIsoCode: 'TZ',
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a phone number';
                  }
                  return PhoneCountries.byIso('TZ').validateNational(value);
                },
              ),

              if (_detectedNetwork != null && _detectedNetwork!.name.isNotEmpty) ...[
                const SizedBox(height: 8),
                Chip(
                  label: Text(
                    _detectedNetwork!.name,
                    style: const TextStyle(fontSize: 11, color: Colors.white),
                  ),
                  backgroundColor: _detectedNetwork!.color,
                  avatar: Icon(
                    _detectedNetwork!.icon,
                    size: 14,
                    color: Colors.white,
                  ),
                ),
              ],

              const SizedBox(height: 8),

              Wrap(
                spacing: 6,
                children: [
                  _networkBadge('M-Pesa', const Color(0xFF4CAF50)),
                  _networkBadge('Airtel', const Color(0xFFE53935)),
                  _networkBadge('Tigo', const Color(0xFF1565C0)),
                  _networkBadge('Halopesa', const Color(0xFFFF6F00)),
                  _networkBadge('Mixx YAS', const Color(0xFF9C27B0)),
                ],
              ),

              const SizedBox(height: 28),

              // Pay button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _proceedToPayment,
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
