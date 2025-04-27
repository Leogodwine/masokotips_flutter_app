import 'package:flutter/material.dart';

class FriendlyErrorDisplay extends StatelessWidget {
  final String? error;
  final VoidCallback onRetry;

  const FriendlyErrorDisplay({
    Key? key,
    required this.error,
    required this.onRetry,
  }) : super(key: key);

  String get _friendlyMessage {
    if (error == null) return '';
    if (error!.contains('SocketException')) {
      return 'No internet connection. Please check and try again.';
    }
    if (error!.contains('text/html')) {
      return 'The server responded with an unexpected format.';
    }
    return 'Something went wrong. Please try again.';
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.wifi_off, size: 48, color: Colors.red[300]),
            const SizedBox(height: 16),
            Text(
              _friendlyMessage,
              style: TextStyle(
                color: Colors.red[700],
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
