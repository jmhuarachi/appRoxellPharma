// lib/features/auth/domain/models/user_model.g.dart
// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

User _$UserFromJson(Map<String, dynamic> json) => User(
      id: json['id'] as int,
      name: json['name'] as String,
      email: json['email'] as String,
      role: json['role'] as String,
      sucursalId: json['sucursal_id'] as int?,
      isActive: json['is_active'] as bool,
      lastLoginAt: json['last_login_at'] as String?,
      sucursalName: json['sucursal_name'] as String?,
    );

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'email': instance.email,
      'role': instance.role,
      'sucursal_id': instance.sucursalId,
      'is_active': instance.isActive,
      'last_login_at': instance.lastLoginAt,
      'sucursal_name': instance.sucursalName,
    };