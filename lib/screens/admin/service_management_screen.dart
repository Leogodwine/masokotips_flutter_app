import 'package:flutter/material.dart';
import '../../models/service.dart';
import '../../services/service_service.dart';

class ServiceManagementScreen extends StatefulWidget {
  const ServiceManagementScreen({super.key});

  @override
  State<ServiceManagementScreen> createState() =>
      _ServiceManagementScreenState();
}

class _ServiceManagementScreenState extends State<ServiceManagementScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _imageUrlController = TextEditingController();
  String _selectedCategory = 'Buyers & Sellers';
  final ServiceService _serviceService = ServiceService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Service Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showServiceDialog(context),
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: 2, // Replace with actual services list
        itemBuilder: (context, index) {
          final service = Service(
            id: index,
            title: 'Sample Service ${index + 1}',
            description: 'Sample description',
            price: 99.99,
            categoryId: index,
            userId: 1,
            imageUrl: 'https://via.placeholder.com/150',
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          );

          return Card(
            margin: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            child: ListTile(
              leading: service.imageUrl != null
                  ? Image.network(
                      service.imageUrl!,
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                    )
                  : const Icon(Icons.image),
              title: Text(service.title ?? 'No Title'),
              subtitle: Text(
                'TZS ${service.price.toStringAsFixed(2)} - Category ${service.categoryId}',
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () => _showServiceDialog(context, service),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete),
                    color: Colors.red,
                    onPressed: () => _showDeleteConfirmation(context, service),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showServiceDialog(BuildContext context, [Service? service]) {
    if (service != null) {
      _titleController.text = service.title ?? '';
      _descriptionController.text = service.description ?? '';
      _priceController.text = service.price.toString();
      _imageUrlController.text = service.imageUrl ?? '';
      _selectedCategory = 'Category ${service.categoryId}';
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(service == null ? 'Add Service' : 'Edit Service'),
        content: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(labelText: 'Title'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a title';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(labelText: 'Description'),
                  maxLines: 3,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a description';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _priceController,
                  decoration: const InputDecoration(labelText: 'Price'),
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
                TextFormField(
                  controller: _imageUrlController,
                  decoration: const InputDecoration(labelText: 'Image URL'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter an image URL';
                    }
                    return null;
                  },
                ),
                DropdownButtonFormField<String>(
                  initialValue: _selectedCategory,
                  decoration: const InputDecoration(labelText: 'Category'),
                  items: [
                    'Buyers & Sellers',
                    'Transport',
                    'Services',
                    'Organic Products',
                  ].map((category) {
                    return DropdownMenuItem(
                      value: category,
                      child: Text(category),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedCategory = value!;
                    });
                  },
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              _clearForm();
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                // Capture context-dependent objects before async operation
                final navigator = Navigator.of(context);
                final scaffoldMessenger = ScaffoldMessenger.of(context);

                await _saveService(service);
                if (mounted) {
                  navigator.pop();
                  scaffoldMessenger.showSnackBar(
                    SnackBar(
                      content: Text(
                        service == null
                            ? 'Service added successfully'
                            : 'Service updated successfully',
                      ),
                      backgroundColor: Colors.green,
                    ),
                  );
                  _clearForm();
                }
              }
            },
            child: Text(service == null ? 'Add' : 'Update'),
          ),
        ],
      ),
    );
  }

  Future<void> _saveService(Service? service) async {
    try {
      if (service == null) {
        // Create new service
        await _serviceService.addService(
          title: _titleController.text,
          description: _descriptionController.text,
          price: double.parse(_priceController.text),
          categoryId: 1, // Default category ID
          categoryName: _selectedCategory,
          imageUrl: _imageUrlController.text.isNotEmpty
              ? _imageUrlController.text
              : null,
        );
      } else {
        // Update existing service
        await _serviceService.updateService(
          id: service.id.toString(),
          title: _titleController.text,
          description: _descriptionController.text,
          price: double.parse(_priceController.text),
          categoryId: 1, // Default category ID
          categoryName: _selectedCategory,
          imageUrl: _imageUrlController.text.isNotEmpty
              ? _imageUrlController.text
              : null,
        );
      }
    } catch (e) {
      debugPrint('Error saving service: $e');
      // Handle error - could show error message to user
    }
  }

  void _showDeleteConfirmation(BuildContext context, Service service) {
    // Capture context-dependent objects before async operation
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Service'),
        content: Text('Are you sure you want to delete "${service.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(dialogContext).pop();
              try {
                await _serviceService.deleteService(service.id.toString());
                if (mounted) {
                  scaffoldMessenger.showSnackBar(
                    SnackBar(
                      content: Text('${service.title} deleted successfully'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  scaffoldMessenger.showSnackBar(
                    SnackBar(
                      content: Text('Failed to delete service: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _clearForm() {
    _titleController.clear();
    _descriptionController.clear();
    _priceController.clear();
    _imageUrlController.clear();
    _selectedCategory = 'Buyers & Sellers';
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }
}
