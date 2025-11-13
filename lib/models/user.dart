import 'package:json_annotation/json_annotation.dart';
import 'dart:convert';
import 'package:masoko_tips/widgets/int_converter.dart';

part 'user.g.dart';

@JsonSerializable()
class User {
  @StringToIntConverter()
  final int id;
  final String name;
  final String email;

  @JsonKey(name: 'phone')
  final String? phoneNumber;

  final String? avatar;
  final List<String> roles;

  @JsonKey(includeFromJson: false, includeToJson: false)
  String? avatarPath;

  @JsonKey(name: 'email_verified_at')
  final DateTime? emailVerifiedAt;

  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;

  final String? token;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.phoneNumber,
    this.avatar,
    required this.roles,
    this.emailVerifiedAt,
    required this.createdAt,
    required this.updatedAt,
    this.token,
    this.avatarPath,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    final rolesRaw = json['roles'] ?? json['role'];

    List<String> parsedRoles = [];

    if (rolesRaw is String) {
      try {
        parsedRoles = List<String>.from(jsonDecode(rolesRaw));
      } catch (_) {
        parsedRoles = [rolesRaw];
      }
    } else if (rolesRaw is List) {
      parsedRoles = rolesRaw.map((e) => e.toString()).toList();
    } else if (rolesRaw != null) {
      parsedRoles = [rolesRaw.toString()];
    }

    return _$UserFromJson({
      ...json,
      'roles': parsedRoles,
    });
  }

  Map<String, dynamic> toJson() => _$UserToJson(this);

  bool hasRole(String role) => roles.contains(role);

  // Role management methods
  bool get isBuyer => hasRole('buyer');
  bool get isSeller => hasRole('seller');
  bool get isServiceProvider => hasRole('service_provider');
  bool get isAdmin => hasRole('admin');

  bool get hasMultipleRoles => roles.length > 1;

  String? get primaryRole => roles.isNotEmpty ? roles.first : null;

  bool get canAccessSellerFeatures => isSeller;
  bool get canAccessServiceProviderFeatures => isServiceProvider;

  List<String> get accessibleFeatures {
    List<String> features = [];

    if (isBuyer) {
      features.add('buying');
    }

    if (isSeller) {
      features.addAll([
        'selling_products',
        'selling_transport',
        'selling_organic_products'
      ]);
    }

    if (isServiceProvider) {
      features.addAll(['providing_services', 'managing_bookings']);
    }

    if (isAdmin) {
      features.addAll(['admin_panel', 'user_management']);
    }

    return features;
  }

  User copyWith({
    int? id,
    String? name,
    String? email,
    String? phoneNumber,
    String? avatar,
    List<String>? roles,
    DateTime? emailVerifiedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? token,
    String? avatarPath,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      avatar: avatar ?? this.avatar,
      roles: roles ?? this.roles,
      emailVerifiedAt: emailVerifiedAt ?? this.emailVerifiedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      token: token ?? this.token,
      avatarPath: avatarPath ?? this.avatarPath,
    );
  }
}
