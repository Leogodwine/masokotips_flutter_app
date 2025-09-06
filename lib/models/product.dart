import 'package:flutter/foundation.dart';
import '../config/api_config.dart';

class Product {
  final int id;
  final String name;
  final String slug;
  final String description;
  final double price;
  final int? stock;
  final String? unit;
  final bool isActive;
  final bool isFeatured;
  final String imageUrl;
  final int categoryId;
  final int userId;
  final List<String>? images;
  final Map<String, dynamic>? specifications;
  final double rating;
  final int ratingCount;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final Map<String, dynamic>? category;

  // Category name from category map or fallback
  String get categoryName {
    if (category != null && category!['name'] != null) {
      return category!['name'];
    }
    const categoryMap = {
      1: 'Products',
      3: 'Market Information',
      4: 'Transport',
      5: 'Organic Products',
      6: 'Agricultural Services',
      11: 'Vegetables',
      12: 'Fruits',
      13: 'Spices',
      14: 'Cash Crops',
      15: 'Cereals',
      16: 'Seeds and Seedling',
      17: 'Livestock and poultry',
      41: 'Tandem',
      42: 'Kirikuu',
      43: 'FlatbedTrucks',
      44: 'Tanker',
      45: 'Refrigerator Truck',
      46: 'Box Truck',
      47: 'Liftgate Truck',
      48: 'Van',
      49: 'Container Hauler',
      410: 'Pickups Trucks',
      411: 'Fuso',
      412: 'Semi Trailers',
      413: 'Tracker Trailers',
      51: 'Organic Vegetables',
      52: 'Organic Fruits',
      53: 'Organic Spices',
      54: 'Organic Cash Crops',
      55: 'Organic Cereals',
      56: 'Organic Livestock and Poultry',
      61: 'Packaging Materials',
      62: 'Hydroponics',
      63: 'Fertilizer',
      64: 'Organic Manure',
      65: 'Machinery',
      66: 'Behive and Aquatic',
      67: 'Food and Beverage'
    };
    return categoryMap[categoryId] ?? 'Unknown Category';
  }

  // Getter to safely access and process first image
  String get firstImageUrl {
    if (images != null && images!.isNotEmpty) {
      return _processImageUrl(images!.first);
    }
    return imageUrl;
  }

  Product({
    required this.id,
    required this.name,
    required this.slug,
    required this.description,
    required this.price,
    this.stock,
    this.unit,
    required this.isActive,
    required this.isFeatured,
    required this.imageUrl,
    required this.categoryId,
    required this.userId,
    this.images,
    this.specifications,
    required this.rating,
    required this.ratingCount,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    this.category,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    // Handle image URL - use image_url if available, otherwise first from images[]
    String imageUrl = json['image_url'] ?? '';
    if (imageUrl.isEmpty &&
        json['images'] != null &&
        (json['images'] as List).isNotEmpty) {
      imageUrl = json['images'][0];
    }

    imageUrl = _processImageUrl(imageUrl);
    if (kDebugMode) {
      // Log only in debug to avoid verbose logs in production
      // ignore: avoid_print
      print('✅ Final processed image URL: $imageUrl');
    }

    return Product(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      slug: json['slug'] ?? '',
      description: json['description'] ?? '',
      price: () {
        final priceStr = json['price']?.toString() ?? '0';
        final price = double.tryParse(priceStr) ?? 0.0;
        if (kDebugMode) {
          print('Price parsing: "$priceStr" -> $price');
        }
        return price;
      }(),
      stock:
          json['stock'] != null ? int.tryParse(json['stock'].toString()) : null,
      unit: json['unit'],
      isActive: json['is_active'] ?? true,
      isFeatured: json['is_featured'] == true ||
          json['is_featured'] == 1 ||
          json['is_featured'] == '1',
      imageUrl: imageUrl,
      categoryId: int.tryParse(json['category_id']?.toString() ?? '0') ?? 0,
      userId: int.tryParse(json['user_id']?.toString() ?? '0') ?? 0,
      images: json['images'] != null ? List<String>.from(json['images']) : null,
      specifications: json['specifications'],
      rating: double.tryParse(json['rating']?.toString() ?? '0') ?? 0.0,
      ratingCount: int.tryParse(json['rating_count']?.toString() ?? '0') ?? 0,
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at'] ?? '') ?? DateTime.now(),
      deletedAt: json['deleted_at'] != null
          ? DateTime.tryParse(json['deleted_at'])
          : null,
      category: json['category'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'slug': slug,
      'description': description,
      'price': price,
      'stock': stock,
      'unit': unit,
      'is_active': isActive,
      'is_featured': isFeatured,
      'image_url': imageUrl,
      'category_id': categoryId,
      'user_id': userId,
      'images': images,
      'specifications': specifications,
      'rating': rating,
      'rating_count': ratingCount,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'deleted_at': deletedAt?.toIso8601String(),
      'category': category,
    };
  }

  static String _processImageUrl(String path) {
    path = path.replaceAll('\\', '/').trim();

    if (path.isEmpty) return '';

    if (path.startsWith('http://') || path.startsWith('https://')) {
      return path;
    }

    final base = Uri.parse(ApiConfig.baseUrl);
    final cleanBase = '${base.scheme}://${base.host}';

    if (path.startsWith('/')) {
      path = path.substring(1);
    }

    if (!path.startsWith('storage/')) {
      path = 'storage/$path';
    }

    return '$cleanBase/$path';
  }

  Product copyWith({
    int? id,
    String? name,
    String? slug,
    String? description,
    double? price,
    int? stock,
    String? unit,
    bool? isActive,
    bool? isFeatured,
    String? imageUrl,
    int? categoryId,
    int? userId,
    List<String>? images,
    Map<String, dynamic>? specifications,
    double? rating,
    int? ratingCount,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
    Map<String, dynamic>? category,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      slug: slug ?? this.slug,
      description: description ?? this.description,
      price: price ?? this.price,
      stock: stock ?? this.stock,
      unit: unit ?? this.unit,
      isActive: isActive ?? this.isActive,
      isFeatured: isFeatured ?? this.isFeatured,
      imageUrl: imageUrl ?? this.imageUrl,
      categoryId: categoryId ?? this.categoryId,
      userId: userId ?? this.userId,
      images: images ?? this.images,
      specifications: specifications ?? this.specifications,
      rating: rating ?? this.rating,
      ratingCount: ratingCount ?? this.ratingCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      category: category ?? this.category,
    );
  }
}
