// subscription/payment_screen.dart
// FINAL VERSION — Initiates payment only

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/subscription.dart';
import '../../providers/subscription_provider.dart';
import '../../utils/logger.dart';

class PaymentScreen extends StatefulWidget {
  final Subscription subscription;

  const PaymentScreen({
    super.key,
    required this.subscription,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  bool _isLoading = false;

  Future<void> _startCheckout() async {
    setState(() => _isLoading = true);

    try {
      final subscriptionProvider =
          Provider.of<SubscriptionProvider>(context, listen: false);

      final int amount = widget.subscription.amount?.round() ?? 0;

      if (amount <= 0) {
        _showError('Invalid subscription amount.');
        return;
      }

      final phone = widget.subscription.metadata?['phone'];

      if (phone == null || phone.toString().isEmpty) {
        _showError('Phone number is required.');
        return;
      }

      // TEMP — replace with dropdown later
      const String selectedMno = 'AIRTEL';

      Log.i(
        'Starting AzamPay checkout → '
        'subscription=${widget.subscription.id}, '
        'amount=$amount, phone=$phone, provider=$selectedMno',
      );

      final result = await subscriptionProvider.startCheckout(
        subscriptionId: widget.subscription.id,
        amount: amount,
        phone: phone.toString(),
        provider: selectedMno, // MUST be TIGO / AIRTEL / VODACOM / HALOTEL
      );

      if (!mounted) return;

      if (result == null || !result.success || result.externalId == null) {
        _showError(result?.message ?? 'Failed to initiate payment.');
        return;
      }

      // 🔥 MOVE TO PROCESSING SCREEN
      Navigator.pushReplacementNamed(
        context,
        '/azampay-processing',
        arguments: result.externalId,
      );
    } catch (e) {
      Log.e('Payment initiation error: $e');
      _showError('Unable to start payment.');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Confirm Payment'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Subscription summary
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(Icons.receipt_long,
                        size: 32, color: theme.primaryColor),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.subscription.typeLabel,
                            style: theme.textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            '${widget.subscription.amount?.toStringAsFixed(0)} '
                            '${widget.subscription.currency}',
                            style: theme.textTheme.headlineSmall?.copyWith(
                              color: theme.primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),

            const Spacer(),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _startCheckout,
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Confirm & Pay'),
              ),
            ),

            const SizedBox(height: 12),

            Text(
              'You will receive a payment request on your phone.',
              style: theme.textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
