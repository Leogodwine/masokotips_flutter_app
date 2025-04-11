// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transport.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Transport _$TransportFromJson(Map<String, dynamic> json) => Transport(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      description: json['description'] as String,
      type: json['type'] as String,
      status: json['status'] as String,
      imageUrl: json['imageUrl'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      supportedProductTypes: (json['supportedProductTypes'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      capacity: (json['capacity'] as num).toDouble(),
      price: (json['price'] as num).toDouble(),
      isTemperatureControlled: json['isTemperatureControlled'] as bool,
      vehicleLocation: json['vehicleLocation'] as String,
      vehicleType: json['vehicleType'] as String,
      temperatureRange: (json['temperatureRange'] as num?)?.toDouble(),
      driverId: json['driverId'] as String?,
      driverRating: (json['driverRating'] as num?)?.toDouble(),
      hasInsurance: json['hasInsurance'] as bool,
      insuranceDetails: json['insuranceDetails'] as String?,
      certifications: (json['certifications'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      amenities: (json['amenities'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      ownerName: json['ownerName'] as String,
      pricePerKg: (json['pricePerKg'] as num?)?.toDouble(),
      driverName: json['driverName'] as String,
      driverPhone: json['driverPhone'] as String,
    );

Map<String, dynamic> _$TransportToJson(Transport instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'type': instance.type,
      'status': instance.status,
      'imageUrl': instance.imageUrl,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'supportedProductTypes': instance.supportedProductTypes,
      'capacity': instance.capacity,
      'price': instance.price,
      'isTemperatureControlled': instance.isTemperatureControlled,
      'vehicleLocation': instance.vehicleLocation,
      'vehicleType': instance.vehicleType,
      'temperatureRange': instance.temperatureRange,
      'driverId': instance.driverId,
      'driverRating': instance.driverRating,
      'hasInsurance': instance.hasInsurance,
      'insuranceDetails': instance.insuranceDetails,
      'certifications': instance.certifications,
      'amenities': instance.amenities,
      'ownerName': instance.ownerName,
      'pricePerKg': instance.pricePerKg,
      'driverName': instance.driverName,
      'driverPhone': instance.driverPhone,
    };
