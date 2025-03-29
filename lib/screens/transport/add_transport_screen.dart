import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/transport_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class AddTransportScreen extends StatefulWidget {
  const AddTransportScreen({Key? key}) : super(key: key);

  @override
  State<AddTransportScreen> createState() => _AddTransportScreenState();
}

class _AddTransportScreenState extends State<AddTransportScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  final List<XFile> _selectedImages = [];
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
    'Tracker Trailers'
  ];
  List<String> _selectedProductTypes = [];
  String? _selectedVehicleType;
  String _status = 'active';

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
  bool _isTemperatureControlled = false;
  bool _hasInsurance = false;
  bool _isAvailable = true;
  String? _temperatureRange;
  List<String>? _certifications;

  @override
  void initState() {
    super.initState();
    // Initialize any necessary data after the widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        try {
          // Any initialization can be done here
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
    super.dispose();
  }

  void _addAmenity() {
    if (_amenityController.text.isNotEmpty) {
      setState(() {
        _amenities.add(_amenityController.text);
        _amenityController.clear();
      });
    }
  }

  void _removeAmenity(String amenity) {
    setState(() {
      _amenities.remove(amenity);
    });
  }

  Future<void> _pickImages() async {
    try {
      final ImagePicker picker = ImagePicker();
      final List<XFile> images = await picker.pickMultiImage();

      if (images.isNotEmpty) {
        setState(() {
          _selectedImages.addAll(images);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking images: $e')),
        );
      }
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      String? imageUrl;
      if (_selectedImages.isNotEmpty) {
        // Upload the first image
        imageUrl = await context.read<TransportProvider>().uploadTransportImage(
              DateTime.now()
                  .millisecondsSinceEpoch
                  .toString(), // Temporary ID for new transport
              _selectedImages[0].path,
            );
      }

      final transport = await context.read<TransportProvider>().addTransport(
            title: _titleController.text,
            description: _descriptionController.text,
            fromLocation: '',
            toLocation: '',
            vehicleType: _selectedVehicleType!,
            departureTime: DateTime.now(),
            arrivalTime: DateTime.now(),
            price: double.parse(_priceController.text),
            capacity: double.parse(_capacityController.text),
            isTemperatureControlled: _isTemperatureControlled,
            temperatureRange: _temperatureRange != null
                ? double.tryParse(_temperatureRange!)
                : null,
            supportedProductTypes: _selectedProductTypes,
            driverId: '',
            driverRating: _driverRatingController.text.isNotEmpty
                ? double.tryParse(_driverRatingController.text)
                : null,
            hasInsurance: _hasInsurance,
            insuranceDetails: _insuranceDetailsController.text,
            certifications: _certifications != null
                ? {'certifications': _certifications}
                : null,
            amenities: _amenities,
            status: _status,
            imageUrl: imageUrl,
            ownerName: _ownerNameController.text,
            pricePerKg: _pricePerKgController.text.isNotEmpty
                ? double.tryParse(_pricePerKgController.text)
                : null,
            driverName: _driverNameController.text,
            driverPhone: _driverPhoneController.text,
          );

      if (mounted) {
        Navigator.pop(context, transport);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error adding transport: $e'),
            backgroundColor: Colors.red,
          ),
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
        title: const Text('Add New Vehicle'),
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Basic Information',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        labelText: 'Vehicle Name/Title',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.title),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a vehicle name';
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
                      controller: _ownerNameController,
                      decoration: const InputDecoration(
                        labelText: 'Owner Name',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.person),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter owner name';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Vehicle Details',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _selectedVehicleType,
                      decoration: const InputDecoration(
                        labelText: 'Vehicle Type',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.directions_car),
                      ),
                      items: _vehicleTypes.map((type) {
                        return DropdownMenuItem(
                          value: type,
                          child: Text(type),
                        );
                      }).toList(),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select a vehicle type';
                        }
                        return null;
                      },
                      onChanged: (value) {
                        setState(() {
                          _selectedVehicleType = value;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _capacityController,
                      decoration: const InputDecoration(
                        labelText: 'Volume Capacity (tons)',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.scale),
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
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Pricing',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _priceController,
                      decoration: const InputDecoration(
                        labelText: 'Daily Rate',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.attach_money),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a daily rate';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Please enter a valid rate';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _pricePerKgController,
                      decoration: const InputDecoration(
                        labelText: 'Price per kg',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.attach_money),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter price per kg';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Please enter a valid price';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Driver Information',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _driverNameController,
                      decoration: const InputDecoration(
                        labelText: 'Driver Name',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.person),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter driver name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _driverPhoneController,
                      decoration: const InputDecoration(
                        labelText: 'Driver Phone',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.phone),
                      ),
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter driver phone';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _driverRatingController,
                      decoration: const InputDecoration(
                        labelText: 'Driver Rating (0-5)',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.star),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter driver rating';
                        }
                        final rating = double.tryParse(value);
                        if (rating == null || rating < 0 || rating > 5) {
                          return 'Please enter a valid rating (0-5)';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Vehicle Images',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: _pickImages,
                    icon: const Icon(Icons.add_photo_alternate),
                    label: const Text('Add Images'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  if (_selectedImages.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 100,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _selectedImages.length,
                        itemBuilder: (context, index) {
                          return Stack(
                            children: [
                              Container(
                                margin: const EdgeInsets.only(right: 8),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.grey[300]!),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.file(
                                    File(_selectedImages[index].path),
                                    height: 100,
                                    width: 100,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              Positioned(
                                right: 0,
                                top: 0,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.red,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: IconButton(
                                    icon: const Icon(
                                      Icons.remove_circle,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _selectedImages.removeAt(index);
                                      });
                                    },
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Vehicle Features',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SwitchListTile(
                      title: const Text('Temperature Controlled'),
                      subtitle: const Text('For perishable goods'),
                      value: _isTemperatureControlled,
                      onChanged: (value) {
                        setState(() {
                          _isTemperatureControlled = value;
                        });
                      },
                    ),
                    const Divider(),
                    SwitchListTile(
                      title: const Text('Insurance Included'),
                      subtitle: const Text('Vehicle insurance coverage'),
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
                          labelText: 'Insurance Coverage Details',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.security),
                        ),
                        maxLines: 3,
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Product Types',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
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
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Additional Features',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _amenityController,
                            decoration: const InputDecoration(
                              labelText: 'Add Feature',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.add_circle_outline),
                            ),
                            onFieldSubmitted: (_) => _addAmenity(),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add_circle),
                          onPressed: _addAmenity,
                          color: Theme.of(context).primaryColor,
                        ),
                      ],
                    ),
                    if (_amenities.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _amenities
                            .map((amenity) => Chip(
                                  label: Text(amenity),
                                  onDeleted: () => _removeAmenity(amenity),
                                ))
                            .toList(),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Status',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SwitchListTile(
                      title: const Text('Available for Hire'),
                      subtitle: const Text('Vehicle is currently available'),
                      value: _isAvailable,
                      onChanged: (value) {
                        setState(() {
                          _isAvailable = value;
                          _status = value ? 'active' : 'inactive';
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isLoading ? null : _submitForm,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text(
                      'Add Vehicle',
                      style: TextStyle(fontSize: 18),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
