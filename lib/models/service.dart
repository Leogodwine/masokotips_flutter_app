import 'package:json_annotation/json_annotation.dart';
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

  Service({
    required this.id,
    this.title,
    this.description,
    required this.price,
    required this.categoryId,
    required this.userId,
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
    print('Service.fromJson: Parsing service with keys: ${json.keys.toList()}');
    print(
        'Service.fromJson: title = ${json['title']} (${json['title'].runtimeType})');
    print(
        'Service.fromJson: description = ${json['description']} (${json['description'].runtimeType})');
    print(
        'Service.fromJson: user_id = ${json['user_id']} (${json['user_id'].runtimeType})');
    print(
        'Service.fromJson: provider_id = ${json['provider_id']} (${json['provider_id'].runtimeType})');
    print(
        'Service.fromJson: category_id = ${json['category_id']} (${json['category_id'].runtimeType})');
    print(
        'Service.fromJson: price = ${json['price']} (${json['price'].runtimeType})');

    // Handle the case where API returns provider_id instead of user_id
    if (json.containsKey('provider_id') && !json.containsKey('user_id')) {
      json['user_id'] = json['provider_id'];
    }

    // Check if this is a minimal response with only relationships
    if (json.keys.length <= 2 &&
        json.containsKey('provider') &&
        json.containsKey('category')) {
      print(
          'Service.fromJson: Warning - Received minimal response with only relationships');
      // Return a default service if we only have relationships
      return Service(
        id: 0,
        title: 'Service Updated',
        description: 'Service has been updated successfully',
        price: 0.0,
        categoryId: 0,
        userId: 0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    }

    try {
      return _$ServiceFromJson(json);
    } catch (e) {
      print('Service.fromJson: Error parsing service: $e');
      print('Service.fromJson: JSON data: $json');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() => _$ServiceToJson(this);

  // Helper functions for price conversion
  static double _priceFromJson(dynamic value) {
    if (value == null) {
      print('Warning: Price is null, using 0.0 as default');
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
      print('Warning: User ID is null, using 0 as default');
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
      print('Warning: Service ID is null, using 0 as default');
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
      print('Warning: Category ID is null, using 0 as default');
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
