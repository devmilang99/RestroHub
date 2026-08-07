// CLEANED BY AI
import 'dart:async';

import 'package:drift/drift.dart' as drift;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:restro_hub/core/data/database/app_database.dart';
import 'package:restro_hub/core/data/database/database_provider.dart';
import 'package:restro_hub/core/services/notification_service.dart';
import 'package:restro_hub/core/utils/logger.dart';
import 'package:restro_hub/features/cart/data/models/cart_model.dart';
import 'package:restro_hub/features/checkout/presentation/providers/checkout_provider.dart';
import 'package:restro_hub/features/dashboard/presentation/providers/loyalty_provider.dart';
import 'package:restro_hub/features/notifications/data/models/notification_model.dart';
import 'package:restro_hub/features/notifications/presentation/providers/notifications_provider.dart';
import 'package:restro_hub/infrastructure/printer/printer_api.g.dart';
import 'package:restro_hub/infrastructure/sync/supabase_sync_manager.dart';
import 'package:uuid/uuid.dart';

enum OrderSubStatus {
  pending, // 10-second cancellation window
  preparing, // Cooking, Packed, InRoute phases
  delivered, // Order is being carried
  pickup, // Please pick up
  success,
  cancelled,
}

class OrderModel {
  final String id;
  final String? restaurantId;
  final List<CartModel> items;
  final double totalAmount;
  final OrderSubStatus subStatus;
  final DateTime timestamp;
  final String? voucherCode;
  final double discount;
  final PaymentMethod paymentMethod;
  final double progress; // 0.0 to 1.0 for the current phase
  final DateTime? targetConfirmationTime;
  final int? remainingPendingSeconds;
  final bool isPendingPaused;
  final String? cancellationReason;

  OrderModel({
    required this.id,
    required this.items,
    required this.totalAmount,
    required this.subStatus,
    required this.timestamp,
    required this.paymentMethod,
    this.restaurantId,
    this.voucherCode,
    this.discount = 0.0,
    this.progress = 0.0,
    this.targetConfirmationTime,
    this.remainingPendingSeconds,
    this.isPendingPaused = false,
    this.cancellationReason,
  });

  OrderModel copyWith({
    OrderSubStatus? subStatus,
    double? progress,
    DateTime? targetConfirmationTime,
    int? remainingPendingSeconds,
    bool? isPendingPaused,
    String? cancellationReason,
  }) {
    return OrderModel(
      id: id,
      restaurantId: restaurantId,
      items: items,
      totalAmount: totalAmount,
      subStatus: subStatus ?? this.subStatus,
      timestamp: timestamp,
      voucherCode: voucherCode,
      discount: discount,
      paymentMethod: paymentMethod,
      progress: progress ?? this.progress,
      targetConfirmationTime:
          targetConfirmationTime ?? this.targetConfirmationTime,
      remainingPendingSeconds:
          remainingPendingSeconds ?? this.remainingPendingSeconds,
      isPendingPaused: isPendingPaused ?? this.isPendingPaused,
      cancellationReason: cancellationReason ?? this.cancellationReason,
    );
  }
}

class OrdersNotifier extends AsyncNotifier<List<OrderModel>> {
  Timer? _globalTimer;

  @override
  FutureOr<List<OrderModel>> build() async {
    _startGlobalTimer();
    final db = await ref.watch(appDatabaseProvider.future);

    // Initial load from local Drift
    final orders = await _loadLocalOrders(db);

    // If we have a user, try to sync missing orders from remote in background
    final userId = ref
        .read(supabaseSyncManagerProvider.notifier)
        .currentUser
        ?.id;
    if (userId != null) {
      unawaited(_syncWithRemote(db));
    }

    return orders;
  }

  Future<List<OrderModel>> _loadLocalOrders(AppDatabase db) async {
    final orderRows = await db.select(db.cachedOrders).get();
    if (orderRows.isEmpty) return [];

    final List<Map<String, dynamic>> ordersWithItems = [];

    for (final row in orderRows) {
      final itemRows = await (db.select(
        db.cachedOrderItems,
      )..where((t) => t.orderId.equals(row.id))).get();

      ordersWithItems.add({
        'order': row,
        'items': itemRows,
      });
    }

    return compute(_mapOrdersDataToModels, ordersWithItems);
  }

  Future<void> _syncWithRemote(AppDatabase db) async {
    final syncManager = ref.read(supabaseSyncManagerProvider.notifier);
    final remoteOrders = await syncManager.fetchRemoteOrders();

    if (remoteOrders.isEmpty) return;

    await db.batch((batch) {
      for (final remote in remoteOrders) {
        final orderId = remote['id'] as String;

        // Insert Order
        batch.insert(
          db.cachedOrders,
          CachedOrdersCompanion.insert(
            id: orderId,
            restaurantId: (remote['restaurant_id'] ?? 'unknown').toString(),
            status: remote['status'] as String,
            paymentStatus: 'paid', // Assuming remote orders are paid
            subtotal: (remote['total_amount'] as num).toDouble(),
            deliveryFee: 0,
            taxAmount: 0,
            discountAmount: 0,
            totalAmount: (remote['total_amount'] as num).toDouble(),
            createdAt: DateTime.parse(remote['created_at'] as String),
          ),
          mode: drift.InsertMode.insertOrReplace,
        );

        // Insert Items
        final remoteItems = remote['order_items'] as List<dynamic>?;
        if (remoteItems != null) {
          for (final item in remoteItems) {
            batch.insert(
              db.cachedOrderItems,
              CachedOrderItemsCompanion.insert(
                id: (item['id'] ?? const Uuid().v4()).toString(),
                orderId: orderId,
                menuItemId: drift.Value(item['menu_item_id'] as String?),
                name: item['name'] as String,
                quantity: item['quantity'] as int,
                unitPrice: (item['unit_price'] as num).toDouble(),
                totalPrice: (item['total_price'] as num).toDouble(),
              ),
              mode: drift.InsertMode.insertOrReplace,
            );
          }
        }
      }
    });

    // Refresh state after sync
    final updatedOrders = await _loadLocalOrders(db);
    state = AsyncValue.data(updatedOrders);
  }

  void _startGlobalTimer() {
    _globalTimer?.cancel();
    _globalTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final currentState = state.value ?? [];
      final now = DateTime.now();
      var stateChanged = false;
      final newState = currentState.map((order) {
        if (order.subStatus == OrderSubStatus.pending &&
            !order.isPendingPaused &&
            order.targetConfirmationTime != null) {
          if (now.isAfter(order.targetConfirmationTime!)) {
            stateChanged = true;
            return order.copyWith(
              subStatus: OrderSubStatus.preparing,
              targetConfirmationTime: null,
              progress: 0.01,
            );
          } else {
            // Force state update to refresh UI timers
            stateChanged = true;
            return order.copyWith();
          }
        }
        return order;
      }).toList();

      if (stateChanged) {
        state = AsyncValue.data(newState);
        // Find IDs that just transitioned
        final newlyConfirmedIds = newState
            .where(
              (o) =>
                  o.subStatus == OrderSubStatus.preparing && o.progress == 0.01,
            )
            .map((o) => o.id)
            .toList();

        for (final id in newlyConfirmedIds) {
          _startOrderTracking(id);
          _triggerPrinter(id);
        }
      }
    });
  }

  void _triggerPrinter(String orderId) {
    try {
      final orders = state.value ?? [];
      final order = orders.firstWhere((o) => o.id == orderId);
      unawaited(
        PrinterApi().printReceipt({
          'orderId': orderId,
          'amount': order.totalAmount.toStringAsFixed(2),
          'itemsCount': order.items.length.toString(),
        }),
      );
    } on Object catch (e) {
      debugPrint('Printer API Error: $e');
    }
  }

  Future<void> addOrder(OrderModel order) async {
    var newOrder = order;
    if (order.subStatus == OrderSubStatus.pending) {
      newOrder = order.copyWith(
        targetConfirmationTime: DateTime.now().add(const Duration(seconds: 10)),
        remainingPendingSeconds: 10,
      );
    }

    final currentState = state.value ?? [];
    state = AsyncValue.data([newOrder, ...currentState]);

    // Persist to Drift
    final db = await ref.read(appDatabaseProvider.future);
    await db
        .into(db.cachedOrders)
        .insert(
          CachedOrdersCompanion.insert(
            id: newOrder.id,
            restaurantId: newOrder.restaurantId ?? 'unknown',
            status: newOrder.subStatus.name,
            paymentStatus: 'pending',
            subtotal: newOrder.totalAmount + newOrder.discount,
            deliveryFee: 0,
            taxAmount: 0,
            discountAmount: newOrder.discount,
            totalAmount: newOrder.totalAmount,
            createdAt: newOrder.timestamp,
          ),
        );

    for (final item in newOrder.items) {
      await db
          .into(db.cachedOrderItems)
          .insert(
            CachedOrderItemsCompanion.insert(
              id: const Uuid().v4(),
              orderId: newOrder.id,
              menuItemId: drift.Value(item.id),
              name: item.name,
              quantity: item.quantity,
              unitPrice: item.price,
              totalPrice: item.price * item.quantity,
            ),
          );
    }

    // Sync to Supabase
    final syncManager = ref.read(supabaseSyncManagerProvider.notifier);
    try {
      await syncManager.pushOrderToRemote(
        {
          'id': newOrder.id,
          'restaurant_id': newOrder.restaurantId ?? 'unknown',
          'status': newOrder.subStatus.name,
          'total_amount': newOrder.totalAmount,
          'created_at': newOrder.timestamp.toIso8601String(),
          'payment_method': newOrder.paymentMethod.name,
          'discount_amount': newOrder.discount,
        },
        newOrder.items
            .map(
              (i) => {
                'menu_item_id': i.id,
                'name': i.name,
                'quantity': i.quantity,
                'unit_price': i.price,
                'total_price': i.price * i.quantity,
              },
            )
            .toList(),
      );
    } catch (e, st) {
      logError('Failed to sync order to remote Supabase', e, st);
    }

    // Push Transaction Record in background
    await syncManager
        .pushTransaction({
          'order_id': newOrder.id,
          'amount': newOrder.totalAmount,
          'status': 'completed',
          'payment_method': newOrder.paymentMethod.name,
        })
        .catchError((Object e, StackTrace st) {
          logError('Failed to push transaction to remote', e);
        });

    if (newOrder.subStatus != OrderSubStatus.pending) {
      _startOrderTracking(newOrder.id);
    }
  }

  void pausePendingTimer(String orderId) {
    final currentState = state.value ?? [];
    state = AsyncValue.data([
      for (final order in currentState)
        if (order.id == orderId && order.targetConfirmationTime != null)
          order.copyWith(
            isPendingPaused: true,
            remainingPendingSeconds: order.targetConfirmationTime!
                .difference(DateTime.now())
                .inSeconds,
            targetConfirmationTime: null,
          )
        else
          order,
    ]);
  }

  void resumePendingTimer(String orderId) {
    final currentState = state.value ?? [];
    state = AsyncValue.data([
      for (final order in currentState)
        if (order.id == orderId && order.remainingPendingSeconds != null)
          order.copyWith(
            isPendingPaused: false,
            targetConfirmationTime: DateTime.now().add(
              Duration(seconds: order.remainingPendingSeconds!),
            ),
          )
        else
          order,
    ]);
  }

  void confirmOrder(String orderId) {
    final currentState = state.value ?? [];
    state = AsyncValue.data([
      for (final order in currentState)
        if (order.id == orderId)
          order.copyWith(
            subStatus: OrderSubStatus.preparing,
            targetConfirmationTime: null,
            progress: 0.01,
          )
        else
          order,
    ]);
    _startOrderTracking(orderId);
    _triggerPrinter(orderId);
  }

  void _startOrderTracking(String orderId) {
    _showStatusNotification(orderId, OrderSubStatus.preparing);
    _runPhase(orderId, OrderSubStatus.preparing, 60, () {
      _showStatusNotification(orderId, OrderSubStatus.delivered);
      _runPhase(orderId, OrderSubStatus.delivered, 60, () {
        _showStatusNotification(orderId, OrderSubStatus.pickup);
        _runPhase(orderId, OrderSubStatus.pickup, 15, () {
          _showStatusNotification(orderId, OrderSubStatus.success);
          _updateOrderStatus(orderId, OrderSubStatus.success, 1);
          ref.read(loyaltyProvider.notifier).addPoints(10);
        });
      });
    });
  }

  void _showStatusNotification(String orderId, OrderSubStatus status) {
    String title = 'Order Update';
    String body = '';
    String icon = '🔔';
    Color color = const Color(0xFF339AF0);

    switch (status) {
      case OrderSubStatus.preparing:
        body = 'Your order #$orderId is being prepared!';
        icon = '🍳';
        color = const Color(0xFFFFA94D);
        break;
      case OrderSubStatus.delivered:
        body = 'Your order #$orderId is on the way!';
        icon = '🛵';
        color = const Color(0xFF339AF0);
        break;
      case OrderSubStatus.pickup:
        body = 'Your order #$orderId is ready for pickup!';
        icon = '🛍️';
        color = const Color(0xFF845EF7);
        break;
      case OrderSubStatus.success:
        title = 'Order Delivered';
        body = 'Enjoy your meal! Order #$orderId was successful.';
        icon = '✅';
        color = const Color(0xFF51CF66);
        break;
      case OrderSubStatus.cancelled:
        title = 'Order Cancelled';
        body = 'Your order #$orderId has been cancelled.';
        icon = '❌';
        color = const Color(0xFFFF6B6B);
        break;
      case OrderSubStatus.pending:
        return;
    }

    ref
        .read(notificationServiceProvider)
        .showNotification(
          id: orderId.hashCode,
          title: title,
          body: body,
        );

    if (status == OrderSubStatus.success ||
        status == OrderSubStatus.cancelled) {
      ref
          .read(notificationsProvider.notifier)
          .addNotification(
            MockNotification(
              title: title,
              message: body,
              icon: icon,
              timestamp: DateTime.now(),
              accentColor: color,
            ),
          );
    }
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

      final currentState = state.value ?? [];
      if (!currentState.any((o) => o.id == orderId)) {
        timer.cancel();
      }
    });
  }

  void _updateOrderStatus(
    String orderId,
    OrderSubStatus status,
    double progress,
  ) {
    final currentState = state.value ?? [];
    state = AsyncValue.data([
      for (final order in currentState)
        if (order.id == orderId)
          order.copyWith(subStatus: status, progress: progress)
        else
          order,
    ]);
  }

  void cancelOrder(String orderId, {String? reason}) {
    _showStatusNotification(orderId, OrderSubStatus.cancelled);
    final currentState = state.value ?? [];
    state = AsyncValue.data([
      for (final order in currentState)
        if (order.id == orderId)
          order.copyWith(
            subStatus: OrderSubStatus.cancelled,
            cancellationReason: reason,
          )
        else
          order,
    ]);
  }
}

List<OrderModel> _mapOrdersDataToModels(List<Map<String, dynamic>> data) {
  return data
      .map((entry) {
        final row = entry['order'] as CachedOrder;
        final itemRows = entry['items'] as List<CachedOrderItem>;

        return OrderModel(
          id: row.id,
          restaurantId: row.restaurantId,
          items: itemRows
              .map(
                (i) => CartModel(
                  id: i.menuItemId,
                  restaurantId: row.restaurantId,
                  name: i.name,
                  image: '',
                  price: i.unitPrice,
                  quantity: i.quantity,
                ),
              )
              .toList(),
          totalAmount: row.totalAmount,
          subStatus: _parseStatusString(row.status),
          timestamp: row.createdAt,
          paymentMethod: PaymentMethod.cod,
          discount: row.discountAmount,
        );
      })
      .toList()
      .reversed
      .toList();
}

OrderSubStatus _parseStatusString(String status) {
  return OrderSubStatus.values.firstWhere(
    (e) => e.name == status,
    orElse: () => OrderSubStatus.pending,
  );
}

final ordersProvider = AsyncNotifierProvider<OrdersNotifier, List<OrderModel>>(
  () {
    return OrdersNotifier();
  },
);
