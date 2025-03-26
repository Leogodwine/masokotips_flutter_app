class Category {
  final int id;
  final String name;
  final String? icon;
  final List<Category> subcategories;

  Category({
    required this.id,
    required this.name,
    this.icon,
    this.subcategories = const [],
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      icon: json['icon'],
      subcategories: (json['subcategories'] as List<dynamic>?)
              ?.map((e) => Category.fromJson(e))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
      'subcategories': subcategories.map((e) => e.toJson()).toList(),
    };
  }
}

// Predefined categories and subcategories
final mainCategories = [
  Category(
    id: 1,
    name: 'Products',
    icon: 'shopping_basket',
    subcategories: [
      Category(id: 11, name: 'Vegetables'),
      Category(id: 12, name: 'Fruits'),
      Category(id: 13, name: 'Spices'),
      Category(id: 14, name: 'Cash Crops'),
      Category(id: 15, name: 'Cereals'),
      Category(id: 16, name: 'Seeds and Seedling'),
      Category(id: 17, name: 'Livestock and poultry'),
    ],
  ),
  Category(
    id: 2,
    name: 'Services',
    icon: 'miscellaneous_services',
  ),
  Category(
    id: 3,
    name: 'Market Information',
    icon: 'trending_up',
  ),
  Category(
    id: 4,
    name: 'Transport',
    icon: 'local_shipping',
    subcategories: [
      Category(id: 41, name: 'Tandem'),
      Category(id: 42, name: 'Kirikuu'),
      Category(id: 43, name: 'FlatbedTrucks'),
      Category(id: 44, name: 'Tanker'),
      Category(id: 45, name: 'Refrigerator Truck'),
      Category(id: 46, name: 'Box Truck'),
      Category(id: 47, name: 'Liftgate Truck'),
      Category(id: 48, name: 'Van'),
      Category(id: 49, name: 'Container Hauler'),
      Category(id: 410, name: 'Pickups Trucks'),
      Category(id: 411, name: 'Fuso'),
      Category(id: 412, name: 'Semi Trailers'),
      Category(id: 413, name: 'Tracker Trailers'),
    ],
  ),
  Category(
    id: 5,
    name: 'Organic Products',
    icon: 'eco',
    subcategories: [
      Category(id: 51, name: 'Organic Vegetables'),
      Category(id: 52, name: 'Organic Fruits'),
      Category(id: 53, name: 'Organic Spices'),
      Category(id: 54, name: 'Organic Cash Crops'),
      Category(id: 55, name: 'Organic Cereals'),
      Category(id: 56, name: 'Organic Livestock and Poultry'),
    ],
  ),
  Category(
    id: 6,
    name: 'Other Services',
    icon: 'more_horiz',
    subcategories: [
      Category(id: 61, name: 'Packaging Materials'),
      Category(id: 62, name: 'Hydroponics'),
      Category(id: 63, name: 'Fertilizer'),
      Category(id: 64, name: 'Organic Manure'),
      Category(id: 65, name: 'Machinery'),
      Category(id: 66, name: 'Behive and Aquatic'),
      Category(id: 67, name: 'Food and Beverage'),
    ],
  ),
];
