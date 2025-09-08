// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'service.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Service _$ServiceFromJson(Map<String, dynamic> json) => Service(
      id: Service._idFromJson(json['id']),
      title: json['title'] as String?,
      description: json['description'] as String?,
      price: Service._priceFromJson(json['price']),
      categoryId: Service._categoryIdFromJson(json['category_id']),
      userId: Service._userIdFromJson(json['user_id']),
      imageUrl: json['image_url'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      subcategory: json['subcategory'] as String?,
      providerName: json['provider_name'] as String?,
      providerImage: json['provider_image'] as String?,
      location: json['location'] as String?,
      serviceType: json['service_type'] as String?,
      expertise: json['expertise'] as String?,
      certifications: json['certifications'] as String?,
      experienceYears:
          Service._experienceYearsFromJson(json['experience_years']),
      availability: json['availability'] as String?,
      contactPhone: json['contact_phone'] as String?,
      contactEmail: json['contact_email'] as String?,
      status: json['status'] as String?,
      rating: Service._ratingFromJson(json['rating']),
      reviewCount: Service._reviewCountFromJson(json['review_count']),
      isActive: json['is_active'] as bool?,
      featured: json['featured'] as bool?,
    );

Map<String, dynamic> _$ServiceToJson(Service instance) => <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'price': Service._priceToJson(instance.price),
      'category_id': instance.categoryId,
      'user_id': Service._userIdToJson(instance.userId),
      'image_url': instance.imageUrl,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
      'subcategory': instance.subcategory,
      'provider_name': instance.providerName,
      'provider_image': instance.providerImage,
      'location': instance.location,
      'service_type': instance.serviceType,
      'expertise': instance.expertise,
      'certifications': instance.certifications,
      'experience_years': instance.experienceYears,
      'availability': instance.availability,
      'contact_phone': instance.contactPhone,
      'contact_email': instance.contactEmail,
      'status': instance.status,
      'rating': instance.rating,
      'review_count': instance.reviewCount,
      'is_active': instance.isActive,
      'featured': instance.featured,
    };
