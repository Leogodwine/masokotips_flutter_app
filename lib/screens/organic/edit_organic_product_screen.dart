import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../utils/image_upload_helper.dart';
import 'package:masoko_tips/widgets/cached_network_image_with_cors.dart';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:masoko_tips/models/organic_product.dart';
import 'package:masoko_tips/providers/admin_provider.dart';
import 'package:masoko_tips/providers/auth_provider.dart';
import 'package:masoko_tips/theme/app_theme.dart';
import 'package:masoko_tips/widgets/custom_app_bar.dart';
import 'package:masoko_tips/models/category.dart' as models;
import 'package:masoko_tips/providers/category_provider.dart';
import 'package:provider/provider.dart';
import 'package:masoko_tips/l10n/app_localizations.dart';

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
  List<models.Category> _categories = [];
  bool _isLoadingCategories = false;
  File? _selectedImage;
  String? _existingImageUrl;
  bool _isRemovingExistingImage = false;

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
    _existingImageUrl = widget.product?.imageUrl;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_categories.isEmpty && !_isLoadingCategories) {
      _loadCategories();
    }
  }

  Future<void> _loadCategories() async {
    setState(() => _isLoadingCategories = true);
    try {
      final categoryProvider =
          Provider.of<CategoryProvider>(context, listen: false);

      // First load main categories to find "Organic Products"
      await categoryProvider.loadMainCategories();

      // Find the "Organic Products" category
      final organicProductsCategory =
          categoryProvider.mainCategories.firstWhere(
        (cat) => cat.name == 'Organic Products',
        orElse: () => throw Exception('Organic Products category not found'),
      );

      // Load subcategories for Organic Products
      await categoryProvider.loadSubcategories(organicProductsCategory.id);

      _categories = categoryProvider.subcategories;

      // If the selected category is not in the list, set to first available
      if (_categories.isNotEmpty &&
          !_categories.any((cat) => cat.id == _selectedCategoryId)) {
        setState(() => _selectedCategoryId = _categories.first.id);
      }
    } catch (e) {
      debugPrint('Error loading organic product categories: $e');
      // Fallback to hardcoded categories if API fails
      _categories = [
        models.Category(
            id: 26,
            name: 'Organic Vegetables',
            slug: 'organic-vegetables',
            isActive: true,
            sortOrder: 1),
        models.Category(
            id: 27,
            name: 'Organic Fruits',
            slug: 'organic-fruits',
            isActive: true,
            sortOrder: 2),
        models.Category(
            id: 28,
            name: 'Organic Spices',
            slug: 'organic-spices',
            isActive: true,
            sortOrder: 3),
        models.Category(
            id: 29,
            name: 'Organic Cash Crops',
            slug: 'organic-cash-crops',
            isActive: true,
            sortOrder: 4),
        models.Category(
            id: 30,
            name: 'Organic Cereals',
            slug: 'organic-cereals',
            isActive: true,
            sortOrder: 5),
        models.Category(
            id: 31,
            name: 'Organic Livestock and Poultry',
            slug: 'organic-livestock-and-poultry',
            isActive: true,
            sortOrder: 6),
      ];
    } finally {
      setState(() => _isLoadingCategories = false);
    }
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await ImageUploadHelper.pickAndCropImage(
        context,
        source: ImageSource.gallery,
      );

      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
          // Clear the existing image removal flag when selecting a new image
          _isRemovingExistingImage = false;
        });
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error picking image: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
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
                    value: category.id,
                    child: Text(category.name),
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
              // Image Upload Section
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Icon(
                      _selectedImage != null ||
                              (_existingImageUrl != null &&
                                  !_isRemovingExistingImage)
                          ? Icons.check_circle_outline
                          : Icons.image_outlined,
                      size: 48,
                      color: (_selectedImage != null ||
                              (_existingImageUrl != null &&
                                  !_isRemovingExistingImage))
                          ? Colors.green
                          : Colors.grey[600],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Product Image',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _selectedImage != null
                          ? 'New image selected'
                          : (_existingImageUrl != null &&
                                  !_isRemovingExistingImage)
                              ? 'Existing image will be kept'
                              : _isRemovingExistingImage
                                  ? 'Image will be removed'
                                  : 'Add an image to make your product more appealing',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: (_selectedImage != null ||
                                (_existingImageUrl != null &&
                                    !_isRemovingExistingImage))
                            ? Colors.green[600]
                            : (_isRemovingExistingImage
                                ? Colors.orange[600]
                                : Colors.grey[600]),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton.icon(
                          onPressed: _pickImage,
                          icon: const Icon(Icons.upload),
                          label: Text(AppLocalizations.of(context)!.chooseImage),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                        if (_isRemovingExistingImage &&
                            widget.product?.imageUrl != null) ...[
                          const SizedBox(width: 12),
                          ElevatedButton.icon(
                            onPressed: () {
                              setState(() {
                                _isRemovingExistingImage = false;
                                _existingImageUrl = widget.product?.imageUrl;
                              });
                            },
                            icon: const Icon(Icons.undo),
                            label: Text(AppLocalizations.of(context)!.undoRemove),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              if (_selectedImage != null ||
                  (_existingImageUrl != null && !_isRemovingExistingImage)) ...[
                const SizedBox(height: 20),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Stack(
                      children: [
                        // Show selected image if available, otherwise show existing image
                        if (_selectedImage != null)
                          kIsWeb
                              ? Image.network(
                                  _selectedImage!.path,
                                  height: 200,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      height: 200,
                                      color: Colors.grey[300],
                                      child: const Center(
                                        child:
                                            Icon(Icons.error_outline, size: 48),
                                      ),
                                    );
                                  },
                                )
                              : Image.file(
                                  _selectedImage!,
                                  height: 200,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      height: 200,
                                      color: Colors.grey[300],
                                      child: const Center(
                                        child:
                                            Icon(Icons.error_outline, size: 48),
                                      ),
                                    );
                                  },
                                )
                        else if (_existingImageUrl != null &&
                            !_isRemovingExistingImage)
                          CachedNetworkImageWithCors(
                            imageUrl: _existingImageUrl ?? '',
                            height: 200,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),

                        // Image type indicator
                        if (_selectedImage != null)
                          Positioned(
                            top: 8,
                            left: 8,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.blue.withValues(alpha: 0.8),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Text(
                                'NEW',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),

                        // Remove button
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.6),
                              shape: BoxShape.circle,
                            ),
                            child: IconButton(
                              icon: const Icon(
                                Icons.close,
                                color: Colors.white,
                                size: 20,
                              ),
                              onPressed: () {
                                setState(() {
                                  if (_selectedImage != null) {
                                    // Remove newly selected image
                                    _selectedImage = null;
                                  } else if (_existingImageUrl != null) {
                                    // Mark existing image for removal
                                    _isRemovingExistingImage = true;
                                    _existingImageUrl = null;
                                  }
                                });
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 16),
              SwitchListTile(
                title: Text(AppLocalizations.of(context)!.active),
                value: _isActive,
                onChanged: (value) => setState(() => _isActive = value),
                activeThumbColor: AppTheme.primaryColor,
              ),
              SwitchListTile(
                title: Text(AppLocalizations.of(context)!.featured),
                value: _isFeatured,
                onChanged: (value) => setState(() => _isFeatured = value),
                activeThumbColor: AppTheme.primaryColor,
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

    // Get service_provider references before async operations
    final adminProvider = Provider.of<AdminProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    final product = OrganicProduct(
      id: widget.product?.id ?? 0,
      name: _nameController.text,
      slug: _nameController.text.toLowerCase().replaceAll(' ', '-'),
      description: _descriptionController.text,
      price: double.parse(_priceController.text),
      stock: int.parse(_stockController.text),
      imageUrl: _isRemovingExistingImage ? null : _existingImageUrl,
      isActive: _isActive,
      isFeatured: _isFeatured,
      sellerId: authProvider.user?.id ?? 1,
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
        await adminProvider.addOrganicProduct(product,
            imageFiles: _selectedImage != null ? [_selectedImage!] : null);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!.productAddedSuccessfully),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        await adminProvider.updateOrganicProduct(product,
            imageFiles: _selectedImage != null ? [_selectedImage!] : null);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!.productUpdatedSuccessfully),
              backgroundColor: Colors.green,
            ),
          );
        }
      }

      // Reset the removal flag after successful save
      setState(() {
        _isRemovingExistingImage = false;
      });

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
