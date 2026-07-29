import 'package:equatable/equatable.dart';
import 'package:restro_hub/core/models/enums.dart';

/// Represents a status update for an order.
class OrderTrackingModel extends Equatable {
  final String? id;
  final String orderId;
  final OrderStatus status;
  final double? latitude;
  final double? longitude;
  final String? notes;
  final DateTime? createdAt;

  const OrderTrackingModel({
    required this.orderId,
    required this.status,
    this.id,
    this.latitude,
    this.longitude,
    this.notes,
    this.createdAt,
  });

  factory OrderTrackingModel.fromJson(Map<String, dynamic> json) {
    return OrderTrackingModel(
      id: json['id'] as String?,
      orderId: json['order_id'] as String,
      status: OrderStatus.fromString((json['status'] ?? 'pending') as String),
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      notes: json['notes'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

  @override
  List<Object?> get props => [
    id,
    orderId,
    status,
    latitude,
    longitude,
    notes,
    createdAt,
  ];
}
