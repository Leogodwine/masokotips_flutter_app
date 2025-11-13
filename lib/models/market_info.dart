import 'package:json_annotation/json_annotation.dart';

part 'market_info.g.dart';

// Custom converter for handling both string and numeric IDs
class NumericConverter {
  static int fromJson(dynamic value) {
    if (value is int) return value;
    if (value is String) return int.parse(value);
    if (value is num) return value.toInt();
    throw ArgumentError('Cannot convert $value to int');
  }

  static int? fromJsonNullable(dynamic value) {
    if (value == null) return null;
    return fromJson(value);
  }
}

@JsonSerializable()
class MarketInfo {
  @JsonKey(fromJson: NumericConverter.fromJson)
  final int id;
  final String title;
  final String description;
  final String content;
  @JsonKey(name: 'image_url')
  final String imageUrl;
  final String location;
  final String category;
  final String contact;
  @JsonKey(name: 'user_id', fromJson: NumericConverter.fromJson)
  final int userId;
  @JsonKey(name: 'is_active')
  final bool isActive;
  @JsonKey(name: 'is_featured')
  final bool isFeatured;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;

  MarketInfo({
    required this.id,
    this.title = '',
    this.description = '',
    this.content = '',
    this.imageUrl = '',
    this.location = '',
    this.category = '',
    this.contact = '',
    this.userId = 0,
    this.isActive = true,
    this.isFeatured = false,
    required this.createdAt,
    required this.updatedAt,
  });

  /// ✅ Use the generated function here
  factory MarketInfo.fromJson(Map<String, dynamic> json) =>
      _$MarketInfoFromJson(json);

  Map<String, dynamic> toJson() => _$MarketInfoToJson(this);
}



