import 'product.dart';
import 'organic_product.dart';
import 'service.dart';
import 'transport.dart';

class SellerPublicProfile {
  final String id;
  final String name;
  final String? avatar;
  final String? phone;
  final double rating;
  final DateTime? joinedAt;
  final List<Product> products;
  final List<OrganicProduct> organicProducts;
  final List<Service> services;
  final List<Transport> transports;

  SellerPublicProfile({
    required this.id,
    required this.name,
    this.avatar,
    this.phone,
    required this.rating,
    this.joinedAt,
    required this.products,
    required this.organicProducts,
    required this.services,
    required this.transports,
  });

  factory SellerPublicProfile.fromJson(Map<String, dynamic> json) {
    var userJson = json['user'] ?? {};

    String displayUsername = userJson['username']?.toString() ?? '';
    String displayName = userJson['name']?.toString() ?? 'Unknown Seller';

    return SellerPublicProfile(
      id: userJson['id']?.toString() ?? '',
      name: displayUsername.trim().isNotEmpty ? displayUsername : displayName,
      avatar: userJson['avatar'],
      phone: userJson['phone'],
      rating: (userJson['rating'] ?? 0.0).toDouble(),
      joinedAt: userJson['joined_at'] != null 
          ? DateTime.tryParse(userJson['joined_at'])
          : null,
      products: (json['products'] as List?)
              ?.map((e) => Product.fromJson(e))
              .toList() ??
          [],
      organicProducts: (json['organic_products'] as List?)
              ?.map((e) => OrganicProduct.fromJson(e))
              .toList() ??
          [],
      services: (json['services'] as List?)
              ?.map((e) => Service.fromJson(e))
              .toList() ??
          [],
      transports: (json['transports'] as List?)
              ?.map((e) => Transport.fromJson(e))
              .toList() ??
          [],
    );
  }
}
