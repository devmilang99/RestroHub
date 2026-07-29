import 'package:equatable/equatable.dart';
import 'package:restro_hub/core/models/enums.dart';

/// Represents a customer order.
class OrderModel extends Equatable {
  final String? id;
  final String customerId;
  final String restaurantId;
  final String? deliveryAddressId;
  final OrderStatus status;
  final PaymentStatus paymentStatus;
  final double subtotal;
  final double deliveryFee;
  final double taxAmount;
  final double discountAmount;
  final double totalAmount;
  final String? deliveryPartnerId;
  final DateTime? estimatedDeliveryTime;
  final String? notes;
  final DateTime? createdAt;
  final List<OrderItemModel> items;

  const OrderModel({
    required this.customerId,
    required this.restaurantId,
    required this.subtotal,
    required this.totalAmount,
    this.id,
    this.deliveryAddressId,
    this.status = OrderStatus.pending,
    this.paymentStatus = PaymentStatus.pending,
    this.deliveryFee = 0.0,
    this.taxAmount = 0.0,
    this.discountAmount = 0.0,
    this.deliveryPartnerId,
    this.estimatedDeliveryTime,
    this.notes,
    this.createdAt,
    this.items = const [],
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'] as String?,
      customerId: json['customer_id'] as String,
      restaurantId: json['restaurant_id'] as String,
      deliveryAddressId: json['delivery_address_id'] as String?,
      status: OrderStatus.fromString((json['status'] ?? 'pending') as String),
      paymentStatus: PaymentStatus.fromString(
        (json['payment_status'] ?? 'pending') as String,
      ),
      subtotal: ((json['subtotal'] ?? 0.0) as num).toDouble(),
      deliveryFee: ((json['delivery_fee'] ?? 0.0) as num).toDouble(),
      taxAmount: ((json['tax_amount'] ?? 0.0) as num).toDouble(),
      discountAmount: ((json['discount_amount'] ?? 0.0) as num).toDouble(),
      totalAmount: ((json['total_amount'] ?? 0.0) as num).toDouble(),
      deliveryPartnerId: json['delivery_partner_id'] as String?,
      estimatedDeliveryTime: json['estimated_delivery_time'] != null
          ? DateTime.parse(json['estimated_delivery_time'] as String)
          : null,
      notes: json['notes'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      items: json['order_items'] != null
          ? (json['order_items'] as List)
                .map((i) => OrderItemModel.fromJson(i as Map<String, dynamic>))
                .toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'customer_id': customerId,
      'restaurant_id': restaurantId,
      'delivery_address_id': deliveryAddressId,
      'status': status.toSnakeCase(),
      'payment_status': paymentStatus.toSnakeCase(),
      'subtotal': subtotal,
      'delivery_fee': deliveryFee,
      'tax_amount': taxAmount,
      'discount_amount': discountAmount,
      'total_amount': totalAmount,
      'delivery_partner_id': deliveryPartnerId,
      'estimated_delivery_time': estimatedDeliveryTime?.toIso8601String(),
      'notes': notes,
    };
  }

  @override
  List<Object?> get props => [
    id,
    customerId,
    restaurantId,
    deliveryAddressId,
    status,
    paymentStatus,
    subtotal,
    deliveryFee,
    taxAmount,
    discountAmount,
    totalAmount,
    deliveryPartnerId,
    estimatedDeliveryTime,
    notes,
    createdAt,
    items,
  ];
}

class OrderItemModel extends Equatable {
  final String? id;
  final String? orderId;
  final String? menuItemId;
  final String name; // Snapshot of item name at time of order
  final int quantity;
  final double unitPrice;
  final double totalPrice;
  final String? notes;

  const OrderItemModel({
    required this.name,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
    this.id,
    this.orderId,
    this.menuItemId,
    this.notes,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    return OrderItemModel(
      id: json['id'] as String?,
      orderId: json['order_id'] as String?,
      menuItemId: json['menu_item_id'] as String?,
      name: (json['name'] ?? '') as String,
      quantity: (json['quantity'] ?? 1) as int,
      unitPrice: ((json['unit_price'] ?? 0.0) as num).toDouble(),
      totalPrice: ((json['total_price'] ?? 0.0) as num).toDouble(),
      notes: json['notes'] as String?,
    );
  }

  @override
  List<Object?> get props => [
    id,
    orderId,
    menuItemId,
    name,
    quantity,
    unitPrice,
    totalPrice,
    notes,
  ];
}
