import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// MODELS
import '../../models/subscription.dart';

// SERVICES / PROVIDERS
import '../../providers/subscription_provider.dart';

import '../../widgets/loading_indicator.dart';
import '../../widgets/api_error_widget.dart';
import '../../utils/logger.dart';

// SCREENS
import 'zenopay_phone_input_screen.dart';
import 'card_payment_screen.dart';
import '../seller/seller_dashboard_screen.dart';
import '../service_provider/provider_dashboard_screen.dart';
import '../buyer/buyer_dashboard_screen.dart';
import '../../providers/auth_provider.dart';

// WIDGET COMPONENTS
import 'widgets/header_section.dart';
import 'widgets/subscribe_bottom_bar.dart';
import 'package:masoko_tips/l10n/app_localizations.dart';

class SubscriptionScreen extends StatefulWidget {
  final String? preSelectedType;

  const SubscriptionScreen({
    super.key,
    this.preSelectedType,
  });

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  bool isLoading = true;
  bool isSubscribing = false;
  String? _errorMessage;

  List<SubscriptionPackage> packages = [];
  SubscriptionPackage? selectedPackage;
  SubscriptionPlan? selectedPlan;
  BillingOptions? billingOptions;

  @override
  void initState() {
    super.initState();
    _initializeScreen();
  }

  // ---------------------------------------------------------------------------
  // INIT
  // ---------------------------------------------------------------------------
  Future<void> _initializeScreen() async {
    await _fetchSubscriptionPackages();

    if (widget.preSelectedType != null && packages.isNotEmpty) {
      final match = packages.firstWhere(
        (p) => p.id == widget.preSelectedType,
        orElse: () => packages.first,
      );

      setState(() {
        selectedPackage = match;
        selectedPlan = match.plans.isNotEmpty ? match.plans.first : null;
      });
    }
  }

  // ---------------------------------------------------------------------------
  // LOAD PACKAGES
  // ---------------------------------------------------------------------------
  Future<void> _fetchSubscriptionPackages() async {
    try {
      setState(() {
        isLoading = true;
        _errorMessage = null;
      });

      final provider =
          Provider.of<SubscriptionProvider>(context, listen: false);

      final response = await provider.getSubscriptionPackages();

      if (response != null && response['success'] == true) {
        if (response['billing_options'] is Map<String, dynamic>) {
          billingOptions = BillingOptions.fromJson(
            response['billing_options'] as Map<String, dynamic>,
          );
        }

        final currency = billingOptions?.currency ?? 'TZS';
        packages = (response['data'] as List)
            .map((e) => SubscriptionPackage.fromJson(
                  e as Map<String, dynamic>,
                  currency: currency,
                ))
            .toList();

        setState(() => isLoading = false);
      } else {
        setState(() {
          _errorMessage =
              response?['message'] ?? 'Failed to load subscriptions';
          isLoading = false;
        });
      }
    } catch (e) {
      Log.e('Subscription load error: $e');
      setState(() {
        _errorMessage = 'Connection error. Please try again.';
        isLoading = false;
      });
    }
  }

  // ---------------------------------------------------------------------------
  // SUBSCRIBE → choose payment method
  // ---------------------------------------------------------------------------
  Future<void> _subscribe() async {
    if (selectedPackage == null || selectedPlan == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.pleaseSelectAPlan)),
      );
      return;
    }

    if (!mounted) return;

    // Show payment method picker
    await showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Choose Payment Method',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              Text(
                'TZS ${selectedPlan!.price!.toStringAsFixed(0)} · ${selectedPlan!.durationLabel}',
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 20),

              // Mobile Money
              _paymentMethodTile(
                ctx,
                icon: Icons.phone_android,
                iconColor: Colors.green,
                title: 'Mobile Money',
                subtitle: 'M-Pesa · Airtel · Tigo · Halo Pesa · Mixx by YAS',
                onTap: () async {
                  Navigator.pop(ctx);
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ZenopayPhoneInputScreen(
                        package: selectedPackage!,
                        plan: selectedPlan!,
                      ),
                    ),
                  );

                  if (result == true && mounted) {
                    _handlePostSubscriptionRedirection();
                  }
                },
              ),

              const SizedBox(height: 12),

              // Card
              _paymentMethodTile(
                ctx,
                icon: Icons.credit_card,
                iconColor: Colors.blue,
                title: 'Card Payment',
                subtitle: 'Visa · Mastercard · All cards',
                onTap: () async {
                  Navigator.pop(ctx);
                  final result = await _startCardPayment();
                  if (result == true && mounted) {
                    _handlePostSubscriptionRedirection();
                  }
                },
              ),

              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _paymentMethodTile(
    BuildContext ctx, {
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade200),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor),
              ),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 15)),
                  Text(subtitle,
                      style: const TextStyle(
                          color: Colors.grey, fontSize: 12)),
                ],
              ),
              const Spacer(),
              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  Future<bool?> _startCardPayment() async {
    if (selectedPackage == null || selectedPlan == null) return false;

    // First create the subscription record
    setState(() => isSubscribing = true);
    try {
      final provider = context.read<SubscriptionProvider>();
      final subscription = await provider.createSubscription(
        subscriptionType: selectedPackage!.id,
        duration: selectedPlan!.duration,
        months: selectedPlan!.months,
        paymentMethod: 'card',
        // phone not needed for card payment
      );

      if (!mounted) return false;
      setState(() => isSubscribing = false);

      if (subscription == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  provider.errorMessage ?? 'Failed to create subscription')),
        );
        return false;
      }

      return await Navigator.push<bool>(
        context,
        MaterialPageRoute(
          builder: (_) => CardPaymentScreen(subscription: subscription),
        ),
      );
    } catch (e) {
      if (mounted) {
        setState(() => isSubscribing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
      return false;
    }
  }

  // ---------------------------------------------------------------------------
  // REDIRECTION AFTER SUCCESS
  // ---------------------------------------------------------------------------
  Future<void> _handlePostSubscriptionRedirection() async {
    if (!mounted) return;

    final subscriptionProvider = context.read<SubscriptionProvider>();
    final authProvider = context.read<AuthProvider>();

    await subscriptionProvider.loadUserSubscriptions();
    await authProvider.fetchUserProfile();

    if (!mounted) return;

    final type = selectedPackage?.id;
    Log.i('Redirecting after successful subscription of type: $type');

    if (type == 'transporter') {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
            builder: (_) => const SellerDashboardScreen(initialIndex: 1)),
        (route) => route.isFirst,
      );
    } else if (type == 'seller') {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
            builder: (_) => const SellerDashboardScreen(initialIndex: 0)),
        (route) => route.isFirst,
      );
    } else if (type == 'service_provider') {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const ProviderDashboardScreen()),
        (route) => route.isFirst,
      );
    } else if (type == 'buyer') {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const BuyerDashboardScreen()),
        (route) => route.isFirst,
      );
    } else {
      // Default fallback to profile
      Navigator.popUntil(context, (route) => route.isFirst);
      Navigator.pushNamed(context, '/profile');
    }
  }

  // ---------------------------------------------------------------------------
  // UI HELPERS
  // ---------------------------------------------------------------------------
  String _displayPrice() {
    if (selectedPlan != null) {
      return '${_formatPrice(selectedPlan!.price)} ${billingOptions?.currency ?? 'TZS'}';
    }
    return '';
  }

  String _formatPrice(double? price) {
    if (price == null) return '—';
    return price.toStringAsFixed(0);
  }

  // ---------------------------------------------------------------------------
  // BUILD
  // ---------------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.subscription)),
      body: isLoading
          ? const Center(child: LoadingIndicator())
          : _errorMessage != null
              ? ApiErrorWidget(
                  errorMessage: _errorMessage!,
                  onRetry: _fetchSubscriptionPackages,
                )
              : RefreshIndicator(
                  onRefresh: _fetchSubscriptionPackages,
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      const HeaderSection(),
                      if (billingOptions != null) ...[
                        const SizedBox(height: 12),
                        _BillingSummary(options: billingOptions!),
                      ],
                      const SizedBox(height: 20),
                      ...packages.map((package) {
                        final isSelected = selectedPackage?.id == package.id;

                        return Card(
                          elevation: isSelected ? 6 : 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: () {
                              setState(() {
                                selectedPackage = package;
                                selectedPlan = package.plans.isNotEmpty
                                    ? package.plans.first
                                    : null;
                              });
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    package.name,
                                    style:
                                        Theme.of(context).textTheme.titleLarge,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(package.description),
                                  const SizedBox(height: 16),
                                  ...package.plans.map((plan) {
                                    final selected = selectedPlan?.duration ==
                                            plan.duration &&
                                        isSelected;

                                    return ListTile(
                                      title: Text(plan.durationLabel),
                                      subtitle: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            '${_formatPrice(plan.price)} ${billingOptions?.currency ?? 'TZS'}',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          if (plan.originalPrice != null &&
                                              plan.originalPrice! > (plan.price ?? 0))
                                            Text(
                                              'Was ${_formatPrice(plan.originalPrice)} ${billingOptions?.currency ?? 'TZS'}',
                                              style: TextStyle(
                                                decoration: TextDecoration.lineThrough,
                                                color: Colors.grey.shade600,
                                                fontSize: 12,
                                              ),
                                            ),
                                        ],
                                      ),
                                      trailing: plan.popular
                                          ? Chip(
                                              label: Text(
                                                plan.badge ?? 'Popular',
                                                style: const TextStyle(fontSize: 11),
                                              ),
                                            )
                                          : (selected
                                              ? const Icon(
                                                  Icons.check_circle,
                                                  color: Colors.green,
                                                )
                                              : null),
                                      onTap: () {
                                        setState(() {
                                          selectedPackage = package;
                                          selectedPlan = plan;
                                        });
                                      },
                                    );
                                  }),
                                ],
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ],
                  ),
                ),
      bottomNavigationBar: SubscribeBottomBar(
        isLoading: isSubscribing,
        selectedPackage: selectedPackage,
        displayPrice: _displayPrice(),
        onPressed: (selectedPackage != null && selectedPlan != null)
            ? _subscribe
            : null,
      ),
    );
  }
}

class _BillingSummary extends StatelessWidget {
  final BillingOptions options;

  const _BillingSummary({required this.options});

  @override
  Widget build(BuildContext context) {
    final plans = options.publicPlans;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Reference: ${options.currency} ${options.pricePerMonth} / month',
            style: TextStyle(color: Colors.grey.shade700, fontSize: 12),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: plans.map((plan) {
              final listPrice = options.pricePerMonth * plan.months;
              final hasDiscount = listPrice > plan.amount;

              return Chip(
                label: Text(
                  hasDiscount
                      ? '${plan.months} mo · ${options.currency} ${plan.amount} (was $listPrice)'
                      : '${plan.months} mo · ${options.currency} ${plan.amount}',
                  style: const TextStyle(fontSize: 12),
                ),
                visualDensity: VisualDensity.compact,
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
