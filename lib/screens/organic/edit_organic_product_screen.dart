import 'package:flutter/material.dart';
import 'package:masoko_tips/models/organic_product.dart';
import 'package:masoko_tips/providers/admin_provider.dart';
import 'package:masoko_tips/theme/app_theme.dart';
import 'package:masoko_tips/widgets/custom_app_bar.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class EditOrganicProductScreen extends StatefulWidget {
  final OrganicProduct? product;

  const EditOrganicProductScreen({super.key, this.product});

  @override
  State<EditOrganicProductScreen> createState() =>
      _EditOrganicProductScreenState();
}

class _EditOrganicProductScreenState extends State<EditOrganicProductScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _priceController;
  late TextEditingController _stockController;
  late TextEditingController _certificationController;
  late TextEditingController _originController;
  late TextEditingController _storageConditionsController;
  late TextEditingController _shelfLifeController;
  bool _isActive = true;
  bool _isFeatured = false;
  int _selectedCategoryId = 1;
  List<Map<String, dynamic>> _categories = [
    {'id': 1, 'name': 'Organic Vegetables'},
    {'id': 2, 'name': 'Organic Fruits'},
    {'id': 3, 'name': 'Organic Spices'},
    {'id': 4, 'name': 'Organic Cash Crops'},
    {'id': 5, 'name': 'Organic Cereals'},
    {'id': 6, 'name': 'Organic Livestock and Poultry'},
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.product?.name);
    _descriptionController =
        TextEditingController(text: widget.product?.description);
    _priceController =
        TextEditingController(text: widget.product?.price.toString());
    _stockController =
        TextEditingController(text: widget.product?.stock.toString());
    _certificationController =
        TextEditingController(text: widget.product?.certification);
    _originController = TextEditingController(text: widget.product?.origin);
    _storageConditionsController =
        TextEditingController(text: widget.product?.storageConditions);
    _shelfLifeController =
        TextEditingController(text: widget.product?.shelfLife);
    _isActive = widget.product?.isActive ?? true;
    _isFeatured = widget.product?.isFeatured ?? false;
    _selectedCategoryId = widget.product?.categoryId ?? 1;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    _certificationController.dispose();
    _originController.dispose();
    _storageConditionsController.dispose();
    _shelfLifeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: widget.product == null
            ? 'Add Organic Product'
            : 'Edit Organic Product',
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildTextField(
                controller: _nameController,
                label: 'Product Name',
                icon: Icons.shopping_bag,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a product name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _descriptionController,
                label: 'Description',
                icon: Icons.description,
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      controller: _priceController,
                      label: 'Price',
                      icon: Icons.attach_money,
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
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildTextField(
                      controller: _stockController,
                      label: 'Stock',
                      icon: Icons.inventory,
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter stock quantity';
                        }
                        if (int.tryParse(value) == null) {
                          return 'Please enter a valid quantity';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildDropdownField(
                label: 'Category',
                icon: Icons.category,
                value: _selectedCategoryId,
                items: _categories.map((category) {
                  return DropdownMenuItem<int>(
                    value: category['id'],
                    child: Text(category['name']),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _selectedCategoryId = value);
                  }
                },
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _certificationController,
                label: 'Certification',
                icon: Icons.verified,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter certification details';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _originController,
                label: 'Origin',
                icon: Icons.location_on,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the origin';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _storageConditionsController,
                label: 'Storage Conditions',
                icon: Icons.storage,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter storage conditions';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _shelfLifeController,
                label: 'Shelf Life',
                icon: Icons.timer,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter shelf life';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Active'),
                value: _isActive,
                onChanged: (value) => setState(() => _isActive = value),
                activeColor: AppTheme.primaryColor,
              ),
              SwitchListTile(
                title: const Text('Featured'),
                value: _isFeatured,
                onChanged: (value) => setState(() => _isFeatured = value),
                activeColor: AppTheme.primaryColor,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _saveProduct,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(
                  widget.product == null ? 'Add Product' : 'Update Product',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: validator,
    );
  }

  Widget _buildDropdownField({
    required String label,
    required IconData icon,
    required int value,
    required List<DropdownMenuItem<int>> items,
    required void Function(int?)? onChanged,
  }) {
    return InputDecorator(
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          value: value,
          items: items,
          onChanged: onChanged,
          isExpanded: true,
        ),
      ),
    );
  }

  void _saveProduct() async {
    if (!_formKey.currentState!.validate()) return;

    final product = OrganicProduct(
      id: widget.product?.id ?? 0,
      name: _nameController.text,
      slug: _nameController.text.toLowerCase().replaceAll(' ', '-'),
      description: _descriptionController.text,
      price: double.parse(_priceController.text),
      stock: int.parse(_stockController.text),
      isActive: _isActive,
      isFeatured: _isFeatured,
      sellerId: 1, // TODO: Get actual seller ID from auth
      categoryId: _selectedCategoryId,
      certification: _certificationController.text,
      origin: _originController.text,
      storageConditions: _storageConditionsController.text,
      shelfLife: _shelfLifeController.text,
      createdAt: widget.product?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );

    try {
      if (widget.product == null) {
        await context.read<AdminProvider>().addOrganicProduct(product);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Product added successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        await context.read<AdminProvider>().updateOrganicProduct(product);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Product updated successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
