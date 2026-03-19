import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import './provider_dashboard_screen.dart';
import './add_service_screen.dart';
import './edit_service_screen.dart';
import '../../models/service.dart';
import '../../services/service_service.dart';

/// A utility class that provides a central way to manage service provider functionality
/// across the application.
class ProviderManager {
  /// Checks if a user is a service provider
  static bool isServiceProvider(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.user;
    return user != null && user.roles.contains('service_provider');
  }

  /// Opens the provider dashboard screen
  static void openProviderDashboard(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ProviderDashboardScreen()),
    );
  }

  /// Opens the add service screen
  static void openAddServiceScreen(
      BuildContext context, Function(Service) onServiceAdded) {
    final serviceService = ServiceService();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.token != null) {
      serviceService.setAuthToken(authProvider.token!);
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddServiceScreen(
          onServiceAdded: onServiceAdded,
          serviceService: serviceService,
        ),
      ),
    );
  }

  /// Opens the edit service screen
  static void openEditServiceScreen(BuildContext context, Service service,
      Function(Service) onServiceUpdated) {
    final serviceService = ServiceService();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.token != null) {
      serviceService.setAuthToken(authProvider.token!);
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditServiceScreen(
          service: service,
          onServiceUpdated: onServiceUpdated,
          serviceService: serviceService,
        ),
      ),
    );
  }

  /// Updates routes in main app with provider-related routes
  static Map<String, WidgetBuilder> getProviderRoutes() {
    return {
      '/provider/dashboard': (context) => const ProviderDashboardScreen(),
    };
  }
}
