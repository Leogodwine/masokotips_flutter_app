// subscription/payment_screen.dart
// NEW CHECKOUT VERSION — No manual entry required

import '../../models/subscription.dart';
import '../../models/checkout_status_result.dart';
import '../../providers/subscription_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../utils/logger.dart';

class PaymentScreen extends StatefulWidget {
  final Subscription subscription;
  final String transactionId;

  const PaymentScreen({
    super.key,
    required this.subscription,
    required this.transactionId,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  String _paymentStatus = "PENDING";
  bool _isChecking = false;

  @override
  void initState() {
    super.initState();
    _checkStatus(); // auto-check on load
  }

  Future<void> _checkStatus() async {
    setState(() => _isChecking = true);

    try {
      final provider = Provider.of<SubscriptionProvider>(
        context,
        listen: false,
      );

      final AzamPayCheckoutStatusResult? result =
          await provider.checkCheckoutStatus(widget.transactionId);

      if (!mounted) return;

      if (result != null) {
        setState(() => _paymentStatus = result.status);

        if (result.isPaid) {
          _showSuccessDialog();
        } else if (result.status == "FAILED") {
          _showFailedDialog();
        }
      } else {
        _showError("Could not check payment status");
      }
    } catch (e) {
      Log.e("Error checking payment status: $e");
      _showError("Unexpected error occurred");
    } finally {
      if (mounted) {
        setState(() => _isChecking = false);
      }
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text("Payment Successful"),
        content: const Text("Your subscription is now active."),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // close dialog
              Navigator.pop(context); // close screen
            },
            child: const Text("Continue"),
          )
        ],
      ),
    );
  }

  void _showFailedDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Payment Failed"),
        content: const Text(
            "Your payment could not be completed. Please try again."),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // close dialog
            },
            child: const Text("OK"),
          )
        ],
      ),
    );
  }

  IconData get _statusIcon {
    switch (_paymentStatus) {
      case "SUCCESS":
        return Icons.check_circle;
      case "FAILED":
        return Icons.error;
      default:
        return Icons.pending;
    }
  }

  Color get _statusColor {
    switch (_paymentStatus) {
      case "SUCCESS":
        return Colors.green;
      case "FAILED":
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Payment Status"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Subscription Summary
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
                            "${widget.subscription.amount?.toStringAsFixed(0)} ${widget.subscription.currency}",
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

            const SizedBox(height: 20),

            // Status Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Icon(
                      _statusIcon,
                      size: 72,
                      color: _statusColor,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _paymentStatus == "SUCCESS"
                          ? "Payment Successful"
                          : _paymentStatus == "FAILED"
                              ? "Payment Failed"
                              : "Payment Pending",
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: _statusColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Transaction ID: ${widget.transactionId}",
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Check Again Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isChecking ? null : _checkStatus,
                child: _isChecking
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text("Re-check Payment Status"),
              ),
            ),

            const SizedBox(height: 16),

            // Help
            Text(
              "If your payment is still pending, please wait a moment and try again.",
              textAlign: TextAlign.center,
              style:
                  theme.textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }
}
