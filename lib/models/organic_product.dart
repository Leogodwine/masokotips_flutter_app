class OrganicProduct {
  final int id;
  final String name;
  final String slug;
  final String? description;
  final double price;
  final int stock;
  final String? imageUrl;
  final List<String>? images;
  final bool isActive;
  final bool isFeatured;
  final int sellerId;
  final int categoryId;
  final String? certification;
  final String? origin;
  final DateTime? harvestDate;
  final String? storageConditions;
  final String? shelfLife;
  final DateTime createdAt;
  final DateTime updatedAt;

  OrganicProduct({
    required this.id,
    required this.name,
    required this.slug,
    this.description,
    required this.price,
    required this.stock,
    this.imageUrl,
    this.images,
    required this.isActive,
    required this.isFeatured,
    required this.sellerId,
    required this.categoryId,
    this.certification,
    this.origin,
    this.harvestDate,
    this.storageConditions,
    this.shelfLife,
    required this.createdAt,
    required this.updatedAt,
  });

  factory OrganicProduct.fromJson(Map<String, dynamic> json) {
    return OrganicProduct(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      slug: json['slug'] ?? '',
      description: json['description'],
      price: double.tryParse(json['price']?.toString() ?? '0') ?? 0.0,
      stock: int.tryParse(json['stock']?.toString() ?? '0') ?? 0,
      imageUrl: json['image_url'],
      images: json['images']?.cast<String>(),
      isActive: json['is_active'] == 1 || json['is_active'] == true,
      isFeatured: json['is_featured'] == 1 || json['is_featured'] == true,
      sellerId: int.tryParse(json['seller_id']?.toString() ?? '0') ?? 0,
      categoryId: int.tryParse(json['category_id']?.toString() ?? '0') ?? 0,
      certification: json['certification'],
      origin: json['origin'],
      harvestDate: json['harvest_date'] != null
          ? DateTime.tryParse(json['harvest_date'])
          : null,
      storageConditions: json['storage_conditions'],
      shelfLife: json['shelf_life'],
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at'] ?? '') ?? DateTime.now(),
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
      'image_url': imageUrl,
      'images': images,
      'is_active': isActive ? 1 : 0,
      'is_featured': isFeatured ? 1 : 0,
      'seller_id': sellerId,
      'category_id': categoryId,
      'certification': certification,
      'origin': origin,
      'harvest_date': harvestDate?.toIso8601String(),
      'storage_conditions': storageConditions,
      'shelf_life': shelfLife,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  OrganicProduct copyWith({
    int? id,
    String? name,
    String? slug,
    String? description,
    double? price,
    int? stock,
    String? imageUrl,
    List<String>? images,
    bool? isActive,
    bool? isFeatured,
    int? sellerId,
    int? categoryId,
    String? certification,
    String? origin,
    DateTime? harvestDate,
    String? storageConditions,
    String? shelfLife,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return OrganicProduct(
      id: id ?? this.id,
      name: name ?? this.name,
      slug: slug ?? this.slug,
      description: description ?? this.description,
      price: price ?? this.price,
      stock: stock ?? this.stock,
      imageUrl: imageUrl ?? this.imageUrl,
      images: images ?? this.images,
      isActive: isActive ?? this.isActive,
      isFeatured: isFeatured ?? this.isFeatured,
      sellerId: sellerId ?? this.sellerId,
      categoryId: categoryId ?? this.categoryId,
      certification: certification ?? this.certification,
      origin: origin ?? this.origin,
      harvestDate: harvestDate ?? this.harvestDate,
      storageConditions: storageConditions ?? this.storageConditions,
      shelfLife: shelfLife ?? this.shelfLife,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
