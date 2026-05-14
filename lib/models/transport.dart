import 'category.dart' as models;
import '../config/api_config.dart';

String _processTransportImageUrl(String path) {
  path = path.replaceAll('\\', '/').trim();

  if (path.isEmpty) return '';

  if (path.startsWith('http://') || path.startsWith('https://')) {
      return path;
    }

  // Use the same robust cleanup logic as OrganicProduct
  final baseUrl = ApiConfig.baseUrl.replaceAll('/api', '');
  
  if (path.startsWith('/')) {
    path = path.substring(1);
  }

  if (!path.startsWith('storage/')) {
    path = 'storage/$path';
  }

  return '$baseUrl/$path';
}

class Transport {
  final int? id;
  final String title;
  final String? description;
  final String vehicleLocation;
  final String vehicleType;
  final double price;
  final double capacity;
  final bool isTemperatureControlled;
  final double? temperatureRange;
  final List<String>? supportedProductTypes;
  final String? driverId;
  final double? driverRating;
  final bool hasInsurance;
  final String? insuranceDetails;
  final List<String>? certifications;
  final List<String>? amenities;
  final String status;
  final String? imageUrl;
  final String ownerName;
  final double? pricePerKg;
  final String? driverName;
  final String? driverPhone;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? productName;
  final String? productType;
  final double? amount;
  final int? categoryId;
  final models.Category? category;
  final Map<String, dynamic>? user;
  final int? userId;

  // Computed properties for seller info
  String get sellerName {
    final username = user?['username'];
    if (username != null && username.toString().trim().isNotEmpty) {
      return username.toString();
    }
    if (user != null && user!['name'] != null && user!['name'].toString().trim().isNotEmpty) {
      return user!['name'];
    }
    if (ownerName.isNotEmpty) return ownerName;
    return title;
  }
  String? get sellerAvatar => user?['avatar'];
  String? get sellerLocation => user?['location'];
  String? get sellerPhone => user?['phone'];

  static double _stringToDouble(String? value) {
    if (value == null) return 0.0;
    return double.tryParse(value) ?? 0.0;
  }

  static double? _stringToDoubleNullable(String? value) {
    if (value == null) return null;
    return double.tryParse(value);
  }

  static List<String> _ensureStringList(dynamic value) {
    if (value == null) return [];
    if (value is List) {
      return value.map((e) => e.toString()).toList();
    }
    return [];
  }

  static String _standardizeProductType(String? value) {
    if (value == null) return '';
    return value;
  }

  Transport({
    this.id,
    required this.title,
    this.description,
    required this.vehicleLocation,
    required this.vehicleType,
    required this.price,
    required this.capacity,
    required this.isTemperatureControlled,
    this.temperatureRange,
    this.supportedProductTypes,
    this.driverId,
    this.driverRating,
    required this.hasInsurance,
    this.insuranceDetails,
    this.certifications,
    this.amenities,
    required this.status,
    this.imageUrl,
    required this.ownerName,
    this.pricePerKg,
    this.driverName,
    this.driverPhone,
    this.createdAt,
    this.updatedAt,
    this.productName,
    this.productType,
    this.amount,
    this.categoryId,
    this.category,
    this.user,
    this.userId,
  });

  // Getter for processed image URL
  String get processedImageUrl {
    if (imageUrl == null || imageUrl!.isEmpty) return '';
    return _processTransportImageUrl(imageUrl!);
  }

  factory Transport.fromJson(Map<String, dynamic> json) {
    return Transport(
      id: (json['id'] as num?)?.toInt(),
      title: json['title'] as String? ?? 'Unknown',
      description: json['description'] as String?,
      vehicleLocation: json['vehicle_location'] as String? ?? 'Unknown',
      vehicleType: json['vehicle_type'] as String? ?? 'Unknown',
      price: _stringToDouble(json['price']?.toString()),
      capacity: _stringToDouble(json['capacity']?.toString()),
      isTemperatureControlled:
          json['is_temperature_controlled'] == true || json['is_temperature_controlled'] == 1,
      temperatureRange: _stringToDoubleNullable(json['temperature_range']?.toString()),
      supportedProductTypes: _ensureStringList(json['supported_product_types']),
      driverId: json['driver_id']?.toString(),
      driverRating: _stringToDoubleNullable(json['driver_rating']?.toString()),
      hasInsurance: json['has_insurance'] == true || json['has_insurance'] == 1,
      insuranceDetails: json['insurance_details'] as String?,
      certifications: json['certifications'] != null
          ? (json['certifications'] as List<dynamic>).map((e) => e.toString()).toList()
          : null,
      amenities: json['amenities'] != null
          ? (json['amenities'] as List<dynamic>).map((e) => e.toString()).toList()
          : null,
      status: json['status'] as String? ?? 'active',
      imageUrl: json['image_url'] as String?,
      ownerName: json['owner_name'] as String? ?? '',
      pricePerKg: _stringToDoubleNullable(json['price_per_kg']?.toString()),
      driverName: json['driver_name'] as String?,
      driverPhone: json['driver_phone'] as String?,
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.tryParse(json['updated_at']) : null,
      productName: json['product_name'] as String?,
      productType: _standardizeProductType(json['product_type'] as String?),
      amount: _stringToDouble(json['amount']?.toString()),
      categoryId: (json['category_id'] as num?)?.toInt(),
      category: json['category'] != null
          ? models.Category.fromJson(json['category'] as Map<String, dynamic>)
          : null,
      user: json['user'] as Map<String, dynamic>?,
      userId: (json['user_id'] as num?)?.toInt(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'vehicle_location': vehicleLocation,
      'vehicle_type': vehicleType,
      'price': price,
      'capacity': capacity,
      'is_temperature_controlled': isTemperatureControlled,
      'temperature_range': temperatureRange,
      'supported_product_types': supportedProductTypes,
      'driver_id': driverId,
      'driver_rating': driverRating,
      'has_insurance': hasInsurance,
      'insurance_details': insuranceDetails,
      'certifications': certifications,
      'amenities': amenities,
      'status': status,
      'image_url': imageUrl,
      'owner_name': ownerName,
      'price_per_kg': pricePerKg,
      'driver_name': driverName,
      'driver_phone': driverPhone,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'product_name': productName,
      'product_type': productType,
      'amount': amount,
      'category_id': categoryId,
      'user_id': userId,
    };
  }

  Transport copyWith({
    int? id,
    String? title,
    String? description,
    String? vehicleLocation,
    String? vehicleType,
    double? price,
    double? capacity,
    bool? isTemperatureControlled,
    double? temperatureRange,
    List<String>? supportedProductTypes,
    String? driverId,
    double? driverRating,
    bool? hasInsurance,
    String? insuranceDetails,
    List<String>? certifications,
    List<String>? amenities,
    String? status,
    String? imageUrl,
    String? ownerName,
    double? pricePerKg,
    String? driverName,
    String? driverPhone,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? productName,
    String? productType,
    double? amount,
    int? categoryId,
    models.Category? category,
    Map<String, dynamic>? user,
    int? userId,
  }) {
    return Transport(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      vehicleLocation: vehicleLocation ?? this.vehicleLocation,
      vehicleType: vehicleType ?? this.vehicleType,
      price: price ?? this.price,
      capacity: capacity ?? this.capacity,
      isTemperatureControlled:
          isTemperatureControlled ?? this.isTemperatureControlled,
      temperatureRange: temperatureRange ?? this.temperatureRange,
      supportedProductTypes:
          supportedProductTypes ?? this.supportedProductTypes,
      driverId: driverId ?? this.driverId,
      driverRating: driverRating ?? this.driverRating,
      hasInsurance: hasInsurance ?? this.hasInsurance,
      insuranceDetails: insuranceDetails ?? this.insuranceDetails,
      certifications: certifications ?? this.certifications,
      amenities: amenities ?? this.amenities,
      status: status ?? this.status,
      imageUrl: imageUrl ?? this.imageUrl,
      ownerName: ownerName ?? this.ownerName,
      pricePerKg: pricePerKg ?? this.pricePerKg,
      driverName: driverName ?? this.driverName,
      driverPhone: driverPhone ?? this.driverPhone,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      productName: productName ?? this.productName,
      productType: productType ?? this.productType,
      amount: amount ?? this.amount,
      categoryId: categoryId ?? this.categoryId,
      category: category ?? this.category,
      user: user ?? this.user,
      userId: userId ?? this.userId,
    );
  }
}
