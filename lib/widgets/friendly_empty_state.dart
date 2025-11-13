import 'package:flutter/material.dart';

class FriendlyEmptyState extends StatelessWidget {
  final String message;
  final IconData icon;
  final String buttonText;
  final VoidCallback onRetry;

  const FriendlyEmptyState({
    super.key,
    required this.message,
    required this.icon,
    required this.onRetry,
    this.buttonText = 'Retry',
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              message,
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: Text(buttonText),
            ),
          ],
        ),
      ),
    );
  }
}
