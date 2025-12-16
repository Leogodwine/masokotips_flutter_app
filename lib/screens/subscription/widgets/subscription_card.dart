import 'package:flutter/material.dart';
import '../../../models/subscription.dart';

class SubscriptionCard extends StatelessWidget {
  final SubscriptionPackage package;
  final bool isSelected;
  final VoidCallback onTap;

  const SubscriptionCard({
    super.key,
    required this.package,
    this.isSelected = false,
    required this.onTap,
  });

  Color _hexToColor(String hex) {
    try {
      hex = hex.replaceAll('#', '');
      if (hex.length == 6) hex = 'FF$hex';
      if (hex.length != 8) {
        // Fallback to default color if hex format is invalid
        return Colors.blue;
      }
      return Color(int.parse(hex, radix: 16));
    } catch (e) {
      // Fallback to default color if parsing fails
      return Colors.blue;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final packageColor = _hexToColor(package.color);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? packageColor.withValues() : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? packageColor : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: packageColor.withValues(),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  )
                ]
              : [],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Package Header
            Row(
              children: [
                Icon(
                  Icons.star, // Replace with your icon logic if needed
                  color: isSelected ? packageColor : packageColor.withValues(),
                  size: 28,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    package.name,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isSelected ? packageColor : Colors.black87,
                    ),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isSelected ? packageColor : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    "${package.price?.toStringAsFixed(0) ?? 'TBA'} ${package.currency}",
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.white : Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Description
            Text(
              package.description,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isSelected ? Colors.grey[800] : Colors.grey[700],
              ),
            ),
            const SizedBox(height: 12),
            // Features
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: package.features.map((f) {
                return Chip(
                  label: Text(f),
                  backgroundColor: isSelected
                      ? packageColor.withValues()
                      : Colors.grey.shade200,
                  labelStyle: TextStyle(
                    color: isSelected ? packageColor : Colors.black87,
                    fontSize: 12,
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
