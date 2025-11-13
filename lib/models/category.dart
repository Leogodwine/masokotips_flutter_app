import 'package:json_annotation/json_annotation.dart';
import '../../widgets/int_converter.dart';

part 'category.g.dart';

@JsonSerializable(explicitToJson: true)
class Category {
  @StringToIntConverter()
  final int id;
  final String name;
  final String? description;

  @JsonKey(name: 'image')
  final String? imageUrl;

  final String? slug;

  @JsonKey(name: 'is_active')
  final bool isActive;

  @StringToIntConverter()
  @JsonKey(name: 'sort_order')
  final int sortOrder;

  final String? icon;

  @NullableIntConverter()
  @JsonKey(name: 'parent_id')
  final int? parentId;

  @StringToIntConverter()
  @JsonKey(name: 'products_count')
  final int productsCount;

  @StringToIntConverter()
  @JsonKey(name: 'subcategories_count')
  final int subcategoriesCount;

  @JsonKey(name: 'subcategories')
  List<Category>? subcategories;

  Category({
    required this.id,
    required this.name,
    this.description,
    this.imageUrl,
    this.slug,
    this.isActive = true,
    this.sortOrder = 0,
    this.icon,
    this.parentId,
    this.productsCount = 0,
    this.subcategoriesCount = 0,
    this.subcategories,
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
    subcategories: [
      Category(
          id: 6,
          name: 'Vegetables',
          slug: 'vegetables',
          isActive: true,
          sortOrder: 1),
      Category(
          id: 7, name: 'Fruits', slug: 'fruits', isActive: true, sortOrder: 2),
      Category(
          id: 8, name: 'Spices', slug: 'spices', isActive: true, sortOrder: 3),
      Category(
          id: 9,
          name: 'Cash Crops',
          slug: 'cash-crops',
          isActive: true,
          sortOrder: 4),
      Category(
          id: 10,
          name: 'Cereals',
          slug: 'cereals',
          isActive: true,
          sortOrder: 5),
      Category(
          id: 11,
          name: 'Seeds and Seedling',
          slug: 'seeds-and-seedling',
          isActive: true,
          sortOrder: 6),
      Category(
          id: 12,
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
    subcategories: null,
  ),
  Category(
    id: 4,
    name: 'Transport',
    slug: 'transport',
    isActive: true,
    sortOrder: 4,
    icon: 'local_shipping',
    subcategories: [
      Category(
          id: 13, name: 'Tandem', slug: 'tandem', isActive: true, sortOrder: 1),
      Category(
          id: 14,
          name: 'Kirikuu',
          slug: 'kirikuu',
          isActive: true,
          sortOrder: 2),
      Category(
          id: 15,
          name: 'Flatbed Trucks',
          slug: 'flatbed-trucks',
          isActive: true,
          sortOrder: 3),
      Category(
          id: 16, name: 'Tanker', slug: 'tanker', isActive: true, sortOrder: 4),
      Category(
          id: 17,
          name: 'Refrigerator Truck',
          slug: 'refrigerator-truck',
          isActive: true,
          sortOrder: 5),
      Category(
          id: 18,
          name: 'Box Truck',
          slug: 'box-truck',
          isActive: true,
          sortOrder: 6),
      Category(
          id: 19,
          name: 'Liftgate Truck',
          slug: 'liftgate-truck',
          isActive: true,
          sortOrder: 7),
      Category(id: 20, name: 'Van', slug: 'van', isActive: true, sortOrder: 8),
      Category(
          id: 21,
          name: 'Container Hauler',
          slug: 'container-hauler',
          isActive: true,
          sortOrder: 9),
      Category(
          id: 22,
          name: 'Pickups Trucks',
          slug: 'pickup-trucks',
          isActive: true,
          sortOrder: 10),
      Category(
          id: 23, name: 'Fuso', slug: 'fuso', isActive: true, sortOrder: 11),
      Category(
          id: 24,
          name: 'Semi Trailers',
          slug: 'semi-trailers',
          isActive: true,
          sortOrder: 12),
      Category(
          id: 25,
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
    subcategories: [
      Category(
          id: 26,
          name: 'Organic Vegetables',
          slug: 'organic-vegetables',
          isActive: true,
          sortOrder: 1),
      Category(
          id: 27,
          name: 'Organic Fruits',
          slug: 'organic-fruits',
          isActive: true,
          sortOrder: 2),
      Category(
          id: 28,
          name: 'Organic Spices',
          slug: 'organic-spices',
          isActive: true,
          sortOrder: 3),
      Category(
          id: 29,
          name: 'Organic Cash Crops',
          slug: 'organic-cash-crops',
          isActive: true,
          sortOrder: 4),
      Category(
          id: 30,
          name: 'Organic Cereals',
          slug: 'organic-cereals',
          isActive: true,
          sortOrder: 5),
      Category(
          id: 31,
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
    subcategories: [
      Category(
          id: 32,
          name: 'Packaging Materials',
          slug: 'packaging-materials',
          isActive: true,
          sortOrder: 1),
      Category(
          id: 33,
          name: 'Hydroponics',
          slug: 'hydroponics',
          isActive: true,
          sortOrder: 2),
      Category(
          id: 34,
          name: 'Fertilizer',
          slug: 'fertilizer',
          isActive: true,
          sortOrder: 3),
      Category(
          id: 35,
          name: 'Organic Manure',
          slug: 'organic-manure',
          isActive: true,
          sortOrder: 4),
      Category(
          id: 36,
          name: 'Machinery',
          slug: 'machinery',
          isActive: true,
          sortOrder: 5),
      Category(
          id: 37,
          name: 'Beehive and Aquatic',
          slug: 'beehive-and-aquatic',
          isActive: true,
          sortOrder: 6),
      Category(
          id: 38,
          name: 'Food and Beverage',
          slug: 'food-and-beverage',
          isActive: true,
          sortOrder: 7),
      Category(
          id: 39,
          name: 'Cold Rooms Services',
          slug: 'cold-rooms-services',
          isActive: true,
          sortOrder: 8),
      Category(
          id: 40,
          name: 'Machinery and Rental Services',
          slug: 'machinery-and-rental-services',
          isActive: true,
          sortOrder: 9),
      Category(
          id: 41,
          name: 'Agronomist Services',
          slug: 'agronomist-services',
          isActive: true,
          sortOrder: 10),
      Category(
          id: 42,
          name: 'Financial Services',
          slug: 'financial-services',
          isActive: true,
          sortOrder: 11),
      Category(
          id: 43,
          name: 'Irrigation Services',
          slug: 'irrigation-services',
          isActive: true,
          sortOrder: 12),
      Category(
          id: 44,
          name: 'Branding and Consultation Services',
          slug: 'branding-and-consultation-services',
          isActive: true,
          sortOrder: 13),
    ],
  ),
];
