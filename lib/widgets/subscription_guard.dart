import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/subscription_provider.dart';
import '../providers/auth_provider.dart';
import '../screens/subscription/subscription_screen.dart';
import '../widgets/loading_indicator.dart';

class SubscriptionGuard extends StatelessWidget {
  final Widget child;
  final String? requiredRole;
  final bool showLoader;

  const SubscriptionGuard({
    super.key,
    required this.child,
    this.requiredRole,
    this.showLoader = true,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer2<AuthProvider, SubscriptionProvider>(
      builder: (context, authProvider, subscriptionProvider, child) {
        // Show loading while checking subscription status
        if (subscriptionProvider.isLoading) {
          return showLoader
              ? const LoadingIndicator()
              : const SizedBox.shrink();
        }

        // If user is not authenticated, don't show subscription guard
        if (!authProvider.isAuthenticated || authProvider.user == null) {
          return this.child;
        }

        final user = authProvider.user!;
        final userRole =
            requiredRole ?? user.primaryRole ?? 'registered_user';

        // Check if user needs subscription
        final needsSubscription =
            subscriptionProvider.needsSubscription(userRole);

        if (needsSubscription) {
          // Show subscription required dialog or navigate to subscription screen
          _showSubscriptionRequiredDialog(
            context,
            userRole,
            subscriptionProvider,
          );
          return const SizedBox.shrink();
        }

        return this.child;
      },
    );
  }

  void _showSubscriptionRequiredDialog(
    BuildContext context,
    String userRole,
    SubscriptionProvider subscriptionProvider,
  ) {
    // Only show dialog once
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (Navigator.of(context).canPop()) {
        // If we can pop, we're likely in a navigation stack, so don't show dialog
        return;
      }

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Subscription Required'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.lock,
                  size: 64,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(height: 16),
                Text(
                  'Complete Your Subscription',
                  style: Theme.of(context).textTheme.titleLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'To access all features of the app, you need to complete your subscription. Choose a membership type that best fits your needs.',
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SubscriptionScreen(
                        preSelectedType:
                            userRole == 'registered_user' ? null : userRole,
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Subscribe Now'),
              ),
            ],
          );
        },
      );
    });
  }
}

// Helper widget that automatically handles subscription checks
class SubscriptionRequired extends StatelessWidget {
  final Widget child;
  final String? requiredRole;
  final Widget? loadingWidget;
  final Widget? placeholderWidget;

  const SubscriptionRequired({
    super.key,
    required this.child,
    this.requiredRole,
    this.loadingWidget,
    this.placeholderWidget,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer2<AuthProvider, SubscriptionProvider>(
      builder: (context, authProvider, subscriptionProvider, child) {
        // Show loading while checking subscription status
        if (subscriptionProvider.isLoading) {
          return loadingWidget ?? const LoadingIndicator();
        }

        // If user is not authenticated, show placeholder
        if (!authProvider.isAuthenticated || authProvider.user == null) {
          return placeholderWidget ??
              _buildPlaceholder(context, 'Please log in to continue');
        }

        final user = authProvider.user!;
        final userRole =
            requiredRole ?? user.primaryRole ?? 'registered_user';

        // Check if user needs subscription
        final needsSubscription =
            subscriptionProvider.needsSubscription(userRole);

        if (needsSubscription) {
          return placeholderWidget ??
              _buildSubscriptionPlaceholder(context, userRole);
        }

        return child ?? const SizedBox.shrink();
      },
    );
  }

  Widget _buildPlaceholder(BuildContext context, String message) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.info_outline,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.grey.shade600,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSubscriptionPlaceholder(BuildContext context, String userRole) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.lock,
            size: 64,
            color: Theme.of(context).primaryColor,
          ),
          const SizedBox(height: 16),
          Text(
            'Subscription Required',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.bold,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Complete your subscription to access this feature.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey.shade600,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => SubscriptionScreen(
                    preSelectedType:
                        userRole == 'registered_user' ? null : userRole,
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
            ),
            child: const Text('Subscribe Now'),
          ),
        ],
      ),
    );
  }
}
