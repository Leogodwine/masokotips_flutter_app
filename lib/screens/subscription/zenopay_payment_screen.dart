import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/subscription.dart';
import '../../providers/subscription_provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/logger.dart';
import 'package:masoko_tips/l10n/app_localizations.dart';

// Payment screen states
enum _PayState { starting, waiting, checking, success, failed, timedOut }

class ZenopayPaymentScreen extends StatefulWidget {
  final Subscription subscription;

  const ZenopayPaymentScreen({
    super.key,
    required this.subscription,
  });

  @override
  State<ZenopayPaymentScreen> createState() => _ZenopayPaymentScreenState();
}

class _ZenopayPaymentScreenState extends State<ZenopayPaymentScreen>
    with SingleTickerProviderStateMixin {
  _PayState _state = _PayState.starting;
  String? _orderId;
  String _failReason = 'Payment failed. Please try again.';

  Timer? _pollingTimer;
  int _pollingAttempts = 0;
  int _elapsedSeconds = 0;
  Timer? _clockTimer;

  // Poll every 5 seconds, give up after 3 minutes
  static const Duration _pollInterval = Duration(seconds: 5);
  static const int _maxAttempts = 36;

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) => _startCheckout());
  }

  @override
  void dispose() {
    _stopPolling();
    _clockTimer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  // ─────────────────────────────────────────────────────────
  // START CHECKOUT
  // ─────────────────────────────────────────────────────────
  Future<void> _startCheckout() async {
    if (!mounted) return;
    setState(() => _state = _PayState.starting);

    try {
      final provider = context.read<SubscriptionProvider>();
      final auth = context.read<AuthProvider>();

      final int amount = (widget.subscription.amount ?? 0).round();
      if (amount <= 0) {
        return _setFailed('Invalid subscription amount.');
      }

      final phone =
          widget.subscription.metadata?['phone'] ?? auth.user?.phoneNumber;
      if (phone == null || phone.toString().trim().isEmpty) {
        return _setFailed('Phone number is required to make payment.');
      }

      final result = await provider.startZenopayCheckout(
        subscriptionId: widget.subscription.id,
        amount: amount,
        phone: phone.toString(),
      );

      if (!mounted) return;

      final ok = result != null && result['success'] == true;
      final orderId = result?['order_id']?.toString();

      if (!ok || orderId == null || orderId.isEmpty) {
        return _setFailed(
            result?['message']?.toString() ?? 'Failed to initiate payment.');
      }

      setState(() {
        _orderId = orderId;
        _state = _PayState.waiting;
      });

      _startClock();
      _startPolling();
    } catch (e, st) {
      Log.e('ZenoPay checkout error', e, st);
      _setFailed('Unable to start payment. Check your connection.');
    }
  }

  // ─────────────────────────────────────────────────────────
  // CLOCK (elapsed timer shown to user)
  // ─────────────────────────────────────────────────────────
  void _startClock() {
    _elapsedSeconds = 0;
    _clockTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _elapsedSeconds++);
    });
  }

  // ─────────────────────────────────────────────────────────
  // POLLING
  // ─────────────────────────────────────────────────────────
  void _startPolling() {
    _stopPolling();
    _pollingAttempts = 0;

    _pollingTimer = Timer.periodic(_pollInterval, (_) async {
      if (!mounted) { _stopPolling(); return; }
      _pollingAttempts++;

      // Check subscription status first
      final done = await _checkSubscriptionStatus();
      if (done) return;

      // Fallback: hit Zenopay directly at 30s, 60s, 90s (faster than before)
      if (_pollingAttempts == 6 || _pollingAttempts == 12 || _pollingAttempts == 18) {
        await _fallbackCheckZenopayStatus();
      }

      // Timeout after 3 minutes
      if (_pollingAttempts >= _maxAttempts) {
        _stopPolling();
        if (mounted) setState(() => _state = _PayState.timedOut);
      }
    });
  }

  void _stopPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
    _clockTimer?.cancel();
    _clockTimer = null;
  }

  Future<bool> _checkSubscriptionStatus() async {
    if (!mounted) return true;
    setState(() => _state = _PayState.checking);

    final provider = context.read<SubscriptionProvider>();
    final result = await provider.checkSubscriptionStatus(widget.subscription.id);

    if (!mounted) return true;

    if (result == null) {
      // Network blip — stay waiting
      if (mounted) setState(() => _state = _PayState.waiting);
      return false;
    }

    Log.i('📡 Status poll result: ${result.status}');

    if (result.status == 'active') {
      _stopPolling();
      setState(() => _state = _PayState.success);
      await Future.delayed(const Duration(milliseconds: 600));
      _showSuccessDialog();
      return true;
    }

    if (result.status == 'failed' || result.status == 'cancelled') {
      _stopPolling();
      _setFailed(_resolveFailReason(result));
      return true;
    }

    // Still pending — go back to waiting state
    if (mounted) setState(() => _state = _PayState.waiting);
    return false;
  }

  Future<void> _fallbackCheckZenopayStatus() async {
    final orderId = _orderId;
    if (orderId == null || !mounted) return;

    Log.i('🧾 Fallback Zenopay check for $orderId');
    final provider = context.read<SubscriptionProvider>();
    final res = await provider.checkZenopayOrderStatus(orderId);
    if (!mounted || res == null) return;

    final payStatus = (res['payment_status'] ?? '').toString().toUpperCase();
    Log.i('🧾 Fallback Zenopay payment_status: $payStatus');

    const failStatuses = ['FAILED', 'CANCELLED', 'REJECTED', 'DECLINED',
                          'EXPIRED', 'TIMEOUT', 'INSUFFICIENT_FUNDS'];

    if (failStatuses.contains(payStatus)) {
      _stopPolling();
      _setFailed(_zenopayStatusToMessage(payStatus));
    }
  }

  // ─────────────────────────────────────────────────────────
  // HELPERS
  // ─────────────────────────────────────────────────────────
  void _setFailed(String reason) {
    if (!mounted) return;
    _stopPolling();
    setState(() {
      _failReason = reason;
      _state = _PayState.failed;
    });
  }

  String _resolveFailReason(dynamic result) {
    // Try to extract a meaningful message from the status result
    final msg = result?.message?.toString() ?? '';
    if (msg.isNotEmpty) return msg;
    return 'Payment was declined. Please check your balance and try again.';
  }

  String _zenopayStatusToMessage(String status) {
    switch (status) {
      case 'INSUFFICIENT_FUNDS':
        return 'Insufficient balance. Please top up your mobile wallet and try again.';
      case 'CANCELLED':
        return 'Payment was cancelled. You can try again.';
      case 'REJECTED':
      case 'DECLINED':
        return 'Payment was declined by your network. Please try again.';
      case 'EXPIRED':
      case 'TIMEOUT':
        return 'Payment request expired. Please try again.';
      default:
        return 'Payment failed ($status). Please try again.';
    }
  }

  String _formatElapsed() {
    final m = _elapsedSeconds ~/ 60;
    final s = _elapsedSeconds % 60;
    if (m > 0) return '${m}m ${s.toString().padLeft(2, '0')}s';
    return '${s}s';
  }

  // ─────────────────────────────────────────────────────────
  // SUCCESS DIALOG
  // ─────────────────────────────────────────────────────────
  void _showSuccessDialog() {
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 64),
            SizedBox(height: 16),
            Text(
              'Payment Successful!',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8),
            Text(
              'Your subscription is now active.\nWelcome aboard!',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
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
                    borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                Navigator.of(context).pop(); // close dialog
                Navigator.of(context).pop(true); // return success to caller
              },
              child: Text(AppLocalizations.of(context)!.continueText),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────
  // BUILD
  // ─────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.processingPayment),
        backgroundColor: theme.primaryColor,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
        elevation: 0,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: _buildBody(theme),
          ),
        ),
      ),
    );
  }

  Widget _buildBody(ThemeData theme) {
    switch (_state) {
      case _PayState.starting:
        return _buildStarting(theme);
      case _PayState.waiting:
      case _PayState.checking:
        return _buildWaiting(theme);
      case _PayState.success:
        return _buildSuccess(theme);
      case _PayState.failed:
        return _buildFailed(theme);
      case _PayState.timedOut:
        return _buildTimedOut(theme);
    }
  }

  // ── Starting ──────────────────────────────────────────────
  Widget _buildStarting(ThemeData theme) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircularProgressIndicator(color: theme.primaryColor),
        const SizedBox(height: 24),
        const Text(
          'Initiating payment...',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      ],
    );
  }

  // ── Waiting / Checking ────────────────────────────────────
  Widget _buildWaiting(ThemeData theme) {
    final isChecking = _state == _PayState.checking;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Pulsing icon
        ScaleTransition(
          scale: _pulseAnimation,
          child: Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: theme.primaryColor.withValues(alpha: 0.1),
            ),
            child: Icon(
              Icons.phone_android,
              size: 50,
              color: theme.primaryColor,
            ),
          ),
        ),
        const SizedBox(height: 28),

        Text(
          isChecking ? 'Checking payment status...' : 'Waiting for payment approval',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'A push notification was sent to your phone.\nApprove it to complete your subscription.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey[600], height: 1.5),
        ),
        const SizedBox(height: 20),

        // Order ID
        if (_orderId != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.receipt_outlined, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    'Order: $_orderId',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
              ],
            ),
          ),

        const SizedBox(height: 8),
        // Elapsed time
        Text(
          'Waiting: ${_formatElapsed()}',
          style: TextStyle(fontSize: 12, color: Colors.grey[500]),
        ),

        const SizedBox(height: 32),

        // Tip card
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.amber.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.amber.withValues(alpha: 0.3)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.lightbulb_outline, color: Colors.amber, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Make sure your mobile wallet has enough balance before approving. '
                  'If the request does not appear, tap "Check status now".',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[700],
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // Check Now button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: isChecking
                ? null
                : () async {
                    final done = await _checkSubscriptionStatus();
                    if (!mounted) return;
                    if (!done && _state == _PayState.waiting) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(AppLocalizations.of(context)!.stillPendingPleaseApproveOnYour),
                          duration: const Duration(seconds: 3),
                        ),
                      );
                    }
                  },
            icon: isChecking
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white),
                  )
                : const Icon(Icons.refresh),
            label: Text(isChecking ? 'Checking...' : 'Check status now'),
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

        // Cancel button
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => _confirmCancel(),
            icon: const Icon(Icons.close, size: 18),
            label: Text(AppLocalizations.of(context)!.cancelPaymentAltAlt),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red,
              side: const BorderSide(color: Colors.red),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
      ],
    );
  }

  // ── Success ───────────────────────────────────────────────
  Widget _buildSuccess(ThemeData theme) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.check_circle, color: Colors.green, size: 80),
        const SizedBox(height: 16),
        const Text('Payment Confirmed!',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Text('Your subscription is now active.',
            style: TextStyle(color: Colors.grey[600])),
      ],
    );
  }

  // ── Failed ────────────────────────────────────────────────
  Widget _buildFailed(ThemeData theme) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 90,
          height: 90,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.red.withValues(alpha: 0.1),
          ),
          child: const Icon(Icons.error_outline, color: Colors.red, size: 50),
        ),
        const SizedBox(height: 24),

        const Text(
          'Payment Failed',
          style: TextStyle(
              fontSize: 22, fontWeight: FontWeight.bold, color: Colors.red),
        ),
        const SizedBox(height: 12),

        // Reason card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.red.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.red.withValues(alpha: 0.2)),
          ),
          child: Text(
            _failReason,
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 15, color: Colors.red[700], height: 1.5),
          ),
        ),

        const SizedBox(height: 28),

        // Try Again
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => _startCheckout(),
            icon: const Icon(Icons.refresh),
            label: Text(AppLocalizations.of(context)!.tryAgain),
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

        // Go Back
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () => Navigator.of(context).pop(false),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(AppLocalizations.of(context)!.goBack),
          ),
        ),
      ],
    );
  }

  // ── Timed Out ─────────────────────────────────────────────
  Widget _buildTimedOut(ThemeData theme) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 90,
          height: 90,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.orange.withValues(alpha: 0.1),
          ),
          child:
              const Icon(Icons.hourglass_empty, color: Colors.orange, size: 50),
        ),
        const SizedBox(height: 24),

        const Text(
          'Request Timed Out',
          style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.orange),
        ),
        const SizedBox(height: 12),

        Text(
          'We did not receive a payment confirmation after 3 minutes.\n\n'
          'If you approved the payment on your phone, tap "Check Status" below. '
          'Otherwise tap "Try Again" to send a new payment request.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey[600], height: 1.5),
        ),

        const SizedBox(height: 28),

        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () async {
              setState(() => _state = _PayState.checking);
              await _checkSubscriptionStatus();
            },
            icon: const Icon(Icons.search),
            label: Text(AppLocalizations.of(context)!.checkStatus),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
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
          child: ElevatedButton.icon(
            onPressed: () => _startCheckout(),
            icon: const Icon(Icons.refresh),
            label: Text(AppLocalizations.of(context)!.tryAgain),
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
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(AppLocalizations.of(context)!.goBack),
          ),
        ),
      ],
    );
  }

  // ── Cancel confirmation ───────────────────────────────────
  Future<void> _confirmCancel() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.cancelPaymentAlt),
        content: const Text(
            'This will cancel the current payment request. '
            'You can try again later.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(AppLocalizations.of(context)!.keepWaiting)),
          TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              onPressed: () => Navigator.pop(context, true),
              child: Text(AppLocalizations.of(context)!.cancelPayment)),
        ],
      ),
    );

    if (confirm == true && mounted) {
      _stopPolling();
      // Cancel on backend so user can retry fresh
      final provider = context.read<SubscriptionProvider>();
      await provider.cancelPendingSubscription(widget.subscription.id);
      if (mounted) Navigator.of(context).pop(false);
    }
  }
}
