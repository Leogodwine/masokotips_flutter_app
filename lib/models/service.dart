class Service {
  final String id;
  final String title;
  final String description;
  final double price;
  final String imageUrl;
  final double rating;
  final int reviewCount;
  final String providerId;
  final String providerName;
  final String providerImage;
  final String category;
  final int categoryId; // Added categoryId

  Service({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.imageUrl,
    this.rating = 0.0,
    this.reviewCount = 0,
    required this.providerId,
    this.providerName = 'Unknown Provider',
    this.providerImage = 'https://via.placeholder.com/50',
    required this.category,
    required this.categoryId, // Initialize categoryId
  });

  factory Service.fromJson(Map<String, dynamic> json) {
    return Service(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      price: (json['price'] as num).toDouble(),
      imageUrl: json['image_url'] as String,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      reviewCount: json['review_count'] as int? ?? 0,
      providerId: json['provider_id'] as String,
      providerName: json['provider_name'] as String? ?? 'Unknown Provider',
      providerImage:
          json['provider_image'] as String? ?? 'https://via.placeholder.com/50',
      category: json['category'] as String,
      categoryId: json['category_id'], // Parse categoryId
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'price': price,
      'image_url': imageUrl,
      'rating': rating,
      'review_count': reviewCount,
      'provider_id': providerId,
      'provider_name': providerName,
      'provider_image': providerImage,
      'category': category,
      'category_id': categoryId, // Include categoryId
    };
  }
}
