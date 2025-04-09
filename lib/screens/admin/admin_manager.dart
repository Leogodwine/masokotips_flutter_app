import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/admin_auth_service.dart';
import './admin_dashboard_screen.dart';
import './market_info_management_screen.dart';
import './user_management_screen.dart';
import './review_moderation_screen.dart';
import './analytics_screen.dart';
import './create_admin_screen.dart';

/// A utility class that provides a central way to manage admin functionality
/// across the application.
class AdminManager {
  static final AdminAuthService _adminAuthService = AdminAuthService();

  /// Checks if a user is an admin and has a valid admin session
  static Future<bool> isAdmin(BuildContext context) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.user;

    // First check if user has admin role
    if (user == null || !user.roles.contains('admin')) {
      return false;
    }

    // Then verify admin session is valid
    return await _adminAuthService.isAdminSessionValid();
  }

  /// Verifies admin credentials and establishes a secure session
  static Future<bool> verifyAdminCredentials(
      String email, String password) async {
    return await _adminAuthService.verifyAdminCredentials(email, password);
  }

  /// Creates a new admin account with additional security measures
  static Future<bool> createAdminAccount(
      String name, String email, String password, String adminKey) async {
    return await _adminAuthService.createAdminAccount(
        name, email, password, adminKey);
  }

  /// Logs out the admin user and clears the admin session
  static Future<void> logoutAdmin() async {
    await _adminAuthService.logoutAdmin();
  }

  /// Opens the admin dashboard screen with security check
  static Future<void> openAdminDashboard(BuildContext context) async {
    final isAdminUser = await isAdmin(context);
    if (!context.mounted) return;
    if (!isAdminUser) {
      _showAccessDeniedDialog(context);
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AdminDashboardScreen()),
    );
  }

  /// Opens the market info management screen with security check
  static Future<void> openMarketInfoManagement(BuildContext context) async {
    final isAdminUser = await isAdmin(context);
    if (!context.mounted) return;
    if (!isAdminUser) {
      _showAccessDeniedDialog(context);
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => const MarketInfoManagementScreen()),
    );
  }

  /// Opens the user management screen with security check
  static Future<void> openUserManagement(BuildContext context) async {
    final isAdminUser = await isAdmin(context);
    if (!context.mounted) return;
    if (!isAdminUser) {
      _showAccessDeniedDialog(context);
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const UserManagementScreen()),
    );
  }

  /// Opens the review moderation screen with security check
  static Future<void> openReviewModeration(BuildContext context) async {
    final isAdminUser = await isAdmin(context);
    if (!context.mounted) return;
    if (!isAdminUser) {
      _showAccessDeniedDialog(context);
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ReviewModerationScreen()),
    );
  }

  /// Opens the analytics screen with security check
  static Future<void> openAnalytics(BuildContext context) async {
    final isAdminUser = await isAdmin(context);
    if (!context.mounted) return;
    if (!isAdminUser) {
      _showAccessDeniedDialog(context);
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AnalyticsScreen()),
    );
  }

  /// Opens the create admin screen with security check
  static Future<void> openCreateAdminScreen(BuildContext context) async {
    final isAdminUser = await isAdmin(context);
    if (!context.mounted) return;
    if (!isAdminUser) {
      _showAccessDeniedDialog(context);
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CreateAdminScreen()),
    );
  }

  /// Shows an access denied dialog
  static void _showAccessDeniedDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Access Denied'),
        content:
            const Text('You do not have permission to access this feature.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
