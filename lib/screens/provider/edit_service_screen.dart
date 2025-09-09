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
  File? _imageFile;
  bool _isLoading = false;
  String? _error;

  int? _selectedCategoryId;
  List<dynamic> _agriculturalCategories = [];
  bool _isLoadingCategories = false;

  @override
  void initState() {
    super.initState();
    debugPrint('EditServiceScreen: Service ID: ${widget.service.id}');
    debugPrint('EditServiceScreen: Service title: ${widget.service.title}');
    debugPrint(
        'EditServiceScreen: Service categoryId: ${widget.service.categoryId}');

    _titleController = TextEditingController(text: widget.service.title);
    _descriptionController =
        TextEditingController(text: widget.service.description);
    _priceController =
        TextEditingController(text: widget.service.price.toStringAsFixed(2));
    _categoryController =
        TextEditingController(text: widget.service.categoryId.toString());
    _selectedCategoryId = widget.service.categoryId;
    _loadAgriculturalCategories();
  }

  Future<void> _loadAgriculturalCategories() async {
    setState(() {
      _isLoadingCategories = true;
    });

    try {
      final categories =
          await widget.serviceService.getAgriculturalServiceCategories();

      // Remove duplicates based on ID
      final uniqueCategories = <int, dynamic>{};
      for (final category in categories) {
        uniqueCategories[category.id] = category;
      }

      setState(() {
        _agriculturalCategories = uniqueCategories.values.toList();

        debugPrint(
            'EditServiceScreen: Loaded ${_agriculturalCategories.length} categories');
        debugPrint(
            'EditServiceScreen: Category IDs: ${_agriculturalCategories.map((c) => c.id).toList()}');
        debugPrint(
            'EditServiceScreen: Selected category ID: $_selectedCategoryId');

        // Set the category ID from the existing service
        _selectedCategoryId ??= widget.service.categoryId;
      });
    } catch (e) {
      debugPrint('Error loading agricultural categories: $e');
    } finally {
      setState(() {
        _isLoadingCategories = false;
      });
    }
  }

  List<DropdownMenuItem<int>> _getUniqueDropdownItems() {
    // Create a map to track unique categories by ID
    final Map<int, dynamic> uniqueCategories = {};

    for (final category in _agriculturalCategories) {
      if (category.id != null) {
        uniqueCategories[category.id] = category;
      }
    }

    // Convert to dropdown items and ensure no duplicates
    final List<DropdownMenuItem<int>> items = [];
    final Set<int> usedValues = {};

    for (final category in uniqueCategories.values) {
      if (category.id != null && !usedValues.contains(category.id)) {
        usedValues.add(category.id);
        items.add(DropdownMenuItem<int>(
          value: category.id,
          child: Text(category.name),
        ));
      }
    }

    debugPrint(
        'EditServiceScreen: Generated ${items.length} unique dropdown items');
    debugPrint(
        'EditServiceScreen: Values: ${items.map((item) => item.value).toList()}');

    return items;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _categoryController.dispose();
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
          debugPrint('Image file path: ${_imageFile!.path}');
          debugPrint('Current service ID: ${widget.service.id}');

          if (kIsWeb) {
            debugPrint('Web environment detected for image upload');
            if (_imageFile!.path.startsWith('blob:')) {
              debugPrint('Blob URL detected: ${_imageFile!.path}');
            }
          } else {
            debugPrint('Image file exists: ${await _imageFile!.exists()}');
            debugPrint('Image file size: ${await _imageFile!.length()} bytes');
          }

          // First check if we need to update an existing service or create a new one
          String serviceId;
          bool isNewService = false;

          // For new services or temporary ones, create a service first to get a valid ID
          if (widget.service.id <= 0) {
            isNewService = true;
            debugPrint('Creating new service to get valid ID');

            try {
              // Create a service first without image
              if (_selectedCategoryId == null) {
                setState(() {
                  _error = 'Please select a category';
                });
                return;
              }

              // Find the selected category name
              final selectedCategory = _agriculturalCategories.firstWhere(
                (category) => category.id == _selectedCategoryId,
              );

              final tempService = await widget.serviceService.addService(
                title: _titleController.text,
                description: _descriptionController.text,
                price: double.parse(_priceController.text),
                categoryId: _selectedCategoryId!,
                categoryName: selectedCategory.name,
              );

              serviceId = tempService.id.toString();
              debugPrint('Successfully created service with ID: $serviceId');
            } catch (e) {
              debugPrint('Error creating service: $e');
              setState(() {
                _error = 'Failed to create service: $e';
                _isLoading = false;
              });
              return;
            }
          } else {
            // For existing services, use the actual ID
            serviceId = widget.service.id.toString();
            debugPrint('Using existing service ID: $serviceId');
          }

          try {
            imageUrl = await widget.serviceService.uploadServiceImage(
              serviceId,
              _imageFile!.path,
            );
            debugPrint('Image uploaded successfully: $imageUrl');
          } catch (uploadError) {
            debugPrint('Error uploading image: $uploadError');
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
              // Find the selected category name
              final selectedCategory = _agriculturalCategories.firstWhere(
                (category) => category.id == _selectedCategoryId,
              );

              final updatedService = await widget.serviceService.updateService(
                id: serviceId,
                title: _titleController.text,
                description: _descriptionController.text,
                price: double.parse(_priceController.text),
                categoryId: _selectedCategoryId!,
                categoryName: selectedCategory.name,
                imageUrl: imageUrl,
              );

              widget.onServiceUpdated(updatedService);
              if (mounted) {
                Navigator.pop(context);
              }
              return;
            } catch (e) {
              debugPrint('Error updating new service with image: $e');
              setState(() {
                _error = 'Failed to update service with image: $e';
                _isLoading = false;
              });
              return;
            }
          }
        }

        // Standard update for existing service or no image case
        // Find the selected category name
        final selectedCategory = _agriculturalCategories.firstWhere(
          (category) => category.id == _selectedCategoryId,
        );

        debugPrint(
            'EditServiceScreen: Updating service with ID: ${widget.service.id}');
        debugPrint(
            'EditServiceScreen: Service ID as string: ${widget.service.id.toString()}');

        // Check if this is a new service (ID = 0) or existing service
        if (widget.service.id == 0) {
          debugPrint(
              'EditServiceScreen: This is a new service, creating instead of updating');

          // Create a new service instead of updating
          final newService = await widget.serviceService.addService(
            title: _titleController.text,
            description: _descriptionController.text,
            price: double.parse(_priceController.text),
            categoryId: _selectedCategoryId!,
            categoryName: selectedCategory.name,
            imageUrl: imageUrl ?? widget.service.imageUrl,
          );

          widget.onServiceUpdated(newService);
        } else {
          // Update existing service
          final updatedService = await widget.serviceService.updateService(
            id: widget.service.id.toString(),
            title: _titleController.text,
            description: _descriptionController.text,
            price: double.parse(_priceController.text),
            categoryId: _selectedCategoryId!,
            categoryName: selectedCategory.name,
            imageUrl: imageUrl ?? widget.service.imageUrl,
          );

          widget.onServiceUpdated(updatedService);
        }

        if (mounted) {
          Navigator.pop(context);
        }
      } catch (e) {
        debugPrint('Error updating service: $e');
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
                  labelText: 'Price (TZS)',
                  border: OutlineInputBorder(),
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
              Builder(
                builder: (context) {
                  final dropdownItems = _isLoadingCategories
                      ? <DropdownMenuItem<int>>[
                          const DropdownMenuItem<int>(
                              value: null, child: Text('Loading...'))
                        ]
                      : _getUniqueDropdownItems();

                  final validSelectedValue = _selectedCategoryId != null &&
                          dropdownItems
                              .any((item) => item.value == _selectedCategoryId)
                      ? _selectedCategoryId
                      : null;

                  return DropdownButtonFormField<int>(
                    value: validSelectedValue,
                    decoration: const InputDecoration(
                      labelText: 'Agricultural Service Category',
                      border: OutlineInputBorder(),
                    ),
                    items: dropdownItems,
                    onChanged: _isLoadingCategories
                        ? null
                        : (value) {
                            setState(() {
                              _selectedCategoryId = value!;
                            });
                          },
                  );
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
                              debugPrint('Error loading image: $error');
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
                              debugPrint('Error loading image: $error');
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
                        debugPrint('Error loading image: $error');
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
