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
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    // Handle image URL - use image_url if available, otherwise use first image from images array
    String imageUrl = json['image_url'] ?? '';
    if (imageUrl.isEmpty &&
        json['images'] != null &&
        (json['images'] as List).isNotEmpty) {
      imageUrl = json['images'][0];
    }

    // Process the image URL if it's not empty
    if (imageUrl.isNotEmpty) {
      imageUrl = _processImageUrl(imageUrl);
    }

    return Product(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      slug: json['slug'] ?? '',
      description: json['description'] ?? '',
      price: double.tryParse(json['price']?.toString() ?? '0') ?? 0.0,
      stock:
          json['stock'] != null ? int.tryParse(json['stock'].toString()) : null,
      unit: json['unit'],
      isActive: json['is_active'] ?? true,
      isFeatured: json['is_featured'] == 1,
      imageUrl: imageUrl,
      categoryId: int.tryParse(json['category_id']?.toString() ?? '0') ?? 0,
      userId: int.tryParse(json['user_id']?.toString() ?? '0') ?? 0,
      images: json['images'] != null
          ? (json['images'] as List).cast<String>()
          : null,
      specifications: json['specifications'],
      rating: double.tryParse(json['rating']?.toString() ?? '0') ?? 0.0,
      ratingCount: int.tryParse(json['rating_count']?.toString() ?? '0') ?? 0,
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at'] ?? '') ?? DateTime.now(),
      deletedAt: json['deleted_at'] != null
          ? DateTime.tryParse(json['deleted_at'])
          : null,
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
      'is_featured': isFeatured ? 1 : 0,
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
    };
  }

  // Helper method to process image URLs
  static String _processImageUrl(String path) {
    print('Processing image URL: $path');
    print('Base URL: ${ApiConfig.baseUrl}');

    if (path.isEmpty) {
      print('Empty path detected, returning empty string');
      return '';
    }

    // Remove any backslashes and trim whitespace
    path = path.replaceAll('\\', '/').trim();
    print('Cleaned path: $path');

    // If it's already a full URL, return it as is
    if (path.startsWith('http://') || path.startsWith('https://')) {
      print('Full URL detected, returning as is: $path');
      return path;
    }

    // Get the base URL without the /api suffix
    final baseUrl = ApiConfig.baseUrl.replaceAll('/api', '');

    // If the path already includes /storage/, don't add it again
    final storagePath = path.startsWith('/storage/') ? path : '/storage/$path';

    // Construct the full URL
    final fullUrl = '$baseUrl$storagePath';
    print('Constructed full URL: $fullUrl');
    return fullUrl;
  }

  // Add the copyWith method
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
    );
  }
}
