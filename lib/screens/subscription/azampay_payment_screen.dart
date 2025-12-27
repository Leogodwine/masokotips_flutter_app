import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/subscription.dart';
import '../../providers/subscription_provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/logger.dart';
import '../subscription/azampay_processing_screen.dart';
import '../../config/api_config.dart';

class AzamPayPaymentScreen extends StatefulWidget {
  final Subscription subscription;

  const AzamPayPaymentScreen({
    super.key,
    required this.subscription,
  });

  @override
  State<AzamPayPaymentScreen> createState() => _AzamPayPaymentScreenState();
}

class _AzamPayPaymentScreenState extends State<AzamPayPaymentScreen> {
  bool _loading = true;

  // Polling state
  Timer? _pollingTimer;
  bool _isPolling = false;
  int _pollingAttempts = 0;
  static const Duration _pollingInterval = Duration(seconds: 5);
  static const int _maxPollingAttempts = 36; // 3 minutes (36 * 5s)
  // TEMP or UI-selected value
  static const String apiBaseUrl = ApiConfig.baseUrl;
  String selectedMno = 'TIGO';

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _startCheckout();

      if (mounted) {
        setState(() => _loading = false);
        _startPolling();
      }
    });
  }

  @override
  void dispose() {
    // Ensure the timer is cancelled when the screen is disposed
    // to prevent memory leaks and background execution.
    _stopPolling();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // START CHECKOUT
  // ---------------------------------------------------------------------------
  Future<void> _startCheckout() async {
    try {
      final provider =
          Provider.of<SubscriptionProvider>(context, listen: false);

      final int amount = (widget.subscription.amount ?? 0).round();

      if (amount <= 0) {
        _fail('Invalid subscription amount.');
        return;
      }

      final phone = widget.subscription.metadata?['phone'] ??
          Provider.of<AuthProvider>(context, listen: false).user?.phoneNumber;

      if (phone == null || phone.toString().isEmpty) {
        _fail('Phone number is required to make payment.');
        return;
      }

      Log.i(
        'AzamPay checkout → subscription=${widget.subscription.id}, '
        'amount=$amount, phone=$phone',
      );

      final result = await provider.startCheckout(
        subscriptionId: widget.subscription.id,
        amount: amount,
        phone: phone.toString(),
        // IMPORTANT: provider (AIRTEL/VODACOM/TIGO/HALOTEL)
        //provider: provider.selectedMno,
        provider: selectedMno,
      );

      if (!mounted) return;

      if (result == null || !result.success || result.externalId == null) {
        _fail(result?.message ?? 'Failed to initiate payment.');
        return;
      }

      // 🚀 MOVE TO PROCESSING SCREEN
      final processingResult = await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => AzamPayProcessingScreen(
            baseUrl: apiBaseUrl,
            token: Provider.of<AuthProvider>(context, listen: false).token!,
            externalId: result.externalId!,
          ),
        ),
      );

      if (!mounted) return;

      if (processingResult != null && processingResult['success'] == true) {
        // Payment confirmed → go to dashboard / success screen
        Navigator.pushReplacementNamed(context, '/dashboard');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              processingResult?['message'] ?? 'Payment not confirmed yet.',
            ),
          ),
        );
      }
    } catch (e, st) {
      Log.e('Checkout init error', e, st);
      _fail('Unable to start payment.');
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

    Log.i('🔄 Starting automatic subscription status polling...');

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
          setState(() {}); // Update UI to show manual check button
          _showSnack(
            'Payment verification timed out. Please check your payment status.',
          );
        }
        return;
      }

      // Use isPolling=true to prevent UI feedback on each check
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

    if (result.status == 'active') {
      _stopPolling();
      setState(() => _loading = false);
      _showSuccess();
    } else if (result.status == 'failed') {
      _stopPolling();
      setState(() => _loading = false);
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
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  void _showSuccess() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text('Payment Successful'),
        content: const Text('Your subscription is now active.'),
        actions: [
          TextButton(
            onPressed: () {
              _stopPolling();
              // Pop twice to close the dialog and the payment screen
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: const Text('Continue'),
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
        title: const Text('Processing Payment'),
        automaticallyImplyLeading: false,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : const Center(
              child: Text(
                'Waiting for payment approval...\n'
                'Please approve on your phone.',
                textAlign: TextAlign.center,
              ),
            ),
    );
  }
}
