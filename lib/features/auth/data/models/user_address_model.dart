import 'package:equatable/equatable.dart';

/// Represents a delivery address for a user.
class UserAddressModel extends Equatable {
  final String? id;
  final String userId;
  final String label;
  final String addressLine1;
  final String? addressLine2;
  final String city;
  final String? state;
  final String? postalCode;
  final double? latitude;
  final double? longitude;
  final bool isDefault;

  const UserAddressModel({
    required this.userId,
    required this.addressLine1,
    required this.city,
    this.id,
    this.label = 'Home',
    this.addressLine2,
    this.state,
    this.postalCode,
    this.latitude,
    this.longitude,
    this.isDefault = false,
  });

  factory UserAddressModel.fromJson(Map<String, dynamic> json) {
    return UserAddressModel(
      id: json['id'] as String?,
      userId: json['user_id'] as String,
      label: (json['label'] ?? 'Home') as String,
      addressLine1: json['address_line1'] as String,
      addressLine2: json['address_line2'] as String?,
      city: json['city'] as String,
      state: json['state'] as String?,
      postalCode: json['postal_code'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      isDefault: (json['is_default'] ?? false) as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'user_id': userId,
      'label': label,
      'address_line1': addressLine1,
      'address_line2': addressLine2,
      'city': city,
      'state': state,
      'postal_code': postalCode,
      'latitude': latitude,
      'longitude': longitude,
      'is_default': isDefault,
    };
  }

  @override
  List<Object?> get props => [
    id,
    userId,
    label,
    addressLine1,
    addressLine2,
    city,
    state,
    postalCode,
    latitude,
    longitude,
    isDefault,
  ];
}
