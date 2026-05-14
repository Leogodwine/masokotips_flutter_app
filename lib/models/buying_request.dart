class BuyingRequest {
  final int id;
  final int userId;
  final String title;
  final String description;
  final double quantity;
  final String unit;
  final String deliveryLocation;
  final String? imageUrl;
  final String status;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? expiresAt;
  final Map<String, dynamic>? user;

  BuyingRequest({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.quantity,
    required this.unit,
    required this.deliveryLocation,
    this.imageUrl,
    required this.status,
    required this.isActive,
    required this.createdAt,
    this.expiresAt,
    this.user,
  });

  factory BuyingRequest.fromJson(Map<String, dynamic> json) {
    return BuyingRequest(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      quantity: double.tryParse(json['quantity']?.toString() ?? '0') ?? 0.0,
      unit: json['unit'] ?? 'tons',
      deliveryLocation: json['delivery_location'] ?? '',
      imageUrl: json['image_url'],
      status: json['status'] ?? 'open',
      isActive: json['is_active'] ?? true,
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      expiresAt: json['expires_at'] != null
          ? DateTime.tryParse(json['expires_at'])
          : null,
      user: json['user'],
    );
  }

  /// True when the post is still live (not expired).
  bool get isLive =>
      expiresAt == null || expiresAt!.isAfter(DateTime.now());

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'description': description,
      'quantity': quantity,
      'unit': unit,
      'delivery_location': deliveryLocation,
      'image_url': imageUrl,
      'status': status,
      'is_active': isActive,
      'expires_at': expiresAt?.toIso8601String(),
    };
  }
}
