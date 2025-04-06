import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import './service_provider_dashboard_screen.dart';
import './edit_service_screen.dart';
import '../../models/service.dart';
import '../../services/service_service.dart';
import '../agriculture/add_agricultural_service_screen.dart';
import '../../services/agriculture_service.dart';

/// A utility class that provides a central way to manage service provider functionality
/// across the application.
class ServiceProviderManager {
  /// Checks if a user is a service provider
  static bool isServiceProvider(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.user;
    return user != null && user.roles.contains('service_provider');
  }

  /// Opens the service provider dashboard screen
  static void openServiceProviderDashboard(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => const ServiceProviderDashboardScreen()),
    );
  }

  /// Opens the add agricultural service screen
  static void openAddAgriculturalServiceScreen(
      BuildContext context, Function(Service) onServiceAdded) {
    final agricultureService = AgricultureService();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    // Check if user is authenticated
    if (!authProvider.isAuthenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please login to add agricultural services'),
          duration: Duration(seconds: 2),
        ),
      );
      // Navigate to login screen
      Navigator.pushNamed(context, '/login');
      return;
    }

    // Set the auth token for the agriculture service
    agricultureService.setAuthToken(authProvider.token!);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddAgriculturalServiceScreen(
          onServiceAdded: onServiceAdded,
          agricultureService: agricultureService,
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

  /// Deletes a service
  static Future<void> deleteService(
      BuildContext context, Service service) async {
    final serviceService = ServiceService();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.token != null) {
      serviceService.setAuthToken(authProvider.token!);
    }

    try {
      await serviceService.deleteService(service.id.toString());
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Service deleted successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete service: $e')),
      );
    }
  }

  /// Updates routes in main app with service provider-related routes
  static Map<String, WidgetBuilder> getServiceProviderRoutes() {
    return {
      '/provider/dashboard': (context) =>
          const ServiceProviderDashboardScreen(),
      '/provider/add-agricultural-service': (context) {
        final agricultureService = AgricultureService();
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        if (authProvider.token != null) {
          agricultureService.setAuthToken(authProvider.token!);
        }

        return AddAgriculturalServiceScreen(
          onServiceAdded: (service) {
            // Handle service added
            Navigator.pop(context);
          },
          agricultureService: agricultureService,
        );
      },
    };
  }

  static Future<void> showAddAgriculturalServiceDialog(
    BuildContext context,
    Function(Service) onServiceAdded,
  ) async {
    final agricultureService = AgricultureService();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.token != null) {
      agricultureService.setAuthToken(authProvider.token!);
    }

    await showDialog(
      context: context,
      builder: (context) => AddAgriculturalServiceScreen(
        onServiceAdded: onServiceAdded,
        agricultureService: agricultureService,
      ),
    );
  }

  static Future<void> showAddAgriculturalServiceScreen(
    BuildContext context,
    Function(Service) onServiceAdded,
  ) async {
    final agricultureService = AgricultureService();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.token != null) {
      agricultureService.setAuthToken(authProvider.token!);
    }

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddAgriculturalServiceScreen(
          onServiceAdded: onServiceAdded,
          agricultureService: agricultureService,
        ),
      ),
    );
  }
}
