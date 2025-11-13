import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import './seller_dashboard_screen.dart';
import './add_product_screen.dart';
import './edit_product_screen.dart';
import '../../models/product.dart';
import '../../services/product_service.dart';

/// A utility class that provides a central way to manage seller functionality
/// across the application.
class SellerManager {
  /// Checks if a user is a seller
  static bool isSeller(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.user;
    return user != null && user.roles.contains('seller');
  }

  /// Opens the seller dashboard screen
  static void openSellerDashboard(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SellerDashboardScreen()),
    );
  }

  /// Opens the add product screen
  static void openAddProductScreen(
      BuildContext context, Function(Product) onProductAdded) {
    final productService = ProductService();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.token != null) {
      productService.setAuthToken(authProvider.token!);
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddProductScreen(
          onProductAdded: onProductAdded,
          productService: productService,
        ),
      ),
    );
  }

  /// Opens the edit product screen
  static void openEditProductScreen(BuildContext context, Product product,
      Function(Product) onProductUpdated) {
    final productService = ProductService();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.token != null) {
      productService.setAuthToken(authProvider.token!);
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditProductScreen(
          product: product,
          onProductUpdated: onProductUpdated,
          productService: productService,
        ),
      ),
    );
  }

  /// Updates routes in main app with seller-related routes
  static Map<String, WidgetBuilder> getSellerRoutes() {
    return {
      '/seller/dashboard': (context) => const SellerDashboardScreen(),
    };
  }
}
