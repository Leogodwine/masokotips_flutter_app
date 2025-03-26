import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/category_provider.dart';
import '../config/api_config.dart';

class CategoryErrorHandler extends StatelessWidget {
  final String? error;
  final VoidCallback? onRetry;
  final Widget child;

  const CategoryErrorHandler({
    Key? key,
    this.error,
    this.onRetry,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // If there's no error, show the child
    if (error == null) {
      return child;
    }

    // Otherwise show error with retry and mock data options
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.category_outlined,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Failed to load categories',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              error!,
              style: TextStyle(color: Colors.red[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                  onPressed: onRetry,
                ),
                const SizedBox(width: 16),
                OutlinedButton.icon(
                  icon: const Icon(Icons.local_mall),
                  label: const Text('Use Sample Data'),
                  onPressed: () {
                    // Enable mock mode
                    ApiConfig.useMockData = true;

                    // Use mock categories
                    final categoryProvider =
                        Provider.of<CategoryProvider>(context, listen: false);
                    categoryProvider.useMockData();

                    // Show feedback to user
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Using sample category data'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
