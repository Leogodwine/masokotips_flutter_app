import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/custom_drawer.dart';

class AppScaffold extends StatelessWidget {
  final String title;
  final Widget body;
  final List<Widget>? actions;
  final bool showBottomNavigation;
  final int currentIndex;
  final Function(int)? onBottomNavItemTapped;

  const AppScaffold({
    super.key,
    required this.title,
    required this.body,
    this.actions,
    this.showBottomNavigation = true,
    this.currentIndex = 0,
    this.onBottomNavItemTapped,
  });

  void _handleProtectedRoute(BuildContext context, int index) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (!authProvider.isAuthenticated && index == 2) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Login Required'),
          content: const Text('Please login to access this feature.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/login');
              },
              child: const Text('Login'),
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
        actions: [
          ...?actions,
          Consumer<AuthProvider>(
            builder: (context, authProvider, child) {
              return Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.admin_panel_settings),
                    onPressed: () {
                      Navigator.pushNamed(context, '/admin/login');
                    },
                  ),
                  IconButton(
                    icon: Icon(
                      authProvider.isAuthenticated ? Icons.logout : Icons.login,
                    ),
                    onPressed: () async {
                      if (authProvider.isAuthenticated) {
                        authProvider.logout();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Logged out successfully')),
                        );
                      } else {
                        Navigator.pushNamed(context, '/login');
                      }
                    },
                  ),
                ],
              );
            },
          ),
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
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home),
                  label: 'Home',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.category),
                  label: 'Categories',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.shopping_bag),
                  label: 'Orders',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person),
                  label: 'Profile',
                ),
              ],
            )
          : null,
    );
  }
}
