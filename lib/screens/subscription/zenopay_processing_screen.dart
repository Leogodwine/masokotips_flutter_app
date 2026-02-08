import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ZenopayProcessingScreen extends StatefulWidget {
  final String baseUrl; // e.g. https://yourdomain.com
  final String token; // Sanctum token (Bearer)
  final String externalId; // returned by initiate
  final Duration pollInterval; // default 4s
  final Duration timeout; // default 90s

  const ZenopayProcessingScreen({
    super.key,
    required this.baseUrl,
    required this.token,
    required this.externalId,
    this.pollInterval = const Duration(seconds: 4),
    this.timeout = const Duration(seconds: 90),
  });

  @override
  State<ZenopayProcessingScreen> createState() =>
      _ZenoPayProcessingScreenState();
}

class _ZenoPayProcessingScreenState extends State<ZenopayProcessingScreen> {
  Timer? _pollTimer;
  Timer? _timeoutTimer;

  bool _isDone = false;
  bool _isLoading = true;

  String _message =
      'Payment request sent. Please check your phone and approve the payment.';

  @override
  void initState() {
    super.initState();
    _startPolling();
    _startTimeout();
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    _timeoutTimer?.cancel();
    super.dispose();
  }

  void _startPolling() {
    // Safety: cancel existing timer if any
    _pollTimer?.cancel();

    // Do an immediate check first (no waiting for interval)
    _checkStatusOnce();

    _pollTimer = Timer.periodic(widget.pollInterval, (_) {
      _checkStatusOnce();
    });
  }

  void _startTimeout() {
    _timeoutTimer?.cancel();
    _timeoutTimer = Timer(widget.timeout, () {
      if (_isDone) return;
      _finish(
        success: false,
        reason: 'timeout',
        message:
            'Still waiting for confirmation. If you approved, your subscription will activate automatically shortly.',
      );
    });
  }

  Future<void> _checkStatusOnce() async {
    if (_isDone) return;

    final uri =
        Uri.parse('${widget.baseUrl}/api/zenopay/status/${widget.externalId}');

    try {
      final resp = await http.get(
        uri,
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer ${widget.token}',
        },
      );

      if (resp.statusCode == 404) {
        // Transaction not found; keep polling briefly (can happen if timing issues)
        _setUiMessage('Preparing payment session…');
        return;
      }

      if (resp.statusCode < 200 || resp.statusCode >= 300) {
        _setUiMessage('Checking payment status…');
        return;
      }

      final data = jsonDecode(resp.body) as Map<String, dynamic>;

      final txStatus =
          (data['transaction_status'] ?? '').toString().toLowerCase();
      final subStatus =
          (data['subscription_status'] ?? '').toString().toLowerCase();
      final isCompleted = (data['isCompleted'] == true);

      // Success rule: subscription completed OR transaction completed
      if (subStatus == 'completed' || isCompleted || txStatus == 'completed') {
        _finish(
          success: true,
          reason: 'completed',
          message: 'Payment confirmed. Activating your subscription…',
        );
        return;
      }

      // Failure rule
      if (subStatus == 'failed' || txStatus == 'failed') {
        _finish(
          success: false,
          reason: 'failed',
          message: 'Payment failed or was rejected. Please try again.',
        );
        return;
      }

      // Still pending/processing
      if (txStatus == 'processing') {
        _setUiMessage('Payment processing… please wait.');
      } else {
        _setUiMessage('Waiting for approval… please check your phone.');
      }
    } catch (_) {
      // Network hiccup: keep polling, but update UI
      _setUiMessage('Network issue… retrying.');
    } finally {
      if (mounted && !_isDone) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _setUiMessage(String msg) {
    if (!mounted || _isDone) return;
    if (_message == msg) return;
    setState(() {
      _message = msg;
      _isLoading = false;
    });
  }

  void _finish({
    required bool success,
    required String reason,
    required String message,
  }) {
    if (_isDone) return;
    _isDone = true;

    _pollTimer?.cancel();
    _timeoutTimer?.cancel();

    if (!mounted) return;

    // Return a result object to caller
    Navigator.of(context).pop({
      'success': success,
      'reason': reason,
      'externalId': widget.externalId,
      'message': message,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Processing Payment')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 24),
            if (_isLoading) const CircularProgressIndicator(),
            const SizedBox(height: 24),
            Text(
              _message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 8),
            Text(
              'Reference: ${widget.externalId}',
              style: const TextStyle(fontSize: 12),
            ),
            const Spacer(),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      _finish(
                        success: false,
                        reason: 'user_cancelled',
                        message: 'You cancelled the payment check.',
                      );
                    },
                    child: const Text('Cancel'),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
