import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/reviews_provider.dart';
import 'review_moderation_screen.dart';
import 'service_management_screen.dart';
import 'user_management_screen.dart';
import 'analytics_screen.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildAdminSection(
            context,
            'Content Management',
            [
              _buildActionCard(
                context,
                'Review Moderation',
                'Manage user reviews and ratings',
                Icons.rate_review,
                Colors.orange,
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ReviewModerationScreen(),
                  ),
                ),
              ),
              _buildActionCard(
                context,
                'Service Management',
                'Add, edit, or remove services',
                Icons.miscellaneous_services,
                Colors.blue,
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ServiceManagementScreen(),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildAdminSection(
            context,
            'User Management',
            [
              _buildActionCard(
                context,
                'Users',
                'Manage user accounts and roles',
                Icons.people,
                Colors.green,
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const UserManagementScreen(),
                  ),
                ),
              ),
              _buildActionCard(
                context,
                'Analytics',
                'View platform statistics',
                Icons.analytics,
                Colors.purple,
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AnalyticsScreen(),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildReviewStats(context),
        ],
      ),
    );
  }

  Widget _buildAdminSection(
    BuildContext context,
    String title,
    List<Widget> children,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 16),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 1.2,
          children: children,
        ),
      ],
    );
  }

  Widget _buildActionCard(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 40,
                color: color,
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReviewStats(BuildContext context) {
    return Consumer<ReviewsProvider>(
      builder: (context, reviewsProvider, child) {
        final allReviews = reviewsProvider.getUserReviews('all');
        final pendingCount = allReviews
            .where((review) => review.status == ReviewStatus.pending)
            .length;
        final approvedCount = allReviews
            .where((review) => review.status == ReviewStatus.approved)
            .length;
        final rejectedCount = allReviews
            .where((review) => review.status == ReviewStatus.rejected)
            .length;

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Review Statistics',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatItem(
                      context,
                      'Pending',
                      pendingCount,
                      Colors.orange,
                    ),
                    _buildStatItem(
                      context,
                      'Approved',
                      approvedCount,
                      Colors.green,
                    ),
                    _buildStatItem(
                      context,
                      'Rejected',
                      rejectedCount,
                      Colors.red,
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    String label,
    int count,
    Color color,
  ) {
    return Column(
      children: [
        Text(
          count.toString(),
          style: Theme.of(context)
              .textTheme
              .headlineMedium
              ?.copyWith(color: color),
        ),
        Text(label),
      ],
    );
  }
}
