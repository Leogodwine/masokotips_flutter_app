import '../config/api_config.dart';

class FoodBeverage {
  final int id;
  final String name;
  final String slug;
  final String? description;
  final double price;
  final String? unit;
  final int stock;
  final String? imageUrl;
  final List<String>? images;
  final bool isActive;
  final bool isFeatured;
  final int sellerId;
  final int categoryId;
  final String? ingredients;
  final String? dietaryInfo;
  final DateTime? expirationDate;
  final String? storageConditions;
  final String? preparationTime;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Map<String, dynamic>? seller;
  final Map<String, dynamic>? category;
  final Map<String, dynamic>? user;
  final double rating;
  final int reviewsCount;

  // Computed properties for seller info
  String get sellerName {
    final username = user?['username'] ?? seller?['username'];
    if (username != null && username.toString().trim().isNotEmpty) {
      return username.toString();
    }
    return user?['name'] ?? seller?['name'] ?? 'Unknown Seller';
  }
  String? get sellerAvatar => seller?['avatar'];
  String? get sellerLocation => seller?['location'];
  String? get sellerPhone => seller?['phone'];

  static String _processImageUrl(String path) {
    path = path.replaceAll('\\', '/').trim();

    if (path.isEmpty) return '';

    if (path.startsWith('http://') || path.startsWith('https://')) {
      path = path.replaceAll(RegExp(r'/storage/+/storage/'), '/storage/');
      path = path.replaceAll(RegExp(r'/+/'), '/');
      if (path.startsWith('https:/') && !path.startsWith('https://')) {
        path = path.replaceFirst('https:/', 'https://');
      }
      if (path.startsWith('http:/') && !path.startsWith('http://')) {
        path = path.replaceFirst('http:/', 'http://');
      }
      return path;
    }

    final baseUrl = ApiConfig.baseUrl.replaceAll('/api', '');
    if (path.startsWith('/')) {
      path = path.substring(1);
    }
    if (!path.startsWith('storage/')) {
      path = 'storage/$path';
    }
    return '$baseUrl/$path';
  }

  // Getter for processed image URL
  String get processedImageUrl {
    if (imageUrl == null || imageUrl!.isEmpty) return '';
    return _processImageUrl(imageUrl!);
  }

  // Getter to get first image from images array (already processed)
  String get firstImageUrl {
    if (images != null && images!.isNotEmpty) {
      return _processImageUrl(images!.first);
    }
    return processedImageUrl;
  }

  FoodBeverage({
    required this.id,
    required this.name,
    required this.slug,
    this.description,
    required this.price,
    this.unit,
    required this.stock,
    this.imageUrl,
    this.images,
    required this.isActive,
    required this.isFeatured,
    required this.sellerId,
    required this.categoryId,
    this.ingredients,
    this.dietaryInfo,
    this.expirationDate,
    this.storageConditions,
    this.preparationTime,
    required this.createdAt,
    required this.updatedAt,
    this.seller,
    this.category,
    this.user,
    this.rating = 0.0,
    this.reviewsCount = 0,
  });

  factory FoodBeverage.fromJson(Map<String, dynamic> json) {
    String? imageUrl = json['image_url'];

    return FoodBeverage(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      slug: json['slug'] ?? '',
      description: json['description'],
      price: double.tryParse(json['price']?.toString() ?? '0') ?? 0.0,
      unit: json['unit'],
      stock: int.tryParse(json['stock']?.toString() ?? '0') ?? 0,
      imageUrl: imageUrl,
      images: json['images'] != null ? List<String>.from(json['images']) : null,
      isActive: json['is_active'] == 1 || json['is_active'] == true,
      isFeatured: json['is_featured'] == 1 || json['is_featured'] == true,
      sellerId: int.tryParse(json['seller_id']?.toString() ?? '0') ?? 0,
      categoryId: int.tryParse(json['category_id']?.toString() ?? '0') ?? 0,
      ingredients: json['ingredients'],
      dietaryInfo: json['dietary_info'],
      expirationDate: json['expiration_date'] != null
          ? DateTime.tryParse(json['expiration_date'])
          : null,
      storageConditions: json['storage_conditions'],
      preparationTime: json['preparation_time'],
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at'] ?? '') ?? DateTime.now(),
      seller: json['seller'],
      user: json['user'],
      category: json['category'],
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      reviewsCount: (json['reviews_count'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'id': id,
      'name': name,
      'slug': slug,
      'description': description,
      'price': price,
      'unit': unit,
      'stock': stock,
      'image_url': imageUrl,
      'images': images,
      'is_active': isActive ? 1 : 0,
      'is_featured': isFeatured ? 1 : 0,
      'seller_id': sellerId,
      'category_id': categoryId,
      'ingredients': ingredients,
      'dietary_info': dietaryInfo,
      'storage_conditions': storageConditions,
      'preparation_time': preparationTime,
      'rating': rating,
      'reviews_count': reviewsCount,
    };

    if (expirationDate != null) {
      data['expiration_date'] = expirationDate!.toIso8601String();
    }
    data['created_at'] = createdAt.toIso8601String();
    data['updated_at'] = updatedAt.toIso8601String();

    return data;
  }
}
