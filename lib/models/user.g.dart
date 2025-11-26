// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

User _$UserFromJson(Map<String, dynamic> json) => User(
      id: const StringToIntConverter().fromJson(json['id']),
      name: json['name'] as String,
      email: json['email'] as String,
      phoneNumber: json['phone'] as String?,
      avatar: json['avatar'] as String?,
      roles: (json['roles'] as List<dynamic>).map((e) => e as String).toList(),
      emailVerifiedAt: json['email_verified_at'] == null
          ? null
          : DateTime.parse(json['email_verified_at'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      token: json['token'] as String?,
    );

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
      'id': const StringToIntConverter().toJson(instance.id),
      'name': instance.name,
      'email': instance.email,
      'phone': instance.phoneNumber,
      'avatar': instance.avatar,
      'roles': instance.roles,
      'email_verified_at': instance.emailVerifiedAt?.toIso8601String(),
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
      'token': instance.token,
    };
