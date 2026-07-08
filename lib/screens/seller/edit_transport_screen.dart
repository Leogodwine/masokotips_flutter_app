import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:io';
import '../../models/transport.dart';
import '../../models/category.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';
import '../../config/api_config.dart';
import '../../utils/logger.dart';
import 'package:masoko_tips/l10n/app_localizations.dart';

class EditTransportScreen extends StatefulWidget {
  final Transport transport;
  final Function(Transport) onTransportUpdated;

  const EditTransportScreen({
    Key? key,
    required this.transport,
    required this.onTransportUpdated,
  }) : super(key: key);

  @override
  State<EditTransportScreen> createState() => _EditTransportScreenState();
}

class _EditTransportScreenState extends State<EditTransportScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _vehicleLocationController = TextEditingController();
  final _pricePerKmController = TextEditingController();
  final _capacityController = TextEditingController();
  final _contactPhoneController = TextEditingController();

  // Category-related fields
  List<Category> _categories = [];
  Category? _selectedCategory;
  bool _isLoadingCategories = false;

  String _selectedVehicleType = 'Truck';
  String _selectedStatus = 'Available';
  File? _selectedImage;
  bool _isLoading = false;
  ApiService? _apiService;
  double? _latitude;
  double? _longitude;
  bool _isCapturingGps = false;

  final List<String> _vehicleTypes = [
    'Truck',
    'Van',
    'Pickup',
    'Motorcycle',
    'Bicycle',
    'Cargo',
    'Other'
  ];

  final List<String> _statusOptions = ['Available', 'Busy', 'Maintenance'];

  @override
  void initState() {
    super.initState();
    _initializeApiService();
    _populateFields();
    _loadCategories();
  }

  void _initializeApiService() {
    final authProvider = context.read<AuthProvider>();
    Log.e('EditTransport - AuthProvider token: ${authProvider.token}');
    if (authProvider.token != null) {
      _apiService = ApiService(
        baseUrl: ApiConfig.baseUrl,
        apiKey: authProvider.token!,
      );
      Log.e(
          'EditTransport - ApiService initialized with token: ${authProvider.token}');
    } else {
      Log.e('EditTransport - No authentication token available');
    }
  }

  void _populateFields() {
    _titleController.text = widget.transport.title;
    _descriptionController.text = widget.transport.description ?? '';
    _vehicleLocationController.text = widget.transport.vehicleLocation;
    _pricePerKmController.text = widget.transport.price
        .toString(); // Fixed: use 'price' instead of 'pricePerKg'
    _capacityController.text = widget.transport.capacity.toString();
    _contactPhoneController.text = widget.transport.driverPhone ?? '';

    // Handle vehicle type - add to list if not present
    if (!_vehicleTypes.contains(widget.transport.vehicleType)) {
      _vehicleTypes.add(widget.transport.vehicleType);
    }
    _selectedVehicleType = widget.transport.vehicleType;

    // Handle status - add to list if not present
    if (!_statusOptions.contains(widget.transport.status)) {
      _statusOptions.add(widget.transport.status);
    }
    _selectedStatus = widget.transport.status;

    // Pre-fill existing GPS coordinates if available
    _latitude = widget.transport.latitude;
    _longitude = widget.transport.longitude;
  }

  Future<void> _loadCategories() async {
    if (_apiService == null) return;

    setState(() {
      _isLoadingCategories = true;
    });

    try {
      // Use getTransportSubcategories to fetch only Transport subcategories
      final categories = await _apiService!.getTransportSubcategories();
      setState(() {
        _categories = categories;

        // Find and set the current category from the list if possible
        if (widget.transport.categoryId != null) {
          try {
            _selectedCategory = categories.firstWhere(
              (cat) => cat.id == widget.transport.categoryId,
            );
          } catch (e) {
            Log.e('Category ID ${widget.transport.categoryId} not found in fetched list');
          }
        }
      });
      Log.e('EditTransport: Loaded ${categories.length} transport subcategories');
    } catch (e) {
      Log.e('Error loading transport subcategories: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingCategories = false;
        });
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

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 80,
    );

    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
      });
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    if (_apiService == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      String? imageUrl = widget.transport.imageUrl;

      // Upload new image if selected
      if (_selectedImage != null) {
        Log.e('Uploading new transport image...');
        final bytes = await _selectedImage!.readAsBytes();
        final filename = _selectedImage!.path.split('/').last.split('\\').last;
        final uploadResponse =
            await _apiService!.uploadTransportImage(bytes, filename);
        if (uploadResponse['success'] == true) {
          imageUrl = uploadResponse['data']['url'];
          Log.e('New image uploaded successfully: $imageUrl');
        }
      }

      // Update transport
      final transportData = {
        'title': _titleController.text.trim(),
        'description': _descriptionController.text.trim(),
        'vehicle_type': _selectedVehicleType,
        'vehicle_location': _vehicleLocationController.text.trim(),
        'price': double.parse(_pricePerKmController.text),
        'capacity': int.parse(_capacityController.text),
        'contact_phone': _contactPhoneController.text.trim(),
        'status': _selectedStatus.toLowerCase(),
        'image_url': imageUrl,
        'category_id': _selectedCategory?.id,
        if (_latitude != null) 'latitude': _latitude,
        if (_longitude != null) 'longitude': _longitude,
      };

      Log.e('Updating transport: $transportData');
      final response = await _apiService!
          .updateTransport(widget.transport.id!, transportData);

      if (response['success'] == true || response['data'] != null) {
        final transportData = response['data'] ?? response;
        final updatedTransport = Transport.fromJson(transportData);
        widget.onTransportUpdated(updatedTransport);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!.transportServiceUpdatedSuccessfully),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
        }
      } else {
        throw Exception(response['message'] ?? 'Failed to update transport');
      }
    } catch (e) {
      Log.e('Error updating transport: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update transport: $e'),
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.editTransportService),
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
              const SizedBox(height: 16),

              DropdownButtonFormField<String>(
                initialValue: _selectedVehicleType,
                decoration: InputDecoration(
                  labelText: 'Vehicle Type',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.category),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
                items: _vehicleTypes.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(type),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedVehicleType = value!;
                  });
                },
              ),
              const SizedBox(height: 16),

              // Transport Category Dropdown
              DropdownButtonFormField<Category>(
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
                        labelText: 'Price per KM',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixText: 'TZS ',
                        prefixIcon: const Icon(Icons.monetization_on),
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

              DropdownButtonFormField<String>(
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
                          'Update Transport Service',
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
            child: _selectedImage != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.file(
                      _selectedImage!,
                      fit: BoxFit.cover,
                    ),
                  )
                : widget.transport.imageUrl != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(
                          widget.transport.imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return _buildPlaceholderImage();
                          },
                        ),
                      )
                    : _buildPlaceholderImage(),
          ),
        ),
        if (widget.transport.imageUrl != null && _selectedImage == null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              'Tap to change image',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildPlaceholderImage() {
    return Column(
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
