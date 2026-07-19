import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/orders_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/address.dart';
import '../../models/cart_item.dart' as models;
import '../profile/address_management_screen.dart';
import '../../widgets/loading_button.dart';
import '../orders/order_success_screen.dart';
import '../../l10n/app_localizations.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({Key? key}) : super(key: key);

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _notesController = TextEditingController();
  String _paymentMethod = 'Cash';
  String _deliveryMethod = 'Standard';
  bool _isLoading = false;
  Address? _selectedAddress;
  List<Address> _addresses = [];

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  void _loadInitialData() {
    // Use sample phone number for demo purposes
    _phoneController.text = '+255 123 456 789';

    _loadSavedAddresses();
  }

  Future<void> _loadSavedAddresses() async {
    await Future.delayed(const Duration(milliseconds: 300));

    setState(() {
      _addresses = [
        Address(
          id: '1',
          name: 'Home',
          street: 'Shanty town',
          city: 'Moshi',
          state: 'Kilimanjaro',
          zipCode: '25100',
          country: 'Tanzania',
          isDefault: true,
        ),
      ];

      _selectedAddress = _addresses.firstWhere(
        (address) => address.isDefault,
        orElse: () => _addresses.first,
      );

      _addressController.text =
          '${_selectedAddress?.street}, ${_selectedAddress?.city}, ${_selectedAddress?.state} ${_selectedAddress?.zipCode}, ${_selectedAddress?.country}';
    });
  }

  void _selectAddress() async {
    if (_addresses.isEmpty) {
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const AddressManagementScreen()),
      );
      _loadSavedAddresses();
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.addAddress),
        content: SizedBox(
          height: 300,
          width: double.maxFinite,
          child: RadioGroup<String>(
            groupValue: _selectedAddress?.id,
            onChanged: (value) {
              final address = _addresses.firstWhere((a) => a.id == value);
              setState(() {
                _selectedAddress = address;
                _addressController.text =
                    '${address.street}, ${address.city}, ${address.state} ${address.zipCode}, ${address.country}';
              });
              Navigator.pop(context);
            },
            child: ListView.builder(
              itemCount: _addresses.length,
              itemBuilder: (context, index) {
                final address = _addresses[index];
                return RadioListTile<String>(
                  value: address.id,
                  title: Text(address.name),
                  subtitle: Text('${address.street}, ${address.city}'),
                );
              },
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
        ],
      ),
    );
  }

  void _placeOrder() async {
    if (!_formKey.currentState!.validate()) return;

    // Check if user is authenticated
    final authProvider = context.read<AuthProvider>();
    if (!authProvider.isAuthenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.pleaseLoginToPlaceOrder),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Capture context-dependent objects before async operation
    final cart = context.read<CartProvider>();
    final orders = context.read<OrdersProvider>();
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    setState(() => _isLoading = true);

    try {
      await orders.addOrder(
        cartItems: cart.items.values
            .map((item) => models.CartItem(
                  id: item.product.id,
                  name: item.product.name,
                  price: item.product.price,
                  quantity: item.quantity,
                  imageUrl: item.product.imageUrl,
                ))
            .toList(),
        total: cart.total,
        address: _addressController.text,
        phone: _phoneController.text,
        paymentMethod: _paymentMethod,
        notes: _notesController.text.isNotEmpty ? _notesController.text : null,
      );

      cart.clearCart();

      if (mounted) {
        navigator.pushReplacement(
          MaterialPageRoute(
            builder: (context) =>
                const OrderSuccessScreen(), // ✅ GO TO success screen
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text(
                AppLocalizations.of(context)!.failedToPlaceOrder(e.toString())),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _addressController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.checkout),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        leading: Navigator.canPop(context)
            ? IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              )
            : null,
        actions: [
          // Cart icon with badge
          Consumer<CartProvider>(
            builder: (context, cartProvider, child) {
              return Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.shopping_cart),
                    onPressed: () {
                      Navigator.pushNamed(context, '/cart');
                    },
                  ),
                  if (cartProvider.itemCount > 0)
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
                          '${cartProvider.itemCount}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Order Summary Card
              _buildOrderSummaryCard(cart),
              const SizedBox(height: 20),

              // Delivery Information Card
              _buildDeliveryInfoCard(),
              const SizedBox(height: 20),

              // Payment Info Card (Replaces Payment Method)
              _buildPaymentInfoCard(),
              const SizedBox(height: 20),

              // Order Notes Card
              _buildOrderNotesCard(),
              const SizedBox(height: 30),

              // Place Order Button
              LoadingButton(
                text: AppLocalizations.of(context)!.placeOrder(cart.total),
                isLoading: _isLoading,
                onPressed: _placeOrder,
                height: 56,
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOrderSummaryCard(CartProvider cart) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.shopping_bag, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                Text(
                  AppLocalizations.of(context)!.orderSummary,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...cart.items.values.map((item) => Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: Theme.of(context)
                              .primaryColor
                              .withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.shopping_basket,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.product.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Qty: ${item.quantity} × TZS ${item.product.price.toStringAsFixed(2)}',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        'TZS ${item.total.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ],
                  ),
                )),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  AppLocalizations.of(context)!.total,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Text(
                  'TZS ${cart.total.toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor,
                      ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeliveryInfoCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.local_shipping,
                    color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                Text(
                  AppLocalizations.of(context)!.deliveryInformation,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Delivery Method
            Text(
              AppLocalizations.of(context)!.deliveryMethod,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: RadioGroup<String>(
                    groupValue: _deliveryMethod,
                    onChanged: (value) {
                      setState(() => _deliveryMethod = value.toString());
                    },
                    child: Column(
                      children: [
                        RadioListTile(
                          title: Text(
                              AppLocalizations.of(context)!.standardDelivery),
                          subtitle: Text(AppLocalizations.of(context)!
                              .standardDeliveryTime),
                          value: 'Standard',
                          contentPadding: EdgeInsets.zero,
                        ),
                        RadioListTile(
                          title: Text(
                              AppLocalizations.of(context)!.expressDelivery),
                          subtitle: Text(AppLocalizations.of(context)!
                              .expressDeliveryTime),
                          value: 'Express',
                          contentPadding: EdgeInsets.zero,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Address Selection
            TextFormField(
              controller: _addressController,
              readOnly: true,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)!.deliveryAddress,
                prefixIcon: const Icon(Icons.location_on),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.edit_location_alt),
                  onPressed: _selectAddress,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey[50],
              ),
              validator: (value) => (value == null || value.isEmpty)
                  ? AppLocalizations.of(context)!.pleaseSelectDeliveryAddress
                  : null,
            ),
            const SizedBox(height: 16),

            // Phone Number
            TextFormField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)!.phoneNumber,
                hintText: AppLocalizations.of(context)!.phoneNumberHint,
                prefixIcon: const Icon(Icons.phone),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey[50],
              ),
              validator: (value) => (value == null || value.isEmpty)
                  ? AppLocalizations.of(context)!.phoneNumberRequired
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentInfoCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Theme.of(context).primaryColor.withValues(alpha: 0.05),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info_outline, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Direct Seller Payment',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'This system does not collect money on behalf of sellers. Once you place this order, the seller will receive your details and message. You will communicate directly to arrange payment and delivery.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderNotesCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.message, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                Text(
                  'Message to Seller (Optional)',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _notesController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Add any specific instructions or questions for the seller...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey[50],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
