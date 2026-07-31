import 'package:flutter/foundation.dart' hide Category;
import 'package:json_annotation/json_annotation.dart';
import '../config/api_config.dart';
import 'category.dart';

part 'service.g.dart';

@JsonSerializable()
class Service {
  @JsonKey(fromJson: _idFromJson)
  final int id;
  final String? title;
  final String? description;

  @JsonKey(fromJson: _priceFromJson, toJson: _priceToJson)
  final double price;

  @JsonKey(name: 'category_id', fromJson: _categoryIdFromJson)
  final int categoryId;

  @JsonKey(name: 'user_id', fromJson: _userIdFromJson, toJson: _userIdToJson)
  final int userId;

  @JsonKey(name: 'image_url')
  final String? imageUrl;

  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;

  final String? subcategory;

  // Agricultural-specific fields
  @JsonKey(name: 'provider_name')
  final String? providerName;

  @JsonKey(name: 'provider_image')
  final String? providerImage;

  final String? location;

  @JsonKey(name: 'service_type')
  final String? serviceType;

  final String? expertise;

  final String? certifications;

  @JsonKey(name: 'experience_years', fromJson: _experienceYearsFromJson)
  final int? experienceYears;

  @JsonKey(name: 'availability')
  final String? availability;

  @JsonKey(name: 'contact_phone')
  final String? contactPhone;

  @JsonKey(name: 'contact_email')
  final String? contactEmail;

  final String? status;

  @JsonKey(fromJson: _ratingFromJson)
  final double? rating;

  @JsonKey(name: 'review_count', fromJson: _reviewCountFromJson)
  final int? reviewCount;

  @JsonKey(name: 'is_active')
  final bool? isActive;

  final bool? featured;

  @JsonKey(includeFromJson: false, includeToJson: false)
  final Category? category;
  
  @JsonKey(name: 'provider')
  final Map<String, dynamic>? user;

  // Computed properties for seller info
  String get sellerName {
    final username = user?['username'];
    if (username != null && username.toString().trim().isNotEmpty) {
      final value = username.toString().trim();
      return value.startsWith('@') ? value : '@$value';
    }
    return user?['name'] ?? 'Unknown';
  }
  String? get sellerAvatar => user?['avatar'];
  String? get sellerLocation => user?['location'];
  String? get sellerPhone => user?['phone'];

  Service({
    required this.id,
    this.title,
    this.description,
    required this.price,
    required this.categoryId,
    required this.userId,
    this.user,
    this.imageUrl,
    required this.createdAt,
    required this.updatedAt,
    this.subcategory,
    this.providerName,
    this.providerImage,
    this.location,
    this.serviceType,
    this.expertise,
    this.certifications,
    this.experienceYears,
    this.availability,
    this.contactPhone,
    this.contactEmail,
    this.status,
    this.rating,
    this.reviewCount,
    this.isActive,
    this.featured,
    this.category,
  });

  factory Service.fromJson(Map<String, dynamic> json) {
    // Debug logging
    debugPrint(
        'Service.fromJson: Parsing service with keys: ${json.keys.toList()}');

    // Handle the case where API returns provider_id instead of user_id
    if (json.containsKey('provider_id') && !json.containsKey('user_id')) {
      json['user_id'] = json['provider_id'];
    }

    // Process image URLs
    if (json['image_url'] != null) {
      json['image_url'] = _processImageUrl(json['image_url']);
    }
    if (json['provider_image'] != null) {
      json['provider_image'] = _processImageUrl(json['provider_image']);
    }

    // Check if this is a minimal response with only relationships
    if (json.keys.length <= 4 &&
        json.containsKey('service_provider') &&
        json.containsKey('category')) {
      debugPrint(
          'Service.fromJson: Warning - Received minimal response with only relationships');
      // Return a default service if we only have relationships
      return Service(
        id: json['id'] ?? 0,
        title: json['title'] ?? 'Service Updated',
        description: json['description'] ?? 'Service has been updated successfully',
        price: _priceFromJson(json['price']),
        categoryId: _categoryIdFromJson(json['category_id']),
        userId: _userIdFromJson(json['user_id']),
        imageUrl: json['image_url'],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    }

    try {
      final service = _$ServiceFromJson(json);
      debugPrint('Service.fromJson: Finished parsing service ${service.id}');
      debugPrint('Service.fromJson: Final image URL: ${service.imageUrl}');
      return service;
    } catch (e) {
      debugPrint('Service.fromJson: Error parsing service: $e');
      debugPrint('Service.fromJson: JSON data: $json');
      rethrow;
    }
  }


  static String? _processImageUrl(String? path) {
    if (path == null || path.isEmpty) return null;

    path = path.replaceAll('\\', '/').trim();

    if (path.startsWith('http://') || path.startsWith('https://')) {
      return path;
    }

    final base = Uri.parse(ApiConfig.baseUrl);
    final cleanBase = '${base.scheme}://${base.host}';

    if (path.startsWith('/')) {
      path = path.substring(1);
    }

    if (!path.startsWith('storage/')) {
      path = 'storage/$path';
    }

    return '$cleanBase/$path';
  }

  Map<String, dynamic> toJson() => _$ServiceToJson(this);

  // Helper functions for price conversion
  static double _priceFromJson(dynamic value) {
    if (value == null) {
      debugPrint('Warning: Price is null, using 0.0 as default');
      return 0.0; // Use 0.0 as default for null prices
    }
    if (value is String) {
      return double.parse(value);
    } else if (value is num) {
      return value.toDouble();
    }
    throw ArgumentError(
        'Price must be a string or number, got ${value.runtimeType}');
  }

  static dynamic _priceToJson(double value) => value;

  // Helper function for userId conversion (handles both user_id and provider_id)
  static int _userIdFromJson(dynamic value) {
    if (value == null) {
      debugPrint('Warning: User ID is null, using 0 as default');
      return 0; // Use 0 as default for null user IDs
    }
    if (value is String) {
      return int.parse(value);
    } else if (value is num) {
      return value.toInt();
    }
    throw ArgumentError(
        'User ID must be a string or number, got ${value.runtimeType}');
  }

  static dynamic _userIdToJson(int value) => value;

  // Helper function for id conversion
  static int _idFromJson(dynamic value) {
    if (value == null) {
      debugPrint('Warning: Service ID is null, using 0 as default');
      return 0; // Use 0 as default for null IDs
    }
    if (value is String) {
      return int.parse(value);
    } else if (value is num) {
      return value.toInt();
    }
    throw ArgumentError(
        'ID must be a string or number, got ${value.runtimeType}');
  }

  // Helper function for categoryId conversion
  static int _categoryIdFromJson(dynamic value) {
    if (value == null) {
      debugPrint('Warning: Category ID is null, using 0 as default');
      return 0; // Use 0 as default for null category IDs
    }
    if (value is String) {
      return int.parse(value);
    } else if (value is num) {
      return value.toInt();
    }
    throw ArgumentError(
        'Category ID must be a string or number, got ${value.runtimeType}');
  }

  // Helper function for experienceYears conversion
  static int? _experienceYearsFromJson(dynamic value) {
    if (value == null) return null;
    if (value is String) {
      return int.parse(value);
    } else if (value is num) {
      return value.toInt();
    }
    throw ArgumentError(
        'Experience years must be a string or number, got ${value.runtimeType}');
  }

  // Helper function for rating conversion
  static double? _ratingFromJson(dynamic value) {
    if (value == null) return null;
    if (value is String) {
      return double.parse(value);
    } else if (value is num) {
      return value.toDouble();
    }
    throw ArgumentError(
        'Rating must be a string or number, got ${value.runtimeType}');
  }

  // Helper function for reviewCount conversion
  static int? _reviewCountFromJson(dynamic value) {
    if (value == null) return null;
    if (value is String) {
      return int.parse(value);
    } else if (value is num) {
      return value.toInt();
    }
    throw ArgumentError(
        'Review count must be a string or number, got ${value.runtimeType}');
  }
}
