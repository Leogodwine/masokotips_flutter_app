import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/transport.dart';
import '../../providers/admin_provider.dart';

class TransportFormScreen extends StatefulWidget {
  final Transport? transport;

  const TransportFormScreen({Key? key, this.transport}) : super(key: key);

  @override
  State<TransportFormScreen> createState() => _TransportFormScreenState();
}

class _TransportFormScreenState extends State<TransportFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _locationController;
  late TextEditingController _typeController;
  late TextEditingController _priceController;
  late TextEditingController _capacityController;
  late TextEditingController _temperatureController;
  late TextEditingController _driverNameController;
  late TextEditingController _driverPhoneController;
  late TextEditingController _ownerNameController;
  late TextEditingController _insuranceDetailsController;

  bool _isTemperatureControlled = false;
  bool _hasInsurance = false;
  String _status = 'active';
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
    _descriptionController =
        TextEditingController(text: widget.transport?.description ?? '');
    _locationController =
        TextEditingController(text: widget.transport?.vehicleLocation ?? '');
    _typeController =
        TextEditingController(text: widget.transport?.vehicleType ?? '');
    _priceController =
        TextEditingController(text: widget.transport?.price.toString() ?? '');
    _capacityController = TextEditingController(
        text: widget.transport?.capacity.toString() ?? '');
    _temperatureController = TextEditingController(
        text: widget.transport?.temperatureRange.toString() ?? '');
    _driverNameController =
        TextEditingController(text: widget.transport?.driverName ?? '');
    _driverPhoneController =
        TextEditingController(text: widget.transport?.driverPhone ?? '');
    _ownerNameController =
        TextEditingController(text: widget.transport?.ownerName ?? '');
    _insuranceDetailsController =
        TextEditingController(text: widget.transport?.insuranceDetails ?? '');

    _isTemperatureControlled =
        widget.transport?.isTemperatureControlled ?? false;
    _hasInsurance = widget.transport?.hasInsurance ?? false;
    _status = widget.transport?.status ?? 'active';
    _selectedProductTypes = widget.transport?.supportedProductTypes ?? [];
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _typeController.dispose();
    _priceController.dispose();
    _capacityController.dispose();
    _temperatureController.dispose();
    _driverNameController.dispose();
    _driverPhoneController.dispose();
    _ownerNameController.dispose();
    _insuranceDetailsController.dispose();
    super.dispose();
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
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _locationController,
              decoration: const InputDecoration(
                labelText: 'Location',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a location';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _typeController,
              decoration: const InputDecoration(
                labelText: 'Vehicle Type',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a vehicle type';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _priceController,
              decoration: const InputDecoration(
                labelText: 'Price (TZS)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a price';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _capacityController,
              decoration: const InputDecoration(
                labelText: 'Capacity (kg)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a capacity';
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
            if (_isTemperatureControlled) ...[
              const SizedBox(height: 8),
              TextFormField(
                controller: _temperatureController,
                decoration: const InputDecoration(
                  labelText: 'Temperature Range (°C)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (_isTemperatureControlled &&
                      (value == null || value.isEmpty)) {
                    return 'Please enter a temperature range';
                  }
                  return null;
                },
              ),
            ],
            const SizedBox(height: 16),
            const Text(
              'Supported Product Types',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _productTypes.map((type) {
                final isSelected = _selectedProductTypes.contains(type);
                return FilterChip(
                  label: Text(type),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _selectedProductTypes.add(type);
                      } else {
                        _selectedProductTypes.remove(type);
                      }
                    });
                  },
                  backgroundColor: Colors.grey[200],
                  selectedColor: Colors.green,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : Colors.black,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _driverNameController,
              decoration: const InputDecoration(
                labelText: 'Driver Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _driverPhoneController,
              decoration: const InputDecoration(
                labelText: 'Driver Phone',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _ownerNameController,
              decoration: const InputDecoration(
                labelText: 'Owner Name',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter an owner name';
                }
                return null;
              },
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
              const SizedBox(height: 8),
              TextFormField(
                controller: _insuranceDetailsController,
                decoration: const InputDecoration(
                  labelText: 'Insurance Details',
                  border: OutlineInputBorder(),
                ),
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
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _submitForm,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Text(
                  widget.transport == null
                      ? 'Add Transport'
                      : 'Update Transport',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final adminProvider = context.read<AdminProvider>();
      final navigator = Navigator.of(context);
      final scaffoldMessenger = ScaffoldMessenger.of(context);

      final transport = Transport(
        id: widget.transport?.id,
        title: _titleController.text,
        description: _descriptionController.text,
        vehicleLocation: _locationController.text,
        vehicleType: _typeController.text,
        price: double.tryParse(_priceController.text) ?? 0.0,
        capacity: double.tryParse(_capacityController.text) ?? 0.0,
        isTemperatureControlled: _isTemperatureControlled,
        temperatureRange: _isTemperatureControlled
            ? double.tryParse(_temperatureController.text)
            : null,
        supportedProductTypes: _selectedProductTypes,
        driverName: _driverNameController.text,
        driverPhone: _driverPhoneController.text,
        ownerName: _ownerNameController.text,
        hasInsurance: _hasInsurance,
        insuranceDetails: _insuranceDetailsController.text,
        status: _status,
      );

      final success = widget.transport == null
          ? await adminProvider.createTransport(transport)
          : await adminProvider.updateTransport(transport);

      if (success && mounted) {
        navigator.pop(context);
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text(
              widget.transport == null
                  ? 'Transport added successfully'
                  : 'Transport updated successfully',
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }
}
