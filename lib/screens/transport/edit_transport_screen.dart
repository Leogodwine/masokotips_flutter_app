import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/transport.dart';
import '../../providers/transport_provider.dart';

class EditTransportScreen extends StatefulWidget {
  final Transport transport;

  const EditTransportScreen({
    Key? key,
    required this.transport,
  }) : super(key: key);

  @override
  State<EditTransportScreen> createState() => _EditTransportScreenState();
}

class _EditTransportScreenState extends State<EditTransportScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _vehicleLocationController;
  late TextEditingController _vehicleTypeController;
  late TextEditingController _priceController;
  late TextEditingController _capacityController;
  late TextEditingController _ownerNameController;
  late TextEditingController _driverNameController;
  late TextEditingController _driverPhoneController;
  late TextEditingController _pricePerKgController;
  late TextEditingController _insuranceDetailsController;
  late TextEditingController _temperatureRangeController;

  bool _isTemperatureControlled = false;
  bool _hasInsurance = false;
  List<String> _selectedProductTypes = [];
  List<String> _selectedAmenities = [];
  List<String> _selectedCertifications = [];

  final List<String> _productTypes = [
    'Grains',
    'Vegetables',
    'Fruits',
    'Livestock',
    'Dairy',
    'Other'
  ];

  final List<String> _amenities = [
    'GPS Tracking',
    'Temperature Control',
    'Loading Equipment',
    'Security System',
    'Cargo Insurance',
    '24/7 Support'
  ];

  final List<String> _certifications = [
    'ISO 9001',
    'HACCP',
    'Food Safety',
    'Transport License',
    'Insurance Certificate'
  ];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.transport.title);
    _descriptionController =
        TextEditingController(text: widget.transport.description);
    _vehicleLocationController =
        TextEditingController(text: widget.transport.vehicleLocation);
    _vehicleTypeController =
        TextEditingController(text: widget.transport.vehicleType);
    _priceController =
        TextEditingController(text: widget.transport.price.toString());
    _capacityController =
        TextEditingController(text: widget.transport.capacity.toString());
    _ownerNameController =
        TextEditingController(text: widget.transport.ownerName);
    _driverNameController =
        TextEditingController(text: widget.transport.driverName);
    _driverPhoneController =
        TextEditingController(text: widget.transport.driverPhone);
    _pricePerKgController = TextEditingController(
        text: widget.transport.pricePerKg?.toString() ?? '');
    _insuranceDetailsController =
        TextEditingController(text: widget.transport.insuranceDetails ?? '');
    _temperatureRangeController = TextEditingController(
        text: widget.transport.temperatureRange?.toString() ?? '');

    _isTemperatureControlled = widget.transport.isTemperatureControlled;
    _hasInsurance = widget.transport.hasInsurance;
    _selectedProductTypes =
        List<String>.from(widget.transport.supportedProductTypes);
    _selectedAmenities = List<String>.from(widget.transport.amenities ?? []);
    _selectedCertifications =
        List<String>.from(widget.transport.certifications ?? []);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _vehicleLocationController.dispose();
    _vehicleTypeController.dispose();
    _priceController.dispose();
    _capacityController.dispose();
    _ownerNameController.dispose();
    _driverNameController.dispose();
    _driverPhoneController.dispose();
    _pricePerKgController.dispose();
    _insuranceDetailsController.dispose();
    _temperatureRangeController.dispose();
    super.dispose();
  }

  Future<void> _saveTransport() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final updatedTransport = Transport(
        id: widget.transport.id,
        title: _titleController.text,
        description: _descriptionController.text,
        vehicleLocation: _vehicleLocationController.text,
        vehicleType: _vehicleTypeController.text,
        price: double.parse(_priceController.text),
        capacity: double.parse(_capacityController.text),
        isTemperatureControlled: _isTemperatureControlled,
        temperatureRange: _temperatureRangeController.text.isEmpty
            ? null
            : double.tryParse(_temperatureRangeController.text),
        supportedProductTypes: _selectedProductTypes,
        driverId: widget.transport.driverId,
        driverRating: widget.transport.driverRating,
        hasInsurance: _hasInsurance,
        insuranceDetails: _insuranceDetailsController.text.isEmpty
            ? null
            : _insuranceDetailsController.text,
        certifications:
            _selectedCertifications.isEmpty ? null : _selectedCertifications,
        amenities: _selectedAmenities.isEmpty ? null : _selectedAmenities,
        status: widget.transport.status,
        imageUrl: widget.transport.imageUrl,
        ownerName: _ownerNameController.text,
        pricePerKg: _pricePerKgController.text.isEmpty
            ? null
            : double.parse(_pricePerKgController.text),
        driverName: _driverNameController.text,
        driverPhone: _driverPhoneController.text,
        createdAt: widget.transport.createdAt,
        updatedAt: DateTime.now(),
      );

      await context.read<TransportProvider>().updateTransport(updatedTransport);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Transport updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating transport: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Transport'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  prefixIcon: Icon(Icons.title),
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
                  prefixIcon: Icon(Icons.description),
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _vehicleLocationController,
                decoration: const InputDecoration(
                  labelText: 'Vehicle Location',
                  prefixIcon: Icon(Icons.location_on),
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
                controller: _vehicleTypeController,
                decoration: const InputDecoration(
                  labelText: 'Vehicle Type',
                  prefixIcon: Icon(Icons.directions_car),
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
                controller: _priceController,
                decoration: const InputDecoration(
                  labelText: 'Price',
                  prefixIcon: Icon(Icons.attach_money),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a price';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _capacityController,
                decoration: const InputDecoration(
                  labelText: 'Capacity (tons)',
                  prefixIcon: Icon(Icons.scale),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the capacity';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _ownerNameController,
                decoration: const InputDecoration(
                  labelText: 'Owner Name',
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the owner name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _driverNameController,
                decoration: const InputDecoration(
                  labelText: 'Driver Name',
                  prefixIcon: Icon(Icons.drive_eta),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the driver name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _driverPhoneController,
                decoration: const InputDecoration(
                  labelText: 'Driver Phone',
                  prefixIcon: Icon(Icons.phone),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the driver phone number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _pricePerKgController,
                decoration: const InputDecoration(
                  labelText: 'Price per kg (optional)',
                  prefixIcon: Icon(Icons.attach_money),
                ),
                keyboardType: TextInputType.number,
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
                const SizedBox(height: 16),
                TextFormField(
                  controller: _temperatureRangeController,
                  decoration: const InputDecoration(
                    labelText: 'Temperature Range (e.g., 2-8°C)',
                    prefixIcon: Icon(Icons.thermostat),
                  ),
                ),
              ],
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
                    prefixIcon: Icon(Icons.security),
                  ),
                  maxLines: 2,
                ),
              ],
              const SizedBox(height: 16),
              const Text(
                'Supported Product Types',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
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
              const Text(
                'Amenities',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Wrap(
                spacing: 8,
                children: _amenities.map((amenity) {
                  return FilterChip(
                    label: Text(amenity),
                    selected: _selectedAmenities.contains(amenity),
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _selectedAmenities.add(amenity);
                        } else {
                          _selectedAmenities.remove(amenity);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              const Text(
                'Certifications',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Wrap(
                spacing: 8,
                children: _certifications.map((cert) {
                  return FilterChip(
                    label: Text(cert),
                    selected: _selectedCertifications.contains(cert),
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _selectedCertifications.add(cert);
                        } else {
                          _selectedCertifications.remove(cert);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveTransport,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Save Changes'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
