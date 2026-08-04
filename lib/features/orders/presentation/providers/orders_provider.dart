import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:restro_hub/core/services/notification_service.dart';
import 'package:restro_hub/features/cart/data/models/cart_model.dart';
import 'package:restro_hub/features/checkout/presentation/providers/checkout_provider.dart';
import 'package:restro_hub/features/dashboard/presentation/providers/loyalty_provider.dart';

enum OrderSubStatus {
  preparing, // Cooking, Packed, InRoute phases
  delivered, // Order is being carried
  pickup, // Please pick up
  success,
  cancelled,
}

class OrderModel {
  final String id;
  final List<CartModel> items;
  final double totalAmount;
  final OrderSubStatus subStatus;
  final DateTime timestamp;
  final String? voucherCode;
  final double discount;
  final PaymentMethod paymentMethod;
  final double progress; // 0.0 to 1.0 for the current phase

  OrderModel({
    required this.id,
    required this.items,
    required this.totalAmount,
    required this.subStatus,
    required this.timestamp,
    required this.paymentMethod,
    this.voucherCode,
    this.discount = 0.0,
    this.progress = 0.0,
  });

  OrderModel copyWith({OrderSubStatus? subStatus, double? progress}) {
    return OrderModel(
      id: id,
      items: items,
      totalAmount: totalAmount,
      subStatus: subStatus ?? this.subStatus,
      timestamp: timestamp,
      voucherCode: voucherCode,
      discount: discount,
      paymentMethod: paymentMethod,
      progress: progress ?? this.progress,
    );
  }
}

class OrdersNotifier extends Notifier<List<OrderModel>> {
  @override
  List<OrderModel> build() => [];

  void addOrder(OrderModel order) {
    state = [order, ...state];
    _startOrderTracking(order.id);
  }

  void _startOrderTracking(String orderId) {
    _showStatusNotification(orderId, OrderSubStatus.preparing);
    // 1. Preparing (Cooking, Packed, InRoute) - 60 seconds
    _runPhase(orderId, OrderSubStatus.preparing, 60, () {
      _showStatusNotification(orderId, OrderSubStatus.delivered);
      // 2. Delivered / Order being carried - 60 seconds
      _runPhase(orderId, OrderSubStatus.delivered, 60, () {
        _showStatusNotification(orderId, OrderSubStatus.pickup);
        // 3. Pick Up - 15 seconds
        _runPhase(orderId, OrderSubStatus.pickup, 15, () {
          _showStatusNotification(orderId, OrderSubStatus.success);
          // 4. Move to Success
          _updateOrderStatus(orderId, OrderSubStatus.success, 1);
          // Add 10 points for successful order
          ref.read(loyaltyProvider.notifier).addPoints(10);
        });
      });
    });
  }

  void _showStatusNotification(String orderId, OrderSubStatus status) {
    var title = 'Order Update';
    var body = '';

    switch (status) {
      case OrderSubStatus.preparing:
        body = 'Your order #$orderId is being prepared!';
      case OrderSubStatus.delivered:
        body = 'Your order #$orderId is on the way!';
      case OrderSubStatus.pickup:
        body = 'Your order #$orderId is ready for pickup!';
      case OrderSubStatus.success:
        title = 'Order Delivered';
        body = 'Enjoy your meal! Order #$orderId was successful.';
      case OrderSubStatus.cancelled:
        title = 'Order Cancelled';
        body = 'Your order #$orderId has been cancelled.';
    }

    ref
        .read(notificationServiceProvider)
        .showNotification(
          id: orderId.hashCode,
          title: title,
          body: body,
        );
  }

  void _runPhase(
    String orderId,
    OrderSubStatus status,
    int durationSeconds,
    VoidCallback onComplete,
  ) {
    var elapsed = 0;
    Timer.periodic(const Duration(seconds: 1), (timer) {
      elapsed++;
      final progress = elapsed / durationSeconds;

      if (elapsed >= durationSeconds) {
        timer.cancel();
        _updateOrderStatus(orderId, status, 1);
        onComplete();
      } else {
        _updateOrderStatus(orderId, status, progress);
      }

      // If order was cancelled or removed, stop timer
      if (!state.any((o) => o.id == orderId)) {
        timer.cancel();
      }
    });
  }

  void _updateOrderStatus(
    String orderId,
    OrderSubStatus status,
    double progress,
  ) {
    state = [
      for (final order in state)
        if (order.id == orderId)
          order.copyWith(subStatus: status, progress: progress)
        else
          order,
    ];
  }

  void cancelOrder(String orderId) {
    _showStatusNotification(orderId, OrderSubStatus.cancelled);
    state = [
      for (final order in state)
        if (order.id == orderId)
          order.copyWith(subStatus: OrderSubStatus.cancelled)
        else
          order,
    ];
  }
}

final ordersProvider = NotifierProvider<OrdersNotifier, List<OrderModel>>(() {
  return OrdersNotifier();
});
