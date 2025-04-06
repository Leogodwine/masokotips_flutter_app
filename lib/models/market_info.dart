import 'package:json_annotation/json_annotation.dart';

part 'market_info.g.dart';

@JsonSerializable()
class MarketInfo {
  final int id;
  final String title;
  final String content;
  final String? imageUrl;
  final String? location;
  final String? category;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int userId;
  final bool isActive;
  final bool isFeatured;

  MarketInfo({
    required this.id,
    required this.title,
    required this.content,
    this.imageUrl,
    this.location,
    this.category,
    required this.createdAt,
    required this.updatedAt,
    required this.userId,
    this.isActive = true,
    this.isFeatured = false,
  });

  factory MarketInfo.fromJson(Map<String, dynamic> json) =>
      _$MarketInfoFromJson(json);

  Map<String, dynamic> toJson() => _$MarketInfoToJson(this);
}
