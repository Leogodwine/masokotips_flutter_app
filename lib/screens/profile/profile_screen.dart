import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../providers/auth_provider.dart';
import 'dart:io';
import 'developer_settings_screen.dart';
import 'edit_profile_screen.dart';
import './address_management_screen.dart';
import '../seller/seller_dashboard_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final isLoggedIn = authProvider.isAuthenticated;
    final user = authProvider.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        actions: [
          if (isLoggedIn)
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () async {
                // Capture context-dependent objects before async operation
                final navigator = Navigator.of(context);
                await authProvider.logout();
                if (mounted) {
                  navigator.pushReplacementNamed('/');
                }
              },
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Divider(),

              // Profile header
              if (isLoggedIn && user != null) ...[
                Center(
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundImage: user.avatarPath != null
                            ? FileImage(File(user.avatarPath!))
                            : null,
                        child: user.avatarPath == null
                            ? const Icon(Icons.person, size: 50)
                            : null,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        user.name,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        user.email,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // User role badges
                      if (user.roles.isNotEmpty)
                        Wrap(
                          spacing: 8,
                          children: user.roles.map((role) {
                            return Chip(
                              avatar: Icon(
                                _getRoleIcon(role),
                                size: 16,
                                color: Theme.of(context).primaryColor,
                              ),
                              label: Text(
                                _formatRoleName(role),
                                style: TextStyle(
                                  color: Theme.of(context).primaryColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              backgroundColor:
                                  Theme.of(context).primaryColor.withAlpha(26),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            );
                          }).toList(),
                        ),
                      const SizedBox(height: 16),
                      // Quick action buttons
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildQuickActionButton(
                              context,
                              icon: Icons.edit,
                              label: 'Edit Profile',
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const EditProfileScreen(),
                                  ),
                                );
                              },
                            ),
                            _buildQuickActionButton(
                              context,
                              icon: Icons.location_on,
                              label: 'Addresses',
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const AddressManagementScreen(),
                                  ),
                                );
                              },
                            ),
                            if (user.roles.contains('seller'))
                              _buildQuickActionButton(
                                context,
                                icon: Icons.store,
                                label: 'Seller Dashboard',
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const SellerDashboardScreen(),
                                    ),
                                  );
                                },
                              ),
                            if (user.roles.contains('service_provider'))
                              _buildQuickActionButton(
                                context,
                                icon: Icons.handyman,
                                label: 'Service Provider',
                                onPressed: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                          'Service provider dashboard is currently unavailable'),
                                    ),
                                  );
                                },
                              ),
                            if (user.roles.contains('admin'))
                              _buildQuickActionButton(
                                context,
                                icon: Icons.admin_panel_settings,
                                label: 'Admin Dashboard',
                                onPressed: () {
                                  Navigator.pushNamed(
                                      context, '/admin/dashboard');
                                },
                              ),
                            if (user.roles.contains('admin'))
                              _buildQuickActionButton(
                                context,
                                icon: Icons.info_outline,
                                label: 'Market Info',
                                onPressed: () {
                                  Navigator.pushNamed(
                                      context, '/admin/market-info');
                                },
                              ),
                            _buildQuickActionButton(
                              context,
                              icon: Icons.shopping_bag,
                              label: 'My Orders',
                              onPressed: () {
                                Navigator.pushNamed(context, '/orders');
                              },
                            ),
                            _buildQuickActionButton(
                              context,
                              icon: Icons.settings,
                              label: 'Settings',
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const DeveloperSettingsScreen(),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ] else ...[
                // Not logged in state
                Center(
                  child: Column(
                    children: [
                      const CircleAvatar(
                        radius: 50,
                        child: Icon(Icons.person, size: 50),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Guest User',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/login');
                        },
                        child: const Text('Login / Register'),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 32),
              const Text(
                'Account',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              // Account settings
              Card(
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.person_outline),
                      title: const Text('Personal Details'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: user != null
                          ? () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const EditProfileScreen(),
                                ),
                              );
                            }
                          : () => _showLoginDialog(context),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.delete_forever_rounded),
                      title: const Text('Request Account Deletion'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () async {
                        // Capture context-dependent objects before async operation
                        final scaffoldMessenger = ScaffoldMessenger.of(context);

                        final uri = Uri(
                          scheme: 'mailto',
                          path: 'info@masokotips.com',
                          queryParameters: <String, String>{
                            'subject': 'Account Deletion Request - maSOKOtips',
                            'body': 'Hello maSOKOtips Team,\n\nI would like to request deletion of my account and associated data.'
                                '\n\nPlease confirm once completed.\n\nThanks.',
                          },
                        );
                        if (await canLaunchUrl(uri)) {
                          await launchUrl(uri);
                        } else if (mounted) {
                          scaffoldMessenger.showSnackBar(
                            const SnackBar(
                                content:
                                    Text('No email app found to send request')),
                          );
                        }
                      },
                    ),
                    // Add Seller Dashboard for users with seller role
                    if (isLoggedIn &&
                        user != null &&
                        user.roles.contains('seller')) ...[
                      ListTile(
                        leading: const Icon(Icons.store_outlined),
                        title: const Text('Seller Dashboard'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const SellerDashboardScreen(),
                            ),
                          );
                        },
                      ),
                      const Divider(height: 1),
                    ],
                    // Add Service Provider Dashboard for users with service_provider role
                    if (isLoggedIn &&
                        user != null &&
                        user.roles.contains('service_provider')) ...[
                      ListTile(
                        leading: const Icon(Icons.handyman_outlined),
                        title: const Text('Service Provider Dashboard'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          // Service provider dashboard temporarily disabled
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                  'Service provider dashboard is currently unavailable'),
                            ),
                          );
                        },
                      ),
                      const Divider(height: 1),
                    ],
                    ListTile(
                      leading: const Icon(Icons.location_on_outlined),
                      title: const Text('Manage Addresses'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: user != null
                          ? () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const AddressManagementScreen(),
                                ),
                              );
                            }
                          : () => _showLoginDialog(context),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.shopping_bag),
                      title: const Text('My Orders'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        if (isLoggedIn) {
                          Navigator.pushNamed(context, '/orders');
                        } else {
                          _showLoginDialog(context);
                        }
                      },
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.favorite),
                      title: const Text('My Favorites'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        Navigator.pushNamed(context, '/wishlist');
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),
              const Text(
                'App Settings',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              // App settings
              Card(
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.notifications),
                      title: const Text('Notifications'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content:
                                  Text('Notifications settings coming soon')),
                        );
                      },
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.help),
                      title: const Text('Help & Support'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Help & Support coming soon')),
                        );
                      },
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.code),
                      title: const Text('Developer Settings'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const DeveloperSettingsScreen(),
                          ),
                        );
                      },
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.info_outline),
                      title: const Text('About'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        _showAboutDialog(context);
                      },
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.privacy_tip_outlined),
                      title: const Text('Privacy Policy'),
                      trailing: const Icon(Icons.open_in_new_rounded),
                      onTap: () async {
                        // Capture context-dependent objects before async operation
                        final scaffoldMessenger = ScaffoldMessenger.of(context);

                        final uri = Uri.parse(
                            'https://masokotips.com/privacy-policy.html');
                        bool opened = false;
                        if (await canLaunchUrl(uri)) {
                          opened = await launchUrl(uri,
                              mode: LaunchMode.externalApplication);
                        }
                        if (!opened) {
                          opened = await launchUrl(
                            uri,
                            mode: LaunchMode.inAppWebView,
                            webViewConfiguration: const WebViewConfiguration(
                                enableJavaScript: true),
                          );
                        }
                        if (!opened && mounted) {
                          scaffoldMessenger.showSnackBar(
                            const SnackBar(
                                content: Text('Could not open link')),
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),

              if (isLoggedIn) ...[
                const SizedBox(height: 32),
                Center(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.logout),
                    label: const Text('Logout'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () async {
                      // Capture context-dependent objects before async operation
                      final scaffoldMessenger = ScaffoldMessenger.of(context);
                      final navigator = Navigator.of(context);

                      try {
                        // Show confirmation dialog
                        final result = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Logout'),
                            content:
                                const Text('Are you sure you want to logout?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: const Text('Logout'),
                              ),
                            ],
                          ),
                        );

                        if (result == true && mounted) {
                          await authProvider.logout();

                          // Show success message
                          if (mounted) {
                            scaffoldMessenger.showSnackBar(
                              const SnackBar(
                                content: Text('Logged out successfully'),
                                backgroundColor: Colors.green,
                              ),
                            );
                          }

                          // Navigate to home screen
                          if (mounted) {
                            navigator.pushNamedAndRemoveUntil(
                              '/',
                              (route) => false,
                            );
                          }
                        }
                      } catch (e) {
                        // Show error message
                        if (mounted) {
                          scaffoldMessenger.showSnackBar(
                            SnackBar(
                              content: Text('Logout failed: $e'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    },
                  ),
                ),
              ],

              // Add Market Info Management for admin users
              if (isLoggedIn &&
                  user != null &&
                  user.roles.contains('admin')) ...[
                ListTile(
                  leading: const Icon(Icons.info_outline),
                  title: const Text('Market Information'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.pushNamed(context, '/admin/market-info');
                  },
                ),
                const Divider(height: 1),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _showLoginDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Login Required'),
        content: const Text(
            'You need to login to access this feature. Would you like to login now?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('LATER'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/login');
            },
            child: const Text('LOGIN'),
          ),
        ],
      ),
    );
  }

  IconData _getRoleIcon(String role) {
    switch (role) {
      case 'admin':
        return Icons.admin_panel_settings;
      case 'seller':
        return Icons.store;
      case 'service_provider':
        return Icons.handyman;
      case 'buyer':
        return Icons.shopping_cart;
      default:
        return Icons.person;
    }
  }

  String _formatRoleName(String role) {
    switch (role) {
      case 'admin':
        return 'Admin';
      case 'seller':
        return 'Seller';
      case 'service_provider':
        return 'Service Provider';
      case 'buyer':
        return 'Buyer';
      default:
        return role.substring(0, 1).toUpperCase() + role.substring(1);
    }
  }

  Widget _buildQuickActionButton(BuildContext context,
      {required IconData icon,
      required String label,
      required VoidCallback onPressed}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withAlpha(26),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: Theme.of(context).primaryColor,
                  size: 24,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'Masoko Tips',
      applicationVersion: '1.0.0',
      applicationIcon: Image.asset(
        'assets/images/logo-moble.png',
        width: 48,
        height: 48,
        errorBuilder: (context, error, stackTrace) => const Icon(
          Icons.shopping_basket,
          size: 48,
          color: Colors.green,
        ),
      ),
      applicationLegalese: '© 2023 Masoko Tips - All rights reserved',
      children: [
        const SizedBox(height: 16),
        const Text(
          'Masoko Tips is a platform connecting buyers and sellers of agricultural products. Our mission is to promote sustainable farming and fair trade practices.',
        ),
        const SizedBox(height: 16),
        const Text(
          'For more information, contact us at support@masokotips.com',
        ),
      ],
    );
  }
}
