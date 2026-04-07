import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:geolocator/geolocator.dart';
import 'package:map_launcher/map_launcher.dart';
import '../../providers/auth_provider.dart';
import '../../providers/subscription_provider.dart';
import 'dart:io';
import '../seller/seller_dashboard_screen.dart';
import '../service_provider/provider_dashboard_screen.dart';
import './admin_login_screen.dart';
import '../subscription/subscription_screen.dart';
import '../../l10n/app_localizations.dart';

// Feature flags - set to false to disable features temporarily
// Set to true to re-enable these features later
const bool kLocationFeatureEnabled = false;
const bool kFollowUserLocationEnabled = false;

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Position? _currentPosition;
  bool _isLoadingLocation = false;
  String _locationError = '';

  // For another user's location (could be from API in real app)
  double? _targetUserLatitude;
  double? _targetUserLongitude;
  String? _targetUserName;

  @override
  void initState() {
    super.initState();
    _loadSubscriptionsIfLoggedIn();
    _getCurrentLocation();

    // Simulate another user's location for demo
    // In a real app, this would come from an API response
    _targetUserLatitude = -6.7924; // Example: Dar es Salaam
    _targetUserLongitude = 39.2083;
    _targetUserName = 'John\'s Location';
  }

  Future<void> _loadSubscriptionsIfLoggedIn() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.isAuthenticated) {
      final subscriptionProvider =
          Provider.of<SubscriptionProvider>(context, listen: false);
      await subscriptionProvider.loadUserSubscriptions();
    }
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoadingLocation = true;
      _locationError = '';
    });

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _locationError = 'Location services are disabled';
          _isLoadingLocation = false;
        });
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            _locationError = 'Location permission denied';
            _isLoadingLocation = false;
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _locationError = 'Location permissions are permanently denied';
          _isLoadingLocation = false;
        });
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      setState(() {
        _currentPosition = position;
        _isLoadingLocation = false;
      });
    } catch (e) {
      setState(() {
        _locationError = 'Error getting location: $e';
        _isLoadingLocation = false;
      });
    }
  }

  Future<void> _navigateToLocation(double lat, double lng, String title) async {
    if (await MapLauncher.isMapAvailable(MapType.google) ?? false) {
      await MapLauncher.showMarker(
        mapType: MapType.google,
        coords: Coords(lat, lng),
        title: title,
      );
    } else {
      // Fallback to URL launcher
      final uri = Uri.parse(
          'https://www.google.com/maps/search/?api=1&query=$lat,$lng');
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Could not open maps app')),
          );
        }
      }
    }
  }

  String _formatCoordinates(Position? position) {
    if (position == null) return 'Location not available';
    return '${position.latitude.toStringAsFixed(6)}, ${position.longitude.toStringAsFixed(6)}';
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final subscriptionProvider = Provider.of<SubscriptionProvider>(context);
    final isLoggedIn = authProvider.isAuthenticated;
    final user = authProvider.user;
    final hasActiveSubscription = subscriptionProvider.hasActiveSubscription;
    final currentSubscription = subscriptionProvider.getUserSubscription();

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.myProfile),
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
                      // Subscription Badge
                      if (hasActiveSubscription && currentSubscription != null)
                        _buildSubscriptionBadge(context, currentSubscription),
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
                            if (user.roles.contains('seller'))
                              _buildQuickActionButton(
                                context,
                                icon: Icons.add_circle,
                                label: 'Post',
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
                            // Subscribe button - positioned after Post
                            _buildQuickActionButton(
                              context,
                              icon: Icons.subscriptions,
                              label: 'Subscribe',
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const SubscriptionScreen(),
                                  ),
                                );
                              },
                            ),
                            if (user.roles.contains('service_provider'))
                              _buildQuickActionButton(
                                context,
                                icon: Icons.add,
                                label: 'Post',
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const ProviderDashboardScreen(),
                                    ),
                                  );
                                },
                              ),
                            if (user.roles.contains('admin'))
                              _buildQuickActionButton(
                                context,
                                icon: Icons.admin_panel_settings,
                                label:
                                    '${AppLocalizations.of(context)!.admin} Dashboard',
                                onPressed: () {
                                  Navigator.pushNamed(
                                      context, '/admin/dashboard');
                                },
                              ),
                            if (user.roles.contains('admin'))
                              _buildQuickActionButton(
                                context,
                                icon: Icons.info_outline,
                                label: AppLocalizations.of(context)!
                                    .marketInformation,
                                onPressed: () {
                                  Navigator.pushNamed(
                                      context, '/admin/market-info');
                                },
                              ),
                            _buildQuickActionButton(
                              context,
                              icon: Icons.shopping_bag,
                              label: AppLocalizations.of(context)!.myOrders,
                              onPressed: () {
                                Navigator.pushNamed(context, '/orders');
                              },
                            ),
                            _buildQuickActionButton(
                              context,
                              icon: Icons.settings,
                              label: AppLocalizations.of(context)!.settings,
                              onPressed: () {
                                Navigator.pushNamed(context, '/settings');
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
                      Text(
                        AppLocalizations.of(context)!.guestUser,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/login');
                        },
                        child:
                            Text(AppLocalizations.of(context)!.loginRegister),
                      ),
                    ],
                  ),
                ),
              ],

              // Subscription Status Card
              if (isLoggedIn &&
                  hasActiveSubscription &&
                  currentSubscription != null)
                _buildSubscriptionStatusCard(context, currentSubscription),

              const SizedBox(height: 32),
              Text(
                AppLocalizations.of(context)!.account,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              // Account settings
              Card(
                child: Column(
                  children: [
                    // Subscriber Location - DISABLED
                    if (kLocationFeatureEnabled) ...[
                      ListTile(
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor.withAlpha(26),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            _isLoadingLocation
                                ? Icons.location_searching
                                : Icons.my_location,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                        title: const Text('My Location'),
                        subtitle: _isLoadingLocation
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              )
                            : _locationError.isNotEmpty
                                ? Text(
                                    _locationError,
                                    style: const TextStyle(color: Colors.red),
                                  )
                                : Text(_formatCoordinates(_currentPosition)),
                        trailing: IconButton(
                          icon: const Icon(Icons.refresh),
                          onPressed: _getCurrentLocation,
                          tooltip: 'Refresh location',
                        ),
                        onTap: _getCurrentLocation,
                      ),
                      const Divider(height: 1),
                    ],
                    // Follow User Location - DISABLED
                    if (kFollowUserLocationEnabled) ...[
                      ListTile(
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.blue.withAlpha(26),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.navigation,
                            color: Colors.blue,
                          ),
                        ),
                        title: const Text('Follow User Location'),
                        subtitle: Text(_targetUserName ?? 'Tap to navigate'),
                        trailing: ElevatedButton.icon(
                          icon: const Icon(Icons.directions),
                          label: const Text('Navigate'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                          ),
                          onPressed: _targetUserLatitude != null &&
                                  _targetUserLongitude != null
                              ? () {
                                  _navigateToLocation(
                                    _targetUserLatitude!,
                                    _targetUserLongitude!,
                                    _targetUserName ?? 'User Location',
                                  );
                                }
                              : null,
                        ),
                        onTap: _targetUserLatitude != null &&
                                _targetUserLongitude != null
                            ? () {
                                _navigateToLocation(
                                  _targetUserLatitude!,
                                  _targetUserLongitude!,
                                  _targetUserName ?? 'User Location',
                                );
                              }
                            : null,
                      ),
                      const Divider(height: 1),
                    ],
                    ListTile(
                      leading: const Icon(Icons.delete_forever_rounded),
                      title: Text(
                          AppLocalizations.of(context)!.requestAccountDeletion),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () async {
                        // Capture context-dependent objects before async operation
                        final scaffoldMessenger = ScaffoldMessenger.of(context);
                        final localizations = AppLocalizations.of(context)!;

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
                            SnackBar(content: Text(localizations.noEmailApp)),
                          );
                        }
                      },
                    ),
                    // Add Seller Dashboard for users with seller role
                    if (isLoggedIn &&
                        user != null &&
                        user.roles.contains('seller')) ...[
                      ListTile(
                        leading: const Icon(Icons.add_circle_outlined),
                        title: const Text('Post'),
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
                        leading: const Icon(Icons.add),
                        title: const Text('Post'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const ProviderDashboardScreen(),
                            ),
                          );
                        },
                      ),
                      const Divider(height: 1),
                    ],
                    ListTile(
                      leading: const Icon(Icons.shopping_bag),
                      title: Text(AppLocalizations.of(context)!.myOrders),
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
                      title: Text(AppLocalizations.of(context)!.myFavorites),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        Navigator.pushNamed(context, '/wishlist');
                      },
                    ),
                    const Divider(height: 1),
                    // Admin Login Access
                    ListTile(
                      leading: const Icon(Icons.admin_panel_settings),
                      title: const Text('Admin Login'),
                      subtitle: const Text('Access admin dashboard'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AdminLoginScreen(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),
              Text(
                AppLocalizations.of(context)!.appSettings,
                style: const TextStyle(
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
                      title: Text(AppLocalizations.of(context)!.notifications),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text(AppLocalizations.of(context)!
                                  .notificationsComingSoon)),
                        );
                      },
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.language),
                      title: Text(AppLocalizations.of(context)!.language),
                      subtitle:
                          Text(AppLocalizations.of(context)!.englishKiswahili),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        Navigator.pushNamed(context, '/settings/language');
                      },
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.help),
                      title: Text(AppLocalizations.of(context)!.helpSupport),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text(AppLocalizations.of(context)!
                                  .helpSupportComingSoon)),
                        );
                      },
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.info_outline),
                      title: Text(AppLocalizations.of(context)!.about),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        _showAboutDialog(context);
                      },
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.privacy_tip_outlined),
                      title: Text(AppLocalizations.of(context)!.privacyPolicy),
                      trailing: const Icon(Icons.open_in_new_rounded),
                      onTap: () async {
                        // Capture context-dependent objects before async operation
                        final scaffoldMessenger = ScaffoldMessenger.of(context);
                        final localizations = AppLocalizations.of(context)!;

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
                            SnackBar(
                                content: Text(localizations.couldNotOpenLink)),
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
                    label: Text(AppLocalizations.of(context)!.logout),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () async {
                      // Capture context-dependent objects before async operation
                      final scaffoldMessenger = ScaffoldMessenger.of(context);
                      final navigator = Navigator.of(context);
                      final localizations = AppLocalizations.of(context)!;

                      try {
                        // Show confirmation dialog
                        final result = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text(localizations.logout),
                            content: Text(localizations.logoutConfirmation),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: Text(localizations.cancel),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: Text(localizations.logout),
                              ),
                            ],
                          ),
                        );

                        if (result == true && mounted) {
                          await authProvider.logout();

                          // Show success message
                          if (mounted) {
                            scaffoldMessenger.showSnackBar(
                              SnackBar(
                                content:
                                    Text(localizations.loggedOutSuccessfully),
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
                              content: Text('${localizations.logoutFailed} $e'),
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
                  title: Text(AppLocalizations.of(context)!.marketInformation),
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
        title: Text(AppLocalizations.of(context)!.loginRequired),
        content: Text(AppLocalizations.of(context)!.loginRequiredMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.later),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/login');
            },
            child: Text(AppLocalizations.of(context)!.loginButton),
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
        return AppLocalizations.of(context)!.admin;
      case 'seller':
        return AppLocalizations.of(context)!.seller;
      case 'service_provider':
        return AppLocalizations.of(context)!.serviceProvider;
      case 'buyer':
        return AppLocalizations.of(context)!.buyer;
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

  Widget _buildSubscriptionBadge(BuildContext context, dynamic subscription) {
    final Color badgeColor = subscription.status == 'completed'
        ? Colors.green
        : subscription.status == 'pending'
            ? Colors.orange
            : Colors.red;

    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: badgeColor.withAlpha(30),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: badgeColor, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.verified,
            color: badgeColor,
            size: 18,
          ),
          const SizedBox(width: 8),
          Text(
            subscription.typeLabel,
            style: TextStyle(
              color: badgeColor,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubscriptionStatusCard(
      BuildContext context, dynamic subscription) {
    final Color statusColor = subscription.status == 'completed'
        ? Colors.green
        : subscription.status == 'pending'
            ? Colors.orange
            : Colors.red;

    final String expiryText = subscription.expiresAt != null
        ? 'Expires: ${_formatDate(subscription.expiresAt)}'
        : 'No expiry date';

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              statusColor.withAlpha(40),
              Theme.of(context).primaryColor.withAlpha(20),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: statusColor,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.card_membership,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          subscription.typeLabel,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          subscription.statusLabel,
                          style: TextStyle(
                            color: statusColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(50),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      expiryText,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              if (subscription.amount != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(50),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.attach_money, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        '${subscription.currency} ${subscription.amount!.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.refresh),
                  label: const Text('Manage Subscription'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SubscriptionScreen(),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    return '${date.day}/${date.month}/${date.year}';
  }

  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: AppLocalizations.of(context)!.masokoTips,
      applicationVersion: '1.0.0',
      applicationIcon: Image.asset(
        'assets/images/logo-moble.webp',
        width: 48,
        height: 48,
        errorBuilder: (context, error, stackTrace) => const Icon(
          Icons.shopping_basket,
          size: 48,
          color: Colors.green,
        ),
      ),
      applicationLegalese: AppLocalizations.of(context)!.copyright,
      children: [
        const SizedBox(height: 16),
        Text(
          AppLocalizations.of(context)!.aboutDescription,
        ),
        const SizedBox(height: 16),
        Text(
          AppLocalizations.of(context)!.aboutContact,
        ),
      ],
    );
  }
}
