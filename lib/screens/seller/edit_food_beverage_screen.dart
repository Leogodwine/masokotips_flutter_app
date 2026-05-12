import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../models/food_beverage.dart';
import '../../providers/category_provider.dart';
import '../../services/api_service.dart';
import '../../providers/auth_provider.dart';
import '../../config/api_config.dart';
import '../../utils/logger.dart';

class EditFoodBeverageScreen extends StatefulWidget {
  final FoodBeverage product;

  const EditFoodBeverageScreen({Key? key, required this.product})
      : super(key: key);

  @override
  State<EditFoodBeverageScreen> createState() => _EditFoodBeverageScreenState();
}

class _EditFoodBeverageScreenState extends State<EditFoodBeverageScreen> {
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
    _populateFields();
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
      await categoryProvider.loadSubcategories(6);
    } catch (e) {
      Log.e('Error loading food beverage categories: $e');
    } finally {
      if (mounted) {
        setState(() {});
      }
    }
  }

  void _populateFields() {
    _nameController.text = widget.product.name;
    _descriptionController.text = widget.product.description ?? '';
    _priceController.text = widget.product.price.toString();
    _stockController.text = widget.product.stock.toString();
    _ingredientsController.text = widget.product.ingredients ?? '';
    _dietaryInfoController.text = widget.product.dietaryInfo ?? '';
    _storageConditionsController.text = widget.product.storageConditions ?? '';
    _preparationTimeController.text = widget.product.preparationTime ?? '';
    _unitController.text = widget.product.unit ?? '';
    _isActive = widget.product.isActive;
    _isFeatured = widget.product.isFeatured;
    _expirationDate = widget.product.expirationDate;
    _selectedCategoryId = widget.product.categoryId;
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
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    if (_apiService == null) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      List<String> imageUrls = [];
      for (var image in _selectedImages) {
        try {
          final response = await _apiService!.uploadFoodBeverageImage(image);
          if (response['status'] == 'success' && response['url'] != null) {
            imageUrls.add(response['url']);
          }
        } catch (e) {
          Log.e('Error uploading image: $e');
        }
      }

      final productData = {
        'name': _nameController.text,
        'description': _descriptionController.text,
        'price': double.parse(_priceController.text),
        'stock': int.parse(_stockController.text),
        'category_id': _selectedCategoryId ?? widget.product.categoryId,
        'ingredients': _ingredientsController.text.isNotEmpty ? _ingredientsController.text : null,
        'dietary_info': _dietaryInfoController.text.isNotEmpty ? _dietaryInfoController.text : null,
        'expiration_date': _expirationDate?.toIso8601String(),
        'storage_conditions': _storageConditionsController.text.isNotEmpty ? _storageConditionsController.text : null,
        'preparation_time': _preparationTimeController.text.isNotEmpty ? _preparationTimeController.text : null,
        'unit': _unitController.text.isNotEmpty ? _unitController.text : null,
        'is_active': _isActive,
        'is_featured': _isFeatured,
        'images': imageUrls,
      };

      final response = await _apiService!.updateFoodBeverage(widget.product.id, productData);

      final isSuccess = response['status'] == 'success' || response['success'] == true;
      if (isSuccess) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Item updated successfully!'), backgroundColor: Colors.green),
          );
          Navigator.pop(context, true);
        }
      } else {
        setState(() {
          _errorMessage = response['message'] ?? 'Failed to update item';
        });
      }
    } catch (e) {
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
        title: const Text('Edit Food & Beverage'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => _showDeleteDialog(),
          ),
        ],
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
                        child: Text(_errorMessage!, style: TextStyle(color: Colors.red[700])),
                      ),

                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: 'Item Name *',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        prefixIcon: const Icon(Icons.restaurant),
                      ),
                      validator: (value) => (value == null || value.isEmpty) ? 'Please enter a name' : null,
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _descriptionController,
                      decoration: InputDecoration(
                        labelText: 'Description *',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      maxLines: 3,
                      validator: (value) => (value == null || value.isEmpty) ? 'Please enter a description' : null,
                    ),
                    const SizedBox(height: 16),

                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _priceController,
                            decoration: InputDecoration(
                              labelText: 'Price *',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              prefixText: 'TZS ',
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: _stockController,
                            decoration: InputDecoration(
                              labelText: 'Stock *',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    Consumer<CategoryProvider>(
                      builder: (context, provider, child) {
                        return DropdownButtonFormField<int?>(
                          isExpanded: true,
                          initialValue: _selectedCategoryId,
                          decoration: InputDecoration(
                            labelText: 'Category *',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          items: provider.subcategories.map((category) {
                            return DropdownMenuItem<int?>(value: category.id, child: Text(category.name));
                          }).toList(),
                          onChanged: (value) => setState(() => _selectedCategoryId = value),
                        );
                      },
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _ingredientsController,
                      decoration: InputDecoration(
                        labelText: 'Ingredients (Optional)',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _dietaryInfoController,
                      decoration: InputDecoration(
                        labelText: 'Dietary Info (Optional)',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 16),

                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _preparationTimeController,
                            decoration: InputDecoration(
                              labelText: 'Prep Time',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: _unitController,
                            decoration: InputDecoration(
                              labelText: 'Unit',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    InkWell(
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: _expirationDate ?? DateTime.now().add(const Duration(days: 1)),
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
                        );
                        if (date != null) setState(() => _expirationDate = date);
                      },
                      child: InputDecorator(
                        decoration: InputDecoration(
                          labelText: 'Expiration Date (Optional)',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text(_expirationDate != null ? '${_expirationDate!.day}/${_expirationDate!.month}/${_expirationDate!.year}' : 'Select date'),
                      ),
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _storageConditionsController,
                      decoration: InputDecoration(
                        labelText: 'Storage Conditions',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 16),

                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(border: Border.all(color: Colors.grey[300]!), borderRadius: BorderRadius.circular(12)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.image),
                              const SizedBox(width: 8),
                              const Text('Item Images', style: TextStyle(fontWeight: FontWeight.bold)),
                              const Spacer(),
                              TextButton.icon(onPressed: _pickImages, icon: const Icon(Icons.add_photo_alternate), label: const Text('Add Images')),
                            ],
                          ),
                          if (_selectedImages.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            SizedBox(
                              height: 100,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: _selectedImages.length,
                                itemBuilder: (context, index) => Container(
                                  margin: const EdgeInsets.only(right: 8),
                                  child: ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.file(_selectedImages[index], width: 100, height: 100, fit: BoxFit.cover)),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    Card(
                      child: Column(
                        children: [
                          SwitchListTile(
                            title: const Text('Active'),
                            value: _isActive,
                            activeThumbColor: Colors.orange,
                            onChanged: (value) => setState(() => _isActive = value),
                          ),
                          SwitchListTile(
                            title: const Text('Featured'),
                            value: _isFeatured,
                            activeThumbColor: Colors.orange,
                            onChanged: (value) => setState(() => _isFeatured = value),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    ElevatedButton(
                      onPressed: _isLoading ? null : _submitForm,
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16)),
                      child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text('Update Item', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Item'),
        content: Text('Are you sure you want to delete "${widget.product.name}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(onPressed: () { Navigator.pop(context); _deleteProduct(); }, style: TextButton.styleFrom(foregroundColor: Colors.red), child: const Text('Delete')),
        ],
      ),
    );
  }

  Future<void> _deleteProduct() async {
    setState(() => _isLoading = true);
    try {
      await _apiService!.deleteFoodBeverage(widget.product.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Deleted successfully'), backgroundColor: Colors.green));
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Delete failed: $e'), backgroundColor: Colors.red));
    } finally {
      setState(() => _isLoading = false);
    }
  }
}
