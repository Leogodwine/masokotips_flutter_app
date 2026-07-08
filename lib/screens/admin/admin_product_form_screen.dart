import 'package:flutter/material.dart';
import '../../models/product.dart';
import '../../models/category.dart' as models;
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:provider/provider.dart';
import '../../providers/admin_provider.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:masoko_tips/utils/log.dart';
import 'package:masoko_tips/l10n/app_localizations.dart';

class AdminProductFormScreen extends StatefulWidget {
  final Product? product;

  const AdminProductFormScreen({Key? key, this.product}) : super(key: key);

  @override
  AdminProductFormScreenState createState() => AdminProductFormScreenState();
}

class AdminProductFormScreenState extends State<AdminProductFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _stockController = TextEditingController();
  final _unitController = TextEditingController();
  bool _isActive = true;
  bool _isFeatured = false;
  int? _selectedCategoryId;
  List<models.Category> _categories = [];
  final List<XFile> _selectedImages = [];
  bool _isLoading = false;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    if (widget.product != null) {
      _nameController.text = widget.product!.name;
      _descriptionController.text = widget.product!.description;
      _priceController.text = widget.product!.price.toString();
      _stockController.text = widget.product!.stock.toString();
      _unitController.text = widget.product!.unit ?? '';
      _isActive = widget.product!.isActive;
      _isFeatured = widget.product!.isFeatured;
      _selectedCategoryId = widget.product!.categoryId;
    }
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    try {
      Log.d('Starting to load categories in form screen');
      final adminProvider = Provider.of<AdminProvider>(context, listen: false);
      Log.d('AdminProvider obtained, calling getCategories()');

      final categories = await adminProvider.getCategories();
      Log.d(
          'Categories received from service_provider: ${categories.length} categories');

      // Find the Products category and ensure it has its subcategories
      Log.d('Looking for Products category (id: 1)');

      // First try to find the Products category from API
      final apiProductsCategory = categories.firstWhere(
        (category) => category.id == 1,
        orElse: () => models.Category(id: 1, name: 'Products'),
      );

      // Check if the API category has subcategories, if not use our default subcategories
      models.Category productsCategory;
      if (apiProductsCategory.subcategories == null ||
          apiProductsCategory.subcategories!.isEmpty) {
        Log.d('API Products category has no subcategories, using defaults');
        productsCategory = models.Category(
          id: 1,
          name: 'Products',
          subcategories: [
            models.Category(id: 6, name: 'Vegetables'),
            models.Category(id: 7, name: 'Fruits'),
            models.Category(id: 8, name: 'Spices'),
            models.Category(id: 9, name: 'Cash Crops'),
            models.Category(id: 10, name: 'Cereals'),
            models.Category(id: 11, name: 'Seeds and Seedling'),
            models.Category(id: 12, name: 'Livestock and poultry'),
          ],
        );
      } else {
        Log.d('API Products category has subcategories, using them');
        productsCategory = apiProductsCategory;
      }

      Log.d(
          'Products category found/created with ${productsCategory.subcategories?.length ?? 0} subcategories');

      if (mounted) {
        Log.d('Setting state with categories');
        setState(() {
          _categories = [productsCategory];
          // If editing a product, ensure the selected category is valid
          if (widget.product != null) {
            Log.d('Editing existing product, validating category');
            final productSubcategories = _getProductSubcategories();
            if (!productSubcategories
                .any((c) => c.id == widget.product!.categoryId)) {
              Log.d(
                  'Product category not found in subcategories, setting to null');
              _selectedCategoryId = null;
            } else {
              Log.d(
                  'Product category found, setting to ${widget.product!.categoryId}');
              _selectedCategoryId = widget.product!.categoryId;
            }
          } else {
            // For new products, select the first category by default
            Log.d('Creating new product, selecting first category');
            final subcategories = _getProductSubcategories();
            if (subcategories.isNotEmpty) {
              Log.d('Setting default category to ${subcategories.first.id}');
              _selectedCategoryId = subcategories.first.id;
            }
          }
          _isInitialized = true;
          Log.d('State updated successfully');
        });
      } else {
        Log.d('Widget not mounted, skipping state update');
      }
    } catch (e, stackTrace) {
      Log.e('Error in _loadCategories: $e\n$stackTrace');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load categories: $e')),
        );
        // Set default categories if loading fails
        Log.d('Setting default categories after error');
        setState(() {
          _categories = [
            models.Category(
              id: 1,
              name: 'Products',
              subcategories: [
                models.Category(id: 6, name: 'Vegetables'),
                models.Category(id: 7, name: 'Fruits'),
                models.Category(id: 8, name: 'Spices'),
                models.Category(id: 9, name: 'Cash Crops'),
                models.Category(id: 10, name: 'Cereals'),
                models.Category(id: 11, name: 'Seeds and Seedling'),
                models.Category(id: 12, name: 'Livestock and poultry'),
              ],
            ),
          ];
          _isInitialized = true;
        });
      }
    }
  }

  Future<void> _pickImages() async {
    try {
      final ImagePicker picker = ImagePicker();
      final List<XFile> images = await picker.pickMultiImage();
      if (images.isNotEmpty) {
        setState(() {
          _selectedImages.addAll(images);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking images: $e')),
        );
      }
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.pleaseSelectACategory)),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final adminProvider = Provider.of<AdminProvider>(context, listen: false);

      if (!adminProvider.isAdmin) {
        throw Exception('Please login as admin first');
      }

      final productData = {
        'name': _nameController.text,
        'description': _descriptionController.text,
        'price': double.parse(_priceController.text),
        'stock': int.parse(_stockController.text),
        'unit': _unitController.text,
        'category_id': _selectedCategoryId,
        'is_active': _isActive,
        'is_featured': _isFeatured,
        'images': _selectedImages,
      };

      // Log the form data
      Log.d('Form Data before submission:');
      Log.d('- is_active: $_isActive');
      Log.d('- is_featured: $_isFeatured');

      if (widget.product == null) {
        await adminProvider.createProduct(productData);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(AppLocalizations.of(context)!.productCreatedSuccessfully)),
          );
        }
      } else {
        await adminProvider.updateProduct(
          widget.product!.id,
          productData,
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(AppLocalizations.of(context)!.productUpdatedSuccessfully)),
          );
        }
      }

      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  List<models.Category> _getProductSubcategories() {
    if (_categories.isEmpty) {
      return [];
    }
    final productsCategory = _categories.firstWhere(
      (category) => category.id == 1,
      orElse: () => models.Category(
        id: 1,
        name: 'Products',
        subcategories: [
          models.Category(id: 6, name: 'Vegetables'),
          models.Category(id: 7, name: 'Fruits'),
          models.Category(id: 8, name: 'Spices'),
          models.Category(id: 9, name: 'Cash Crops'),
          models.Category(id: 10, name: 'Cereals'),
          models.Category(id: 11, name: 'Seeds and Seedling'),
          models.Category(id: 12, name: 'Livestock and poultry'),
        ],
      ),
    );
    return productsCategory.subcategories ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.product == null ? 'Add Product' : 'Edit Product'),
        elevation: 0,
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: _isInitialized
          ? SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            TextFormField(
                              controller: _nameController,
                              decoration: const InputDecoration(
                                labelText: 'Name',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.shopping_bag),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter a name';
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
                                prefixIcon: Icon(Icons.description),
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
                                prefix: Padding(
                                  padding:
                                      EdgeInsets.symmetric(horizontal: 8.0),
                                  child: Text('TZS',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                                ),
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
                            TextFormField(
                              controller: _stockController,
                              decoration: const InputDecoration(
                                labelText: 'Stock',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.inventory),
                              ),
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter stock quantity';
                                }
                                if (int.tryParse(value) == null) {
                                  return 'Please enter a valid quantity';
                                }
                                return null;
                              }, //I ended here
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _unitController,
                              decoration: const InputDecoration(
                                labelText: 'Unit (e.g., kg, pcs)',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.straighten),
                              ),
                            ),
                            const SizedBox(height: 16),
                            DropdownButtonFormField<int>(
                              initialValue: _selectedCategoryId,
                              decoration: const InputDecoration(
                                labelText: 'Category',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.category),
                              ),
                              items: _getProductSubcategories().map((category) {
                                return DropdownMenuItem<int>(
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
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: InkWell(
                                    onTap: () {
                                      setState(() {
                                        _isActive = !_isActive;
                                      });
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 12,
                                      ),
                                      decoration: BoxDecoration(
                                        color: _isActive
                                            ? Colors.green.withAlpha(26)
                                            : Colors.grey.withAlpha(26),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: _isActive
                                              ? Colors.green
                                              : Colors.grey,
                                          width: 1,
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            _isActive
                                                ? Icons.check_circle
                                                : Icons.cancel,
                                            color: _isActive
                                                ? Colors.green
                                                : Colors.grey,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            _isActive ? 'Active' : 'Inactive',
                                            style: TextStyle(
                                              color: _isActive
                                                  ? Colors.green
                                                  : Colors.grey,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: InkWell(
                                    onTap: () {
                                      setState(() {
                                        _isFeatured = !_isFeatured;
                                      });
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 12,
                                      ),
                                      decoration: BoxDecoration(
                                        color: _isFeatured
                                            ? Colors.amber.withAlpha(26)
                                            : Colors.grey.withAlpha(26),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: _isFeatured
                                              ? Colors.amber
                                              : Colors.grey,
                                          width: 1,
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            _isFeatured
                                                ? Icons.star
                                                : Icons.star_border,
                                            color: _isFeatured
                                                ? Colors.amber
                                                : Colors.grey,
                                            size: 16,
                                          ),
                                          const SizedBox(width: 4),
                                          Flexible(
                                            child: Text(
                                              _isFeatured
                                                  ? 'Featured'
                                                  : 'Not Featured',
                                              style: TextStyle(
                                                color: _isFeatured
                                                    ? Colors.amber
                                                    : Colors.grey,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 12,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton.icon(
                              onPressed: _pickImages,
                              icon: const Icon(Icons.add_photo_alternate),
                              label: Text(AppLocalizations.of(context)!.addImages),
                              style: ElevatedButton.styleFrom(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                              ),
                            ),
                            const SizedBox(height: 8),
                            if (_selectedImages.isNotEmpty)
                              SizedBox(
                                height: 100,
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: _selectedImages.length,
                                  itemBuilder: (context, index) {
                                    return Padding(
                                      padding:
                                          const EdgeInsets.only(right: 8.0),
                                      child: Stack(
                                        children: [
                                          ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            child: kIsWeb
                                                ? Image.network(
                                                    _selectedImages[index].path,
                                                    width: 100,
                                                    height: 100,
                                                    fit: BoxFit.cover,
                                                    errorBuilder: (context,
                                                        error, stackTrace) {
                                                      return Container(
                                                        width: 100,
                                                        height: 100,
                                                        color: Colors.grey[300],
                                                        child: Column(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                          children: [
                                                            Icon(
                                                                Icons
                                                                    .error_outline,
                                                                size: 32,
                                                                color: Colors
                                                                    .grey[600]),
                                                            const SizedBox(
                                                                height: 4),
                                                            Text(
                                                              'Invalid image',
                                                              style: TextStyle(
                                                                color: Colors
                                                                    .grey[600],
                                                                fontSize: 12,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      );
                                                    },
                                                  )
                                                : Image.file(
                                                    File(_selectedImages[index]
                                                        .path),
                                                    width: 100,
                                                    height: 100,
                                                    fit: BoxFit.cover,
                                                    errorBuilder: (context,
                                                        error, stackTrace) {
                                                      return Container(
                                                        width: 100,
                                                        height: 100,
                                                        color: Colors.grey[300],
                                                        child: Column(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                          children: [
                                                            Icon(
                                                                Icons
                                                                    .error_outline,
                                                                size: 32,
                                                                color: Colors
                                                                    .grey[600]),
                                                            const SizedBox(
                                                                height: 4),
                                                            Text(
                                                              'Invalid image',
                                                              style: TextStyle(
                                                                color: Colors
                                                                    .grey[600],
                                                                fontSize: 12,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      );
                                                    },
                                                  ),
                                          ),
                                          Positioned(
                                            right: 0,
                                            top: 0,
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              child: IconButton(
                                                icon: const Icon(Icons.close,
                                                    color: Colors.red),
                                                onPressed: () {
                                                  setState(() {
                                                    _selectedImages
                                                        .removeAt(index);
                                                  });
                                                },
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _submitForm,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: Theme.of(context).primaryColor,
                        foregroundColor: Colors.white,
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator()
                          : Text(widget.product == null
                              ? 'Create Product'
                              : 'Update Product'),
                    ),
                  ],
                ),
              ),
            )
          : const Center(child: CircularProgressIndicator()),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    _unitController.dispose();
    super.dispose();
  }
}
