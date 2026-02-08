import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/subscription.dart';
import '../../providers/subscription_provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/logger.dart';

class ZenopayPaymentScreen extends StatefulWidget {
  final Subscription subscription;

  const ZenopayPaymentScreen({
    super.key,
    required this.subscription,
  });

  @override
  State<ZenopayPaymentScreen> createState() => _ZenopayPaymentScreenState();
}

class _ZenopayPaymentScreenState extends State<ZenopayPaymentScreen> {
  bool _loading = true;
  String? _orderId;

  Timer? _pollingTimer;
  int _pollingAttempts = 0;

  static const Duration _pollingInterval = Duration(seconds: 5);
  static const int _maxPollingAttempts = 36; // 3 minutes

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final ok = await _startCheckout();
      if (!mounted) return;

      setState(() => _loading = false);

      if (ok) _startPolling();
    });
  }

  @override
  void dispose() {
    _stopPolling();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // START CHECKOUT
  // ---------------------------------------------------------------------------
  Future<bool> _startCheckout() async {
    try {
      final provider =
          Provider.of<SubscriptionProvider>(context, listen: false);

      final int amount = (widget.subscription.amount ?? 0).round();
      if (amount <= 0) {
        _fail('Invalid subscription amount.');
        return false;
      }

      final auth = Provider.of<AuthProvider>(context, listen: false);
      final phone =
          widget.subscription.metadata?['phone'] ?? auth.user?.phoneNumber;

      if (phone == null || phone.toString().trim().isEmpty) {
        _fail('Phone number is required to make payment.');
        return false;
      }

      Log.i(
          'ZenoPay checkout → subscription=${widget.subscription.id}, amount=$amount, phone=$phone');

      final result = await provider.startZenopayCheckout(
        subscriptionId: widget.subscription.id,
        amount: amount,
        phone: phone.toString(),
      );

      if (!mounted) return false;

      final ok = result != null && result['success'] == true;
      final orderId = result?['order_id']?.toString();

      if (!ok || orderId == null || orderId.isEmpty) {
        _fail((result?['message'] ?? 'Failed to initiate payment.').toString());
        return false;
      }

      setState(() => _orderId = orderId);
      Log.d('ZENOPAY RESULT = $result');

      Log.d('Zenopay checkout raw result: $result');
      Log.i('✅ Zenopay started. order_id=$orderId');
      _showSnack('Payment request sent. Please approve on your phone.');

      return true;
    } catch (e, st) {
      Log.e('Checkout init error', e, st);
      _fail('Unable to start payment.');
      return false;
    }
  }

  // ---------------------------------------------------------------------------
  // POLLING
  // ---------------------------------------------------------------------------
  void _startPolling() {
    _stopPolling();
    _pollingAttempts = 0;

    _pollingTimer = Timer.periodic(_pollingInterval, (timer) async {
      if (!mounted) {
        _stopPolling();
        return;
      }

      _pollingAttempts++;

      // 1) Primary: subscription status
      final done = await _checkSubscriptionStatus();
      if (done) return;

      // 2) Fallback: if too long pending, check Zenopay order status (if we have orderId)
      if (_pollingAttempts == 12 ||
          _pollingAttempts == 24 ||
          _pollingAttempts == 36) {
        await _fallbackCheckZenopayStatus();
      }

      if (_pollingAttempts >= _maxPollingAttempts) {
        _stopPolling();
        _showSnack('Payment verification timed out. Please check again.');
      }
    });
  }

  void _stopPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
  }

  Future<bool> _checkSubscriptionStatus() async {
    final provider = Provider.of<SubscriptionProvider>(context, listen: false);

    Log.i('📡 Checking subscription status for ID: ${widget.subscription.id}');
    final result =
        await provider.checkSubscriptionStatus(widget.subscription.id);

    if (!mounted) return true;

    if (result == null) {
      Log.w('⚠️ Subscription status check returned null');
      return false;
    }

    Log.i('📡 Subscription status: ${result.status}');

    if (result.status == 'active') {
      _stopPolling();
      _showSuccess();
      return true;
    }

    if (result.status == 'failed') {
      _stopPolling();
      _showSnack('Payment failed. Please try again.');
      return true;
    }

    return false; // still pending
  }

  Future<void> _fallbackCheckZenopayStatus() async {
    final orderId = _orderId;
    if (orderId == null) return;

    final provider = Provider.of<SubscriptionProvider>(context, listen: false);
    Log.i('🧾 Fallback: checking Zenopay order status for $orderId');

    final res = await provider.checkZenopayOrderStatus(orderId);
    if (!mounted || res == null) return;

    // Your backend status endpoint might return:
    // { success: true, gateway: {...} } or { success: true, payment_status: "FAILED" ... }
    final paymentStatus =
        (res['payment_status'] ?? '').toString().toUpperCase();

    if (paymentStatus == 'FAILED' || paymentStatus == 'CANCELLED') {
      _stopPolling();
      _showSnack('Payment failed (wallet rejected). Please try again.');
    }
  }

  // ---------------------------------------------------------------------------
  // UI
  // ---------------------------------------------------------------------------
  void _fail(String message) {
    if (!mounted) return;
    setState(() => _loading = false);
    _showSnack(message);
  }

  void _showSnack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  void _showSuccess() {
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text('Payment Successful'),
        content: const Text('Your subscription is now active.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // close dialog
              Navigator.of(context).pop(true); // close payment screen
            },
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Processing Payment'),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: _loading
            ? const CircularProgressIndicator()
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Waiting for payment approval...\nPlease approve on your phone.',
                    textAlign: TextAlign.center,
                  ),
                  if (_orderId != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      'Order: $_orderId',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                  const SizedBox(height: 18),
                  ElevatedButton(
                    onPressed: () async {
                      setState(() => _loading = true);

                      final done = await _checkSubscriptionStatus();

                      if (!mounted) {
                        return;
                      }

                      setState(() => _loading = false);

                      if (!done) {
                        _showSnack('Still pending. Please wait a bit.');
                      }
                    },
                    child: const Text('Check status now'),
                  ),
                ],
              ),
      ),
    );
  }
}
