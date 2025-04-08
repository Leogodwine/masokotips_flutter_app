import 'package:json_annotation/json_annotation.dart';

part 'user.g.dart';

@JsonSerializable()
class User {
  final int id;
  final String name;
  final String email;

  @JsonKey(name: 'phone_number')
  final String? phoneNumber;

  final String? avatar;
  final List<String> roles;

  // Local file path for the user's avatar image
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

  // Connect the generated code
  factory User.fromJson(Map<String, dynamic> json) {
    // Handle cases where 'roles' is not present but 'role' is
    if (json['roles'] == null && json['role'] != null) {
      // Convert single role string to an array of strings
      json['roles'] = [json['role']];
    }
    return _$UserFromJson(json);
  }
  Map<String, dynamic> toJson() => _$UserToJson(this);

  // Helper method to check if user has a specific role
  bool hasRole(String role) => roles.contains(role);
}
