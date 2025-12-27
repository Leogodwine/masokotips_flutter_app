import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/cart_provider.dart';
import '../widgets/custom_drawer.dart';

class AppScaffold extends StatelessWidget {
  final String title;
  final Widget body;
  final List<Widget>? actions;
  final bool showBottomNavigation;
  final int currentIndex;
  final Function(int)? onBottomNavItemTapped;
  final bool showBackButton;
  final VoidCallback? onBackPressed;
  final bool showAuthActions; // New parameter to control auth button visibility

  String _getUserInitial(String? name) {
    if (name != null && name.isNotEmpty) {
      return name.substring(0, 1).toUpperCase();
    }
    return 'U';
  }

  const AppScaffold({
    super.key,
    required this.title,
    required this.body,
    this.actions,
    this.showBottomNavigation = true,
    this.currentIndex = 0,
    this.onBottomNavItemTapped,
    this.showBackButton = true,
    this.onBackPressed,
    this.showAuthActions = true, // Default to true for backward compatibility
  });

  void _handleProtectedRoute(BuildContext context, int index) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (!authProvider.isAuthenticated && index == 2) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(AppLocalizations.of(context)!.loginRequired),
          content: Text(AppLocalizations.of(context)!.loginRequiredMessage),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(AppLocalizations.of(context)!.cancel),
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
      return;
    }
    onBottomNavItemTapped?.call(index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        leading: showBackButton && Navigator.canPop(context)
            ? IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () {
                  if (onBackPressed != null) {
                    onBackPressed!();
                  } else {
                    Navigator.pop(context);
                  }
                },
              )
            : null,
        actions: [
          // Cart icon with badge
          Consumer<CartProvider>(
            builder: (context, cartProvider, child) {
              return Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.shopping_cart),
                    onPressed: () {
                      Navigator.pushNamed(context, '/cart');
                    },
                  ),
                  if (cartProvider.itemCount > 0)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          '${cartProvider.itemCount}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
          ...?actions,
          if (showAuthActions) ...[
            // Only show default auth actions if showAuthActions is true
            Consumer<AuthProvider>(
              builder: (context, authProvider, child) {
                if (authProvider.isAuthenticated) {
                  // User profile dropdown and admin login for authenticated users
                  return Row(
                    children: [
                      // Admin login button
                      IconButton(
                        icon: const Icon(Icons.admin_panel_settings),
                        onPressed: () {
                          Navigator.pushNamed(context, '/admin/login');
                        },
                      ),
                      // User profile dropdown
                      PopupMenuButton<String>(
                        icon: CircleAvatar(
                          radius: 16,
                          backgroundColor: Colors.white,
                          child: Text(
                            _getUserInitial(authProvider.user?.name),
                            style: TextStyle(
                              color: Theme.of(context).primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        onSelected: (value) async {
                          switch (value) {
                            case 'profile':
                              Navigator.pushNamed(context, '/profile');
                              break;
                            case 'orders':
                              Navigator.pushNamed(context, '/orders');
                              break;
                            case 'admin_login':
                              Navigator.pushNamed(context, '/admin/login');
                              break;
                            case 'logout':
                              authProvider.logout();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Logged out successfully'),
                                ),
                              );
                              break;
                          }
                        },
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            value: 'profile',
                            child: Row(
                              children: [
                                const Icon(Icons.person),
                                const SizedBox(width: 8),
                                Text(authProvider.user?.name ?? 'Profile'),
                              ],
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'orders',
                            child: Row(
                              children: [
                                Icon(Icons.shopping_bag),
                                SizedBox(width: 8),
                                Text('My Orders'),
                              ],
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'admin_login',
                            child: Row(
                              children: [
                                Icon(Icons.admin_panel_settings),
                                SizedBox(width: 8),
                                Text('Admin Login'),
                              ],
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'logout',
                            child: Row(
                              children: [
                                Icon(Icons.logout),
                                SizedBox(width: 8),
                                Text('Logout'),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                } else {
                  // Login and Admin buttons for unauthenticated users
                  return Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.admin_panel_settings),
                        onPressed: () {
                          Navigator.pushNamed(context, '/admin/login');
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.login),
                        onPressed: () {
                          Navigator.pushNamed(context, '/login');
                        },
                      ),
                    ],
                  );
                }
              },
            ),
          ],
        ],
      ),
      drawer: const CustomDrawer(),
      body: body,
      bottomNavigationBar: showBottomNavigation
          ? BottomNavigationBar(
              currentIndex: currentIndex,
              onTap: (index) => _handleProtectedRoute(context, index),
              type: BottomNavigationBarType.fixed,
              selectedItemColor: Theme.of(context).primaryColor,
              unselectedItemColor: Colors.grey,
              items: [
                BottomNavigationBarItem(
                  icon: const Icon(Icons.home),
                  label: AppLocalizations.of(context)!.home,
                ),
                BottomNavigationBarItem(
                  icon: const Icon(Icons.favorite),
                  label: AppLocalizations.of(context)!.myFavorites,
                ),
                BottomNavigationBarItem(
                  icon: const Icon(Icons.shopping_bag),
                  label: AppLocalizations.of(context)!.orders,
                ),
                BottomNavigationBarItem(
                  icon: const Icon(Icons.person),
                  label: AppLocalizations.of(context)!.profile,
                ),
              ],
            )
          : null,
    );
  }
}
