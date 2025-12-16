import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// MODELS
import '../../models/subscription.dart';

// SERVICES / PROVIDERS
import '../../providers/subscription_provider.dart';
import '../../providers/auth_provider.dart';

// UI
import '../../widgets/loading_indicator.dart';
import '../../widgets/api_error_widget.dart';
import '../../utils/logger.dart';

// SCREENS
import 'azampay_payment_screen.dart';

// WIDGET COMPONENTS
import 'widgets/header_section.dart';
import 'widgets/subscribe_bottom_bar.dart';

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
        packages = (response['data'] as List)
            .map((e) => SubscriptionPackage.fromJson(e))
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
  // SUBSCRIBE → CREATE SUBSCRIPTION → AZAMPAY
  // ---------------------------------------------------------------------------
  Future<void> _subscribe() async {
    if (selectedPackage == null || selectedPlan == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a plan')),
      );
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final phone = authProvider.user?.phoneNumber;

    if (phone == null || phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Your phone number is required. Please update your profile.',
          ),
        ),
      );
      return;
    }

    setState(() => isSubscribing = true);

    try {
      final subscriptionProvider =
          Provider.of<SubscriptionProvider>(context, listen: false);

      final subscription = await subscriptionProvider.createSubscription(
        subscriptionType: selectedPackage!.id,
        duration: selectedPlan!.duration,
        paymentMethod: 'azampay', // ✅ ONLY VALID VALUE
        phone: authProvider.user!.phoneNumber!,
      );

      if (!mounted) return;

      if (subscription != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => AzamPayPaymentScreen(
              subscription: subscription,
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              subscriptionProvider.errorMessage ??
                  'Failed to create subscription',
            ),
          ),
        );
      }
    } catch (e) {
      Log.e('Subscription error: $e');
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unexpected error')),
      );
    } finally {
      if (mounted) setState(() => isSubscribing = false);
    }
  }

  // ---------------------------------------------------------------------------
  // UI HELPERS
  // ---------------------------------------------------------------------------
  String _displayPrice() {
    if (selectedPlan != null) {
      return '${selectedPlan!.price!.toStringAsFixed(0)} TZS';
    }
    return '';
  }

  // ---------------------------------------------------------------------------
  // BUILD
  // ---------------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Subscription')),
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
                                      subtitle: Text(
                                          '${plan.price!.toStringAsFixed(0)} TZS'),
                                      trailing: selected
                                          ? const Icon(
                                              Icons.check_circle,
                                              color: Colors.green,
                                            )
                                          : null,
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
