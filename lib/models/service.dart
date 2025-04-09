import 'package:json_annotation/json_annotation.dart';
import 'category.dart';

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

  @JsonKey(includeFromJson: false, includeToJson: false)
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

  factory Service.fromJson(Map<String, dynamic> json) =>
      _$ServiceFromJson(json);

  Map<String, dynamic> toJson() => _$ServiceToJson(this);
}
