import 'package:equatable/equatable.dart';

/// Represents a delivery partner and their current status.
class DeliveryPartnerModel extends Equatable {
  final String id; // Matches Profile ID
  final String? vehicleType;
  final String? vehicleNumber;
  final String currentStatus; // 'online', 'offline', 'busy'
  final double? lastKnownLat;
  final double? lastKnownLng;
  final DateTime? updatedAt;

  const DeliveryPartnerModel({
    required this.id,
    this.vehicleType,
    this.vehicleNumber,
    this.currentStatus = 'offline',
    this.lastKnownLat,
    this.lastKnownLng,
    this.updatedAt,
  });

  factory DeliveryPartnerModel.fromJson(Map<String, dynamic> json) {
    return DeliveryPartnerModel(
      id: json['id'] as String,
      vehicleType: json['vehicle_type'] as String?,
      vehicleNumber: json['vehicle_number'] as String?,
      currentStatus: (json['current_status'] ?? 'offline') as String,
      lastKnownLat: (json['last_known_lat'] as num?)?.toDouble(),
      lastKnownLng: (json['last_known_lng'] as num?)?.toDouble(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'vehicle_type': vehicleType,
      'vehicle_number': vehicleNumber,
      'current_status': currentStatus,
      'last_known_lat': lastKnownLat,
      'last_known_lng': lastKnownLng,
    };
  }

  @override
  List<Object?> get props => [
    id,
    vehicleType,
    vehicleNumber,
    currentStatus,
    lastKnownLat,
    lastKnownLng,
    updatedAt,
  ];
}
