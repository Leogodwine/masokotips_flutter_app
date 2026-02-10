import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/subscription.dart';
import '../../providers/subscription_provider.dart';
import '../../utils/logger.dart';
import 'zenopay_payment_screen.dart';

class ZenopayPhoneInputScreen extends StatefulWidget {
  final SubscriptionPackage package;
  final SubscriptionPlan plan;

  const ZenopayPhoneInputScreen({
    super.key,
    required this.package,
    required this.plan,
  });

  @override
  State<ZenopayPhoneInputScreen> createState() =>
      _ZenopayPhoneInputScreenState();
}

class _ZenopayPhoneInputScreenState extends State<ZenopayPhoneInputScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  String _normalizePhone(String phone) {
    phone = phone.replaceAll(RegExp(r'\D'), '');

    if (phone.startsWith('0') && phone.length == 10) {
      return '255${phone.substring(1)}';
    }

    if (phone.length == 9 && phone.startsWith('7')) {
      return '255$phone';
    }

    if (phone.startsWith('255') && phone.length == 12) {
      return phone;
    }

    return phone;
  }

  Future<void> _proceedToPayment() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final provider =
          Provider.of<SubscriptionProvider>(context, listen: false);

      String phone = _normalizePhone(_phoneController.text.trim());

      if (phone.isEmpty || phone.length < 9) {
        _showSnack('Please enter a valid phone number');
        setState(() => _isLoading = false);
        return;
      }

      Log.i(
          'Creating subscription with manual phone: ${widget.package.id}, ${widget.plan.duration}, $phone');

      final subscription = await provider.createSubscription(
        subscriptionType: widget.package.id,
        duration: widget.plan.duration,
        paymentMethod: 'zenopay',
        phone: phone,
      );

      if (!mounted) return;

      if (subscription != null) {
        // Navigate to payment processing screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => ZenopayPaymentScreen(subscription: subscription),
          ),
        );
      } else {
        _showSnack(provider.errorMessage ?? 'Failed to create subscription');
      }
    } catch (e) {
      Log.e('Subscription creation error: $e');
      _showSnack('Unexpected error occurred');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final price = widget.plan.price?.toStringAsFixed(0) ?? '0';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Enter Payment Number'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Package summary card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.package.name,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(widget.package.description),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            widget.plan.durationLabel,
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                          Text(
                            '$price TZS',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Phone input section
              const Text(
                'Payment Phone Number',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Enter the phone number that will receive the payment prompt.',
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter phone number';
                  }
                  final normalized = _normalizePhone(value.trim());
                  if (normalized.length < 9) {
                    return 'Invalid phone number format';
                  }
                  return null;
                },
                decoration: const InputDecoration(
                  hintText: '255XXXXXXXXX or 0XXXXXXXXX',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.phone),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Example: 255712345678 or 0712345678',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 24),

              // Proceed button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _proceedToPayment,
                  child: _isLoading
                      ? const CircularProgressIndicator()
                      : Text('Pay $price TZS'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
