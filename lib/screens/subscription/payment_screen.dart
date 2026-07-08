import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/subscription.dart';
import '../../providers/subscription_provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/logger.dart';
import 'package:masoko_tips/l10n/app_localizations.dart';

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

  // Polling state
  Timer? _pollingTimer;
  bool _isPolling = false;
  int _pollingAttempts = 0;

  static const Duration _pollingInterval = Duration(seconds: 5);
  static const int _maxPollingAttempts = 36; // 3 minutes (36 * 5s)

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
  // START CHECKOUT (ZENOPAY)
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
        'Zenopay checkout → subscription=${widget.subscription.id}, amount=$amount, phone=$phone',
      );

      final result = await provider.startZenopayCheckout(
        subscriptionId: widget.subscription.id,
        amount: amount,
        phone: phone.toString(),
      );

      if (!mounted) return false;

      final ok = result != null && result['success'] == true;
      final orderId = result?['order_id'];

      if (!ok || orderId == null) {
        _fail((result?['message'] ?? 'Failed to initiate payment.').toString());
        return false;
      }

      Log.i('✅ Zenopay order created: $orderId');
      _showSnack('Payment request sent. Please approve on your phone.');

      return true;
    } catch (e, st) {
      Log.e('Checkout init error', e, st);
      _fail('Unable to start payment.');
      return false;
    }
  }

  // ---------------------------------------------------------------------------
  // POLLING LOGIC
  // ---------------------------------------------------------------------------
  void _startPolling() {
    if (_isPolling) return;

    setState(() {
      _isPolling = true;
      _pollingAttempts = 0;
    });

    Log.i('🔄 Starting subscription status polling...');

    _pollingTimer = Timer.periodic(_pollingInterval, (timer) async {
      if (!mounted) {
        _stopPolling();
        return;
      }

      _pollingAttempts++;

      if (_pollingAttempts >= _maxPollingAttempts) {
        Log.w('⏰ Polling timeout reached');
        _stopPolling();

        if (mounted) {
          _showSnack(
            'Payment verification timed out. Please check your payment status.',
          );
          setState(() {}); // refresh UI state if you later add a manual button
        }
        return;
      }

      await _checkFinalStatus(isPolling: true);
    });
  }

  void _stopPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
    _isPolling = false;
  }

  // ---------------------------------------------------------------------------
  // CHECK FINAL STATUS
  // ---------------------------------------------------------------------------
  Future<void> _checkFinalStatus({bool isPolling = false}) async {
    final provider = Provider.of<SubscriptionProvider>(context, listen: false);

    Log.i('📡 Checking subscription status for ID: ${widget.subscription.id}');

    final result =
        await provider.checkSubscriptionStatus(widget.subscription.id);

    if (!mounted) return;

    if (result == null) {
      Log.w('⚠️ Subscription status check returned null');
      return;
    }

    Log.i('📡 Subscription status: ${result.status}');

    // Match your backend mapping:
    // completed -> active, pending -> pending, failed -> failed
    if (result.status == 'active') {
      _stopPolling();
      _showSuccess();
    } else if (result.status == 'failed') {
      _stopPolling();
      _showSnack('Payment failed. Please try again.');
    }
  }

  // ---------------------------------------------------------------------------
  // UI HELPERS
  // ---------------------------------------------------------------------------
  void _fail(String message) {
    if (!mounted) return;
    setState(() => _loading = false);
    _showSnack(message);
  }

  void _showSnack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  void _showSuccess() {
    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.paymentSuccessful),
        content: Text(AppLocalizations.of(context)!.yourSubscriptionIsNowActive),
        actions: [
          TextButton(
            onPressed: () {
              _stopPolling();
              Navigator.of(context).pop(); // close dialog
              Navigator.of(context).pop(true); // close payment screen
            },
            child: Text(AppLocalizations.of(context)!.continueText),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // BUILD
  // ---------------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.processingPayment),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: _loading
            ? const CircularProgressIndicator()
            : const Text(
                'Waiting for payment approval...\n'
                'Please approve on your phone.',
                textAlign: TextAlign.center,
              ),
      ),
    );
  }
}
