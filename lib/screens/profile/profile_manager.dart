import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import './profile_screen.dart';
import './edit_profile_screen.dart';
import './security_settings_screen.dart';
import './address_management_screen.dart';
import 'package:masoko_tips/l10n/app_localizations.dart';

/// A utility class that provides a central way to manage user profile
/// functionality across the application.
class ProfileManager {
  /// Opens the profile screen
  static void openProfile(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ProfileScreen()),
    );
  }

  /// Opens the edit profile screen
  static void openEditProfile(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const EditProfileScreen()),
    );
  }

  /// Opens the security settings screen
  static void openSecuritySettings(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SecuritySettingsScreen()),
    );
  }

  /// Opens the address management screen
  static void openAddressManagement(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddressManagementScreen()),
    );
  }

  /// Shows a logout confirmation dialog
  static void showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.logout),
        content: Text(AppLocalizations.of(context)!.areYouSureYouWantToAltAltAlt),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(AppLocalizations.of(context)!.cancelAlt),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Provider.of<AuthProvider>(context, listen: false).logout();
            },
            child: Text(AppLocalizations.of(context)!.logoutAlt),
          ),
        ],
      ),
    );
  }

  /// Updates routes in main app with profile-related routes
  static Map<String, WidgetBuilder> getProfileRoutes() {
    return {
      '/profile': (context) => const ProfileScreen(),
      '/profile/edit': (context) => const EditProfileScreen(),
      '/profile/addresses': (context) => const AddressManagementScreen(),
      '/profile/security': (context) => const SecuritySettingsScreen(),
    };
  }
}
