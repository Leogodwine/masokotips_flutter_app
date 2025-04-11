import 'package:json_annotation/json_annotation.dart';

part 'transport.g.dart';

@JsonSerializable()
class Transport {
  final int id;
  final String name;
  final String description;
  final String type;
  final String status;
  final String? imageUrl;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<String> supportedProductTypes;
  final double capacity;
  final double price;
  final bool isTemperatureControlled;
  final String vehicleLocation;
  final String vehicleType;
  final double? temperatureRange;
  final String? driverId;
  final double? driverRating;
  final bool hasInsurance;
  final String? insuranceDetails;
  final List<String>? certifications;
  final List<String>? amenities;
  final String ownerName;
  final double? pricePerKg;
  final String driverName;
  final String driverPhone;

  Transport({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.status,
    this.imageUrl,
    required this.createdAt,
    required this.updatedAt,
    required this.supportedProductTypes,
    required this.capacity,
    required this.price,
    required this.isTemperatureControlled,
    required this.vehicleLocation,
    required this.vehicleType,
    this.temperatureRange,
    this.driverId,
    this.driverRating,
    required this.hasInsurance,
    this.insuranceDetails,
    this.certifications,
    this.amenities,
    required this.ownerName,
    this.pricePerKg,
    required this.driverName,
    required this.driverPhone,
  });

  factory Transport.fromJson(Map<String, dynamic> json) =>
      _$TransportFromJson(json);
  Map<String, dynamic> toJson() => _$TransportToJson(this);

  Transport copyWith({
    int? id,
    String? name,
    String? description,
    String? type,
    String? status,
    String? imageUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<String>? supportedProductTypes,
    double? capacity,
    double? price,
    bool? isTemperatureControlled,
    String? vehicleLocation,
    String? vehicleType,
    double? temperatureRange,
    String? driverId,
    double? driverRating,
    bool? hasInsurance,
    String? insuranceDetails,
    List<String>? certifications,
    List<String>? amenities,
    String? ownerName,
    double? pricePerKg,
    String? driverName,
    String? driverPhone,
  }) {
    return Transport(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      type: type ?? this.type,
      status: status ?? this.status,
      imageUrl: imageUrl ?? this.imageUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      supportedProductTypes:
          supportedProductTypes ?? this.supportedProductTypes,
      capacity: capacity ?? this.capacity,
      price: price ?? this.price,
      isTemperatureControlled:
          isTemperatureControlled ?? this.isTemperatureControlled,
      vehicleLocation: vehicleLocation ?? this.vehicleLocation,
      vehicleType: vehicleType ?? this.vehicleType,
      temperatureRange: temperatureRange ?? this.temperatureRange,
      driverId: driverId ?? this.driverId,
      driverRating: driverRating ?? this.driverRating,
      hasInsurance: hasInsurance ?? this.hasInsurance,
      insuranceDetails: insuranceDetails ?? this.insuranceDetails,
      certifications: certifications ?? this.certifications,
      amenities: amenities ?? this.amenities,
      ownerName: ownerName ?? this.ownerName,
      pricePerKg: pricePerKg ?? this.pricePerKg,
      driverName: driverName ?? this.driverName,
      driverPhone: driverPhone ?? this.driverPhone,
    );
  }
}
