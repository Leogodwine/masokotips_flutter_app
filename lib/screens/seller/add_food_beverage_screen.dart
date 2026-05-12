import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../services/api_service.dart';
import '../../providers/auth_provider.dart';
import '../../config/api_config.dart';
import '../../utils/logger.dart';
import '../../providers/category_provider.dart';

class AddFoodBeverageScreen extends StatefulWidget {
  const AddFoodBeverageScreen({Key? key}) : super(key: key);

  @override
  State<AddFoodBeverageScreen> createState() => _AddFoodBeverageScreenState();
}

class _AddFoodBeverageScreenState extends State<AddFoodBeverageScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _stockController = TextEditingController();
  final _ingredientsController = TextEditingController();
  final _dietaryInfoController = TextEditingController();
  final _storageConditionsController = TextEditingController();
  final _preparationTimeController = TextEditingController();
  final _unitController = TextEditingController();

  int? _selectedCategoryId;
  DateTime? _expirationDate;
  bool _isActive = true;
  bool _isFeatured = false;
  final List<File> _selectedImages = [];
  bool _isLoading = false;
  String? _errorMessage;
  ApiService? _apiService;

  @override
  void initState() {
    super.initState();
    _initializeApiService();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCategories();
    });
  }

  void _initializeApiService() {
    final authProvider = context.read<AuthProvider>();
    if (authProvider.token != null) {
      _apiService = ApiService(
        baseUrl: ApiConfig.baseUrl,
        apiKey: authProvider.token!,
      );
    }
  }

  Future<void> _loadCategories() async {
    try {
      final categoryProvider = Provider.of<CategoryProvider>(context, listen: false);
      // Food and Beverages category ID is 6
      await categoryProvider.loadSubcategories(6);
      
      if (categoryProvider.subcategories.isNotEmpty) {
        setState(() {
          _selectedCategoryId = categoryProvider.subcategories.first.id;
        });
      }
    } catch (e) {
      Log.e('Error loading food beverage categories: $e');
      setState(() {
        _errorMessage = 'Failed to load categories: $e';
      });
    } finally {
      if (mounted) {
        setState(() {});
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    _ingredientsController.dispose();
    _dietaryInfoController.dispose();
    _storageConditionsController.dispose();
    _preparationTimeController.dispose();
    _unitController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    try {
      final ImagePicker picker = ImagePicker();
      final List<XFile> images = await picker.pickMultiImage(
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );

      if (images.isNotEmpty) {
        setState(() {
          _selectedImages.addAll(images.map((image) => File(image.path)));
        });
      }
    } catch (e) {
      debugPrint('Error picking images: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error picking images: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    if (_apiService == null) {
      setState(() {
        _errorMessage = 'API service not initialized';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // First, upload images if any
      List<String> imageUrls = [];
      Log.e('Uploading ${_selectedImages.length} images for food beverage');
      for (var image in _selectedImages) {
        try {
          Log.e('Uploading image: ${image.path}');
          final response = await _apiService!.uploadFoodBeverageImage(image);
          Log.e('Image upload response: $response');
          if (response['status'] == 'success' && response['url'] != null) {
            imageUrls.add(response['url']);
            Log.e('Added image URL: ${response['url']}');
          }
        } catch (e) {
          Log.e('Error uploading image: $e');
        }
      }
      Log.e('Total image URLs collected: ${imageUrls.length}');

      // Create the food beverage
      final productData = {
        'name': _nameController.text,
        'description': _descriptionController.text,
        'price': double.parse(_priceController.text),
        'stock': int.parse(_stockController.text),
        'category_id': _selectedCategoryId ?? 6,
        'ingredients': _ingredientsController.text.isNotEmpty
            ? _ingredientsController.text
            : null,
        'dietary_info': _dietaryInfoController.text.isNotEmpty
            ? _dietaryInfoController.text
            : null,
        'expiration_date': _expirationDate?.toIso8601String(),
        'storage_conditions': _storageConditionsController.text.isNotEmpty
            ? _storageConditionsController.text
            : null,
        'preparation_time': _preparationTimeController.text.isNotEmpty
            ? _preparationTimeController.text
            : null,
        'unit': _unitController.text.isNotEmpty
            ? _unitController.text
            : null,
        'is_active': _isActive,
        'is_featured': _isFeatured,
        'images': imageUrls,
      };

      Log.e('Creating food beverage: ${productData['name']}');
      final response = await _apiService!.createFoodBeverage(productData);

      Log.e('Create response: $response');
      final isSuccess = response['status'] == 'success' || response['success'] == true;
      if (isSuccess) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Food & Beverage item created successfully!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context, true);
        }
      } else {
        setState(() {
          _errorMessage = response['message'] ?? 'Failed to create item';
        });
      }
    } catch (e) {
      Log.e('Error creating food beverage: $e');
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Food & Beverage'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (_errorMessage != null)
                      Container(
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.red[50],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.red[200]!),
                        ),
                        child: Text(
                          _errorMessage!,
                          style: TextStyle(color: Colors.red[700]),
                        ),
                      ),

                    // Product Name
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: 'Item Name *',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: const Icon(Icons.restaurant),
                        filled: true,
                        fillColor: Colors.grey[50],
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Description
                    TextFormField(
                      controller: _descriptionController,
                      decoration: InputDecoration(
                        labelText: 'Description *',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: const Icon(Icons.description_outlined),
                        filled: true,
                        fillColor: Colors.grey[50],
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

                    // Price and Stock Row
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _priceController,
                            decoration: InputDecoration(
                              labelText: 'Price *',
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
                              if (value == null || value.isEmpty) {
                                return 'Required';
                              }
                              if (double.tryParse(value) == null) {
                                return 'Invalid';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: _stockController,
                            decoration: InputDecoration(
                              labelText: 'Stock *',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              prefixIcon: const Icon(Icons.inventory),
                              filled: true,
                              fillColor: Colors.grey[50],
                            ),
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Required';
                              }
                              if (int.tryParse(value) == null) {
                                return 'Invalid';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Category
                    Consumer<CategoryProvider>(
                      builder: (context, provider, child) {
                        return DropdownButtonFormField<int?>(
                          isExpanded: true,
                          initialValue: _selectedCategoryId,
                          decoration: InputDecoration(
                            labelText: 'Category *',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            prefixIcon: const Icon(Icons.category),
                            filled: true,
                            fillColor: Colors.grey[50],
                          ),
                          hint: const Text('Select Category'),
                          items: provider.subcategories.map((category) {
                            return DropdownMenuItem<int?>(
                              value: category.id,
                              child: Text(category.name),
                            );
                          }).toList(),
                          onChanged: (value) {
                                  setState(() {
                                    _selectedCategoryId = value;
                                  });
                                },
                          validator: (value) {
                            if (value == null) {
                              return 'Please select a category';
                            }
                            return null;
                          },
                        );
                      },
                    ),
                    const SizedBox(height: 16),

                    // Ingredients
                    TextFormField(
                      controller: _ingredientsController,
                      decoration: InputDecoration(
                        labelText: 'Ingredients (Optional)',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: const Icon(Icons.list_alt),
                        filled: true,
                        fillColor: Colors.grey[50],
                      ),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 16),

                    // Dietary Info
                    TextFormField(
                      controller: _dietaryInfoController,
                      decoration: InputDecoration(
                        labelText: 'Dietary Info (Optional)',
                        hintText: 'e.g. Vegan, Gluten-free, Halal',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: const Icon(Icons.health_and_safety),
                        filled: true,
                        fillColor: Colors.grey[50],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Preparation Time & Unit Row
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _preparationTimeController,
                            decoration: InputDecoration(
                              labelText: 'Prep Time',
                              hintText: 'e.g. 15 mins',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              prefixIcon: const Icon(Icons.timer),
                              filled: true,
                              fillColor: Colors.grey[50],
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: _unitController,
                            decoration: InputDecoration(
                              labelText: 'Unit',
                              hintText: 'e.g. per kg, per plate',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              prefixIcon: const Icon(Icons.shopping_basket),
                              filled: true,
                              fillColor: Colors.grey[50],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Expiration Date
                    InkWell(
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now().add(const Duration(days: 1)),
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
                        );
                        if (date != null) {
                          setState(() {
                            _expirationDate = date;
                          });
                        }
                      },
                      child: InputDecorator(
                        decoration: InputDecoration(
                          labelText: 'Expiration Date (Optional)',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          prefixIcon: const Icon(Icons.event_available),
                          filled: true,
                          fillColor: Colors.grey[50],
                        ),
                        child: Text(
                          _expirationDate != null
                              ? '${_expirationDate!.day}/${_expirationDate!.month}/${_expirationDate!.year}'
                              : 'Select expiration date',
                          style: TextStyle(
                            color: _expirationDate != null
                                ? Colors.black
                                : Colors.grey[600],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Storage Conditions
                    TextFormField(
                      controller: _storageConditionsController,
                      decoration: InputDecoration(
                        labelText: 'Storage Conditions',
                        hintText: 'e.g. Refrigerate after opening',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: const Icon(Icons.storage),
                        filled: true,
                        fillColor: Colors.grey[50],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Images
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.image),
                              const SizedBox(width: 8),
                              const Text(
                                'Item Images',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Spacer(),
                              TextButton.icon(
                                onPressed: _pickImages,
                                icon: const Icon(Icons.add_photo_alternate),
                                label: const Text('Add Images'),
                              ),
                            ],
                          ),
                          if (_selectedImages.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            SizedBox(
                              height: 100,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: _selectedImages.length,
                                itemBuilder: (context, index) {
                                  return Container(
                                    margin: const EdgeInsets.only(right: 8),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.file(
                                        _selectedImages[index],
                                        width: 100,
                                        height: 100,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Status Switches
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            SwitchListTile(
                              title: const Text('Active'),
                              subtitle: const Text('Make this item visible to customers'),
                              value: _isActive,
                              activeThumbColor: Colors.orange,
                              onChanged: (value) {
                                setState(() {
                                  _isActive = value;
                                });
                              },
                            ),
                            SwitchListTile(
                              title: const Text('Featured'),
                              subtitle: const Text('Show this item in featured section'),
                              value: _isFeatured,
                              activeThumbColor: Colors.orange,
                              onChanged: (value) {
                                setState(() {
                                  _isFeatured = value;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Submit Button
                    ElevatedButton(
                      onPressed: _isLoading ? null : _submitForm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Text(
                              'Create Food & Beverage Item',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
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
