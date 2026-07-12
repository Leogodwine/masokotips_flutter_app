import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../providers/auth_provider.dart';
import '../../providers/subscription_provider.dart';
import '../../providers/agent_provider.dart';
import 'dart:io';
import '../seller/seller_dashboard_screen.dart';
import '../service_provider/provider_dashboard_screen.dart';
import './admin_login_screen.dart';
import '../subscription/subscription_screen.dart';
import '../../models/subscription.dart';
import '../buyer/add_buying_request_screen.dart';
import '../../l10n/app_localizations.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    _loadSubscriptionsIfLoggedIn();
  }

  Future<void> _loadSubscriptionsIfLoggedIn() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.isAuthenticated) {
      final subscriptionProvider =
          Provider.of<SubscriptionProvider>(context, listen: false);
      await subscriptionProvider.loadUserSubscriptions();
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final subscriptionProvider = Provider.of<SubscriptionProvider>(context);
    final isLoggedIn = authProvider.isAuthenticated;
    final user = authProvider.user;
    final hasSellerSubscription =
        subscriptionProvider.hasActiveSubscriptionFor('seller');
    final hasServiceProviderSubscription =
        subscriptionProvider.hasActiveSubscriptionFor('service_provider');
    final hasTransporterSubscription =
        subscriptionProvider.hasActiveSubscriptionFor('transporter');
    final hasBuyerSubscription =
        subscriptionProvider.hasActiveSubscriptionFor('buyer');

    // Select the most relevant subscription to display
    Subscription? displaySubscription;
    if (isLoggedIn && user != null) {
      // 1. Try to find an ACTIVE subscription first, checking all roles
      for (final role in user.roles) {
        final sub = subscriptionProvider.getUserSubscription(type: role);
        if (sub != null && sub.isActive) {
          displaySubscription = sub;
          break;
        }
      }

      // 2. If no active professional, look for an ACTIVE buyer subscription (as backup if not in roles list)
      if (displaySubscription == null && !user.roles.contains('buyer')) {
        displaySubscription =
            subscriptionProvider.getUserSubscription(type: 'buyer');
      }

      // 3. If still no active subscription, look for the LATEST professional subscription (even if expired)
      if (displaySubscription == null) {
        for (final role in [
          'seller',
          'transporter',
          'service_provider',
          'buyer'
        ]) {
          if (user.roles.contains(role)) {
            final sub = subscriptionProvider.getLatestSubscriptionByType(role);
            if (sub != null) {
              if (displaySubscription == null ||
                  sub.createdAt.isAfter(displaySubscription.createdAt)) {
                displaySubscription = sub;
              }
            }
          }
        }
      }

      // 4. Final fallback: Show the latest overall only if the user is NOT a professional
      // or if they have no professional subscription record at all.
      if (displaySubscription == null &&
          !user.isSeller &&
          !user.isTransporter &&
          !user.isServiceProvider) {
        displaySubscription = subscriptionProvider.getLatestSubscription();
      }
    }

    final localizations = AppLocalizations.of(context)!;

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
                      if (displaySubscription != null &&
                          displaySubscription.isActive)
                        _buildSubscriptionBadge(context, displaySubscription),
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
                            // Unified Post button for professional/buyer users
                            // Show it if they HAVE the role OR if they HAVE an active subscription
                            if (user.isSeller ||
                                user.isTransporter ||
                                user.isServiceProvider ||
                                user.isBuyer ||
                                hasSellerSubscription ||
                                hasTransporterSubscription ||
                                hasServiceProviderSubscription ||
                                hasBuyerSubscription)
                              _buildQuickActionButton(
                                context,
                                icon: Icons.add_circle,
                                label: 'POST',
                                isCTA: true,
                                onPressed: () {
                                  // Smart routing: prefer dashboard where user HAS an active subscription
                                  if (hasSellerSubscription ||
                                      hasTransporterSubscription) {
                                    // If user is ONLY a transporter or has transporter sub but no seller sub,
                                    // go to transport tab (index 1)
                                    int initialIndex = 0;
                                    if (hasTransporterSubscription &&
                                        !hasSellerSubscription) {
                                      initialIndex = 1;
                                    } else if (user.isTransporter &&
                                        !user.isSeller) {
                                      initialIndex = 1;
                                    }

                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            SellerDashboardScreen(
                                                initialIndex: initialIndex),
                                      ),
                                    );
                                  } else if (hasServiceProviderSubscription) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const ProviderDashboardScreen(),
                                      ),
                                    );
                                  } else if (hasBuyerSubscription) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const AddBuyingRequestScreen(),
                                      ),
                                    );
                                  } else {
                                    // Fallback if they have the role but no active sub yet
                                    _showSubscriptionRequiredDialog(context);
                                  }
                                },
                              ),

                            // Only show "Subscribe" if they don't have an active subscription
                            if (!hasSellerSubscription &&
                                !hasTransporterSubscription &&
                                !hasServiceProviderSubscription &&
                                !hasBuyerSubscription)
                              _buildQuickActionButton(
                                context,
                                icon: Icons.rocket_launch,
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

                            // Agent dashboard button
                            if (user.roles.contains('agent'))
                              _buildQuickActionButton(
                                context,
                                icon: Icons.bar_chart,
                                label: 'My Dashboard',
                                onPressed: () {
                                  context.read<AgentProvider>().loadDashboard();
                                  Navigator.pushNamed(
                                      context, '/agent/dashboard');
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

              // Subscription Status Card (hide for agents, and hide stale failed records
              // when the user has an active subscription already shown via the badge)
              if (isLoggedIn &&
                  displaySubscription != null &&
                  !(user?.roles.contains('agent') ?? false) &&
                  !displaySubscription.isFailed)
                _buildSubscriptionStatusCard(context, displaySubscription),

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
                    // Add Buyer Dashboard for users with buyer role
                    if (isLoggedIn &&
                        user != null &&
                        user.roles.contains('buyer')) ...[
                      ListTile(
                        leading: const Icon(Icons.campaign),
                        title: Text(localizations.myRequests),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          if (subscriptionProvider.hasActiveSubscription) {
                            Navigator.pushNamed(context, '/buyer/dashboard');
                          } else {
                            _showSubscriptionRequiredDialog(context);
                          }
                        },
                      ),
                      const Divider(height: 1),
                    ],
                    // Add Seller Dashboard for users with seller role
                    if (isLoggedIn &&
                        user != null &&
                        (user.roles.contains('seller') ||
                            user.roles.contains('transporter'))) ...[
                      ListTile(
                        leading: const Icon(Icons.inventory_2_outlined),
                        title: Text(user.isTransporter && !user.isSeller
                            ? 'Post Transport'
                            : 'Post Products / Transport'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          if (hasSellerSubscription ||
                              hasTransporterSubscription) {
                            int initialIndex = 0;
                            if (hasTransporterSubscription &&
                                !hasSellerSubscription) {
                              initialIndex = 1;
                            } else if (user.isTransporter && !user.isSeller) {
                              initialIndex = 1;
                            }

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => SellerDashboardScreen(
                                    initialIndex: initialIndex),
                              ),
                            );
                          } else {
                            _showSubscriptionRequiredDialog(context);
                          }
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
                        title: Text(localizations.postServices),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          if (hasServiceProviderSubscription) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const ProviderDashboardScreen(),
                              ),
                            );
                          } else {
                            _showSubscriptionRequiredDialog(context);
                          }
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
                      title: Text(localizations.adminLoginAdmin),
                      subtitle: Text(localizations.accessAdminDashboard),
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
      case 'transporter':
        return Icons.local_shipping;
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
      case 'transporter':
        return 'Transporter';
      default:
        return role.substring(0, 1).toUpperCase() + role.substring(1);
    }
  }

  Widget _buildQuickActionButton(BuildContext context,
      {required IconData icon,
      required String label,
      required VoidCallback onPressed,
      bool isCTA = false}) {
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
                padding: EdgeInsets.all(isCTA ? 16 : 12),
                decoration: BoxDecoration(
                  color: isCTA
                      ? Theme.of(context).primaryColor
                      : Theme.of(context).primaryColor.withAlpha(26),
                  shape: BoxShape.circle,
                  boxShadow: isCTA
                      ? [
                          BoxShadow(
                            color: Theme.of(context).primaryColor.withOpacity(0.4),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          )
                        ]
                      : null,
                ),
                child: Icon(
                  icon,
                  color: isCTA ? Colors.white : Theme.of(context).primaryColor,
                  size: isCTA ? 28 : 24,
                ),
              ),
              SizedBox(height: isCTA ? 8 : 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: isCTA ? 14 : 12,
                  fontWeight: isCTA ? FontWeight.bold : FontWeight.normal,
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
    final Color badgeColor = subscription.isActive
        ? Colors.green
        : subscription.isPending
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
    final localizations = AppLocalizations.of(context)!;
    final Color statusColor = subscription.isActive
        ? Colors.green
        : subscription.isPending
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
                      const Icon(Icons.payments_outlined, size: 18),
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
              // If pending/pending_checkout: show Cancel & Retry + Check Now
              if (subscription.isPending) ...[
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.close, size: 18),
                        label: Text(localizations.cancelAndRetry),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          side: const BorderSide(color: Colors.red),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (_) => AlertDialog(
                              title: Text(localizations.cancelPaymentTitle),
                              content: Text(AppLocalizations.of(context)!.thisWillCancelThePendingPayment),
                              actions: [
                                TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, false),
                                    child: Text(localizations.no)),
                                TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, true),
                                    child: Text(localizations.yesCancel,
                                        style: const TextStyle(color: Colors.red))),
                              ],
                            ),
                          );
                          if (confirm == true && context.mounted) {
                            final provider = Provider.of<SubscriptionProvider>(
                                context,
                                listen: false);
                            final ok = await provider
                                .cancelPendingSubscription(subscription.id);
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(ok
                                      ? 'Cancelled. You can now subscribe again.'
                                      : provider.errorMessage ??
                                          'Failed to cancel.'),
                                  backgroundColor:
                                      ok ? Colors.green : Colors.red,
                                ),
                              );
                              if (ok) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const SubscriptionScreen(),
                                  ),
                                );
                              }
                            }
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.refresh, size: 18),
                        label: Text(localizations.checkNow),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                          onPressed: () async {
                            final provider = Provider.of<SubscriptionProvider>(
                                context,
                                listen: false);
                            final result = await provider
                                .checkSubscriptionStatus(subscription.id);
                            if (context.mounted) {
                              if (result?.status == 'active') {
                                  await provider.loadUserSubscriptions();
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(AppLocalizations.of(context)!.paymentConfirmedSubscriptionIsNowActive),
                                        backgroundColor: Colors.green,
                                      ),
                                    );
                                  }
                              } else {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(AppLocalizations.of(context)!.paymentStillPendingPleaseApproveOn),
                                      backgroundColor: Colors.orange,
                                    ),
                                  );
                                }
                              }
                            }
                          },
                      ),
                    ),
                  ],
                ),
              ] else ...[
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.refresh),
                    label: Text(localizations.manageSubscription),
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

  void _showSubscriptionRequiredDialog(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.user;
    String contentText = 'Your subscription has expired or you don\'t have an active membership. Please subscribe to access premium features and post items.';
    if (user != null) {
      if (user.isBuyer && !user.isSeller && !user.isTransporter && !user.isServiceProvider) {
        contentText = 'Your subscription has expired or you don\'t have an active membership. Please subscribe to post buying requests.';
      } else if (user.isSeller || user.isTransporter || user.isServiceProvider) {
        contentText = 'Your subscription has expired or you don\'t have an active membership. Please subscribe to access seller features and post items.';
      }
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(localizations.subscriptionRequired),
        content: Text(contentText),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.later),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SubscriptionScreen(),
                ),
              );
            },
            child: Text(localizations.subscribeNow),
          ),
        ],
      ),
    );
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
