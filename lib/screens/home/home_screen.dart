import 'package:flutter/material.dart';
import 'dart:io';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/product_provider.dart';
import '../products/product_list_screen.dart';
import '../cart/cart_screen.dart';
import '../../providers/cart_provider.dart';
import '../orders/orders_screen.dart';
import '../profile/profile_screen.dart';
import '../../providers/category_provider.dart';
import '../../providers/wishlist_provider.dart';
import '../../screens/profile/profile_manager.dart';
import '../../utils/logger.dart';
import '../home/home_content_screen.dart';
import '../seller/seller_dashboard_screen.dart';
import '../categories/main_categories_screen.dart';
import '../transport/transport_categories_screen.dart';
import '../profile/edit_profile_screen.dart';
import '../profile/address_management_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  bool _isRefreshing = false;
  final PageController _pageController = PageController();

  final List<Widget> _screens = [
    const HomeContentScreen(),
    const ProductListScreen(
      title: 'Products',
      categoryId: 0,
      subcategory: 'defaultSubcategory',
    ),
    const CartScreen(),
    const OrdersScreen(),
    const ProfileScreen(),
  ];

  Future<void> _refreshData() async {
    if (!mounted || _isRefreshing) return;

    setState(() => _isRefreshing = true);

    try {
      final categoryProvider = context.read<CategoryProvider>();
      final productProvider = context.read<ProductProvider>();

      // Load categories first
      if (mounted) {
        await categoryProvider.loadMainCategories();
      }

      // Then load featured products if still mounted
      if (mounted) {
        await productProvider.getFeaturedProducts();
      }
    } catch (e) {
      Log.e('Error refreshing data: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error refreshing data: $e'),
            action: SnackBarAction(
              label: 'RETRY',
              onPressed: _refreshData,
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isRefreshing = false);
      }
    }
  }

  @override
  void initState() {
    super.initState();
    // Initialize data after the widget is mounted
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _initializeData();
      }
    });
  }

  Future<void> _initializeData() async {
    try {
      final categoryProvider = context.read<CategoryProvider>();
      final productProvider = context.read<ProductProvider>();

      // Load categories first
      await categoryProvider.loadMainCategories();

      // Then load featured products if still mounted
      if (mounted) {
        await productProvider.getFeaturedProducts();
      }
    } catch (e) {
      Log.e('Error initializing data: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error initializing data: $e'),
            action: SnackBarAction(
              label: 'RETRY',
              onPressed: _initializeData,
            ),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    final isAuthenticated = context.read<AuthProvider>().isAuthenticated;

    // Show login dialog for protected routes
    if (!isAuthenticated && index >= 2) {
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
                _handleLoginNavigation(context);
              },
              child: const Text('Login'),
            ),
          ],
        ),
      );
      return;
    }

    setState(() {
      _selectedIndex = index;
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    });
  }

  Future<void> _handleLoginNavigation(BuildContext context) async {
    try {
      final result = await Navigator.pushNamed(context, '/login');

      if (result == true && mounted) {
        setState(() {
          _selectedIndex = 2; // Navigate to Cart screen
          _pageController.jumpToPage(2);
        });

        await Future.delayed(const Duration(milliseconds: 100));

        if (mounted) {
          await _refreshData();
        }
      }
    } catch (e) {
      Log.e('Error during login navigation: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error during login: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _selectedIndex == 0,
      onPopInvoked: (didPop) {
        if (!didPop) {
          setState(() {
            _selectedIndex = 0;
            _pageController.jumpToPage(0);
          });
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('maSOKOtips'),
          actions: [
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {
                Navigator.pushNamed(context, '/search');
              },
            ),
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () {
                Navigator.pushNamed(context, '/profile');
              },
            ),
            Consumer<WishlistProvider>(
              builder: (context, wishlistProvider, _) {
                final itemCount = wishlistProvider.wishlistItems.length;
                return Stack(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.favorite_border),
                      onPressed: () =>
                          Navigator.pushNamed(context, '/wishlist'),
                    ),
                    if (itemCount > 0)
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
                            itemCount.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
            Consumer<CartProvider>(
              builder: (context, cartProvider, child) {
                final itemCount = cartProvider.itemCount;
                return Stack(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.shopping_cart),
                      onPressed: () {
                        if (context.read<AuthProvider>().isAuthenticated) {
                          setState(() {
                            _selectedIndex = 2;
                            _pageController.jumpToPage(2);
                          });
                        } else {
                          _showLoginDialog(context);
                        }
                      },
                    ),
                    if (itemCount > 0)
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
                            itemCount.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
            Consumer<AuthProvider>(
              builder: (context, authProvider, child) {
                return IconButton(
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
                      _handleLoginNavigation(context);
                    }
                  },
                );
              },
            ),
          ],
        ),
        drawer: _buildDrawer(context),
        body: RefreshIndicator(
          onRefresh: _refreshData,
          child: PageView(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            children: _screens,
          ),
        ),
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          selectedItemColor: Theme.of(context).colorScheme.primary,
          unselectedItemColor: Colors.grey,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal),
          elevation: 8,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_rounded),
              activeIcon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.shopping_basket_outlined),
              activeIcon: Icon(Icons.shopping_basket),
              label: 'Products',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.shopping_cart_outlined),
              activeIcon: Icon(Icons.shopping_cart),
              label: 'Cart',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.receipt_long_outlined),
              activeIcon: Icon(Icons.receipt_long),
              label: 'Orders',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }

  Drawer _buildDrawer(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.user;
    final isAuthenticated = authProvider.isAuthenticated;

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          // User Profile Section
          Container(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        if (isAuthenticated) {
                          ProfileManager.openProfile(context);
                        } else {
                          _showLoginDialog(context);
                        }
                      },
                      child: CircleAvatar(
                        radius: 30,
                        backgroundImage: user?.avatarPath != null
                            ? FileImage(File(user!.avatarPath!))
                            : const AssetImage(
                                    'assets/images/default_avatar.png')
                                as ImageProvider,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user?.name ?? 'Guest User',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            user?.email ?? 'Not logged in',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 204),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (isAuthenticated && user != null) ...[
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: user.roles.map((role) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 51),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _getRoleIcon(role),
                              size: 16,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _formatRoleName(role),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ],
            ),
          ),

          // Main Menu Section
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Quick Actions
                if (isAuthenticated) ...[
                  _buildDrawerSection(
                    context,
                    title: 'Quick Actions',
                    items: [
                      _buildDrawerItem(
                        context,
                        icon: Icons.shopping_bag,
                        title: 'My Orders',
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.pushNamed(context, '/orders');
                        },
                      ),
                      _buildDrawerItem(
                        context,
                        icon: Icons.favorite,
                        title: 'Wishlist',
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.pushNamed(context, '/wishlist');
                        },
                      ),
                      if (user?.roles.contains('seller') ?? false)
                        _buildDrawerItem(
                          context,
                          icon: Icons.store,
                          title: 'Seller Dashboard',
                          onTap: () {
                            Navigator.pop(context);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const SellerDashboardScreen(),
                              ),
                            );
                          },
                        ),
                      if (user?.roles.contains('service_provider') ?? false)
                        _buildDrawerItem(
                          context,
                          icon: Icons.handyman,
                          title: 'Service Provider Dashboard',
                          onTap: () {
                            Navigator.pop(context);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => Scaffold(
                                  appBar: AppBar(
                                    title: const Text(
                                        'Service Provider Dashboard'),
                                  ),
                                  body: const Center(
                                    child: Text(
                                        'Service provider dashboard is currently unavailable'),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                    ],
                  ),
                  const Divider(),
                ],

                // Categories
                _buildDrawerSection(
                  context,
                  title: 'Categories',
                  items: [
                    _buildDrawerItem(
                      context,
                      icon: Icons.category,
                      title: 'All Categories',
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const MainCategoriesScreen(),
                          ),
                        );
                      },
                    ),
                    _buildDrawerItem(
                      context,
                      icon: Icons.local_shipping,
                      title: 'Transport Services',
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const TransportCategoriesScreen(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
                const Divider(),

                // Account & Settings
                _buildDrawerSection(
                  context,
                  title: 'Account & Settings',
                  items: [
                    if (isAuthenticated) ...[
                      _buildDrawerItem(
                        context,
                        icon: Icons.person_outline,
                        title: 'Profile Settings',
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const EditProfileScreen(),
                            ),
                          );
                        },
                      ),
                      _buildDrawerItem(
                        context,
                        icon: Icons.location_on_outlined,
                        title: 'Manage Addresses',
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const AddressManagementScreen(),
                            ),
                          );
                        },
                      ),
                      _buildDrawerItem(
                        context,
                        icon: Icons.notifications_outlined,
                        title: 'Notifications',
                        onTap: () {
                          Navigator.pop(context);
                          // TODO: Implement notifications screen
                        },
                      ),
                    ] else
                      _buildDrawerItem(
                        context,
                        icon: Icons.login,
                        title: 'Login',
                        onTap: () {
                          Navigator.pop(context);
                          _handleLoginNavigation(context);
                        },
                      ),
                  ],
                ),
                const Divider(),

                // Support & Info
                _buildDrawerSection(
                  context,
                  title: 'Support & Info',
                  items: [
                    _buildDrawerItem(
                      context,
                      icon: Icons.help_outline,
                      title: 'Help & Support',
                      onTap: () {
                        Navigator.pop(context);
                        // TODO: Implement help screen
                      },
                    ),
                    _buildDrawerItem(
                      context,
                      icon: Icons.info_outline,
                      title: 'About',
                      onTap: () {
                        Navigator.pop(context);
                        _showAboutDialog(context);
                      },
                    ),
                    _buildDrawerItem(
                      context,
                      icon: Icons.privacy_tip_outlined,
                      title: 'Privacy Policy',
                      onTap: () {
                        Navigator.pop(context);
                        // TODO: Implement privacy policy screen
                      },
                    ),
                    if (isAuthenticated)
                      _buildDrawerItem(
                        context,
                        icon: Icons.logout,
                        title: 'Logout',
                        onTap: () async {
                          Navigator.pop(context);
                          await authProvider.logout();
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Logged out successfully'),
                              ),
                            );
                          }
                        },
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerSection(
    BuildContext context, {
    required String title,
    required List<Widget> items,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
              letterSpacing: 0.5,
            ),
          ),
        ),
        ...items,
      ],
    );
  }

  Widget _buildDrawerItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      onTap: onTap,
      dense: true,
      visualDensity: const VisualDensity(vertical: -1),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'maSOKOtips',
      applicationVersion: '1.0.0',
      applicationIcon: Image.asset(
        'assets/images/logo.png',
        width: 50,
        height: 50,
      ),
      children: [
        const Text(
          'Your one-stop marketplace for agricultural products and services.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16),
        ),
        const SizedBox(height: 16),
        const Text(
          '© 2024 maSOKOtips. All rights reserved.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14),
        ),
      ],
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
              _handleLoginNavigation(context);
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
        return role;
    }
  }
}
