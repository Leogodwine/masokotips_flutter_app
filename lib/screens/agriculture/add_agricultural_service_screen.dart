import 'package:flutter/material.dart';
import '../../models/service.dart';
import '../../services/agriculture_service.dart';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../../utils/image_upload_helper.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

class AddAgriculturalServiceScreen extends StatefulWidget {
  final Function(Service) onServiceAdded;
  final AgricultureService agricultureService;

  const AddAgriculturalServiceScreen({
    super.key,
    required this.onServiceAdded,
    required this.agricultureService,
  });

  @override
  State<AddAgriculturalServiceScreen> createState() =>
      _AddAgriculturalServiceScreenState();
}

class _AddAgriculturalServiceScreenState
    extends State<AddAgriculturalServiceScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  File? _imageFile;
  bool _isLoading = false;
  String? _error;

  // Agricultural Services subcategories
  final List<String> _agriculturalSubcategories = [
    'Packaging Materials',
    'Hydroponics',
    'Fertilizer',
    'Organic Manure',
    'Machinery',
    'Beehive and Aquatic',
    'Food and Beverage',
    'Cold Rooms Services',
    'Machinery and Rental Services',
    'Agronomist Services',
    'Financial Services',
    'Irrigation Services',
    'Branding and Consultation Services'
  ];

  String? _selectedSubcategory;

  @override
  void initState() {
    super.initState();

    // Check if the agricultureService has an auth token
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (authProvider.isAuthenticated) {
        print('Setting auth token: ${authProvider.token!.substring(0, 10)}...');
        widget.agricultureService.setAuthToken(authProvider.token!);
      } else {
        print('Warning: No auth token available for service creation!');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Authentication error. Please login again.'),
            duration: Duration(seconds: 5),
          ),
        );
        // Navigate back to previous screen
        Navigator.pop(context);
      }
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final imageFile = await ImageUploadHelper.pickImage();

      if (imageFile != null) {
        setState(() {
          _imageFile = imageFile;
        });

        // Log image details for debugging
        if (kIsWeb) {
          print('Web image selected with path: ${_imageFile!.path}');
        } else {
          if (await _imageFile!.exists()) {
            print(
                'Mobile/desktop image exists with size: ${await _imageFile!.length()} bytes');
          } else {
            print(
                'Warning: Selected image file does not exist at path: ${_imageFile!.path}');
          }
        }
      }
    } catch (e) {
      print('Error picking image: $e');
      setState(() {
        _error = 'Error selecting image: $e';
      });
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      try {
        // Check auth status
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        if (authProvider.token == null || authProvider.token!.isEmpty) {
          print('Error: No auth token available!');
          setState(() {
            _error = 'Authentication error. Please login again.';
            _isLoading = false;
          });
          return;
        }

        // Ensure the service has the auth token
        widget.agricultureService.setAuthToken(authProvider.token!);
        print('Auth token set: ${authProvider.token!.substring(0, 10)}...');

        // Check API connection
        print('Checking API connection...');
        final isConnected = await widget.agricultureService.checkConnection();
        if (!isConnected) {
          print('Error: Cannot connect to API');
          setState(() {
            _error =
                'Cannot connect to the server. Please check your network connection.';
            _isLoading = false;
          });
          return;
        }
        print('API connection successful');

        // Prepare the data for the service
        final title = _titleController.text.trim();
        final description = _descriptionController.text.trim();
        final price = double.tryParse(_priceController.text) ?? 0.0;
        const categoryId = 6; // Agricultural Services category ID

        if (_selectedSubcategory == null || _selectedSubcategory!.isEmpty) {
          setState(() {
            _error = 'Please select a service type';
            _isLoading = false;
          });
          return;
        }

        print('Creating service with:');
        print('Title: $title');
        print('Description: $description');
        print('Price: $price');
        print('Category ID: $categoryId');
        print('Subcategory: $_selectedSubcategory');
        print('Base URL: ${widget.agricultureService.getBaseUrl}');

        // First, add service without image
        print('Creating service without image first');
        try {
          final newService =
              await widget.agricultureService.addAgriculturalService(
            title: title,
            description: description,
            price: price,
            subcategory: _selectedSubcategory,
          );

          print('Service created successfully with ID: ${newService.id}');

          // If there's an image, try to upload it and update the service
          if (_imageFile != null) {
            try {
              print('Now uploading image for service ID: ${newService.id}');
              final imageUrl = await widget.agricultureService
                  .uploadAgriculturalServiceImage(
                newService.id.toString(),
                _imageFile!.path,
              );

              print('Image uploaded successfully: $imageUrl');

              // Update the service with the image
              final updatedService =
                  await widget.agricultureService.updateAgriculturalService(
                id: newService.id.toString(),
                title: newService.title,
                description: newService.description,
                price: newService.price,
                categoryId: newService.categoryId,
                imageUrl: imageUrl,
                subcategory: newService.subcategory,
              );

              print('Service updated with image URL');
              widget.onServiceAdded(updatedService);
            } catch (imageError) {
              print('Warning: Failed to upload image: $imageError');
              // If image upload fails, we still created the service successfully
              // Just return the service without an image
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                      'Service created, but image upload failed: $imageError'),
                  duration: const Duration(seconds: 5),
                ),
              );
              widget.onServiceAdded(newService);
            }
          } else {
            // No image to upload
            widget.onServiceAdded(newService);
          }

          if (mounted) {
            Navigator.pop(context);
          }
        } catch (serviceError) {
          print('Error creating service: $serviceError');
          setState(() {
            _error = 'Failed to create service: $serviceError';
            _isLoading = false;
          });
        }
      } catch (e) {
        print('Error in form submission: $e');
        setState(() {
          _error = 'Form submission error: $e';
          _isLoading = false;
        });
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Agricultural Service'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (_error != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Text(
                    _error!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Service Title',
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
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a description';
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
              SizedBox(
                height: 60,
                child: DropdownButtonFormField<String>(
                  value: _selectedSubcategory,
                  decoration: const InputDecoration(
                    labelText: 'Agricultural Service Type',
                    border: OutlineInputBorder(),
                  ),
                  items: _agriculturalSubcategories.map((subcategory) {
                    return DropdownMenuItem(
                      value: subcategory,
                      child: Text(subcategory),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedSubcategory = value;
                    });
                  },
                  validator: (value) {
                    if (_selectedSubcategory == null ||
                        _selectedSubcategory!.isEmpty) {
                      return 'Please select a service type';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _pickImage,
                icon: const Icon(Icons.image),
                label: const Text('Add Service Image'),
              ),
              if (_imageFile != null)
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: kIsWeb
                        ? Image.network(
                            _imageFile!.path,
                            height: 200,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              print('Error loading image: $error');
                              return Container(
                                height: 200,
                                color: Colors.grey[300],
                                child: const Center(
                                  child: Icon(Icons.error_outline, size: 48),
                                ),
                              );
                            },
                          )
                        : FutureBuilder<bool>(
                            future: _imageFile!.exists(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return Container(
                                  height: 200,
                                  color: Colors.grey[300],
                                  child: const Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                );
                              }

                              if (snapshot.hasError || !snapshot.data!) {
                                return Container(
                                  height: 200,
                                  color: Colors.grey[300],
                                  child: const Center(
                                    child: Icon(Icons.error_outline, size: 48),
                                  ),
                                );
                              }

                              return Image.file(
                                _imageFile!,
                                height: 200,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  print('Error loading image: $error');
                                  return Container(
                                    height: 200,
                                    color: Colors.grey[300],
                                    child: const Center(
                                      child:
                                          Icon(Icons.error_outline, size: 48),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                  ),
                ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _submitForm,
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : const Text('Add Service'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
