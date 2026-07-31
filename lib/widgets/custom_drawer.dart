import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:masoko_tips/providers/auth_provider.dart';
import '../l10n/app_localizations.dart';

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final isAuthenticated = authProvider.isAuthenticated;
    final user = authProvider.user;

    return Drawer(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).primaryColor.withValues(),
              Colors.white,
            ],
          ),
        ),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            // User Profile Section
            Container(
              padding: const EdgeInsets.fromLTRB(16, 48, 16, 24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Theme.of(context).primaryColor,
                    Theme.of(context).primaryColor.withValues(),
                  ],
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: CircleAvatar(
                          radius: 28,
                          backgroundColor: Colors.white,
                          child: Icon(
                            Icons.account_circle_outlined,
                            size: 32,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isAuthenticated ? 'Karibu' : AppLocalizations.of(context)!.helloGuest,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              isAuthenticated
                                  ? user?.name ?? 'User'
                                  : AppLocalizations.of(context)!.signInToYourAccount,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (!isAuthenticated) ...[
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.pushNamed(context, '/login');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Theme.of(context).primaryColor,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(AppLocalizations.of(context)!.signIn),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Main Navigation Section
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Column(
                children: [
                  _buildDrawerItem(
                    context,
                    icon: Icons.home_outlined,
                    title: AppLocalizations.of(context)!.homeMenu,
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushReplacementNamed(context, '/home');
                    },
                  ),
                  _buildDrawerItem(
                    context,
                    icon: Icons.storefront_outlined,
                    title: AppLocalizations.of(context)!.productsMenu,
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/products');
                    },
                  ),
                  _buildDrawerItem(
                    context,
                    icon: Icons.local_shipping_outlined,
                    title: AppLocalizations.of(context)!.transportMenu,
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/transport');
                    },
                  ),
                  _buildDrawerItem(
                    context,
                    icon: Icons.insights_outlined,
                    title: AppLocalizations.of(context)!.marketInfoMenu,
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/market-info');
                    },
                  ),
                ],
              ),
            ),

            // Account Section
            if (isAuthenticated) ...[
              const Divider(),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Column(
                  children: [
                    _buildDrawerItem(
                      context,
                      icon: Icons.person_outline,
                      title: AppLocalizations.of(context)!.profileMenu,
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.pushNamed(context, '/profile');
                      },
                    ),
                    _buildDrawerItem(
                      context,
                      icon: Icons.receipt_long_outlined,
                      title: AppLocalizations.of(context)!.myOrdersMenu,
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.pushNamed(context, '/orders');
                      },
                    ),
                    _buildDrawerItem(
                      context,
                      icon: Icons.favorite_border,
                      title: AppLocalizations.of(context)!.wishlistMenu,
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.pushNamed(context, '/wishlist');
                      },
                    ),
                  ],
                ),
              ),
            ],

            // Settings & Support Section
            const Divider(),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                children: [
                  _buildDrawerItem(
                    context,
                    icon: Icons.settings_outlined,
                    title: AppLocalizations.of(context)!.settingsMenu,
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/settings');
                    },
                  ),
                  if (isAuthenticated)
                    _buildDrawerItem(
                      context,
                      icon: Icons.delete_outline,
                      title: AppLocalizations.of(context)!.requestAccountDeletion,
                      onTap: () async {
                        Navigator.pop(context);
                        await _composeDeletionEmail(context);
                      },
                    ),
                  _buildDrawerItem(
                    context,
                    icon: Icons.privacy_tip_outlined,
                    title: AppLocalizations.of(context)!.privacyPolicyMenu,
                    onTap: () async {
                      Navigator.pop(context);
                      await _openExternalUrl(
                        context,
                        'https://masokotips.com/privacy-policy.html',
                      );
                    },
                  ),
                  _buildDrawerItem(
                    context,
                    icon: Icons.help_outline,
                    title: AppLocalizations.of(context)!.helpAndSupportMenu,
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/help');
                    },
                  ),
                  _buildDrawerItem(
                    context,
                    icon: Icons.info_outline,
                    title: AppLocalizations.of(context)!.aboutMenu,
                    onTap: () {
                      Navigator.pop(context);
                      _showAboutDialog(context);
                    },
                  ),
                  if (isAuthenticated)
                    _buildDrawerItem(
                      context,
                      icon: Icons.logout,
                      title: AppLocalizations.of(context)!.logoutMenu,
                      onTap: () async {
                        // Capture context-dependent objects before async operation
                        final scaffoldMessenger = ScaffoldMessenger.of(context);
                        Navigator.pop(context);
                        await authProvider.logout();
                        if (context.mounted) {
                          scaffoldMessenger.showSnackBar(
                            SnackBar(
                              content: Text(AppLocalizations.of(context)!.loggedOutSuccessfully),
                            ),
                          );
                        }
                      },
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return ListTile(
      leading: Icon(
        icon,
        size: 24,
        color: colorScheme.onSurfaceVariant,
      ),
      title: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w500,
              color: colorScheme.onSurface,
            ),
      ),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 0),
      minLeadingWidth: 24,
      horizontalTitleGap: 16,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(28),
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.aboutMasokoTips),
        content: Text(AppLocalizations.of(context)!.aboutMasokoTipsDescription),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.closeButton),
          ),
        ],
      ),
    );
  }

  Future<void> _openExternalUrl(BuildContext context, String url) async {
    // Capture context-dependent objects before async operation
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    final uri = Uri.parse(url);
    bool opened = false;
    if (await canLaunchUrl(uri)) {
      opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
    if (!opened) {
      // Fallback to in-app webview if no external handler available
      opened = await launchUrl(
        uri,
        mode: LaunchMode.inAppWebView,
        webViewConfiguration:
            const WebViewConfiguration(enableJavaScript: true),
      );
    }
    if (!opened && context.mounted) {
      scaffoldMessenger.showSnackBar(
        const SnackBar(content: Text('Could not open link')),
      );
    }
  }

  Future<void> _composeDeletionEmail(BuildContext context) async {
    // Capture context-dependent objects before async operation
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    final uri = Uri(
      scheme: 'mailto',
      path: 'info@masokotips.com',
      queryParameters: <String, String>{
        'subject': AppLocalizations.of(context)!.accountDeletionRequestSubject,
        'body': AppLocalizations.of(context)!.accountDeletionRequestBody,
      },
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (context.mounted) {
        scaffoldMessenger.showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.noEmailAppFound)),
        );
      }
    }
  }
}
