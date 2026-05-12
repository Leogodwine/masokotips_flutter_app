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
    return Container(
      padding: padding,
      child: Image.asset(
        imagePath,
        height: height,
        fit: BoxFit.contain,
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
