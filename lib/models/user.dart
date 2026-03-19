import 'dart:convert';
import 'package:json_annotation/json_annotation.dart';
import 'package:masoko_tips/widgets/int_converter.dart';

part 'user.g.dart';

@JsonSerializable()
class User {
  @StringToIntConverter()
  final int id;

  final String name;
  final String email;

  /// Backend sends: "phone"
  /// Used by subscriptions & AzamPay
  @JsonKey(name: 'phone')
  final String? phoneNumber;

  final String? avatar;

  /// Normalized roles list
  final List<String> roles;

  /// Not serialized – local only
  @JsonKey(includeFromJson: false, includeToJson: false)
  String? avatarPath;

  @JsonKey(name: 'email_verified_at')
  final DateTime? emailVerifiedAt;

  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;

  /// Sometimes returned during auth
  final String? token;

  /// User suspension status
  @JsonKey(name: 'is_suspended')
  final bool isSuspended;

  /// User active status
  @JsonKey(name: 'is_active')
  final bool isActive;

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
    this.isSuspended = false,
    this.isActive = true,
  });

  /// Robust role parsing (string | json string | list | null)
  factory User.fromJson(Map<String, dynamic> json) {
    final rolesRaw = json['roles'] ?? json['role'];

    List<String> parsedRoles = [];

    if (rolesRaw is String) {
      try {
        final decoded = jsonDecode(rolesRaw);
        if (decoded is List) {
          parsedRoles = decoded.map((e) => e.toString()).toList();
        } else {
          parsedRoles = [rolesRaw];
        }
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

  // ---------------------------------------------------------------------------
  // ROLE HELPERS
  // ---------------------------------------------------------------------------

  bool hasRole(String role) => roles.contains(role);

  bool get isBuyer => hasRole('buyer');
  bool get isSeller => hasRole('seller');
  bool get isServiceProvider => hasRole('service_provider');
  bool get isAdmin => hasRole('admin');

  bool get hasMultipleRoles => roles.length > 1;

  String? get primaryRole => roles.isNotEmpty ? roles.first : null;

  // ---------------------------------------------------------------------------
  // FEATURE ACCESS
  // ---------------------------------------------------------------------------

  List<String> get accessibleFeatures {
    final features = <String>[];

    if (isBuyer) {
      features.add('buying');
    }

    if (isSeller) {
      features.addAll([
        'selling_products',
        'selling_transport',
        'selling_organic_products',
      ]);
    }

    if (isServiceProvider) {
      features.addAll([
        'providing_services',
        'managing_bookings',
      ]);
    }

    if (isAdmin) {
      features.addAll([
        'admin_panel',
        'user_management',
      ]);
    }

    return features;
  }

  // ---------------------------------------------------------------------------
  // COPY
  // ---------------------------------------------------------------------------

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
    bool? isSuspended,
    bool? isActive,
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
      isSuspended: isSuspended ?? this.isSuspended,
      isActive: isActive ?? this.isActive,
    );
  }
}
