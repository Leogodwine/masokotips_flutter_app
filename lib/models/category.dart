import 'package:json_annotation/json_annotation.dart';

part 'category.g.dart';

@JsonSerializable()
class Category {
  final int id;
  final String name;
  final String? description;
  final String? imageUrl;
  final List<String>? subcategories;
  final String? slug;
  final bool isActive;
  final int sortOrder;
  final String? icon;
  @JsonKey(name: 'parent_id')
  final int? parentId;
  @JsonKey(includeFromJson: false, includeToJson: false)
  List<Category>? children;
  @JsonKey(name: 'products_count')
  final int productsCount;
  @JsonKey(includeFromJson: false, includeToJson: false)
  final List<dynamic>? services;

  Category({
    required this.id,
    required this.name,
    this.description,
    this.imageUrl,
    this.subcategories,
    this.slug,
    this.isActive = true,
    this.sortOrder = 0,
    this.icon,
    this.children,
    this.parentId,
    this.productsCount = 0,
    this.services,
  });

  factory Category.fromJson(Map<String, dynamic> json) =>
      _$CategoryFromJson(json);

  Map<String, dynamic> toJson() => _$CategoryToJson(this);
}

// Predefined categories and subcategories
final mainCategories = [
  Category(
    id: 1,
    name: 'Products',
    slug: 'products',
    isActive: true,
    sortOrder: 1,
    icon: 'shopping_basket',
    children: [
      Category(
          id: 11,
          name: 'Vegetables',
          slug: 'vegetables',
          isActive: true,
          sortOrder: 1),
      Category(
          id: 12, name: 'Fruits', slug: 'fruits', isActive: true, sortOrder: 2),
      Category(
          id: 13, name: 'Spices', slug: 'spices', isActive: true, sortOrder: 3),
      Category(
          id: 14,
          name: 'Cash Crops',
          slug: 'cash-crops',
          isActive: true,
          sortOrder: 4),
      Category(
          id: 15,
          name: 'Cereals',
          slug: 'cereals',
          isActive: true,
          sortOrder: 5),
      Category(
          id: 16,
          name: 'Seeds and Seedling',
          slug: 'seeds-and-seedling',
          isActive: true,
          sortOrder: 6),
      Category(
          id: 17,
          name: 'Livestock and poultry',
          slug: 'livestock-and-poultry',
          isActive: true,
          sortOrder: 7),
    ],
  ),
  Category(
    id: 3,
    name: 'Market Information',
    slug: 'market-information',
    isActive: true,
    sortOrder: 3,
    icon: 'trending_up',
  ),
  Category(
    id: 4,
    name: 'Transport',
    slug: 'transport',
    isActive: true,
    sortOrder: 4,
    icon: 'local_shipping',
    children: [
      Category(
          id: 41, name: 'Tandem', slug: 'tandem', isActive: true, sortOrder: 1),
      Category(
          id: 42,
          name: 'Kirikuu',
          slug: 'kirikuu',
          isActive: true,
          sortOrder: 2),
      Category(
          id: 43,
          name: 'FlatbedTrucks',
          slug: 'flatbed-trucks',
          isActive: true,
          sortOrder: 3),
      Category(
          id: 44, name: 'Tanker', slug: 'tanker', isActive: true, sortOrder: 4),
      Category(
          id: 45,
          name: 'Refrigerator Truck',
          slug: 'refrigerator-truck',
          isActive: true,
          sortOrder: 5),
      Category(
          id: 46,
          name: 'Box Truck',
          slug: 'box-truck',
          isActive: true,
          sortOrder: 6),
      Category(
          id: 47,
          name: 'Liftgate Truck',
          slug: 'liftgate-truck',
          isActive: true,
          sortOrder: 7),
      Category(id: 48, name: 'Van', slug: 'van', isActive: true, sortOrder: 8),
      Category(
          id: 49,
          name: 'Container Hauler',
          slug: 'container-hauler',
          isActive: true,
          sortOrder: 9),
      Category(
          id: 410,
          name: 'Pickups Trucks',
          slug: 'pickup-trucks',
          isActive: true,
          sortOrder: 10),
      Category(
          id: 411, name: 'Fuso', slug: 'fuso', isActive: true, sortOrder: 11),
      Category(
          id: 412,
          name: 'Semi Trailers',
          slug: 'semi-trailers',
          isActive: true,
          sortOrder: 12),
      Category(
          id: 413,
          name: 'Tracker Trailers',
          slug: 'tracker-trailers',
          isActive: true,
          sortOrder: 13),
    ],
  ),
  Category(
    id: 5,
    name: 'Organic Products',
    slug: 'organic-products',
    isActive: true,
    sortOrder: 5,
    icon: 'eco',
    children: [
      Category(
          id: 51,
          name: 'Organic Vegetables',
          slug: 'organic-vegetables',
          isActive: true,
          sortOrder: 1),
      Category(
          id: 52,
          name: 'Organic Fruits',
          slug: 'organic-fruits',
          isActive: true,
          sortOrder: 2),
      Category(
          id: 53,
          name: 'Organic Spices',
          slug: 'organic-spices',
          isActive: true,
          sortOrder: 3),
      Category(
          id: 54,
          name: 'Organic Cash Crops',
          slug: 'organic-cash-crops',
          isActive: true,
          sortOrder: 4),
      Category(
          id: 55,
          name: 'Organic Cereals',
          slug: 'organic-cereals',
          isActive: true,
          sortOrder: 5),
      Category(
          id: 56,
          name: 'Organic Livestock and Poultry',
          slug: 'organic-livestock-and-poultry',
          isActive: true,
          sortOrder: 6),
    ],
  ),
  Category(
    id: 6,
    name: 'Agricultural Services',
    slug: 'agricultural-services',
    isActive: true,
    sortOrder: 6,
    icon: 'agriculture',
    children: [
      Category(
          id: 61,
          name: 'Packaging Materials',
          slug: 'packaging-materials',
          isActive: true,
          sortOrder: 1),
      Category(
          id: 62,
          name: 'Hydroponics',
          slug: 'hydroponics',
          isActive: true,
          sortOrder: 2),
      Category(
          id: 63,
          name: 'Fertilizer',
          slug: 'fertilizer',
          isActive: true,
          sortOrder: 3),
      Category(
          id: 64,
          name: 'Organic Manure',
          slug: 'organic-manure',
          isActive: true,
          sortOrder: 4),
      Category(
          id: 65,
          name: 'Machinery',
          slug: 'machinery',
          isActive: true,
          sortOrder: 5),
      Category(
          id: 66,
          name: 'Behive and Aquatic',
          slug: 'behive-and-aquatic',
          isActive: true,
          sortOrder: 6),
      Category(
          id: 67,
          name: 'Food and Beverage',
          slug: 'food-and-beverage',
          isActive: true,
          sortOrder: 7),
    ],
  ),
];
