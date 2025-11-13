class ProviderProfile {
  final String id;
  final String name;
  final String imageUrl;
  final String description;
  final String email;
  final String phone;
  final String address;
  final double rating;
  final int reviewCount;
  final List<String> serviceCategories;
  final bool isVerified;

  ProviderProfile({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.description,
    required this.email,
    required this.phone,
    required this.address,
    required this.rating,
    required this.reviewCount,
    required this.serviceCategories,
    required this.isVerified,
  });

  factory ProviderProfile.fromJson(Map<String, dynamic> json) {
    return ProviderProfile(
      id: json['id'] as String,
      name: json['name'] as String,
      imageUrl: json['image_url'] as String,
      description: json['description'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String,
      address: json['address'] as String,
      rating: (json['rating'] as num).toDouble(),
      reviewCount: json['review_count'] as int,
      serviceCategories: (json['service_categories'] as List).cast<String>(),
      isVerified: json['is_verified'] as bool,
    );
  }
}
