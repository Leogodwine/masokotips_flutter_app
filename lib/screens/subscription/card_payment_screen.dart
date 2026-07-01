import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import '../../models/subscription.dart';
import '../../services/card_payment_service.dart';
import '../../utils/logger.dart';

class CardPaymentScreen extends StatefulWidget {
  final Subscription subscription;

  const CardPaymentScreen({super.key, required this.subscription});

  @override
  State<CardPaymentScreen> createState() => _CardPaymentScreenState();
}

class _CardPaymentScreenState extends State<CardPaymentScreen> {
  final CardPaymentService _service = CardPaymentService();

  // Screen states
  bool _loadingCheckout = true; // fetching the payment link
  String? _paymentLink;         // hosted checkout URL
  String? _errorMsg;
  bool _webviewVisible = false;
  bool _verifying = false;      // polling after webview closes

  InAppWebViewController? _webViewController;
  double _loadProgress = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _startCheckout());
  }

  // ── Fetch payment link ────────────────────────────────────
  Future<void> _startCheckout() async {
    setState(() {
      _loadingCheckout = true;
      _errorMsg = null;
    });

    final amount = (widget.subscription.amount ?? 0).round();
    if (amount <= 0) {
      setState(() {
        _loadingCheckout = false;
        _errorMsg = 'Invalid subscription amount.';
      });
      return;
    }

    final res = await _service.startCardCheckout(
      subscriptionId: widget.subscription.id,
      amount: amount,
    );

    if (!mounted) return;

    if (res == null || res['success'] != true || res['payment_link'] == null) {
      setState(() {
        _loadingCheckout = false;
        _errorMsg = res?['message']?.toString() ?? 'Failed to initiate card payment.';
      });
      return;
    }

    setState(() {
      _loadingCheckout = false;
      _paymentLink = res['payment_link'].toString();
      _webviewVisible = true;
    });
  }

  // ── Called when webview navigates to our callback / redirect URL ──
  Future<void> _handleNavigation(String url) async {
    Log.d('Card payment webview nav: $url');

    // Detect our callback URL or ZenoPay redirect signals
    final uri = Uri.tryParse(url);
    if (uri == null) return;

    final status = uri.queryParameters['status']?.toLowerCase();
    final isCallback = url.contains('/zenopay/card/callback') ||
        url.contains('#card-payment') ||
        status != null;

    if (!isCallback) return;

    // Stop the webview
    _webViewController?.stopLoading();

    if (status == 'successful' || status == 'success') {
      await _verifyAndComplete();
    } else if (status == 'cancelled') {
      _showResult(false, 'Payment was cancelled. You can try again.');
    } else if (status == 'failed') {
      _showResult(false, 'Card payment failed. Please try a different card.');
    } else {
      // Unknown — poll the backend
      await _verifyAndComplete();
    }
  }

  // ── Poll backend to confirm subscription is active ────────
  Future<void> _verifyAndComplete() async {
    if (!mounted) return;
    setState(() {
      _webviewVisible = false;
      _verifying = true;
    });

    // Give backend a moment to process the callback
    await Future.delayed(const Duration(seconds: 2));

    // Poll up to 10 times (10 × 3s = 30s max)
    for (int i = 0; i < 10; i++) {
      final res = await _service.checkCardStatus(widget.subscription.id);
      if (!mounted) return;

      final s = res?['status']?.toString().toLowerCase() ?? '';
      Log.d('Card status poll $i: $s');

      if (s == 'active' || res?['is_active'] == true) {
        setState(() => _verifying = false);
        _showSuccess();
        return;
      }
      if (s == 'failed' || s == 'cancelled') {
        break;
      }
      await Future.delayed(const Duration(seconds: 3));
    }

    if (mounted) setState(() => _verifying = false);
    _showResult(false, 'Could not confirm payment. Tap "Check Again" or contact support.');
  }

  // ── Success dialog ─────────────────────────────────────────
  void _showSuccess() {
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 72),
            SizedBox(height: 16),
            Text('Payment Successful!',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center),
            SizedBox(height: 8),
            Text('Your subscription is now active.\nWelcome aboard!',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey)),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12))),
              onPressed: () {
                Navigator.of(context).pop(); // close dialog
                Navigator.of(context).pop(true); // return success
              },
              child: const Text('Continue'),
            ),
          ),
        ],
      ),
    );
  }

  void _showResult(bool success, String message) {
    if (!mounted) return;
    if (success) {
      _showSuccess();
    } else {
      setState(() => _errorMsg = message);
    }
  }

  // ── BUILD ─────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Card Payment'),
        backgroundColor: theme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        // Show close/back only when webview is visible
        leading: _webviewVisible
            ? IconButton(
                icon: const Icon(Icons.close),
                onPressed: _confirmCancelWebview,
              )
            : null,
        automaticallyImplyLeading: !_webviewVisible,
      ),
      body: _buildBody(theme),
    );
  }

  Widget _buildBody(ThemeData theme) {
    // Loading checkout link
    if (_loadingCheckout) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: theme.primaryColor),
            const SizedBox(height: 16),
            const Text('Preparing secure checkout...',
                style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    // Verifying after webview
    if (_verifying) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: theme.primaryColor),
            const SizedBox(height: 16),
            const Text('Verifying payment...',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Please wait, this may take a moment.',
                style: TextStyle(color: Colors.grey[600])),
          ],
        ),
      );
    }

    // Error state
    if (_errorMsg != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.red.withValues(alpha: 0.1)),
                child:
                    const Icon(Icons.error_outline, color: Colors.red, size: 44),
              ),
              const SizedBox(height: 20),
              const Text('Payment Error',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.red)),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: Colors.red.withValues(alpha: 0.2))),
                child: Text(_errorMsg!,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.red[700], height: 1.5)),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _startCheckout,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Try Again'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12))),
                  child: const Text('Go Back'),
                ),
              ),
              const SizedBox(height: 12),
              // Manual check — in case payment went through but we missed it
              TextButton(
                onPressed: () => _verifyAndComplete(),
                child: const Text('Check Again'),
              ),
            ],
          ),
        ),
      );
    }

    // WebView — hosted checkout
    if (_webviewVisible && _paymentLink != null) {
      return Stack(
        children: [
          InAppWebView(
            initialUrlRequest:
                URLRequest(url: WebUri(_paymentLink!)),
            initialSettings: InAppWebViewSettings(
              javaScriptEnabled: true,
              useShouldOverrideUrlLoading: true,
              mediaPlaybackRequiresUserGesture: false,
              allowsInlineMediaPlayback: true,
            ),
            onWebViewCreated: (c) => _webViewController = c,
            onLoadStart: (c, url) {
              if (url != null) _handleNavigation(url.toString());
            },
            onLoadStop: (c, url) {
              if (url != null) _handleNavigation(url.toString());
            },
            shouldOverrideUrlLoading: (c, action) async {
              final url = action.request.url?.toString() ?? '';
              _handleNavigation(url);
              return NavigationActionPolicy.ALLOW;
            },
            onProgressChanged: (c, progress) {
              setState(() => _loadProgress = progress / 100);
            },
          ),
          // Progress bar
          if (_loadProgress < 1.0)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: LinearProgressIndicator(
                value: _loadProgress,
                backgroundColor: Colors.transparent,
                color: theme.primaryColor,
                minHeight: 3,
              ),
            ),
          // Security badge
          Positioned(
            bottom: 16,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.lock_outline, size: 14, color: Colors.white),
                    SizedBox(width: 6),
                    Text('Secured by ZenoPay',
                        style: TextStyle(color: Colors.white, fontSize: 12)),
                  ],
                ),
              ),
            ),
          ),
        ],
      );
    }

    return const SizedBox.shrink();
  }

  Future<void> _confirmCancelWebview() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Cancel Payment?'),
        content: const Text('Go back without completing payment?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Stay')),
          TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Cancel')),
        ],
      ),
    );
    if (ok == true && mounted) {
      setState(() => _webviewVisible = false);
    }
  }
}
