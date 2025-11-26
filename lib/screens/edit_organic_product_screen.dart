import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../models/organic_product.dart';
import '../models/category.dart' as models;
import '../providers/organic_product_provider.dart';
import '../providers/auth_provider.dart';
import '../services/category_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';

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
  DateTime? _harvestDate;
  bool _isActive = true;
  bool _isFeatured = false;
  List<String> _images = [];
  bool _isLoading = false;
  int? _selectedCategoryId;
  List<models.Category> _subcategories = [];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.product?.name ?? '');
    _descriptionController =
        TextEditingController(text: widget.product?.description ?? '');
    _priceController =
        TextEditingController(text: widget.product?.price.toString() ?? '');
    _stockController =
        TextEditingController(text: widget.product?.stock.toString() ?? '');
    _certificationController =
        TextEditingController(text: widget.product?.certification ?? '');
    _originController =
        TextEditingController(text: widget.product?.origin ?? '');
    _storageConditionsController =
        TextEditingController(text: widget.product?.storageConditions ?? '');
    _shelfLifeController =
        TextEditingController(text: widget.product?.shelfLife ?? '');
    _harvestDate = widget.product?.harvestDate;
    _isActive = widget.product?.isActive ?? true;
    _isFeatured = widget.product?.isFeatured ?? false;
    _images = widget.product?.images ?? [];
    _loadSubcategories();
  }

  Future<void> _loadSubcategories() async {
    try {
      final categoryService = CategoryService();
      final authProvider = context.read<AuthProvider>();
      if (authProvider.token != null) {
        categoryService.setAuthToken(authProvider.token!);
      }

      debugPrint('Loading categories from API...');
      // Load all categories from API
      final allCategories = await categoryService.getCategories();
      debugPrint('Loaded ${allCategories.length} categories from API');

      // Use all categories (don't filter, as the API may not return all categories consistently)
      final categoriesToUse = allCategories;

      debugPrint('Using all ${categoriesToUse.length} categories:');
      for (var cat in categoriesToUse) {
        debugPrint('  - ID: ${cat.id}, Name: ${cat.name}, Slug: ${cat.slug}');
      }

      setState(() {
        _subcategories = categoriesToUse;

        // Always set _selectedCategoryId safely after categories are loaded
        if (_subcategories.isNotEmpty) {
          if (widget.product != null) {
            final productCategoryId = widget.product!.categoryId;
            debugPrint('Product categoryId: $productCategoryId');
            debugPrint(
                'Available category IDs: ${_subcategories.map((c) => c.id).toList()}');

            final categoryExists =
                _subcategories.any((cat) => cat.id == productCategoryId);
            if (categoryExists) {
              _selectedCategoryId = productCategoryId;
              debugPrint(
                  'Category exists, setting selectedCategoryId to $productCategoryId');
            } else {
              // Category doesn't exist in loaded categories, set to null to prevent crash
              _selectedCategoryId = null;
              debugPrint(
                  'Category $productCategoryId not found in loaded categories, setting selectedCategoryId to null');
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                        'Product category not found in current categories. Please select a category.'),
                    backgroundColor: Colors.orange,
                  ),
                );
              }
            }
          } else {
            // For new products, select the first category
            _selectedCategoryId = _subcategories.first.id;
            debugPrint(
                'New product, setting selectedCategoryId to ${_subcategories.first.id}');
          }
        } else {
          // No categories available
          _selectedCategoryId = null;
          debugPrint('No categories available, selectedCategoryId set to null');
        }
      });
    } catch (e) {
      debugPrint('Error loading categories: $e');
      // Fallback to hardcoded categories if API fails
      final fallbackCategories = [
        models.Category(
            id: 1,
            name: 'Organic Vegetables',
            slug: 'organic-vegetables',
            isActive: true,
            sortOrder: 1),
        models.Category(
            id: 2,
            name: 'Organic Fruits',
            slug: 'organic-fruits',
            isActive: true,
            sortOrder: 2),
        models.Category(
            id: 3,
            name: 'Organic Spices',
            slug: 'organic-spices',
            isActive: true,
            sortOrder: 3),
        models.Category(
            id: 4,
            name: 'Organic Cash Crops',
            slug: 'organic-cash-crops',
            isActive: true,
            sortOrder: 4),
        models.Category(
            id: 5,
            name: 'Organic Cereals',
            slug: 'organic-cereals',
            isActive: true,
            sortOrder: 5),
        models.Category(
            id: 6,
            name: 'Organic Livestock and Poultry',
            slug: 'organic-livestock-and-poultry',
            isActive: true,
            sortOrder: 6),
      ];

      setState(() {
        _subcategories = fallbackCategories;
        _selectedCategoryId = null; // Reset first

        // Always set _selectedCategoryId safely after categories are loaded
        if (_subcategories.isNotEmpty) {
          if (widget.product != null) {
            final productCategoryId = widget.product!.categoryId;
            final categoryExists =
                _subcategories.any((cat) => cat.id == productCategoryId);
            if (categoryExists) {
              _selectedCategoryId = productCategoryId;
            } else {
              // Category doesn't exist in fallback, keep as null
              debugPrint(
                  'Product category $productCategoryId not found in fallback categories');
            }
          } else {
            _selectedCategoryId = _subcategories.first.id;
          }
        } else {
          debugPrint('No fallback categories available');
        }
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Failed to load categories: $e. Using default categories.'),
            backgroundColor: Colors.orange,
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

  Widget _buildImageGrid() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Product Images',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        if (_images.isNotEmpty)
          SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _images.length,
              itemBuilder: (context, index) {
                final imagePath = _images[index];
                return Container(
                  width: 100,
                  margin: const EdgeInsets.only(right: 8.0),
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: imagePath.startsWith('http')
                            ? CachedNetworkImage(
                                imageUrl: imagePath,
                                height: 100,
                                width: 100,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => Container(
                                  height: 100,
                                  width: 100,
                                  color: Colors.grey[200],
                                  child: const Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                ),
                                errorWidget: (context, url, error) => Container(
                                  height: 100,
                                  width: 100,
                                  color: Colors.grey[200],
                                  child: const Icon(Icons.error),
                                ),
                              )
                            : kIsWeb
                                ? Image.network(
                                    imagePath,
                                    height: 100,
                                    width: 100,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        height: 100,
                                        width: 100,
                                        color: Colors.grey[200],
                                        child: const Icon(Icons.error),
                                      );
                                    },
                                  )
                                : Image.file(
                                    File(imagePath),
                                    height: 100,
                                    width: 100,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        height: 100,
                                        width: 100,
                                        color: Colors.grey[200],
                                        child: const Icon(Icons.error),
                                      );
                                    },
                                  ),
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _images.removeAt(index);
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        const SizedBox(height: 16),
        Row(
          children: [
            ElevatedButton.icon(
              onPressed: _pickImage,
              icon: const Icon(Icons.add_photo_alternate),
              label: const Text('Add Images'),
            ),
            if (_images.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Text(
                  '${_images.length} image(s) selected',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }

  Future<void> _pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final List<XFile> images = await picker.pickMultiImage(
        imageQuality: 80,
        maxWidth: 1200,
        maxHeight: 1200,
      );

      if (images.isEmpty) return;

      // Debug print the selected images
      debugPrint('Selected images: ${images.map((img) => img.path).toList()}');

      // Validate file extensions
      final validExtensions = ['gif', 'png', 'jpg', 'jpeg'];
      final invalidImages = images.where((image) {
        final path = image.path.toLowerCase();

        // Handle blob URLs (web platform)
        if (path.startsWith('blob:')) {
          // For blob URLs, we'll trust the image picker since it only allows image files
          return false;
        }

        // For regular file paths, validate the extension
        final extension = path.contains('.') ? path.split('.').last.trim() : '';
        debugPrint(
            'Checking extension: $extension for file: $path'); // Debug print

        // Check if the extension is valid
        final isValid = validExtensions.contains(extension);
        debugPrint('Is valid extension? $isValid'); // Debug print
        return !isValid;
      }).toList();

      if (invalidImages.isNotEmpty) {
        debugPrint(
            'Invalid images found: ${invalidImages.map((img) => img.path).toList()}'); // Debug print
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content:
                  Text('Only .gif, .png, .jpg, and .jpeg files are allowed'),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 5),
            ),
          );
        }
        return;
      }

      // Clear existing images if this is a new product
      if (widget.product == null) {
        setState(() {
          _images.clear();
        });
      }

      // Add valid images to the list
      setState(() {
        _images.addAll(images.map((image) => image.path));
      });
    } catch (e) {
      debugPrint('Error picking images: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error picking images: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  Future<void> _selectHarvestDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _harvestDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _harvestDate && mounted) {
      setState(() {
        _harvestDate = picked;
      });
    }
  }

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a category')),
      );
      return;
    }

    // Debug print the images before saving
    debugPrint('Images to be saved: $_images');

    // Validate that we have at least one valid image
    if (_images.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add at least one product image'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final authProvider = context.read<AuthProvider>();
      final provider = context.read<OrganicProductProvider>();
      final scaffoldMessenger = ScaffoldMessenger.of(context);
      final navigator = Navigator.of(context);

      // Convert blob URLs to actual files if needed
      List<String> processedImages = [];
      for (String imagePath in _images) {
        if (imagePath.startsWith('blob:')) {
          // For blob URLs, we need to convert them to actual files
          // This will be handled by the provider when making the API request
          processedImages.add(imagePath);
        } else if (imagePath.startsWith('http')) {
          // For existing HTTP URLs, keep them as is
          processedImages.add(imagePath);
        } else {
          // For local file paths, keep them as is
          processedImages.add(imagePath);
        }
      }

      // Create a copy of the product with updated fields
      final product = OrganicProduct(
        id: widget.product?.id ?? 0,
        name: _nameController.text,
        slug: _nameController.text.toLowerCase().replaceAll(' ', '-'),
        description: _descriptionController.text,
        price: double.parse(_priceController.text),
        stock: int.parse(_stockController.text),
        imageUrl: processedImages.isNotEmpty ? processedImages[0] : null,
        images: processedImages,
        isActive: _isActive,
        isFeatured: _isFeatured,
        sellerId: authProvider.user?.id ?? 0,
        categoryId: _selectedCategoryId!,
        certification: _certificationController.text,
        origin: _originController.text,
        harvestDate: _harvestDate,
        storageConditions: _storageConditionsController.text,
        shelfLife: _shelfLifeController.text,
        createdAt: widget.product?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      if (widget.product == null) {
        await provider.createProduct(product);
        if (mounted) {
          scaffoldMessenger.showSnackBar(
            const SnackBar(
              content: Text('Product created successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        await provider.updateProduct(product);
        if (mounted) {
          scaffoldMessenger.showSnackBar(
            const SnackBar(
              content: Text('Product updated successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }

      if (mounted) {
        navigator.pop(true);
      }
    } catch (e) {
      debugPrint('Error saving product: $e'); // Debug print
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _deleteProduct() async {
    final provider = context.read<OrganicProductProvider>();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Product'),
        content: const Text(
          'Are you sure you want to delete this product? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && widget.product != null) {
      setState(() => _isLoading = true);

      try {
        await provider.deleteProduct(widget.product!.id);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Product deleted successfully'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.of(context).pop(true);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error deleting product: $e'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 5),
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.product == null
              ? 'Add Organic Product'
              : 'Edit Organic Product',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onPrimary,
          ),
        ),
        elevation: 0,
        backgroundColor: theme.primaryColor,
        iconTheme: IconThemeData(color: theme.colorScheme.onPrimary),
        actions: [
          if (widget.product != null)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: _deleteProduct,
              tooltip: 'Delete Product',
              color: theme.colorScheme.onPrimary,
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Basic Information Card
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Basic Information',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.primaryColor,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: 'Name',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        prefixIcon: const Icon(Icons.inventory_2_outlined),
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
                      decoration: InputDecoration(
                        labelText: 'Description',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        prefixIcon: const Icon(Icons.description_outlined),
                      ),
                      maxLines: 3,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Pricing and Stock Card
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pricing & Stock',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.primaryColor,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _priceController,
                      decoration: InputDecoration(
                        labelText: 'Price',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        prefixIcon: const Icon(Icons.attach_money),
                        prefixText: 'TZS',
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
                      decoration: InputDecoration(
                        labelText: 'Stock',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        prefixIcon: const Icon(Icons.inventory),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter stock quantity';
                        }
                        if (int.tryParse(value) == null) {
                          return 'Please enter a valid stock quantity';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Category and Certification Card
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Category & Certification',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.primaryColor,
                      ),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<int>(
                      value: _selectedCategoryId,
                      isExpanded: true,
                      decoration: InputDecoration(
                        labelText: 'Category',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        prefixIcon: const Icon(Icons.category),
                      ),
                      items: _subcategories.map((category) {
                        return DropdownMenuItem(
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
                    TextFormField(
                      controller: _certificationController,
                      decoration: InputDecoration(
                        labelText: 'Certification',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        prefixIcon: const Icon(Icons.verified),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Product Details Card
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Product Details',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.primaryColor,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _originController,
                      decoration: InputDecoration(
                        labelText: 'Origin',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        prefixIcon: const Icon(Icons.location_on_outlined),
                      ),
                    ),
                    const SizedBox(height: 16),
                    InkWell(
                      onTap: _selectHarvestDate,
                      child: InputDecorator(
                        decoration: InputDecoration(
                          labelText: 'Harvest Date',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          prefixIcon: const Icon(Icons.calendar_today),
                        ),
                        child: Text(
                          _harvestDate?.toString().split(' ')[0] ??
                              'Select Date',
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _storageConditionsController,
                      decoration: InputDecoration(
                        labelText: 'Storage Conditions',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        prefixIcon: const Icon(Icons.storage),
                      ),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _shelfLifeController,
                      decoration: InputDecoration(
                        labelText: 'Shelf Life',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        prefixIcon: const Icon(Icons.timer),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Status Card
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Status',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.primaryColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SwitchListTile(
                      title: const Text('Active'),
                      subtitle: const Text('Make product visible to customers'),
                      value: _isActive,
                      onChanged: (value) => setState(() => _isActive = value),
                      activeColor: theme.primaryColor,
                    ),
                    SwitchListTile(
                      title: const Text('Featured'),
                      subtitle: const Text('Show product in featured section'),
                      value: _isFeatured,
                      onChanged: (value) => setState(() => _isFeatured = value),
                      activeColor: theme.primaryColor,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Images Card
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Product Images',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.primaryColor,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildImageGrid(),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Save Button
            Container(
              width: double.infinity,
              margin: const EdgeInsets.symmetric(vertical: 24),
              child: ElevatedButton(
                onPressed: _isLoading ? null : _saveProduct,
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.primaryColor,
                  foregroundColor: theme.colorScheme.onPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
                child: _isLoading
                    ? SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                              theme.colorScheme.onPrimary),
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            widget.product == null
                                ? Icons.add_circle_outline
                                : Icons.save_outlined,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            widget.product == null
                                ? 'Create Product'
                                : 'Update Product',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
