import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/transport.dart';
import '../../providers/transport_provider.dart';

class TransportFormScreen extends StatefulWidget {
  final Transport? transport;

  const TransportFormScreen({
    Key? key,
    this.transport,
  }) : super(key: key);

  @override
  State<TransportFormScreen> createState() => _TransportFormScreenState();
}

class _TransportFormScreenState extends State<TransportFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _vehicleLocationController;
  late TextEditingController _priceController;
  late TextEditingController _vehicleTypeController;
  late TextEditingController _amenitiesController;
  late TextEditingController _capacityController;
  late TextEditingController _insuranceDetailsController;
  String _status = 'active';
  bool _isTemperatureControlled = false;
  bool _hasInsurance = false;
  List<String> _selectedProductTypes = [];
  final List<String> _productTypes = [
    'Grains',
    'Vegetables',
    'Fruits',
    'Livestock',
    'Dairy',
    'Other'
  ];

  @override
  void initState() {
    super.initState();
    _titleController =
        TextEditingController(text: widget.transport?.title ?? '');
    _vehicleLocationController =
        TextEditingController(text: widget.transport?.vehicleLocation ?? '');
    _priceController =
        TextEditingController(text: widget.transport?.price.toString() ?? '');
    _vehicleTypeController =
        TextEditingController(text: widget.transport?.vehicleType ?? '');
    _amenitiesController = TextEditingController(
      text: widget.transport?.amenities?.join(', ') ?? '',
    );
    _capacityController = TextEditingController(
      text: widget.transport?.capacity.toString() ?? '',
    );
    _insuranceDetailsController = TextEditingController(
      text: widget.transport?.insuranceDetails ?? '',
    );
    _status = widget.transport?.status ?? 'active';
    _isTemperatureControlled =
        widget.transport?.isTemperatureControlled ?? false;
    _hasInsurance = widget.transport?.hasInsurance ?? false;
    _selectedProductTypes = widget.transport?.supportedProductTypes ?? [];
  }

  @override
  void dispose() {
    _titleController.dispose();
    _vehicleLocationController.dispose();
    _priceController.dispose();
    _vehicleTypeController.dispose();
    _amenitiesController.dispose();
    _capacityController.dispose();
    _insuranceDetailsController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    final amenities = _amenitiesController.text
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    try {
      if (widget.transport == null) {
        await context.read<TransportProvider>().addTransport(
              title: _titleController.text,
              description: _titleController.text,
              vehicleLocation: _vehicleLocationController.text,
              vehicleType: _vehicleTypeController.text,
              price: double.parse(_priceController.text),
              capacity: double.parse(_capacityController.text),
              isTemperatureControlled: _isTemperatureControlled,
              supportedProductTypes: _selectedProductTypes,
              hasInsurance: _hasInsurance,
              insuranceDetails: _insuranceDetailsController.text,
              amenities: amenities,
              status: _status,
              ownerName: _titleController.text,
              driverName: _titleController.text,
              driverPhone: '',
            );
      } else {
        final updatedTransport = widget.transport!.copyWith(
          title: _titleController.text,
          vehicleLocation: _vehicleLocationController.text,
          vehicleType: _vehicleTypeController.text,
          price: double.parse(_priceController.text),
          capacity: double.parse(_capacityController.text),
          isTemperatureControlled: _isTemperatureControlled,
          supportedProductTypes: _selectedProductTypes,
          hasInsurance: _hasInsurance,
          insuranceDetails: _insuranceDetailsController.text,
          amenities: amenities,
          status: _status,
        );
        await context
            .read<TransportProvider>()
            .updateTransport(updatedTransport);
      }

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving transport: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            Text(widget.transport == null ? 'Add Transport' : 'Edit Transport'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a title';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _vehicleLocationController,
              decoration: const InputDecoration(
                labelText: 'Vehicle Location',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter the vehicle location';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _priceController,
              decoration: const InputDecoration(
                labelText: 'Price',
                border: OutlineInputBorder(),
                prefixText: '\$',
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a price';
                }
                if (double.tryParse(value) == null) {
                  return 'Please enter a valid price';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _vehicleTypeController,
              decoration: const InputDecoration(
                labelText: 'Vehicle Type',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter the vehicle type';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _amenitiesController,
              decoration: const InputDecoration(
                labelText: 'Amenities (comma-separated)',
                border: OutlineInputBorder(),
                hintText: 'e.g., WiFi, AC, USB Ports',
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _capacityController,
              decoration: const InputDecoration(
                labelText: 'Capacity (tons)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter capacity';
                }
                if (double.tryParse(value) == null) {
                  return 'Please enter a valid capacity';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Temperature Controlled'),
              value: _isTemperatureControlled,
              onChanged: (value) {
                setState(() {
                  _isTemperatureControlled = value;
                });
              },
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              children: _productTypes.map((type) {
                return FilterChip(
                  label: Text(type),
                  selected: _selectedProductTypes.contains(type),
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _selectedProductTypes.add(type);
                      } else {
                        _selectedProductTypes.remove(type);
                      }
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Has Insurance'),
              value: _hasInsurance,
              onChanged: (value) {
                setState(() {
                  _hasInsurance = value;
                });
              },
            ),
            if (_hasInsurance) ...[
              const SizedBox(height: 16),
              TextFormField(
                controller: _insuranceDetailsController,
                decoration: const InputDecoration(
                  labelText: 'Insurance Details',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
            ],
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _status,
              decoration: const InputDecoration(
                labelText: 'Status',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(
                  value: 'active',
                  child: Text('Active'),
                ),
                DropdownMenuItem(
                  value: 'inactive',
                  child: Text('Inactive'),
                ),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _status = value;
                  });
                }
              },
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _submitForm,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text(
                widget.transport == null ? 'Add Transport' : 'Update Transport',
                style: const TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
