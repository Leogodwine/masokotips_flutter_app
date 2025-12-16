import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/subscription.dart';
import '../../providers/subscription_provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/logger.dart';

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
  String? _transactionId;

  bool _loading = true;
  bool _checkingStatus = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startCheckout();
    });
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
      );

      if (!mounted) return;

      if (result != null && result.success && result.checkoutUrl.isNotEmpty) {
        setState(() {
          _transactionId = result.transactionId;
          _loading = false;
        });
      } else {
        _fail(result?.message ?? 'Failed to initiate payment.');
      }
    } catch (e) {
      Log.e('Checkout init error: $e');
      _fail('Unable to start payment.');
    }
  }

  // ---------------------------------------------------------------------------
  // CHECK FINAL STATUS
  // ---------------------------------------------------------------------------
  Future<void> _checkFinalStatus() async {
    if (_transactionId == null || _transactionId!.isEmpty) return;

    setState(() => _checkingStatus = true);

    final provider = Provider.of<SubscriptionProvider>(context, listen: false);

    final result = await provider.checkCheckoutStatus(_transactionId!);

    if (!mounted) return;

    setState(() => _checkingStatus = false);

    if (result == null) {
      _showSnack('Unable to verify payment.');
      return;
    }

    if (result.isPaid) {
      _showSuccess();
    } else if (result.status == 'FAILED') {
      _showSnack('Payment failed. Please try again.');
    } else {
      _showSnack('Payment pending. Please try again.');
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
              Navigator.pop(context); // dialog
              Navigator.pop(context); // screen
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
        title: const Text('AzamPay Payment'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.phone_android,
                    size: 72,
                    color: Colors.green,
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Payment Request Sent',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Please check your phone and approve the payment to continue.',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _checkingStatus ? null : _checkFinalStatus,
                      child: _checkingStatus
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text('I have completed payment'),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
