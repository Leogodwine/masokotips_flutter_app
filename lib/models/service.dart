import 'package:json_annotation/json_annotation.dart';
import 'category.dart';
import '../utils/logger.dart';

part 'service.g.dart';

@JsonSerializable()
class Service {
  final int id;
  final String title;
  final String description;
  final double price;

  @JsonKey(name: 'category_id')
  final int categoryId;

  @JsonKey(name: 'user_id')
  final int userId;

  @JsonKey(name: 'image_url')
  final String? imageUrl;

  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;

  final String? subcategory;

  @JsonKey(ignore: true)
  final Category? category;

  Service({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.categoryId,
    required this.userId,
    this.imageUrl,
    required this.createdAt,
    required this.updatedAt,
    this.subcategory,
    this.category,
  });

  factory Service.fromJson(Map<String, dynamic> json) {
    try {
      Log.d('Creating Service from JSON: ${json.keys.join(', ')}');

      // Handle potential circular references by checking if category is a string or an object
      Category? categoryObj;
      if (json['category'] != null) {
        Log.d('Category data type: ${json['category'].runtimeType}');

        if (json['category'] is Map<String, dynamic>) {
          // Create a minimal Category object with only the necessary fields
          final categoryData = json['category'] as Map<String, dynamic>;
          Log.d('Category data keys: ${categoryData.keys.join(', ')}');

          categoryObj = Category(
            id: categoryData['id'] as int,
            name: categoryData['name'] as String,
            slug: categoryData['slug'] as String?,
            icon: categoryData['icon'] as String?,
            description: categoryData['description'] as String?,
            parentId: categoryData['parent_id'] as int?,
            isActive: categoryData['is_active'] as bool? ?? true,
            sortOrder: categoryData['sort_order'] as int? ?? 0,
            imageUrl: categoryData['image'] as String?,
            // Don't set children to prevent circular references
            children: null,
            productsCount: categoryData['products_count'] as int? ?? 0,
          );
        } else if (json['category'] is String) {
          // If category is a string, create a minimal Category object
          Log.d('Category is a string: ${json['category']}');
          categoryObj = Category(
            id: json['category_id'] as int,
            name: json['category'] as String,
          );
        }
      }

      // Handle date fields that might be in different formats
      DateTime parseDate(String? dateStr) {
        if (dateStr == null) return DateTime.now();
        try {
          return DateTime.parse(dateStr);
        } catch (e) {
          Log.e('Error parsing date: $dateStr, error: $e');
          return DateTime.now();
        }
      }

      return Service(
        id: json['id'] as int,
        title: json['title'] as String,
        description: json['description'] as String,
        price: (json['price'] as num).toDouble(),
        categoryId: json['category_id'] as int,
        userId: json['user_id'] as int,
        imageUrl: json['image_url'] as String?,
        createdAt: parseDate(json['created_at'] as String?),
        updatedAt: parseDate(json['updated_at'] as String?),
        subcategory: json['subcategory'] as String?,
        category: categoryObj,
      );
    } catch (e, stackTrace) {
      Log.e('Error creating Service from JSON: $e');
      Log.e('Stack trace: $stackTrace');
      Log.e('JSON data: $json');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() => _$ServiceToJson(this);
}
