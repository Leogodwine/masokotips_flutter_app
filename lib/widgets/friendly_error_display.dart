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
    if (error == null) return 'An unknown error occurred.';

    final errorLower = error!.toLowerCase();

    // Network errors
    if (errorLower.contains('socketexception') ||
        errorLower.contains('connection') ||
        errorLower.contains('network') ||
        errorLower.contains('clientexception') ||
        errorLower.contains('failed to fetch')) {
      return 'No internet connection. Please check your network and try again.';
    }

    // HTTP status codes
    if (errorLower.contains('404') || errorLower.contains('not found')) {
      return 'The requested information could not be found. It may have been moved or deleted.';
    }
    if (errorLower.contains('500') ||
        errorLower.contains('internal server error')) {
      return 'Our servers are experiencing issues. Please try again in a few minutes.';
    }
    if (errorLower.contains('403') ||
        errorLower.contains('forbidden') ||
        errorLower.contains('unauthorized')) {
      return 'You do not have permission to access this content. Please log in again.';
    }
    if (errorLower.contains('timeout')) {
      return 'The request took too long. Please check your connection and try again.';
    }

    // API specific errors
    if (errorLower.contains('text/html')) {
      return 'The server responded with an unexpected format. Please contact support if this persists.';
    }
    if (errorLower.contains('json') || errorLower.contains('parsing')) {
      return 'There was an issue processing the data. Please try again.';
    }

    // Generic fallback
    return 'Something went wrong while loading the content. Please try again.';
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
