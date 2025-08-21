// lib/features/auth/domain/models/user_model.dart
import 'package:json_annotation/json_annotation.dart';

part 'user_model.g.dart';

@JsonSerializable()
class User {
  final int id;
  final String name;
  final String email;
  final String role;
  final int? sucursalId;
  final bool isActive;
  final String? lastLoginAt;
  final String? sucursalName;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.sucursalId,
    required this.isActive,
    this.lastLoginAt,
    this.sucursalName,
  });

  bool get isSuperAdmin => role == 'super_admin';
  bool get isAdmin => role == 'admin';
  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);
}
