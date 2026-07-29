import 'package:equatable/equatable.dart';
import 'package:restro_hub/core/models/enums.dart';

/// User Model for Authentication.
/// Extended to support enterprise roles.
class UserModel extends Equatable {
  final String id;
  final String email;
  final String? fullName;
  final String? avatarUrl;
  final String? phone;
  final UserRole role;
  final DateTime? createdAt;

  const UserModel({
    required this.id,
    required this.email,
    this.fullName,
    this.avatarUrl,
    this.phone,
    this.role = UserRole.customer,
    this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: (json['email'] ?? '') as String,
      fullName:
          (json['full_name'] ??
                  json['name'] ??
                  (json['email'] as String?)?.split('@').first)
              as String?,
      avatarUrl: (json['avatar_url'] ?? json['picture']) as String?,
      phone: json['phone'] as String?,
      role: UserRole.fromString((json['role'] ?? 'customer') as String),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'full_name': fullName,
      'avatar_url': avatarUrl,
      'phone': phone,
      'role': role.toSnakeCase(),
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [
    id,
    email,
    fullName,
    avatarUrl,
    phone,
    role,
    createdAt,
  ];
}
