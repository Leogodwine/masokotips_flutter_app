import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/reviews_provider.dart';
import '../../providers/orders_provider.dart';
import 'package:masoko_tips/l10n/app_localizations.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context)!.analytics),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Overview'),
              Tab(text: 'Reviews'),
              Tab(text: 'Orders'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildOverviewTab(context),
            _buildReviewsTab(context),
            _buildOrdersTab(context),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewTab(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildStatCard(
          context,
          'Total Users',
          '1,234',
          Icons.people,
          Colors.blue,
        ),
        const SizedBox(height: 16),
        _buildStatCard(
          context,
          'Active Services',
          '56',
          Icons.miscellaneous_services,
          Colors.green,
        ),
        const SizedBox(height: 16),
        _buildStatCard(
          context,
          'Total Revenue',
          '\$12,345',
          Icons.attach_money,
          Colors.orange,
        ),
      ],
    );
  }

  Widget _buildReviewsTab(BuildContext context) {
    return Consumer<ReviewsProvider>(
      builder: (context, reviewsProvider, child) {
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildRatingDistribution(context),
            const SizedBox(height: 24),
            const Text(
              'Recent Reviews',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            // Add review list here
          ],
        );
      },
    );
  }

  Widget _buildOrdersTab(BuildContext context) {
    return Consumer<OrdersProvider>(
      builder: (context, ordersProvider, child) {
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildOrderStats(context),
            const SizedBox(height: 24),
            const Text(
              'Recent Orders',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            // Add order list here
          ],
        );
      },
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              icon,
              size: 48,
              color: color,
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Text(
                  value,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: color,
                      ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRatingDistribution(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Rating Distribution',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            ...List.generate(5, (index) {
              final stars = 5 - index;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Text('$stars stars'),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: LinearProgressIndicator(
                        value: 0.7, // Replace with actual data
                        backgroundColor: Colors.grey,
                        color: Colors.amber,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text('70%'), // Replace with actual data
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderStats(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Order Statistics',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildOrderStat(context, 'Pending', '12', Colors.orange),
                _buildOrderStat(context, 'Processing', '8', Colors.blue),
                _buildOrderStat(context, 'Completed', '45', Colors.green),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderStat(
    BuildContext context,
    String label,
    String value,
    Color color,
  ) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: color,
              ),
        ),
        Text(label),
      ],
    );
  }
}
