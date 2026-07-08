import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../providers/agent_provider.dart';
import 'package:masoko_tips/l10n/app_localizations.dart';

class AgentDashboardScreen extends StatefulWidget {
  const AgentDashboardScreen({super.key});

  @override
  State<AgentDashboardScreen> createState() => _AgentDashboardScreenState();
}

class _AgentDashboardScreenState extends State<AgentDashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final p = context.read<AgentProvider>();
      p.loadDashboard();
      p.loadReferrals();
      p.loadEarnings();
    });
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.agentDashboard),
        backgroundColor: theme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabs,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          tabs: const [
            Tab(icon: Icon(Icons.dashboard_outlined), text: 'Overview'),
            Tab(icon: Icon(Icons.people_outline), text: 'Referrals'),
            Tab(icon: Icon(Icons.payments_outlined), text: 'Earnings'),
          ],
        ),
      ),
      body: Consumer<AgentProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.stats == null) {
            return const Center(child: CircularProgressIndicator());
          }
          if (provider.error != null && provider.stats == null) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 12),
                  Text(provider.error!),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: provider.loadDashboard,
                    child: Text(AppLocalizations.of(context)!.retry),
                  ),
                ],
              ),
            );
          }
          return TabBarView(
            controller: _tabs,
            children: [
              _OverviewTab(provider: provider),
              _ReferralsTab(provider: provider),
              _EarningsTab(provider: provider),
            ],
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// OVERVIEW TAB
// ─────────────────────────────────────────────────────────────────────────────

class _OverviewTab extends StatelessWidget {
  final AgentProvider provider;
  const _OverviewTab({required this.provider});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final stats = provider.stats;
    final code = provider.referralCode ?? '—';

    return RefreshIndicator(
      onRefresh: provider.loadDashboard,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── Referral Code Card ──────────────────────────────────────────
          Card(
            elevation: 4,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  colors: [theme.primaryColor, theme.primaryColorDark],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.badge_outlined,
                          color: Colors.white70, size: 20),
                      SizedBox(width: 8),
                      Text('Your Referral Code',
                          style:
                              TextStyle(color: Colors.white70, fontSize: 13)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Text(
                        code,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 3,
                          fontFamily: 'monospace',
                        ),
                      ),
                      const Spacer(),
                      // Copy button
                      IconButton(
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: code));
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(AppLocalizations.of(context)!.referralCodeCopied),
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        },
                        icon: const Icon(Icons.copy, color: Colors.white),
                        tooltip: 'Copy code',
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Give this code to users during onboarding.\nYou earn TZS 100 each time a referred user subscribes.',
                    style: TextStyle(
                        color: Colors.white70, fontSize: 12, height: 1.5),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // ── Stats Grid ──────────────────────────────────────────────────
          if (stats != null) ...[
            Text('Performance',
                style: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.6,
              children: [
                _StatCard(
                  label: 'Users Referred',
                  value: '${stats.totalReferred}',
                  icon: Icons.people_outline,
                  color: Colors.blue,
                ),
                _StatCard(
                  label: 'Subscribed',
                  value: '${stats.converted}',
                  icon: Icons.verified_outlined,
                  color: Colors.green,
                ),
                _StatCard(
                  label: 'Total Earned',
                  value: 'TZS ${stats.totalEarned.toStringAsFixed(0)}',
                  icon: Icons.account_balance_wallet_outlined,
                  color: Colors.purple,
                ),
                _StatCard(
                  label: 'Pending Payout',
                  value: 'TZS ${stats.pendingEarnings.toStringAsFixed(0)}',
                  icon: Icons.hourglass_empty,
                  color: Colors.orange,
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Conversion rate
            Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const Icon(Icons.trending_up, color: Colors.teal),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Conversion Rate',
                            style: TextStyle(color: Colors.grey)),
                        Text(
                          stats.totalReferred > 0
                              ? '${(stats.converted / stats.totalReferred * 100).toStringAsFixed(1)}%'
                              : '—',
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text('Commission/sub',
                            style: TextStyle(color: Colors.grey, fontSize: 12)),
                        Text('TZS ${stats.commissionRate.toStringAsFixed(0)}',
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(icon, color: color, size: 22),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value,
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: color)),
                Text(label,
                    style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// REFERRALS TAB
// ─────────────────────────────────────────────────────────────────────────────

class _ReferralsTab extends StatelessWidget {
  final AgentProvider provider;
  const _ReferralsTab({required this.provider});

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: provider.loadReferrals,
      child: provider.referrals.isEmpty
          ? const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.people_outline, size: 64, color: Colors.grey),
                  SizedBox(height: 12),
                  Text('No referrals yet.\nShare your code to get started!',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey)),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: provider.referrals.length,
              itemBuilder: (context, i) {
                final r = provider.referrals[i];
                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: r.hasSubscription
                          ? Colors.green.withAlpha(30)
                          : Colors.grey.withAlpha(30),
                      child: Icon(
                        r.hasSubscription
                            ? Icons.verified
                            : Icons.person_outline,
                        color: r.hasSubscription ? Colors.green : Colors.grey,
                      ),
                    ),
                    title: Text(r.name,
                        style: const TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Text(
                        '${r.role.toUpperCase()} • ${r.referredAt ?? '—'}'),
                    trailing: r.hasSubscription
                        ? Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.green.withAlpha(30),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              r.subscriptionType ?? 'Active',
                              style: const TextStyle(
                                  color: Colors.green, fontSize: 11),
                            ),
                          )
                        : const Text('Not subscribed',
                            style: TextStyle(fontSize: 11, color: Colors.grey)),
                  ),
                );
              },
            ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// EARNINGS TAB
// ─────────────────────────────────────────────────────────────────────────────

class _EarningsTab extends StatelessWidget {
  final AgentProvider provider;
  const _EarningsTab({required this.provider});

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: provider.loadEarnings,
      child: provider.earnings.isEmpty
          ? const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.payments_outlined, size: 64, color: Colors.grey),
                  SizedBox(height: 12),
                  Text('No earnings yet.',
                      style: TextStyle(color: Colors.grey)),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: provider.earnings.length,
              itemBuilder: (context, i) {
                final e = provider.earnings[i];
                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: e.isPaid
                          ? Colors.green.withAlpha(30)
                          : Colors.orange.withAlpha(30),
                      child: Icon(
                        e.isPaid
                            ? Icons.check_circle_outline
                            : Icons.hourglass_empty,
                        color: e.isPaid ? Colors.green : Colors.orange,
                      ),
                    ),
                    title: Text(e.referredUser,
                        style: const TextStyle(fontWeight: FontWeight.w600)),
                    subtitle:
                        Text('${e.subscriptionType ?? '—'} • ${e.earnedAt}'),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${e.currency} ${e.commission.toStringAsFixed(0)}',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: e.isPaid
                                ? Colors.green.withAlpha(30)
                                : Colors.orange.withAlpha(30),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            e.isPaid ? 'Paid' : 'Pending',
                            style: TextStyle(
                              fontSize: 10,
                              color: e.isPaid ? Colors.green : Colors.orange,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
