import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/admin_provider.dart';
import '../models/admin_dashboard_data.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({Key? key}) : super(key: key);

  @override
  AdminDashboardScreenState createState() => AdminDashboardScreenState();
}

class AdminDashboardScreenState extends State<AdminDashboardScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (!mounted) return;
      context.read<AdminProvider>().loadDashboardData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              context.read<AdminProvider>().logout();
              Navigator.pushReplacementNamed(context, '/admin/login');
            },
          ),
        ],
      ),
      body: Consumer<AdminProvider>(
        builder: (context, adminProvider, child) {
          if (adminProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (adminProvider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Error: ${adminProvider.error}',
                    style: const TextStyle(color: Colors.red),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      adminProvider.loadDashboardData();
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final dashboardData = adminProvider.dashboardData;
          if (dashboardData == null) {
            return const Center(child: Text('No dashboard data available'));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildStatsSection(dashboardData),
                const SizedBox(height: 24),
                _buildRecentUsersSection(dashboardData),
                const SizedBox(height: 24),
                _buildSystemInfoSection(dashboardData),
                const SizedBox(height: 24),
                _buildQuickLinksSection(dashboardData),
              ],
            ),
          );
        },
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
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
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
                    users.service_providers.toString(), Icons.handyman),
                _buildStatCard('New Users Today',
                    users.newUsersToday.toString(), Icons.person_add),
                _buildStatCard(
                    'Active Users', users.activeUsers.toString(), Icons.person),
                _buildStatCard('Verified Users', users.verifiedUsers.toString(),
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
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: Theme.of(context).primaryColor),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentUsersSection(AdminDashboardData data) {
    final latestUsers = data.recent_activities.latestUsers;

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
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: latestUsers.length,
              itemBuilder: (context, index) {
                final user = latestUsers[index];
                return ListTile(
                  leading: CircleAvatar(
                    child: Text(user.name[0]),
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
          ],
        ),
      ),
    );
  }

  Widget _buildSystemInfoSection(AdminDashboardData data) {
    final systemInfo = data.system_info;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'System Information',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildInfoRow('PHP Version', systemInfo.phpVersion),
            _buildInfoRow('Laravel Version', systemInfo.laravelVersion),
            _buildInfoRow('Server Software', systemInfo.serverSoftware),
            _buildInfoRow('Database', systemInfo.databaseConnection),
            _buildInfoRow('Timezone', systemInfo.timezone),
            _buildInfoRow('Memory Usage', systemInfo.memoryUsage),
            _buildInfoRow('Disk Space', systemInfo.diskFreeSpace),
            _buildInfoRow('Upload Limit', systemInfo.uploadMaxFilesize),
            _buildInfoRow(
                'Max Execution Time', '${systemInfo.maxExecutionTime}s'),
            _buildInfoRow('Server Time', systemInfo.serverTime),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          Text(value),
        ],
      ),
    );
  }

  Widget _buildQuickLinksSection(AdminDashboardData data) {
    final userLinks = data.quick_links.users;
    final reportLinks = data.quick_links.reports;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Quick Links',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildQuickLinksGroup('Users', userLinks),
            const SizedBox(height: 16),
            _buildQuickLinksGroup('Reports', reportLinks),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickLinksGroup(String title, List<Link> links) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        ...links.map((link) => ListTile(
              leading: const Icon(Icons.link),
              title: Text(link.title),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.pushNamed(context, link.route);
              },
            )),
      ],
    );
  }
}
