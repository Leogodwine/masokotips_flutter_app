import 'package:json_annotation/json_annotation.dart';

part 'market_info.g.dart';

@JsonSerializable()
class MarketInfo {
  final int id;
  final String title;
  final String description;
  final String content;
  @JsonKey(name: 'image_url')
  final String imageUrl;
  final String location;
  final String category;
  final String contact;
  @JsonKey(name: 'user_id')
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

  factory MarketInfo.fromJson(Map<String, dynamic> json) {
    return MarketInfo(
      id: json['id'],
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      content: json['content'] ?? '',
      imageUrl: json['image_url'] ?? '',
      location: json['location'] ?? '',
      category: json['category'] ?? '',
      contact: json['contact'] ?? '',
      userId: json['user_id'] ?? 0,
      isActive: json['is_active'] ?? true,
      isFeatured: json['is_featured'] ?? false,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : DateTime.now(),
    );
  }
}
