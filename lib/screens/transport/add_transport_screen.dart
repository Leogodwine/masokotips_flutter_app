import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/transport_provider.dart';
import '../../providers/auth_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:typed_data';

class AddTransportScreen extends StatefulWidget {
  const AddTransportScreen({Key? key}) : super(key: key);

  @override
  State<AddTransportScreen> createState() => _AddTransportScreenState();
}

class _AddTransportScreenState extends State<AddTransportScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  final List<String> _amenities = [];
  final List<String> _productTypes = [
    'Grains',
    'Vegetables',
    'Fruits',
    'Livestock',
    'Dairy',
    'Other'
  ];
  final List<String> _vehicleTypes = [
    'Tandem',
    'Kirikuu',
    'FlatbedTrucks',
    'Tanker',
    'Refrigerator Truck',
    'Box Truck',
    'Liftgate Truck',
    'Van',
    'Container Hauler',
    'Pickups Trucks',
    'Fuso',
    'Semi Trailers',
    'Tracker Trailers',
    'Cargo'
  ];
  final List<String> _selectedProductTypes = [];
  String? _selectedVehicleType;
  final String _status = 'active';

  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _ownerNameController = TextEditingController();
  final _priceController = TextEditingController();
  final _pricePerKgController = TextEditingController();
  final _capacityController = TextEditingController();
  final _driverNameController = TextEditingController();
  final _driverPhoneController = TextEditingController();
  final _driverRatingController = TextEditingController();
  final _amenityController = TextEditingController();
  final _insuranceDetailsController = TextEditingController();
  final _vehicleLocationController = TextEditingController();
  bool _isTemperatureControlled = false;
  bool _hasInsurance = false;
  String? _temperatureRange;
  Uint8List? _selectedImageBytes;
  String? _selectedImageName;
  double? _latitude;
  double? _longitude;
  bool _isCapturingGps = false;

  @override
  void initState() {
    super.initState();
    // Initialize any necessary data after the widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        try {
          // Initialize TransportProvider with auth token
          final authProvider = context.read<AuthProvider>();
          final transportProvider = context.read<TransportProvider>();

          if (authProvider.token != null) {
            transportProvider.initialize(authProvider.token!);
          } else {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Please login to add a transport'),
                  backgroundColor: Colors.red,
                ),
              );
              Navigator.pop(context);
            }
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error initializing transport: $e'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      }
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _ownerNameController.dispose();
    _priceController.dispose();
    _pricePerKgController.dispose();
    _capacityController.dispose();
    _driverNameController.dispose();
    _driverPhoneController.dispose();
    _driverRatingController.dispose();
    _amenityController.dispose();
    _insuranceDetailsController.dispose();
    _vehicleLocationController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    // Capture context-dependent objects before async operation
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);

      if (image != null) {
        final bytes = await image.readAsBytes();
        setState(() {
          _selectedImageBytes = bytes;
          _selectedImageName = image.name;
        });
      }
    } catch (e) {
      if (mounted) {
        scaffoldMessenger.showSnackBar(
          SnackBar(content: Text('Error picking image: $e')),
        );
      }
    }
  }

  Future<void> _captureGps() async {
    setState(() => _isCapturingGps = true);
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Please enable location services'),
                backgroundColor: Colors.orange),
          );
        }
        return;
      }
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return;
      }
      if (permission == LocationPermission.deniedForever) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text(
                    'Location permission permanently denied. Enable in settings.'),
                backgroundColor: Colors.red),
          );
        }
        return;
      }
      final position = await Geolocator.getCurrentPosition();
      if (mounted) {
        setState(() {
          _latitude = position.latitude;
          _longitude = position.longitude;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'GPS captured: ${_latitude!.toStringAsFixed(5)}, ${_longitude!.toStringAsFixed(5)}'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Error capturing GPS: $e'),
              backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isCapturingGps = false);
    }
  }

  void _addAmenity() {
    if (_amenityController.text.isNotEmpty) {
      setState(() {
        _amenities.add(_amenityController.text);
        _amenityController.clear();
      });
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    // Add validation for supportedProductTypes
    if (_selectedProductTypes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one supported product type'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final authProvider = context.read<AuthProvider>();
    if (authProvider.token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please login to add a transport'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final transportProvider = context.read<TransportProvider>();

      // First create the transport
      final transport = await transportProvider.addTransport(
        title: _titleController.text,
        description: _descriptionController.text.trim(),
        vehicleLocation: _vehicleLocationController.text,
        vehicleType: _selectedVehicleType ?? '',
        price: _priceController.text.isNotEmpty ? double.parse(_priceController.text) : 0.0,
        capacity: double.parse(_capacityController.text),
        isTemperatureControlled: _isTemperatureControlled,
        temperatureRange:
            _temperatureRange != null ? double.parse(_temperatureRange!) : null,
        supportedProductTypes: _selectedProductTypes,
        hasInsurance: _hasInsurance,
        insuranceDetails: _insuranceDetailsController.text,
        amenities: _amenities,
        status: _status,
        imageUrl: null,
        ownerName: _ownerNameController.text,
        pricePerKg: _pricePerKgController.text.isNotEmpty
            ? double.parse(_pricePerKgController.text)
            : null,
        driverName: _driverNameController.text,
        driverPhone: _driverPhoneController.text,
        driverRating: _driverRatingController.text.isNotEmpty
            ? double.parse(_driverRatingController.text)
            : null,
        latitude: _latitude,
        longitude: _longitude,
      );

      // Then upload the image if selected
      if (_selectedImageBytes != null) {
        final imageUrl = await transportProvider.uploadTransportImage(
          transport.id.toString(),
          _selectedImageName!,
          _selectedImageBytes!,
        );

        // Update the transport with the image URL
        await transportProvider.updateTransport(
          transport.copyWith(imageUrl: imageUrl),
        );
      }

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error adding transport: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Transport'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: _titleController,
                      decoration: InputDecoration(
                        labelText: 'Title',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: Icon(Icons.title,
                            color: Theme.of(context).primaryColor),
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
                      decoration: InputDecoration(
                        labelText: 'Description',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: Icon(Icons.description,
                            color: Theme.of(context).primaryColor),
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
                      decoration: InputDecoration(
                        labelText: 'Vehicle Location',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: Icon(Icons.location_on,
                            color: Theme.of(context).primaryColor),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter the vehicle location';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    // GPS Location Capture
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                            color: _latitude != null
                                ? Colors.green
                                : Colors.grey.shade400),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      child: Row(
                        children: [
                          Icon(
                            _latitude != null
                                ? Icons.gps_fixed
                                : Icons.gps_not_fixed,
                            color: _latitude != null
                                ? Colors.green
                                : Colors.grey,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'GPS Location (for Map)',
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600]),
                                ),
                                Text(
                                  _latitude != null
                                      ? '${_latitude!.toStringAsFixed(5)}, ${_longitude!.toStringAsFixed(5)}'
                                      : 'Not captured yet',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: _latitude != null
                                        ? Colors.green[700]
                                        : Colors.grey[500],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          TextButton.icon(
                            onPressed:
                                _isCapturingGps ? null : _captureGps,
                            icon: _isCapturingGps
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2),
                                  )
                                : const Icon(Icons.my_location, size: 18),
                            label: Text(_latitude != null
                                ? 'Update'
                                : 'Use My Location'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      initialValue: _selectedVehicleType,
                      decoration: InputDecoration(
                        labelText: 'Vehicle Type',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: Icon(Icons.directions_car,
                            color: Theme.of(context).primaryColor),
                      ),
                      items: _vehicleTypes.map((type) {
                        return DropdownMenuItem(
                          value: type,
                          child: Text(type),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedVehicleType = value;
                        });
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'Please select a vehicle type';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _priceController,
                      decoration: InputDecoration(
                        labelText: 'Price (Optional)',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: Icon(Icons.attach_money,
                            color: Theme.of(context).primaryColor),
                        prefixText: 'TZS',
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value != null && value.isNotEmpty) {
                          if (double.tryParse(value) == null) {
                            return 'Please enter a valid number';
                          }
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _pricePerKgController,
                      decoration: InputDecoration(
                        labelText: 'Price per Kg (Optional)',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: Icon(Icons.monetization_on,
                            color: Theme.of(context).primaryColor),
                        prefixText: 'TZS',
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _capacityController,
                      decoration: InputDecoration(
                        labelText: 'Capacity (tons)',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: Icon(Icons.scale,
                            color: Theme.of(context).primaryColor),
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
                      decoration: InputDecoration(
                        labelText: 'Owner Name',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: Icon(Icons.person,
                            color: Theme.of(context).primaryColor),
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
                      decoration: InputDecoration(
                        labelText: 'Driver Name',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: Icon(Icons.drive_eta,
                            color: Theme.of(context).primaryColor),
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
                      decoration: InputDecoration(
                        labelText: 'Driver Phone',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: Icon(Icons.phone,
                            color: Theme.of(context).primaryColor),
                      ),
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter the driver phone number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _driverRatingController,
                      decoration: InputDecoration(
                        labelText: 'Driver Rating (Optional)',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: Icon(Icons.star,
                            color: Theme.of(context).primaryColor),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Supported Product Types:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    const SizedBox(height: 8),
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
                          backgroundColor:
                              Theme.of(context).primaryColor.withAlpha(51),
                          selectedColor:
                              Theme.of(context).primaryColor.withAlpha(51),
                          labelStyle: TextStyle(
                            color: _selectedProductTypes.contains(type)
                                ? Theme.of(context).primaryColor
                                : Colors.grey[700],
                          ),
                        );
                      }).toList(),
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
                      activeThumbColor: Theme.of(context).primaryColor,
                    ),
                    if (_isTemperatureControlled) ...[
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Temperature Range (°C)',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          prefixIcon: Icon(Icons.thermostat,
                              color: Theme.of(context).primaryColor),
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          _temperatureRange = value;
                        },
                      ),
                      const SizedBox(height: 16),
                    ],
                    SwitchListTile(
                      title: const Text('Has Insurance'),
                      value: _hasInsurance,
                      onChanged: (value) {
                        setState(() {
                          _hasInsurance = value;
                        });
                      },
                      activeThumbColor: Theme.of(context).primaryColor,
                    ),
                    if (_hasInsurance) ...[
                      TextFormField(
                        controller: _insuranceDetailsController,
                        decoration: InputDecoration(
                          labelText: 'Insurance Details',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          prefixIcon: Icon(Icons.security,
                              color: Theme.of(context).primaryColor),
                        ),
                        maxLines: 2,
                      ),
                      const SizedBox(height: 16),
                    ],
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _amenityController,
                            decoration: InputDecoration(
                              labelText: 'Add Amenity',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              prefixIcon: Icon(Icons.add_circle_outline,
                                  color: Theme.of(context).primaryColor),
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: _addAmenity,
                          icon: Icon(Icons.add,
                              color: Theme.of(context).primaryColor),
                        ),
                      ],
                    ),
                    if (_amenities.isNotEmpty) ...[
                      Wrap(
                        spacing: 8,
                        children: _amenities.map((amenity) {
                          return Chip(
                            label: Text(amenity),
                            onDeleted: () {
                              setState(() {
                                _amenities.remove(amenity);
                              });
                            },
                            backgroundColor:
                                Theme.of(context).primaryColor.withAlpha(26),
                            labelStyle: TextStyle(
                              color: Theme.of(context).primaryColor,
                            ),
                            deleteIcon: Icon(
                              Icons.close,
                              size: 16,
                              color: Theme.of(context).primaryColor,
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 16),
                    ],
                    ElevatedButton.icon(
                      onPressed: _pickImage,
                      icon: Icon(Icons.image,
                          color: Theme.of(context).primaryColor),
                      label: Text(
                        _selectedImageBytes == null
                            ? 'Add Vehicle Image'
                            : 'Change Vehicle Image',
                        style: TextStyle(color: Theme.of(context).primaryColor),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            Theme.of(context).primaryColor.withAlpha(51),
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    if (_selectedImageBytes != null) ...[
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.memory(
                          _selectedImageBytes!,
                          height: 200,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _submitForm,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                        ),
                        child: const Text(
                          'Add Transport',
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
