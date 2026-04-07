// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transport.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Transport _$TransportFromJson(Map<String, dynamic> json) => Transport(
      id: (json['id'] as num?)?.toInt(),
      title: json['title'] as String,
      description: json['description'] as String?,
      vehicleLocation: json['vehicle_location'] as String,
      vehicleType: json['vehicle_type'] as String,
      price: Transport._stringToDouble(json['price'] as String?),
      capacity: Transport._stringToDouble(json['capacity'] as String?),
      isTemperatureControlled:
          json['is_temperature_controlled'] as bool? ?? false,
      temperatureRange: Transport._stringToDoubleNullable(
          json['temperature_range'] as String?),
      supportedProductTypes:
          Transport._ensureStringList(json['supported_product_types']),
      driverId: json['driver_id'] as String?,
      driverRating:
          Transport._stringToDoubleNullable(json['driver_rating'] as String?),
      hasInsurance: json['has_insurance'] as bool? ?? false,
      insuranceDetails: json['insurance_details'] as String?,
      certifications: (json['certifications'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      amenities: (json['amenities'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      status: json['status'] as String,
      imageUrl: json['image_url'] as String?,
      ownerName: json['owner_name'] as String? ?? '',
      pricePerKg:
          Transport._stringToDoubleNullable(json['price_per_kg'] as String?),
      driverName: json['driver_name'] as String?,
      driverPhone: json['driver_phone'] as String?,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
      productName: json['product_name'] as String?,
      productType:
          Transport._standardizeProductType(json['product_type'] as String?),
      amount: Transport._stringToDouble(json['amount'] as String?),
      categoryId: (json['category_id'] as num?)?.toInt(),
      category: json['category'] == null
          ? null
          : models.Category.fromJson(json['category'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$TransportToJson(Transport instance) => <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'vehicle_location': instance.vehicleLocation,
      'vehicle_type': instance.vehicleType,
      'price': instance.price,
      'capacity': instance.capacity,
      'is_temperature_controlled': instance.isTemperatureControlled,
      'temperature_range': instance.temperatureRange,
      'supported_product_types': instance.supportedProductTypes,
      'driver_id': instance.driverId,
      'driver_rating': instance.driverRating,
      'has_insurance': instance.hasInsurance,
      'insurance_details': instance.insuranceDetails,
      'certifications': instance.certifications,
      'amenities': instance.amenities,
      'status': instance.status,
      'image_url': instance.imageUrl,
      'owner_name': instance.ownerName,
      'price_per_kg': instance.pricePerKg,
      'driver_name': instance.driverName,
      'driver_phone': instance.driverPhone,
      'created_at': instance.createdAt?.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
      'product_name': instance.productName,
      'product_type': instance.productType,
      'amount': instance.amount,
      'category_id': instance.categoryId,
      'category': instance.category,
    };
