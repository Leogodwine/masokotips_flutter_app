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

class _ZenoPayProcessingScreenState extends State<ZenopayProcessingScreen>
    with TickerProviderStateMixin {
  Timer? _pollTimer;
  Timer? _timeoutTimer;

  late AnimationController _pulseController;
  late AnimationController _slideController;
  late Animation<double> _pulseAnimation;
  late Animation<Offset> _slideAnimation;

  bool _isDone = false;
  bool? _success;

  String _message =
      'Payment request sent. Please check your phone and approve the payment.';

  @override
  void initState() {
    super.initState();

    // Pulse animation for loading state
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Slide animation for content
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _slideController.forward();

    _startPolling();
    _startTimeout();
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    _timeoutTimer?.cancel();
    _pulseController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  void _startPolling() {
    _pollTimer?.cancel();
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

      if (subStatus == 'completed' || isCompleted || txStatus == 'completed') {
        _finish(
          success: true,
          reason: 'completed',
          message: '🎉 Payment confirmed! Activating your subscription…',
        );
        return;
      }

      if (subStatus == 'failed' || txStatus == 'failed') {
        _finish(
          success: false,
          reason: 'failed',
          message: '❌ Payment failed or was rejected. Please try again.',
        );
        return;
      }

      if (txStatus == 'processing') {
        _setUiMessage('⏳ Payment processing… please wait.');
      } else {
        _setUiMessage('📱 Waiting for approval… please check your phone.');
      }
    } catch (_) {
      _setUiMessage('🔄 Network issue… retrying.');
    } finally {
      if (mounted && !_isDone) {
        // Loading complete - state managed by _success and _message
      }
    }
  }

  void _setUiMessage(String msg) {
    if (!mounted || _isDone) return;
    if (_message == msg) return;
    setState(() {
      _message = msg;
    });
  }

  void _finish({
    required bool success,
    required String reason,
    required String message,
  }) {
    if (_isDone) return;
    _isDone = true;
    _success = success;

    _pollTimer?.cancel();
    _timeoutTimer?.cancel();

    if (!mounted) return;

    // Stop pulse animation
    _pulseController.stop();

    setState(() {
      _message = message;
    });

    // Delay navigation to show success/failure animation
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        Navigator.of(context).pop({
          'success': success,
          'reason': reason,
          'externalId': widget.externalId,
          'message': message,
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: _getGradientColors(),
          ),
        ),
        child: SafeArea(
          child: SlideTransition(
            position: _slideAnimation,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const SizedBox(height: 60),
                  _buildStatusIcon(),
                  const SizedBox(height: 32),
                  _buildTitle(),
                  const SizedBox(height: 16),
                  _buildMessage(),
                  const SizedBox(height: 40),
                  _buildProgressIndicator(),
                  const Spacer(),
                  _buildReference(),
                  const SizedBox(height: 24),
                  _buildCancelButton(),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Color> _getGradientColors() {
    if (_success == null) {
      // Processing - Blue gradient
      return [
        const Color(0xFF667eea),
        const Color(0xFF764ba2),
      ];
    } else if (_success == true) {
      // Success - Green gradient
      return [
        const Color(0xFF11998e),
        const Color(0xFF38ef7d),
      ];
    } else {
      // Failed - Red gradient
      return [
        const Color(0xFFeb3349),
        const Color(0xFFf45c43),
      ];
    }
  }

  Widget _buildStatusIcon() {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        final scale = _success == null ? _pulseAnimation.value : 1.0;
        return Transform.scale(
          scale: scale,
          child: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(51), // 20% opacity (51 out of 255)
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color:
                      Colors.black.withAlpha(26), // 10% opacity (26 out of 255)
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Icon(
              _getStatusIcon(),
              size: 60,
              color: Colors.white,
            ),
          ),
        );
      },
    );
  }

  IconData _getStatusIcon() {
    if (_success == null) {
      return Icons.smartphone_outlined;
    } else if (_success == true) {
      return Icons.check_circle_outline;
    } else {
      return Icons.error_outline;
    }
  }

  Widget _buildTitle() {
    String title;
    if (_success == null) {
      title = 'Processing Payment';
    } else if (_success == true) {
      title = 'Payment Successful!';
    } else {
      title = 'Payment Failed';
    }

    return Text(
      title,
      style: const TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: Colors.white,
        letterSpacing: -0.5,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildMessage() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(38), // 15% opacity (38 out of 255)
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        _message,
        style: TextStyle(
          fontSize: 16,
          color: Colors.white.withAlpha(243), // 95% opacity (243 out of 255)
          height: 1.5,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildProgressIndicator() {
    if (_success != null) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(3, (index) {
            return AnimatedBuilder(
              animation: _pulseController,
              builder: (context, child) {
                final delay = index * 0.2;
                final value = (_pulseController.value + delay) % 1.0;
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.3 + (value * 0.7)),
                  ),
                );
              },
            );
          }),
        ),
        const SizedBox(height: 16),
        Text(
          'Please wait...',
          style: TextStyle(
            fontSize: 14,
            color: Colors.white.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildReference() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 18,
            color: Colors.white.withValues(alpha: 0.8),
          ),
          const SizedBox(width: 8),
          Text(
            'Reference: ${widget.externalId}',
            style: TextStyle(
              fontSize: 13,
              color: Colors.white.withValues(alpha: 0.9),
              fontWeight: FontWeight.w500,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCancelButton() {
    if (_success != null) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () {
          _finish(
            success: false,
            reason: 'user_cancelled',
            message: 'You cancelled the payment check.',
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white.withValues(alpha: 0.2),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: Colors.white.withValues(alpha: 0.3),
            ),
          ),
          elevation: 0,
        ),
        icon: const Icon(Icons.close),
        label: const Text(
          'Cancel',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
