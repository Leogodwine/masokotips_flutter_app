import 'package:flutter/material.dart';
import '../../models/service.dart';
import '../../services/service_service.dart';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../../utils/image_upload_helper.dart';

class EditServiceScreen extends StatefulWidget {
  final Service service;
  final Function(Service) onServiceUpdated;
  final ServiceService serviceService;

  const EditServiceScreen({
    super.key,
    required this.service,
    required this.onServiceUpdated,
    required this.serviceService,
  });

  @override
  State<EditServiceScreen> createState() => _EditServiceScreenState();
}

class _EditServiceScreenState extends State<EditServiceScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _priceController;
  late final TextEditingController _categoryController;
  late final TextEditingController _subcategoryController;
  File? _imageFile;
  bool _isLoading = false;
  String? _error;

  // Service categories with their IDs
  final Map<int, String> _categories = {
    1: 'Buyers & Sellers',
    2: 'Transport',
    3: 'Services',
    4: 'Organic Products',
    5: 'Other Services',
  };

  String? _selectedSubcategory;
  int _selectedCategoryId = 1;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.service.title);
    _descriptionController =
        TextEditingController(text: widget.service.description);
    _priceController =
        TextEditingController(text: widget.service.price.toString());
    _categoryController =
        TextEditingController(text: widget.service.categoryId.toString());
    _subcategoryController =
        TextEditingController(text: widget.service.subcategory ?? '');
    _selectedCategoryId = widget.service.categoryId;
    _selectedSubcategory = widget.service.subcategory;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _categoryController.dispose();
    _subcategoryController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final imageFile = await ImageUploadHelper.pickImage();

    if (imageFile != null) {
      setState(() {
        _imageFile = kIsWeb ? null : File(imageFile.path);
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
        String? imageUrl;
        if (_imageFile != null) {
          // Log the image file details for debugging
          print('Image file path: ${_imageFile!.path}');
          print('Current service ID: ${widget.service.id}');

          if (kIsWeb) {
            print('Web environment detected for image upload');
            if (_imageFile!.path.startsWith('blob:')) {
              print('Blob URL detected: ${_imageFile!.path}');
            }
          } else {
            print('Image file exists: ${await _imageFile!.exists()}');
            print('Image file size: ${await _imageFile!.length()} bytes');
          }

          // First check if we need to update an existing service or create a new one
          String serviceId;
          bool isNewService = false;

          // For new services or temporary ones, create a service first to get a valid ID
          if (widget.service.id <= 0) {
            isNewService = true;
            print('Creating new service to get valid ID');

            try {
              // Create a service first without image
              final tempService = await widget.serviceService.addService(
                title: _titleController.text,
                description: _descriptionController.text,
                price: double.parse(_priceController.text),
                categoryId: _selectedCategoryId,
                subcategory: _selectedSubcategory,
              );

              serviceId = tempService.id.toString();
              print('Successfully created service with ID: $serviceId');
            } catch (e) {
              print('Error creating service: $e');
              setState(() {
                _error = 'Failed to create service: $e';
                _isLoading = false;
              });
              return;
            }
          } else {
            // For existing services, use the actual ID
            serviceId = widget.service.id.toString();
            print('Using existing service ID: $serviceId');
          }

          try {
            imageUrl = await widget.serviceService.uploadServiceImage(
              serviceId,
              _imageFile!.path,
            );
            print('Image uploaded successfully: $imageUrl');
          } catch (uploadError) {
            print('Error uploading image: $uploadError');
            setState(() {
              _error = 'Failed to upload image: $uploadError';
              _isLoading = false;
            });
            return;
          }

          // If this is a newly created service, we already have it created
          if (isNewService) {
            try {
              // Just update with the image URL
              final updatedService = await widget.serviceService.updateService(
                id: serviceId,
                title: _titleController.text,
                description: _descriptionController.text,
                price: double.parse(_priceController.text),
                categoryId: _selectedCategoryId,
                imageUrl: imageUrl,
                subcategory: _selectedSubcategory,
              );

              widget.onServiceUpdated(updatedService);
              if (mounted) {
                Navigator.pop(context);
              }
              return;
            } catch (e) {
              print('Error updating new service with image: $e');
              setState(() {
                _error = 'Failed to update service with image: $e';
                _isLoading = false;
              });
              return;
            }
          }
        }

        // Standard update for existing service or no image case
        final updatedService = await widget.serviceService.updateService(
          id: widget.service.id.toString(),
          title: _titleController.text,
          description: _descriptionController.text,
          price: double.parse(_priceController.text),
          categoryId: _selectedCategoryId,
          imageUrl: imageUrl ?? widget.service.imageUrl,
          subcategory: _selectedSubcategory,
        );

        widget.onServiceUpdated(updatedService);

        if (mounted) {
          Navigator.pop(context);
        }
      } catch (e) {
        print('Error updating service: $e');
        setState(() {
          _error = e.toString();
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
        title: const Text('Edit Service'),
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
                  prefixText: 'TZS ',
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
              DropdownButtonFormField<int>(
                value: _selectedCategoryId,
                decoration: const InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(),
                ),
                items: _categories.entries.map((entry) {
                  return DropdownMenuItem(
                    value: entry.key,
                    child: Text(entry.value),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCategoryId = value!;
                    _selectedSubcategory = null;
                    _subcategoryController.clear();
                  });
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _subcategoryController,
                decoration: const InputDecoration(
                  labelText: 'Subcategory (Optional)',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  setState(() {
                    _selectedSubcategory = value;
                  });
                },
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _pickImage,
                icon: const Icon(Icons.image),
                label: const Text('Change Service Image'),
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
                        : Image.file(
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
                                  child: Icon(Icons.error_outline, size: 48),
                                ),
                              );
                            },
                          ),
                  ),
                )
              else if (widget.service.imageUrl != null)
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      widget.service.imageUrl!,
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
                    ),
                  ),
                ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _submitForm,
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : const Text('Update Service'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
