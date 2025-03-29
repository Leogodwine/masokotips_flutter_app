import '../config/api_config.dart';

class Product {
  final int id;
  final String name;
  final String description;
  final double price;
  final int stock;
  final bool isActive;
  final bool isFeatured;
  final int categoryId;
  final int userId;
  final List<String> images;
  final Map<String, String>? specifications;
  final double rating;
  final int ratingCount;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final String? slug;

  String get imageUrl => images.isNotEmpty ? images[0] : '';

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

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.stock,
    required this.isActive,
    required this.isFeatured,
    required this.categoryId,
    required this.userId,
    required this.images,
    this.specifications,
    required this.rating,
    required this.ratingCount,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    this.slug,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: int.tryParse(json['id'].toString()) ?? 0,
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: double.tryParse(json['price'].toString()) ?? 0.0,
      stock: int.tryParse(json['stock'].toString()) ?? 0,
      isActive: json['is_active'] ?? false,
      isFeatured: json['is_featured'] == 1,
      categoryId: int.tryParse(json['category_id'].toString()) ?? 0,
      userId: int.tryParse(json['user_id'].toString()) ?? 0,
      images: (json['images'] as List<dynamic>?)
              ?.map((e) => _processImageUrl(e.toString()))
              .toList() ??
          [],
      specifications: json['specifications'] != null
          ? Map<String, String>.from(json['specifications'])
          : null,
      rating: double.tryParse(json['rating'].toString()) ?? 0.0,
      ratingCount: int.tryParse(json['rating_count'].toString()) ?? 0,
      createdAt: DateTime.parse(
          json['created_at'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(
          json['updated_at'] ?? DateTime.now().toIso8601String()),
      deletedAt: json['deleted_at'] != null
          ? DateTime.parse(json['deleted_at'])
          : null,
      slug: json['slug'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'price': price,
      'stock': stock,
      'is_active': isActive,
      'is_featured': isFeatured ? 1 : 0,
      'category_id': categoryId,
      'images': images,
      'specifications': specifications,
      'slug': slug,
    };
  }

  // Add the copyWith method
  Product copyWith({
    int? id,
    String? name,
    String? description,
    double? price,
    int? stock,
    bool? isActive,
    bool? isFeatured,
    int? categoryId,
    int? userId,
    List<String>? images,
    Map<String, String>? specifications,
    double? rating,
    int? ratingCount,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
    String? slug,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      stock: stock ?? this.stock,
      isActive: isActive ?? this.isActive,
      isFeatured: isFeatured ?? this.isFeatured,
      categoryId: categoryId ?? this.categoryId,
      userId: userId ?? this.userId,
      images: images ?? this.images,
      specifications: specifications ?? this.specifications,
      rating: rating ?? this.rating,
      ratingCount: ratingCount ?? this.ratingCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      slug: slug ?? this.slug,
    );
  }
}
