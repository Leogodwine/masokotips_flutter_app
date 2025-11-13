// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'category.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Category _$CategoryFromJson(Map<String, dynamic> json) => Category(
      id: const StringToIntConverter().fromJson(json['id']),
      name: json['name'] as String,
      description: json['description'] as String?,
      imageUrl: json['image'] as String?,
      slug: json['slug'] as String?,
      isActive: json['is_active'] as bool? ?? true,
      sortOrder: json['sort_order'] == null
          ? 0
          : const StringToIntConverter().fromJson(json['sort_order']),
      icon: json['icon'] as String?,
      parentId: const NullableIntConverter().fromJson(json['parent_id']),
      productsCount: json['products_count'] == null
          ? 0
          : const StringToIntConverter().fromJson(json['products_count']),
      subcategoriesCount: json['subcategories_count'] == null
          ? 0
          : const StringToIntConverter().fromJson(json['subcategories_count']),
      subcategories: (json['subcategories'] as List<dynamic>?)
          ?.map((e) => Category.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$CategoryToJson(Category instance) => <String, dynamic>{
      'id': const StringToIntConverter().toJson(instance.id),
      'name': instance.name,
      'description': instance.description,
      'image': instance.imageUrl,
      'slug': instance.slug,
      'is_active': instance.isActive,
      'sort_order': const StringToIntConverter().toJson(instance.sortOrder),
      'icon': instance.icon,
      'parent_id': const NullableIntConverter().toJson(instance.parentId),
      'products_count':
          const StringToIntConverter().toJson(instance.productsCount),
      'subcategories_count':
          const StringToIntConverter().toJson(instance.subcategoriesCount),
      'subcategories': instance.subcategories?.map((e) => e.toJson()).toList(),
    };
