import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/admin_provider.dart';
import '../providers/auth_provider.dart';
import '../models/admin_dashboard_data.dart';
import 'profile/profile_screen.dart';
import 'admin/admin_user_management_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({Key? key}) : super(key: key);

  @override
  AdminDashboardScreenState createState() => AdminDashboardScreenState();
}

class AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int _selectedIndex = 0;
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _selectedIndex);
    
    // Load dashboard data after the first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<AdminProvider>().loadDashboardData();
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // Build profile tab content with admin user information
  Widget _buildProfileTab() {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        if (!authProvider.isAuthenticated || authProvider.user == null) {
          return const Center(
            child: Text('Please log in to view profile'),
          );
        }

        final user = authProvider.user!;
        
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              // Profile Picture
              CircleAvatar(
                radius: 50,
                backgroundImage: user.avatar != null 
                    ? NetworkImage(user.avatar!)
                    : const AssetImage('assets/images/default_avatar.png') as ImageProvider,
                backgroundColor: Colors.grey[200],
              ),
              const SizedBox(height: 16),
              // Name
              Text(
                user.name,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              // Email
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.email_outlined, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    user.email,
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              if (user.phoneNumber?.isNotEmpty ?? false) ...[
                const SizedBox(height: 8),
                // Phone Number
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.phone_outlined, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      user.phoneNumber!,
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 24),
              // Roles
              Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: user.roles.map((role) => Chip(
                  label: Text(
                    role.toUpperCase(),
                    style: const TextStyle(fontSize: 12),
                  ),
                  backgroundColor: Theme.of(context).primaryColor.withValues(),
                  labelStyle: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                )).toList(),
              ),
              const SizedBox(height: 32),
              // Account Created
              Text(
                'Member since ${DateFormat('MMM yyyy').format(user.createdAt)}',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
              // Logout Button
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    // Capture the navigator and provider before the first await.
                    final navigator = Navigator.of(context);
                    final adminProvider = context.read<AdminProvider>();

                    final confirmed = await showDialog<bool>(
                      context: context, // This context is still valid here
                      builder: (dialogContext) => AlertDialog( // Use dialogContext for things inside the dialog
                        title: const Text('Logout'),
                        content: const Text('Are you sure you want to logout?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(dialogContext).pop(false),
                            child: const Text('CANCEL'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(dialogContext).pop(true),
                            child: const Text('LOGOUT'),
                          ),
                        ],
                      ),
                    );

                    // Check mounted BEFORE using the context-dependent objects after an await.
                    if (confirmed == true && mounted) {
                      await adminProvider.logout();
                      // It's good practice to check mounted again if another await happened,
                      // or if the operation above could have unmounted the widget.
                      if (mounted) {
                        navigator.pushNamedAndRemoveUntil('/admin/login', (route) => false);
                      }
                    }
                  },

                  icon: const Icon(Icons.logout, size: 20),
                  label: const Text('LOGOUT'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red[50],
                    foregroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Navigation is now handled directly in the BottomNavigationBar's onTap callback

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(_getAppBarTitle(_selectedIndex)),
        actions: [
          if (_selectedIndex == 0) // Only show refresh on dashboard
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () => context.read<AdminProvider>().loadDashboardData(),
            ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'logout') {
                _handleLogout(context);
              }
            },
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Logout'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(), // Disable swiping
        onPageChanged: (index) {
          setState(() => _selectedIndex = index);
        },
        children: [
          // Dashboard Tab
          Consumer<AdminProvider>(
            builder: (context, adminProvider, _) {
              if (adminProvider.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (adminProvider.error != null) {
                return _buildErrorView(adminProvider);
              }

              final dashboardData = adminProvider.dashboardData;
              if (dashboardData == null) {
                return const Center(child: Text('No dashboard data available'));
              }

              return RefreshIndicator(
                onRefresh: () => adminProvider.loadDashboardData(),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildWelcomeCard(authProvider.user?.name ?? 'Admin'),
                      const SizedBox(height: 16),
                      _buildStatsSection(dashboardData),
                      const SizedBox(height: 24),
                      _buildManagementSection(),
                      const SizedBox(height: 24),
                      _buildQuickActions(),
                      const SizedBox(height: 24),
                      _buildRecentUsersSection(dashboardData),
                    ],
                  ),
                ),
              );
            },
          ),
          
          // User Management Tab
          const AdminUserManagementScreen(),
          
          // Profile Tab with custom implementation
          _buildProfileTab(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          // Handle navigation to profile or other tabs
          if (index == 2) { // Profile tab
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ProfileScreen(),
              ),
            );
            // Reset to dashboard tab after navigation
            setState(() => _selectedIndex = 0);
            _pageController.jumpToPage(0);
          } else {
            // For other tabs, update the page view
            setState(() => _selectedIndex = index);
            _pageController.jumpToPage(index);
          }
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Users',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  // Helper method to get app bar title based on selected tab
  String _getAppBarTitle(int index) {
    switch (index) {
      case 0:
        return 'Admin Dashboard';
      case 1:
        return 'User Management';
      case 2:
        return 'My Profile';
      default:
        return 'Admin Panel';
    }
  }

  // Handle logout with confirmation
  // Handle logout with confirmation
  Future<void> _handleLogout(BuildContext context) async {
    // --- Before await ---
    // Capture context-dependent objects IF they are used after an await.
    // In this case, AdminProvider is used before the next mounted check for Navigator,
    // and ScaffoldMessenger is used in the catch block.
    final adminProvider = context.read<AdminProvider>();
    // It's good practice to get the Navigator and ScaffoldMessenger upfront
    // if you know you'll need them after async operations.
    final navigator = Navigator.of(context);
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    final confirmed = await showDialog<bool>(
      context: context, // This context is fine
      builder: (dialogContext) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    // --- After await ---
    // Now, use the captured objects, guarded by 'mounted' checks.
    if (confirmed == true) {
      // Check mounted before the first async operation that uses a captured object
      if (!mounted) return; // If not mounted, exit early

      try {
        await adminProvider.logout(); // Use the captured provider

        if (mounted) { // Check mounted again before using navigator
          navigator.pushNamedAndRemoveUntil(
            '/admin/login',
                (route) => false,
          );
        }
      } catch (e) {
        if (mounted) { // Check mounted before using scaffoldMessenger
          scaffoldMessenger.showSnackBar(
            SnackBar(content: Text('Error during logout: ${e.toString()}')),
          );
        }
      }
    }
  }

  // Build error view widget
  Widget _buildErrorView(AdminProvider adminProvider) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 48),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Text(
              'Error: ${adminProvider.error}',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.red),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: adminProvider.loadDashboardData,
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  // Build welcome card with user info
  Widget _buildWelcomeCard(String userName) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            const CircleAvatar(
              radius: 30,
              child: Icon(Icons.person, size: 32),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Welcome back,',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                  Text(
                    userName,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Build quick action buttons
  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Actions',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 3,
          children: [
            _buildQuickActionButton(
              context,
              icon: Icons.person_add,
              label: 'Add User',
              onTap: () {
                // TODO: Implement add user navigation
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Add user functionality coming soon')),
                );
              },
            ),
            _buildQuickActionButton(
              context,
              icon: Icons.settings,
              label: 'Settings',
              onTap: () {
                // TODO: Implement settings navigation
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Settings screen coming soon')),
                );
              },
            ),
          ],
        ),
      ],
    );
  }

  // Build quick action button
  Widget _buildQuickActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              Icon(icon, size: 20, color: Theme.of(context).primaryColor),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsSection(AdminDashboardData data) {
    final users = data.stats.users;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'User Statistics',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.5,
              children: [
                _buildStatCard(
                    'Total Users', users.total.toString(), Icons.people),
                _buildStatCard('Admins', users.admins.toString(),
                    Icons.admin_panel_settings),
                _buildStatCard(
                    'Sellers', users.sellers.toString(), Icons.store),
                _buildStatCard(
                    'Buyers', users.buyers.toString(), Icons.shopping_cart),
                _buildStatCard('Service Providers',
                    users.serviceProviders.toString(), Icons.handyman),
                _buildStatCard('New Users',
                    users.newUsersToday.toString(), Icons.person_add),
                _buildStatCard(
                    'Active', users.activeUsers.toString(), Icons.person),
                _buildStatCard('Verified', users.verifiedUsers.toString(),
                    Icons.verified_user),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    return Card(
      elevation: 2,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
        constraints: const BoxConstraints(
          minWidth: 0,
          // You can optionally set a maxHeight if needed
          // maxHeight: 100,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 24, color: Theme.of(context).primaryColor),
              const SizedBox(height: 4),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 2),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey[600],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


  Widget _buildManagementSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Management',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              childAspectRatio: 1.1,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: [
                // Users Card
                _buildManagementCard(
                  'Users',
                  Icons.people,
                  () => Navigator.pushNamed(context, '/admin/users'),
                ),
                // Products Card
                _buildManagementCard(
                  'Products',
                  Icons.shopping_bag,
                  () => Navigator.pushNamed(context, '/admin/products'),
                ),
                // Organic Products Card
                _buildManagementCard(
                  'Organic Products',
                  Icons.eco,
                  () => Navigator.pushNamed(context, '/admin/organic-products'),
                ),
                // Market Info Card
                _buildManagementCard(
                  'Market Info',
                  Icons.info,
                  () => Navigator.pushNamed(context, '/admin/market-info'),
                ),
                // Transport Card
                _buildManagementCard(
                  'Transport',
                  Icons.local_shipping,
                  () => Navigator.pushNamed(context, '/admin/transport'),
                ),
                // Services Card
                _buildManagementCard(
                  'Services',
                  Icons.miscellaneous_services,
                  () => Navigator.pushNamed(context, '/admin/services'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildManagementCard(String title, IconData icon, VoidCallback onTap) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 32, color: Theme.of(context).primaryColor),
              const SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


  Widget _buildRecentUsersSection(AdminDashboardData data) {
    final latestUsers = data.recentActivities.latestUsers;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Recent Users',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ConstrainedBox(
              constraints: const BoxConstraints(
                maxHeight: 300, // Adjust this height as needed
              ),
              child: ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: latestUsers.length,
                itemBuilder: (context, index) {
                  final user = latestUsers[index];
                  return ListTile(
                    leading: CircleAvatar(
                      child: Text(user.name.substring(0,1).toUpperCase()),
                    ),
                    title: Text(user.name),
                    subtitle: Text(user.email),
                    trailing: Chip(
                      label: Text(
                        user.role.toUpperCase(),
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
