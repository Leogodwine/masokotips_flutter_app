// sponsor_logo.dart
import 'package:flutter/material.dart';

class SponsorLogo extends StatelessWidget {
  final String imagePath;
  final String fallbackText;
  final double height;
  final EdgeInsets padding;

  const SponsorLogo({
    super.key,
    required this.imagePath,
    required this.fallbackText,
    this.height = 80,
    this.padding = const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
  });

  @override
  Widget build(BuildContext context) {
    debugPrint('SponsorLogo: Building logo with path: $imagePath');
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.transparent,
        // ✅ Removed borderRadius completely - no rounded corners
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.4),
          width: 1.5,
        ),
      ),
      child: Image.asset(
        imagePath,
        height: height,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          debugPrint('SponsorLogo: Error loading image: $error');
          return Text(
            fallbackText,
            style: TextStyle(
              fontSize: height * 0.4,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          );
        },
      ),
    );
  }
}
