import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../utils/image_upload_helper.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:io';
import 'dart:typed_data';
import '../../models/transport.dart';
import '../../models/category.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';
import '../../config/api_config.dart';
import '../../utils/logger.dart';
import 'package:masoko_tips/l10n/app_localizations.dart';

class AddTransportScreen extends StatefulWidget {
  final Function(Transport) onTransportAdded;

  const AddTransportScreen({
    Key? key,
    required this.onTransportAdded,
  }) : super(key: key);

  @override
  State<AddTransportScreen> createState() => _AddTransportScreenState();
}

class _AddTransportScreenState extends State<AddTransportScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _vehicleLocationController = TextEditingController();
  final _pricePerKmController = TextEditingController();
  final _capacityController = TextEditingController();
  final _contactPhoneController = TextEditingController();
  final _ownerNameController = TextEditingController();
  final _driverNameController = TextEditingController();
  final _driverPhoneController = TextEditingController();
  String _selectedStatus = 'Active';
  File? _selectedImage;
  Uint8List? _selectedImageBytes;
  bool _isLoading = false;
  ApiService? _apiService;
  double? _latitude;
  double? _longitude;
  bool _isCapturingGps = false;

  // Category-related fields
  List<Category> _categories = [];
  Category? _selectedCategory;
  bool _isLoadingCategories = false;

  // Required boolean fields
  bool _isTemperatureControlled = false;
  bool _hasInsurance = false;

  final List<String> _statusOptions = ['Active', 'Inactive'];

  @override
  void initState() {
    super.initState();
    _initializeApiService();
    _loadCategories();
  }

  void _initializeApiService() {
    final authProvider = context.read<AuthProvider>();
    Log.e('AddTransport - AuthProvider token: ${authProvider.token}');
    if (authProvider.token != null) {
      _apiService = ApiService(
        baseUrl: ApiConfig.baseUrl,
        apiKey: authProvider.token!,
      );
      Log.e(
          'AddTransport - ApiService initialized with token: ${authProvider.token}');
    } else {
      Log.e('AddTransport - No authentication token available');
    }
  }

  Future<void> _loadCategories() async {
    if (_apiService == null) return;

    setState(() {
      _isLoadingCategories = true;
    });

    try {
      // Use getTransportSubcategories to fetch only Transport subcategories
      _categories = await _apiService!.getTransportSubcategories();
      Log.e('Loaded ${_categories.length} transport subcategories');
    } catch (e) {
      Log.e('Error loading transport subcategories: $e');
    } finally {
      setState(() {
        _isLoadingCategories = false;
      });
    }
  }

  Future<void> _pickImage() async {
    final XFile? image = await ImageUploadHelper.pickAndCropImage(
      context,
      source: ImageSource.gallery,
    );

    if (image != null) {
      final bytes = await image.readAsBytes();
      setState(() {
        _selectedImage = File(image.path);
        _selectedImageBytes = bytes;
      });
    }
  }

  Future<void> _captureGps() async {
    setState(() => _isCapturingGps = true);
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(AppLocalizations.of(context)!.pleaseEnableLocationServices),
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
            SnackBar(
                content: Text(AppLocalizations.of(context)!.locationPermissionPermanentlyDeniedEnableIn),
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

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    if (_apiService == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      String? imageUrl;

      // Upload image if selected
      if (_selectedImage != null) {
        Log.e('Uploading transport image...');
        Map<String, dynamic> uploadResponse;
        try {
          final bytes = _selectedImageBytes ?? await _selectedImage!.readAsBytes();
          final filename = _selectedImage!.path.split('/').last.split('\\').last;
          uploadResponse = await _apiService!.uploadTransportImage(bytes, filename);
        } catch (e) {
          Log.e('Image upload failed: $e');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Failed to upload image: $e'),
                backgroundColor: Colors.red,
              ),
            );
          }
          return;
        }
        if (uploadResponse['success'] == true) {
          final data = uploadResponse['data'];
          if (data is Map) {
            imageUrl = data['url'] as String?;
          }
          Log.e('Image uploaded successfully: $imageUrl');
        } else {
          final message = uploadResponse['message'] ?? 'Image upload failed';
          Log.e('Image upload unsuccessful: $message');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(message),
                backgroundColor: Colors.orange,
              ),
            );
          }
        }
      }

      // Create transport
      final transportData = {
        'title': _titleController.text.trim(),
        'description': _descriptionController.text.trim(),
        'vehicle_location': _vehicleLocationController.text.trim(),
        'price':
            double.parse(_pricePerKmController.text), // Backend expects 'price'
        'capacity': int.parse(_capacityController.text),
        'is_temperature_controlled': _isTemperatureControlled,
        'supported_product_types': ['General'], // Required array
        'has_insurance': _hasInsurance,
        'status': _selectedStatus.toLowerCase(), // 'active' or 'inactive'
        'owner_name': _ownerNameController.text.trim(),
        'driver_name': _driverNameController.text.trim(),
        'driver_phone': _driverPhoneController.text.trim(),
        'image_url': imageUrl,
        'category_id': _selectedCategory?.id,
        if (_latitude != null) 'latitude': _latitude,
        if (_longitude != null) 'longitude': _longitude,
      };

      Log.e('Creating transport: $transportData');
      final response = await _apiService!.createTransport(transportData);

      // Check if response has success field or if it's just the data
      if (response['success'] == true || response['data'] != null) {
        final transportData = response['data'] ?? response;
        final transport = Transport.fromJson(transportData);
        widget.onTransportAdded(transport);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!.transportServiceAddedSuccessfully),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
        }
      } else {
        throw Exception(response['message'] ?? 'Failed to create transport');
      }
    } catch (e) {
      Log.e('Error creating transport: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to add transport: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _vehicleLocationController.dispose();
    _pricePerKmController.dispose();
    _capacityController.dispose();
    _contactPhoneController.dispose();
    _ownerNameController.dispose();
    _driverNameController.dispose();
    _driverPhoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.addTransportService),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _submitForm,
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text(
                    'SAVE',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image Section
              _buildImageSection(),
              const SizedBox(height: 24),

              // Basic Information
              _buildSectionTitle('Basic Information'),
              const SizedBox(height: 16),

              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Service Title',
                  hintText: 'e.g., Reliable Delivery Truck',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.directions_car),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a service title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: 'Description',
                  hintText: 'Describe your transport service...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.description),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Vehicle Details
              _buildSectionTitle('Vehicle Details'),
              // Transport Category Dropdown
              DropdownButtonFormField<Category>(
                isExpanded: true,
                initialValue: _selectedCategory,
                decoration: InputDecoration(
                  labelText: 'Transport Category',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.local_shipping),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
                hint: Text(_isLoadingCategories
                    ? 'Loading categories...'
                    : 'Select a category'),
                items: _categories.map((category) {
                  return DropdownMenuItem<Category>(
                    value: category,
                    child: Text(category.name),
                  );
                }).toList(),
                onChanged: _isLoadingCategories
                    ? null
                    : (Category? value) {
                        setState(() {
                          _selectedCategory = value;
                        });
                      },
                validator: (value) {
                  if (value == null) {
                    return 'Please select a transport category';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _vehicleLocationController,
                decoration: InputDecoration(
                  labelText: 'Vehicle Location',
                  hintText: 'e.g., Dar es Salaam, Tanzania',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.location_on),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter vehicle location';
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(
                  children: [
                    Icon(
                      _latitude != null
                          ? Icons.gps_fixed
                          : Icons.gps_not_fixed,
                      color: _latitude != null ? Colors.green : Colors.grey,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'GPS Location (for Map)',
                            style: TextStyle(
                                fontSize: 12, color: Colors.grey[600]),
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
                      onPressed: _isCapturingGps ? null : _captureGps,
                      icon: _isCapturingGps
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child:
                                  CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.my_location, size: 18),
                      label: Text(
                          _latitude != null ? 'Update' : 'Use My Location'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _pricePerKmController,
                      decoration: InputDecoration(
                        labelText: 'Price per KG',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixText: 'TZS ',
                        filled: true,
                        fillColor: Colors.grey[50],
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Enter price';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Enter valid price';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _capacityController,
                      decoration: InputDecoration(
                        labelText: 'Capacity (kg)',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: const Icon(Icons.scale),
                        filled: true,
                        fillColor: Colors.grey[50],
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Enter capacity';
                        }
                        if (int.tryParse(value) == null) {
                          return 'Enter valid capacity';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Contact Information
              _buildSectionTitle('Contact Information'),
              const SizedBox(height: 16),

              TextFormField(
                controller: _contactPhoneController,
                decoration: InputDecoration(
                  labelText: 'Contact Phone',
                  hintText: 'e.g., +255 123 456 789',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.phone),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter contact phone';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Owner and Driver Information
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _ownerNameController,
                      decoration: InputDecoration(
                        labelText: 'Owner Name',
                        hintText: 'e.g., John Doe',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: const Icon(Icons.person),
                        filled: true,
                        fillColor: Colors.grey[50],
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Enter owner name';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _driverNameController,
                      decoration: InputDecoration(
                        labelText: 'Driver Name',
                        hintText: 'e.g., Jane Smith',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: const Icon(Icons.drive_eta),
                        filled: true,
                        fillColor: Colors.grey[50],
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Enter driver name';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _driverPhoneController,
                decoration: InputDecoration(
                  labelText: 'Driver Phone',
                  hintText: 'e.g., +255 987 654 321',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.phone_android),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter driver phone';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Service Options
              _buildSectionTitle('Service Options'),
              const SizedBox(height: 16),

              CheckboxListTile(
                title: Text(AppLocalizations.of(context)!.temperatureControlled),
                subtitle: Text(AppLocalizations.of(context)!.vehicleHasTemperatureControlForSensitive),
                value: _isTemperatureControlled,
                onChanged: (value) {
                  setState(() {
                    _isTemperatureControlled = value ?? false;
                  });
                },
                controlAffinity: ListTileControlAffinity.leading,
                activeColor: Theme.of(context).primaryColor,
              ),

              CheckboxListTile(
                title: Text(AppLocalizations.of(context)!.hasInsurance),
                subtitle:
                    Text(AppLocalizations.of(context)!.vehicleIsInsuredForCargoAnd),
                value: _hasInsurance,
                onChanged: (value) {
                  setState(() {
                    _hasInsurance = value ?? false;
                  });
                },
                controlAffinity: ListTileControlAffinity.leading,
                activeColor: Theme.of(context).primaryColor,
              ),
              const SizedBox(height: 16),

              DropdownButtonFormField<String>(
                isExpanded: true,
                initialValue: _selectedStatus,
                decoration: InputDecoration(
                  labelText: 'Status',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.info),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
                items: _statusOptions.map((status) {
                  return DropdownMenuItem(
                    value: status,
                    child: Text(status),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedStatus = value!;
                  });
                },
              ),
              const SizedBox(height: 32),

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Add Transport Service',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Service Image',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: _pickImage,
          child: Container(
            width: double.infinity,
            height: 200,
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.grey[300]!,
                width: 2,
                style: BorderStyle.solid,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: _selectedImageBytes != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.memory(
                      _selectedImageBytes!,
                      fit: BoxFit.cover,
                    ),
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.add_photo_alternate,
                        size: 50,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Tap to add image',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Recommended: 600x400px',
                        style: TextStyle(
                          color: Colors.grey[500],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }
}
