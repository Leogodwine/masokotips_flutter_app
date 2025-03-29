class Transport {
  final String id;
  final String title;
  final String description;
  final String fromLocation;
  final String toLocation;
  final String vehicleType;
  final DateTime departureTime;
  final DateTime arrivalTime;
  final double price;
  final List<String>? amenities;
  final String status;
  final String? imageUrl;
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

  Transport({
    required this.id,
    required this.title,
    required this.description,
    required this.fromLocation,
    required this.toLocation,
    required this.vehicleType,
    required this.departureTime,
    required this.arrivalTime,
    required this.price,
    this.amenities,
    required this.status,
    this.imageUrl,
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
  });

  factory Transport.fromJson(Map<String, dynamic> json) {
    print('Parsing Transport from JSON: $json');
    return Transport(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      fromLocation: json['from_location'] ?? '',
      toLocation: json['to_location'] ?? '',
      vehicleType: json['vehicle_type'] ?? '',
      departureTime: DateTime.parse(
          json['departure_time'] ?? DateTime.now().toIso8601String()),
      arrivalTime: DateTime.parse(
          json['arrival_time'] ?? DateTime.now().toIso8601String()),
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
      'from_location': fromLocation,
      'to_location': toLocation,
      'vehicle_type': vehicleType,
      'departure_time': departureTime.toIso8601String(),
      'arrival_time': arrivalTime.toIso8601String(),
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
    String? fromLocation,
    String? toLocation,
    String? vehicleType,
    DateTime? departureTime,
    DateTime? arrivalTime,
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
      fromLocation: fromLocation ?? this.fromLocation,
      toLocation: toLocation ?? this.toLocation,
      vehicleType: vehicleType ?? this.vehicleType,
      departureTime: departureTime ?? this.departureTime,
      arrivalTime: arrivalTime ?? this.arrivalTime,
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
