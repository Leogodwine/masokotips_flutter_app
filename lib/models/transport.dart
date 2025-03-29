import '../config/api_config.dart';

class Transport {
  final String id;
  final String title;
  final String description;
  final String vehicleLocation;
  final String vehicleType;
  final double price;
  final List<String>? amenities;
  final String status;
  final String? _imageUrl;
  final double capacity; // in tons
  final bool isTemperatureControlled;
  final double? temperatureRange; // in Celsius
  final List<String> supportedProductTypes;
  final String? driverId;
  final double? driverRating;
  final bool hasInsurance;
  final String? insuranceDetails;
  final List<String>? certifications;
  final bool isAvailable;
  final String ownerName;
  final double? pricePerKg;
  final String driverName;
  final String driverPhone;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Map<String, dynamic>? driver;

  String? get imageUrl => _processImageUrl(_imageUrl);

  Transport({
    required this.id,
    required this.title,
    required this.description,
    required this.vehicleLocation,
    required this.vehicleType,
    required this.price,
    this.amenities,
    required this.status,
    String? imageUrl,
    required this.capacity,
    required this.isTemperatureControlled,
    this.temperatureRange,
    required this.supportedProductTypes,
    this.driverId,
    this.driverRating,
    required this.hasInsurance,
    this.insuranceDetails,
    this.certifications,
    this.isAvailable = true,
    required this.ownerName,
    this.pricePerKg,
    required this.driverName,
    required this.driverPhone,
    required this.createdAt,
    required this.updatedAt,
    this.driver,
  }) : _imageUrl = imageUrl;

  // Helper method to process image URLs
  String? _processImageUrl(String? path) {
    if (path == null || path.isEmpty) {
      return null;
    }

    // Remove any backslashes and trim whitespace
    path = path.replaceAll('\\', '/').trim();

    // If it's already a full URL, return it as is
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return path;
    }

    // Get the base URL without the /api suffix
    final baseUrl = ApiConfig.baseUrl.replaceAll('/api', '');

    // If the path already includes /storage/, don't add it again
    final storagePath = path.startsWith('/storage/') ? path : '/storage/$path';

    // Construct the full URL using the base URL
    return '$baseUrl$storagePath';
  }

  factory Transport.fromJson(Map<String, dynamic> json) {
    print('Parsing Transport from JSON: $json');
    return Transport(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      vehicleLocation: json['vehicle_location'] ?? '',
      vehicleType: json['vehicle_type'] ?? '',
      price: double.tryParse(json['price']?.toString() ?? '0') ?? 0.0,
      amenities: json['amenities'] != null
          ? List<String>.from(json['amenities'])
          : null,
      status: json['status'] ?? 'active',
      imageUrl: json['image_url'],
      capacity: double.tryParse(json['capacity']?.toString() ?? '0') ?? 0.0,
      isTemperatureControlled: json['is_temperature_controlled'] ?? false,
      temperatureRange: json['temperature_range'] != null
          ? double.tryParse(json['temperature_range'].toString())
          : null,
      supportedProductTypes: json['supported_product_types'] != null
          ? List<String>.from(json['supported_product_types'])
          : [],
      driverId: json['driver_id'],
      driverRating: json['driver_rating'] != null
          ? double.tryParse(json['driver_rating'].toString())
          : null,
      hasInsurance: json['has_insurance'] ?? false,
      insuranceDetails: json['insurance_details'],
      certifications: json['certifications'] != null
          ? List<String>.from(json['certifications']['certifications'] ?? [])
          : null,
      isAvailable: json['is_available'] ?? true,
      ownerName: json['owner_name'] ?? '',
      pricePerKg: json['price_per_kg'] != null
          ? double.tryParse(json['price_per_kg'].toString())
          : null,
      driverName: json['driver_name'] ?? '',
      driverPhone: json['driver_phone'] ?? '',
      createdAt: DateTime.parse(
          json['created_at'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(
          json['updated_at'] ?? DateTime.now().toIso8601String()),
      driver: json['driver'],
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
      'amenities': amenities,
      'status': status,
      'image_url': imageUrl,
      'capacity': capacity,
      'is_temperature_controlled': isTemperatureControlled,
      'temperature_range': temperatureRange,
      'supported_product_types': supportedProductTypes,
      'driver_id': driverId,
      'driver_rating': driverRating,
      'has_insurance': hasInsurance,
      'insurance_details': insuranceDetails,
      'certifications':
          certifications != null ? {'certifications': certifications} : null,
      'is_available': isAvailable,
      'owner_name': ownerName,
      'price_per_kg': pricePerKg,
      'driver_name': driverName,
      'driver_phone': driverPhone,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'driver': driver,
    };
  }

  Transport copyWith({
    String? id,
    String? title,
    String? description,
    String? vehicleLocation,
    String? vehicleType,
    double? price,
    List<String>? amenities,
    String? status,
    String? imageUrl,
    double? capacity,
    bool? isTemperatureControlled,
    double? temperatureRange,
    List<String>? supportedProductTypes,
    String? driverId,
    double? driverRating,
    bool? hasInsurance,
    String? insuranceDetails,
    List<String>? certifications,
    bool? isAvailable,
    String? ownerName,
    double? pricePerKg,
    String? driverName,
    String? driverPhone,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, dynamic>? driver,
  }) {
    return Transport(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      vehicleLocation: vehicleLocation ?? this.vehicleLocation,
      vehicleType: vehicleType ?? this.vehicleType,
      price: price ?? this.price,
      amenities: amenities ?? this.amenities,
      status: status ?? this.status,
      imageUrl: imageUrl ?? this.imageUrl,
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
      isAvailable: isAvailable ?? this.isAvailable,
      ownerName: ownerName ?? this.ownerName,
      pricePerKg: pricePerKg ?? this.pricePerKg,
      driverName: driverName ?? this.driverName,
      driverPhone: driverPhone ?? this.driverPhone,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      driver: driver ?? this.driver,
    );
  }
}
