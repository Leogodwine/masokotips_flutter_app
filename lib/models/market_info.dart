import 'package:json_annotation/json_annotation.dart';

part 'market_info.g.dart';

@JsonSerializable()
class MarketInfo {
  final String id;
  final String title;
  final String description;
  final String content;
  final String? imageUrl;
  final String? location;
  final String? category;
  final String? contact;
  final String? userId;
  final bool isActive;
  final bool isFeatured;
  final DateTime createdAt;
  final DateTime? updatedAt;

  MarketInfo({
    required this.id,
    required this.title,
    required this.description,
    required this.content,
    this.imageUrl,
    this.location,
    this.category,
    this.contact,
    this.userId,
    this.isActive = true,
    this.isFeatured = false,
    required this.createdAt,
    this.updatedAt,
  });

  factory MarketInfo.fromJson(Map<String, dynamic> json) =>
      _$MarketInfoFromJson(json);

  Map<String, dynamic> toJson() => _$MarketInfoToJson(this);
}
