// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'category.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Category _$CategoryFromJson(Map<String, dynamic> json) => Category(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      description: json['description'] as String?,
      imageUrl: json['imageUrl'] as String?,
      subcategories: (json['subcategories'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      slug: json['slug'] as String?,
      isActive: json['isActive'] as bool? ?? true,
      sortOrder: (json['sortOrder'] as num?)?.toInt() ?? 0,
      icon: json['icon'] as String?,
      parentId: (json['parent_id'] as num?)?.toInt(),
      productsCount: (json['products_count'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$CategoryToJson(Category instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'imageUrl': instance.imageUrl,
      'subcategories': instance.subcategories,
      'slug': instance.slug,
      'isActive': instance.isActive,
      'sortOrder': instance.sortOrder,
      'icon': instance.icon,
      'parent_id': instance.parentId,
      'products_count': instance.productsCount,
    };
