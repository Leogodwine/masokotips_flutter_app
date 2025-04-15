import 'package:json_annotation/json_annotation.dart';

part 'transport.g.dart';

@JsonSerializable()
class Transport {
  final int id;
  final String title;
  final String? description;
  @JsonKey(name: 'vehicle_location')
  final String? vehicleLocation;
  @JsonKey(name: 'vehicle_type')
  final String? vehicleType;
  @JsonKey(fromJson: _stringToDouble)
  final double price;
  @JsonKey(fromJson: _stringToDouble)
  final double capacity;
  @JsonKey(name: 'is_temperature_controlled')
  final bool isTemperatureControlled;
  @JsonKey(name: 'temperature_range', fromJson: _stringToDoubleNullable)
  final double? temperatureRange;
  @JsonKey(name: 'supported_product_types', fromJson: _ensureStringList)
  final List<String> supportedProductTypes;
  @JsonKey(name: 'driver_id')
  final String? driverId;
  @JsonKey(name: 'driver_rating', fromJson: _stringToDoubleNullable)
  final double? driverRating;
  @JsonKey(name: 'has_insurance')
  final bool hasInsurance;
  @JsonKey(name: 'insurance_details')
  final String? insuranceDetails;
  final List<String>? certifications;
  final List<String>? amenities;
  final String status;
  @JsonKey(name: 'image_url')
  final String? imageUrl;
  @JsonKey(name: 'owner_name')
  final String? ownerName;
  @JsonKey(name: 'price_per_kg', fromJson: _stringToDoubleNullable)
  final double? pricePerKg;
  @JsonKey(name: 'driver_name')
  final String? driverName;
  @JsonKey(name: 'driver_phone')
  final String? driverPhone;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;
  @JsonKey(name: 'product_name')
  final String? productName;
  @JsonKey(name: 'product_type', fromJson: _standardizeProductType)
  final String? productType;
  @JsonKey(fromJson: _stringToDouble)
  final double? amount;

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
    required this.id,
    required this.title,
    this.description,
    this.vehicleLocation,
    this.vehicleType,
    required this.price,
    required this.capacity,
    required this.isTemperatureControlled,
    this.temperatureRange,
    required this.supportedProductTypes,
    this.driverId,
    this.driverRating,
    required this.hasInsurance,
    this.insuranceDetails,
    this.certifications,
    this.amenities,
    required this.status,
    this.imageUrl,
    this.ownerName,
    this.pricePerKg,
    this.driverName,
    this.driverPhone,
    required this.createdAt,
    required this.updatedAt,
    this.productName,
    this.productType,
    this.amount,
  });

  factory Transport.fromJson(Map<String, dynamic> json) =>
      _$TransportFromJson(json);

  Map<String, dynamic> toJson() => _$TransportToJson(this);

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
    );
  }
}
