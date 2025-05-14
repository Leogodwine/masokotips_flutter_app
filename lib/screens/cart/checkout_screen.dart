import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/orders_provider.dart';
import '../../models/address.dart';
import '../../models/cart_item.dart' as models;
import '../profile/address_management_screen.dart';
import '../../widgets/loading_button.dart';
import '../orders/order_success_screen.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({Key? key}) : super(key: key);

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  String _paymentMethod = 'Cash';
  bool _isLoading = false;
  Address? _selectedAddress;
  List<Address> _addresses = [];

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  void _loadInitialData() {
    final authProvider = context.read<AuthProvider>();
    final user = authProvider.user;

    if (user != null) {
      _phoneController.text = user.phoneNumber ?? '';
    }

    _loadSavedAddresses();
  }

  Future<void> _loadSavedAddresses() async {
    await Future.delayed(const Duration(milliseconds: 300));

    setState(() {
      _addresses = [
        Address(
          id: '1',
          name: 'Home',
          street: '123 Main St',
          city: 'New York',
          state: 'NY',
          zipCode: '10001',
          country: 'USA',
          isDefault: true,
        ),
        Address(
          id: '2',
          name: 'Work',
          street: '456 Business Ave',
          city: 'New York',
          state: 'NY',
          zipCode: '10002',
          country: 'USA',
          isDefault: false,
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
        title: const Text('Select Address'),
        content: SizedBox(
          height: 300,
          width: double.maxFinite,
          child: ListView.builder(
            itemCount: _addresses.length,
            itemBuilder: (context, index) {
              final address = _addresses[index];
              return ListTile(
                leading: Radio<String>(
                  value: address.id,
                  groupValue: _selectedAddress?.id,
                  onChanged: (value) {
                    setState(() {
                      _selectedAddress = address;
                      _addressController.text =
                          '${address.street}, ${address.city}, ${address.state} ${address.zipCode}, ${address.country}';
                    });
                    Navigator.pop(context);
                  },
                ),
                title: Text(address.name),
                subtitle: Text('${address.street}, ${address.city}'),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL'),
          ),
        ],
      ),
    );
  }

  void _placeOrder() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final cart = context.read<CartProvider>();
      final orders = context.read<OrdersProvider>();

      orders.addOrder(
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
      );

      cart.clearCart();

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) =>
              const OrderSuccessScreen(), // ✅ GO TO success screen
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to place order: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Text('Order Summary',
                  style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 12),
              ...cart.items.values.map((item) => ListTile(
                    title: Text(item.product.name),
                    subtitle: Text('Qty: ${item.quantity}'),
                    trailing: Text('TZS${item.total.toStringAsFixed(2)}'),
                  )),
              const Divider(),
              ListTile(
                title: const Text('Total',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                trailing: Text('TZS${cart.total.toStringAsFixed(2)}',
                    style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 24),
              Text('Delivery Info',
                  style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 12),
              TextFormField(
                controller: _addressController,
                readOnly: true,
                decoration: InputDecoration(
                  labelText: 'Address',
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.edit_location_alt),
                    onPressed: _selectAddress,
                  ),
                  border: const OutlineInputBorder(),
                ),
                validator: (value) => (value == null || value.isEmpty)
                    ? 'Please select address'
                    : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    (value == null || value.isEmpty) ? 'Phone required' : null,
              ),
              const SizedBox(height: 24),
              Text('Payment Method',
                  style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 8),
              RadioListTile(
                title: const Text('Cash on Delivery'),
                value: 'Cash',
                groupValue: _paymentMethod,
                onChanged: (value) {
                  setState(() => _paymentMethod = value.toString());
                },
              ),
              RadioListTile(
                title: const Text('Credit Card'),
                value: 'Card',
                groupValue: _paymentMethod,
                onChanged: (value) {
                  setState(() => _paymentMethod = value.toString());
                },
              ),
              const SizedBox(height: 24),
              LoadingButton(
                text: 'PLACE ORDER',
                isLoading: _isLoading,
                onPressed: _placeOrder,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
