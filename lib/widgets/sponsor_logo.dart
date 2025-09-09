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
    this.height = 40,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Image.asset(
        imagePath,
        height: height,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
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
