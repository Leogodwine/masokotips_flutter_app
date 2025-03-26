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

  String get imageUrl => images.isNotEmpty ? images[0] : '';

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
              ?.map((e) => e.toString().replaceAll('\\/', '/'))
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
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'stock': stock,
      'is_active': isActive,
      'is_featured': isFeatured,
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
    );
  }
}
