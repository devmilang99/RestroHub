// CLEANED BY AI
import 'dart:async';

import 'package:drift/drift.dart' as drift;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:restro_hub/core/data/database/app_database.dart';
import 'package:restro_hub/core/data/database/database_provider.dart';
import 'package:restro_hub/core/providers/error_service.dart';
import 'package:restro_hub/core/services/notification_service.dart';
import 'package:restro_hub/core/utils/logger.dart';
import 'package:restro_hub/features/auth/presentation/providers/auth_provider.dart';
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
  final DateTime? phaseStartTime;

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
    this.phaseStartTime,
  });

  OrderModel copyWith({
    OrderSubStatus? subStatus,
    double? progress,
    DateTime? targetConfirmationTime,
    int? remainingPendingSeconds,
    bool? isPendingPaused,
    String? cancellationReason,
    DateTime? phaseStartTime,
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
      phaseStartTime: phaseStartTime ?? this.phaseStartTime,
    );
  }
}

class OrdersNotifier extends AsyncNotifier<List<OrderModel>> {
  Timer? _globalTimer;
  StreamSubscription? _bgProgressSubscription;
  StreamSubscription? _bgStatusSubscription;

  @override
  FutureOr<List<OrderModel>> build() async {
    // Watch current user to ensure data resets on logout/login
    final user = ref.watch(currentUserProvider).value;
    if (user == null) {
      _globalTimer?.cancel();
      _bgProgressSubscription?.cancel();
      _bgStatusSubscription?.cancel();
      return [];
    }

    _startGlobalTimer();
    _listenToBackgroundService();

    final db = await ref.watch(appDatabaseProvider.future);

    // Initial load from local Drift
    final orders = await _loadLocalOrders(db);

    // Resume tracking for active orders after initial load
    if (orders.isNotEmpty) {
      Future.microtask(() {
        for (final order in orders) {
          if (order.subStatus != OrderSubStatus.success &&
              order.subStatus != OrderSubStatus.cancelled) {
            _startOrderTracking(order.id);
          }
        }
      });
    }

    // If we have a user, try to sync missing orders from remote in background
    final syncManager = ref.read(supabaseSyncManagerProvider.notifier);
    final userId = syncManager.currentUser?.id;
    if (userId != null) {
      unawaited(
        syncManager.syncRemoteOrders().then((_) async {
          if (ref.mounted) {
            final updatedOrders = await _loadLocalOrders(db);
            state = AsyncValue.data(updatedOrders);
          }
        }),
      );
    }

    return orders;
  }

  void _listenToBackgroundService() {
    final service = FlutterBackgroundService();

    _bgProgressSubscription?.cancel();
    _bgProgressSubscription = service.on('updateProgress').listen((event) {
      if (event == null) return;
      final id = event['id'] as String;
      final statusStr = event['status'] as String;
      final progress = (event['progress'] as num).toDouble();

      final currentState = state.value ?? [];
      if (currentState.any((o) => o.id == id)) {
        state = AsyncValue.data([
          for (final order in currentState)
            if (order.id == id)
              order.copyWith(
                subStatus: _parseStatusString(statusStr),
                progress: progress,
              )
            else
              order,
        ]);
      }
    });

    _bgStatusSubscription?.cancel();
    _bgStatusSubscription = service.on('statusChanged').listen((event) async {
      if (event == null) return;
      final id = event['id'] as String;
      final statusStr = event['status'] as String;
      final status = _parseStatusString(statusStr);
      final startTimeStr = event['startTime'] as String?;
      final startTime = startTimeStr != null
          ? DateTime.parse(startTimeStr)
          : DateTime.now();

      final currentState = state.value ?? [];
      if (currentState.any((o) => o.id == id)) {
        state = AsyncValue.data([
          for (final order in currentState)
            if (order.id == id)
              order.copyWith(
                subStatus: status,
                progress: 0.0,
                phaseStartTime: startTime,
              )
            else
              order,
        ]);

        await _persistOrderStatus(id, status, startTime: startTime);

        if (status == OrderSubStatus.success) {
          ref.read(loyaltyProvider.notifier).addPoints(10);
        }
      }
    });

    service.on('error').listen((event) {
      if (event == null) return;
      final id = event['id'] as String;
      final errorMessage =
          event['message'] as String? ??
          'Order processing failed due to a technical problem.';

      cancelOrder(id, reason: errorMessage);
      ref
          .read(errorServiceProvider.notifier)
          .showError(
            message: "Order #$id: $errorMessage Please try again.",
          );
    });
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
            final updatedOrder = order.copyWith(
              subStatus: OrderSubStatus.preparing,
              targetConfirmationTime: null,
              progress: 0.01,
              phaseStartTime: now,
            );
            // Persist auto-confirmation to database
            unawaited(
              _persistOrderStatus(
                order.id,
                OrderSubStatus.preparing,
                startTime: now,
              ),
            );
            return updatedOrder;
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
        phaseStartTime: DateTime.now(),
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
            targetConfirmationTime: drift.Value(
              newOrder.targetConfirmationTime,
            ),
            remainingPendingSeconds: drift.Value(
              newOrder.remainingPendingSeconds,
            ),
            isPendingPaused: drift.Value(newOrder.isPendingPaused),
            phaseStartTime: drift.Value(newOrder.phaseStartTime),
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
              imageUrl: drift.Value(item.image),
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
      // Cancel the order if initial sync fails
      cancelOrder(
        newOrder.id,
        reason: 'Technical problem during order placement.',
      );
      ref
          .read(errorServiceProvider.notifier)
          .showError(
            message:
                'Order could not be processed due to a technical problem. Please try again.',
          );
      return;
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
          // We don't necessarily cancel for transaction record failure if the order is synced
        });

    _startOrderTracking(newOrder.id);
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
    final now = DateTime.now();
    state = AsyncValue.data([
      for (final order in currentState)
        if (order.id == orderId)
          order.copyWith(
            subStatus: OrderSubStatus.preparing,
            targetConfirmationTime: null,
            progress: 0.01,
            phaseStartTime: now,
          )
        else
          order,
    ]);

    unawaited(
      _persistOrderStatus(orderId, OrderSubStatus.preparing, startTime: now),
    );
    _startOrderTracking(orderId);
    _triggerPrinter(orderId);
  }

  void _startOrderTracking(String orderId) {
    final service = FlutterBackgroundService();
    service.startService(); // Ensure it is running
    service.invoke('setAsForeground');

    final order = (state.value ?? []).firstWhere((o) => o.id == orderId);

    service.invoke('startTracking', {
      'order': {
        'id': orderId,
        'status': order.subStatus.name,
      },
      'duration': _getPhaseDuration(order.subStatus),
      'startTime': order.phaseStartTime?.toIso8601String(),
    });

    _showStatusNotification(orderId, order.subStatus);
  }

  int _getPhaseDuration(OrderSubStatus status) {
    switch (status) {
      case OrderSubStatus.pending:
        return 10;
      case OrderSubStatus.preparing:
        return 60;
      case OrderSubStatus.delivered:
        return 60;
      case OrderSubStatus.pickup:
        return 15;
      default:
        return 0;
    }
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
        title = 'Order Received';
        body = 'Cancellation window for #$orderId is open for 10s.';
        icon = '⏳';
        color = const Color(0xFFADB5BD);
        break;
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

  Future<void> _persistOrderStatus(
    String orderId,
    OrderSubStatus status, {
    DateTime? startTime,
  }) async {
    try {
      final db = await ref.read(appDatabaseProvider.future);
      final syncManager = ref.read(supabaseSyncManagerProvider.notifier);

      if (status == OrderSubStatus.success ||
          status == OrderSubStatus.cancelled) {
        // 1. Update remote first to ensure source of truth is updated
        await syncManager.syncLocalToRemote('orders', {
          'id': orderId,
          'status': status.name,
        });

        // 2. Proactively clear from local database
        await (db.delete(
          db.cachedOrders,
        )..where((t) => t.id.equals(orderId))).go();
        await (db.delete(
          db.cachedOrderItems,
        )..where((t) => t.orderId.equals(orderId))).go();

        // 3. Trigger a sync to refresh completed/cancelled orders from server
        unawaited(
          syncManager.syncRemoteOrders().then((_) async {
            if (ref.mounted) {
              final updatedOrders = await _loadLocalOrders(db);
              state = AsyncValue.data(updatedOrders);
            }
          }),
        );
      } else {
        // Update local status for in-progress orders
        final companion = CachedOrdersCompanion(
          status: drift.Value(status.name),
          phaseStartTime: drift.Value(startTime ?? DateTime.now()),
        );

        if (status == OrderSubStatus.preparing) {
          await (db.update(
            db.cachedOrders,
          )..where((t) => t.id.equals(orderId))).write(
            companion.copyWith(
              targetConfirmationTime: const drift.Value(null),
              remainingPendingSeconds: const drift.Value(null),
            ),
          );
        } else {
          await (db.update(
            db.cachedOrders,
          )..where((t) => t.id.equals(orderId))).write(companion);
        }
      }
    } catch (e, st) {
      logError('Failed to persist order status update for $orderId', e, st);
      // Handle technical failure by cancelling order (if not already cancelling)
      if (status != OrderSubStatus.cancelled) {
        cancelOrder(orderId, reason: 'Technical synchronization error.');
        ref
            .read(errorServiceProvider.notifier)
            .showError(
              message:
                  'Order #$orderId encountered a technical problem and has been cancelled. Please try again.',
            );
      }
    }
  }

  void cancelOrder(String orderId, {String? reason}) {
    _showStatusNotification(orderId, OrderSubStatus.cancelled);

    // Stop background tracking
    final service = FlutterBackgroundService();
    service.invoke('stopTracking', {'id': orderId});

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

    unawaited(_persistOrderStatus(orderId, OrderSubStatus.cancelled));
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
                  image: i.imageUrl ?? '',
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
          targetConfirmationTime: row.targetConfirmationTime,
          remainingPendingSeconds: row.remainingPendingSeconds,
          isPendingPaused: row.isPendingPaused,
          phaseStartTime: row.phaseStartTime,
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
