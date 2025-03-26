import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/orders_provider.dart';
import '../../models/address.dart';
import '../../models/cart_item.dart' as models;
import '../profile/address_management_screen.dart';
import '../../widgets/loading_button.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  String _paymentMethod = 'Cash';
  bool _isLoading = false;
  Address? _selectedAddress;
  List<Address> _addresses = [];

  @override
  void initState() {
    super.initState();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.user;
    if (user != null) {
      _nameController.text = user.name;
      _emailController.text = user.email;
      // Load user's saved addresses
      _loadSavedAddresses();
    }
  }

  Future<void> _loadSavedAddresses() async {
    // In a real app, this would load from API
    // For now, we'll use mock data
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

      // Set default address if available
      final defaultAddress = _addresses.firstWhere(
        (address) => address.isDefault,
        orElse: () => _addresses.isNotEmpty
            ? _addresses.first
            : Address(
                id: '0',
                name: '',
                street: '',
                city: '',
                state: '',
                zipCode: '',
                country: '',
                isDefault: false,
              ),
      );

      if (defaultAddress.id != '0') {
        _selectedAddress = defaultAddress;
        _addressController.text =
            '${defaultAddress.street}, ${defaultAddress.city}, ${defaultAddress.state} ${defaultAddress.zipCode}, ${defaultAddress.country}';
      }
    });
  }

  void _selectAddress() async {
    if (_addresses.isEmpty) {
      // If no addresses, go directly to add new address
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const AddressManagementScreen(),
        ),
      );
      // Reload addresses after returning
      _loadSavedAddresses();
      return;
    }

    // Show address selection dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Delivery Address'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: _addresses.length + 1, // +1 for "Add new address" option
            itemBuilder: (context, index) {
              if (index == _addresses.length) {
                // Last item is "Add new address"
                return ListTile(
                  leading: const Icon(Icons.add_circle_outline),
                  title: const Text('Add New Address'),
                  onTap: () {
                    Navigator.pop(context); // Close dialog
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AddressManagementScreen(),
                      ),
                    ).then((_) =>
                        _loadSavedAddresses()); // Reload addresses after returning
                  },
                );
              }

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
                onTap: () {
                  setState(() {
                    _selectedAddress = address;
                    _addressController.text =
                        '${address.street}, ${address.city}, ${address.state} ${address.zipCode}, ${address.country}';
                  });
                  Navigator.pop(context);
                },
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

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Text(
                'Order Summary',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),
              ...cart.items.values.map(
                (item) => ListTile(
                  title: Text(item.product.name),
                  subtitle: Text('Quantity: ${item.quantity}'),
                  trailing: Text('\$${item.total.toStringAsFixed(2)}'),
                ),
              ),
              const Divider(),
              ListTile(
                title: const Text(
                  'Total Amount',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                trailing: Text(
                  '\$${cart.total.toStringAsFixed(2)}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Delivery Information',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _addressController,
                readOnly:
                    true, // Make it read-only since we'll use the address selection
                decoration: InputDecoration(
                  labelText: 'Delivery Address',
                  prefixIcon: const Icon(Icons.location_on),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.list_alt),
                    tooltip: 'Select from saved addresses',
                    onPressed: _selectAddress,
                  ),
                  border: const OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your delivery address';
                  }
                  return null;
                },
                onTap: _selectAddress, // Show selection when field is tapped
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your phone number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              Text(
                'Payment Method',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              RadioListTile(
                title: const Text('Cash on Delivery'),
                value: 'Cash',
                groupValue: _paymentMethod,
                onChanged: (value) {
                  setState(() {
                    _paymentMethod = value.toString();
                  });
                },
              ),
              RadioListTile(
                title: const Text('Credit Card'),
                value: 'Card',
                groupValue: _paymentMethod,
                onChanged: (value) {
                  setState(() {
                    _paymentMethod = value.toString();
                  });
                },
              ),
              const SizedBox(height: 24),
              LoadingButton(
                isLoading: _isLoading,
                text: 'PLACE ORDER',
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    setState(() {
                      _isLoading = true;
                    });

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

                      Navigator.of(context).popUntil((route) => route.isFirst);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Order placed successfully!'),
                          backgroundColor: Colors.green,
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
                      setState(() {
                        _isLoading = false;
                      });
                    }
                  }
                },
                height: 56,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }
}
