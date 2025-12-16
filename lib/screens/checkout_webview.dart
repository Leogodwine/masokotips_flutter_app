import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import '../models/subscription.dart';

class CheckoutWebViewScreen extends StatefulWidget {
  final String checkoutUrl;
  final String transactionId;
  final Subscription subscription;

  const CheckoutWebViewScreen({
    super.key,
    required this.checkoutUrl,
    required this.transactionId,
    required this.subscription,
  });

  @override
  State<CheckoutWebViewScreen> createState() => _CheckoutWebViewScreenState();
}

class _CheckoutWebViewScreenState extends State<CheckoutWebViewScreen> {
  bool _isLoading = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Complete Payment"),
        backgroundColor: theme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          if (_isLoading) const LinearProgressIndicator(minHeight: 3),
          Expanded(
            child: InAppWebView(
              initialUrlRequest: URLRequest(
                url: WebUri(widget.checkoutUrl),
              ),
              onLoadStop: (controller, url) async {
                setState(() => _isLoading = false);

                // Detect payment completion automatically
                if (url.toString().contains("payment-status")) {
                  Navigator.pop(context, {
                    "transaction_id": widget.transactionId,
                    "subscription": widget.subscription
                  });
                }
              },
              onReceivedError: (controller, request, error) {
                setState(() => _isLoading = false);

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                        "Failed to load payment page: ${error.description}"),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
