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

  @JsonKey(ignore: true)
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
}
