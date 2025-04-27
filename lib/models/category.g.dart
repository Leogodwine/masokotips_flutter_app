// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'category.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Category _$CategoryFromJson(Map<String, dynamic> json) => Category(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      description: json['description'] as String?,
      imageUrl: json['image'] as String?,
      slug: json['slug'] as String?,
      isActive: json['is_active'] as bool? ?? true,
      sortOrder: (json['sort_order'] as num?)?.toInt() ?? 0,
      icon: json['icon'] as String?,
      parentId: const NullableIntConverter().fromJson(json['parent_id']),
      productsCount: (json['products_count'] as num?)?.toInt() ?? 0,
      subcategories: (json['subcategories'] as List<dynamic>?)
          ?.map((e) => Category.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$CategoryToJson(Category instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'image': instance.imageUrl,
      'slug': instance.slug,
      'is_active': instance.isActive,
      'sort_order': instance.sortOrder,
      'icon': instance.icon,
      'parent_id': const NullableIntConverter().toJson(instance.parentId),
      'products_count': instance.productsCount,
      'subcategories': instance.subcategories?.map((e) => e.toJson()).toList(),
    };
