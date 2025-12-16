// lib/screens/subscription/widgets/subscribe_bottom_bar.dart
import 'package:flutter/material.dart';
import '../../../models/subscription.dart';

class SubscribeBottomBar extends StatelessWidget {
  final bool isLoading;
  final SubscriptionPackage? selectedPackage;
  final String displayPrice;
  final VoidCallback? onPressed;

  const SubscribeBottomBar({
    super.key,
    required this.isLoading,
    required this.selectedPackage,
    required this.displayPrice,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final enabled = !isLoading && selectedPackage != null && onPressed != null;

    return SafeArea(
      child: Container(
        padding: const EdgeInsets.all(16),
        color: Colors.white,
        child: ElevatedButton(
          onPressed: enabled ? onPressed : null,
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 56),
            backgroundColor: Theme.of(context).primaryColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: isLoading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: Colors.white,
                  ),
                )
              : Text(
                  selectedPackage == null
                      ? 'Select a plan'
                      : 'Subscribe — $displayPrice',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
        ),
      ),
    );
  }
}
