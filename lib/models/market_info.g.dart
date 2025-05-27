// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'market_info.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MarketInfo _$MarketInfoFromJson(Map<String, dynamic> json) => MarketInfo(
      id: NumericConverter.fromJson(json['id']),
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      content: json['content'] as String? ?? '',
      imageUrl: json['image_url'] as String? ?? '',
      location: json['location'] as String? ?? '',
      category: json['category'] as String? ?? '',
      contact: json['contact'] as String? ?? '',
      userId: json['user_id'] == null
          ? 0
          : NumericConverter.fromJson(json['user_id']),
      isActive: json['is_active'] as bool? ?? true,
      isFeatured: json['is_featured'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$MarketInfoToJson(MarketInfo instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'content': instance.content,
      'image_url': instance.imageUrl,
      'location': instance.location,
      'category': instance.category,
      'contact': instance.contact,
      'user_id': instance.userId,
      'is_active': instance.isActive,
      'is_featured': instance.isFeatured,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
    };
