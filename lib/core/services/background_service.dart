import 'dart:async';
import 'dart:ui';

import 'package:drift/drift.dart' as drift;
import 'package:flutter/foundation.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:live_activities/live_activities.dart';
import 'package:restro_hub/core/data/database/app_database.dart';

Future<void> initializeBackgroundService() async {
  final service = FlutterBackgroundService();

  const channel = AndroidNotificationChannel(
    'order_status_channel',
    'Order Status',
    description: 'Notifications for your order status updates',
    importance: Importance.max,
  );

  final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin
      >()
      ?.createNotificationChannel(channel);

  await service.configure(
    androidConfiguration: AndroidConfiguration(
      onStart: onStart,
      autoStart: false,
      isForegroundMode: true,
      notificationChannelId: 'order_status_channel',
      initialNotificationTitle: 'Order Tracking',
      initialNotificationContent: 'Monitoring your order progress...',
      foregroundServiceTypes: [AndroidForegroundType.dataSync],
    ),
    iosConfiguration: IosConfiguration(
      autoStart: false,
      onForeground: onStart,
      onBackground: onIosBackground,
    ),
  );
}

@pragma('vm:entry-point')
Future<void> onStart(ServiceInstance service) async {
  DartPluginRegistrant.ensureInitialized();

  final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  final liveActivities = LiveActivities();

  if (service is AndroidServiceInstance) {
    service.on('setAsForeground').listen((event) async {
      await service.setAsForegroundService();
    });

    service.on('setAsBackground').listen((event) async {
      await service.setAsBackgroundService();
    });
  }

  service.on('stopService').listen((event) async {
    await service.stopSelf();
  });

  final trackedOrders = <String, Map<String, dynamic>>{};
  final liveActivityIds = <String, String>{}; // OrderId -> ActivityId

  // Initial load from local database to survive app kill
  try {
    final db = AppDatabase(AppDatabase.openConnection());
    final activeOrders =
        await (db.select(db.cachedOrders)..where(
              (t) =>
                  t.status.equals('pending') |
                  t.status.equals('preparing') |
                  t.status.equals('delivered') |
                  t.status.equals('pickup'),
            ))
            .get();

    for (final order in activeOrders) {
      trackedOrders[order.id] = {
        'id': order.id,
        'status': order.status,
        'startTime':
            order.phaseStartTime?.toIso8601String() ??
            DateTime.now().toIso8601String(),
        'phaseDuration': _getDurationForStatus(order.status),
        'progress': 0.0,
      };

      // Try to reconnect/start Live Activity if possible
      try {
        final activityId = await liveActivities.createActivity(
          order.id,
          {
            'orderId': order.id,
            'status': order.status,
            'progress': 0,
          },
        );
        if (activityId != null) {
          liveActivityIds[order.id] = activityId;
        }
      } catch (e) {
        // Silently fail
      }
    }

    // If we have active orders, ensure we are in foreground mode
    if (activeOrders.isNotEmpty && service is AndroidServiceInstance) {
      await service.setAsForegroundService();
    }

    await db.close();
  } catch (e) {
    debugPrint('BG_SERVICE: Failed to load active orders from DB: $e');
  }

  service.on('startTracking').listen((event) async {
    if (event != null && event['order'] != null) {
      final orderData = Map<String, dynamic>.from(event['order'] as Map);
      final orderId = orderData['id'] as String;
      final startTimeStr = event['startTime'] as String?;

      trackedOrders[orderId] = {
        'id': orderId,
        'status': orderData['status'] as String,
        'startTime': startTimeStr ?? DateTime.now().toIso8601String(),
        'phaseDuration': (event['duration'] as num?)?.toInt() ?? 60,
        'progress': 0.0,
      };

      // Start Live Activity for iOS
      try {
        final activityId = await liveActivities.createActivity(
          orderId,
          {
            'orderId': orderId,
            'status': orderData['status'],
            'progress': 0,
          },
        );
        if (activityId != null) {
          liveActivityIds[orderId] = activityId;
        }
      } catch (e) {
        // Silently fail if not supported or error
      }
    }
  });

  service.on('stopTracking').listen((event) async {
    if (event != null && event['id'] != null) {
      final orderId = event['id'] as String;
      trackedOrders.remove(orderId);
      final activityId = liveActivityIds.remove(orderId);
      if (activityId != null) {
        await liveActivities.endActivity(activityId);
      }
    } else {
      trackedOrders.clear();
      for (final id in liveActivityIds.values) {
        await liveActivities.endActivity(id);
      }
      liveActivityIds.clear();
    }
  });

  Timer.periodic(const Duration(seconds: 1), (timer) async {
    if (trackedOrders.isEmpty) return;

    final now = DateTime.now();
    final completedOrderIds = <String>[];
    final statusChanges = <String, String>{};

    for (final orderId in trackedOrders.keys) {
      try {
        final order = trackedOrders[orderId]!;
        final startTime = DateTime.parse(order['startTime'] as String);
        final duration = order['phaseDuration'] as int;

        final elapsed = now.difference(startTime).inSeconds;
        final progress = (elapsed / duration).clamp(0.0, 1.0);
        order['progress'] = progress;

        // Broadcast update back to main isolate
        service.invoke('updateProgress', {
          'id': orderId,
          'status': order['status'],
          'progress': progress,
          'isPhaseCompleted': elapsed >= duration,
        });

        // Update Live Activity
        final activityId = liveActivityIds[orderId];
        if (activityId != null) {
          await liveActivities.updateActivity(activityId, {
            'orderId': orderId,
            'status': order['status'],
            'progress': (progress * 100).toInt(),
          });
        }

        // Update Foreground Notification for Android
        if (service is AndroidServiceInstance) {
          if (await service.isForegroundService()) {
            await flutterLocalNotificationsPlugin.show(
              id: orderId.hashCode,
              title: 'Order Tracking: #$orderId',
              body:
                  '${_getStatusDisplay(order['status'] as String)} (${(progress * 100).toInt()}%)',
              notificationDetails: NotificationDetails(
                android: AndroidNotificationDetails(
                  'order_status_channel',
                  'Order Status',
                  channelDescription:
                      'Notifications for your order status updates',
                  importance: Importance.max,
                  priority: Priority.high,
                  onlyAlertOnce: true,
                  showProgress: true,
                  maxProgress: 100,
                  progress: (progress * 100).toInt(),
                  ongoing: true,
                ),
              ),
            );
          }
        }

        if (elapsed >= duration) {
          final currentStatus = order['status'] as String;
          final nextStatus = _getNextStatus(currentStatus);

          if (nextStatus != null) {
            // Move to next phase automatically
            final statusStartTime = DateTime.now();
            order['status'] = nextStatus;
            order['startTime'] = statusStartTime.toIso8601String();
            order['phaseDuration'] = _getDurationForStatus(nextStatus);
            order['progress'] = 0.0;
            statusChanges[orderId] = nextStatus;

            // Persist to database so app restart sees correct status
            try {
              final db = AppDatabase(AppDatabase.openConnection());

              var companion = CachedOrdersCompanion(
                status: drift.Value(nextStatus),
                phaseStartTime: drift.Value(statusStartTime),
              );

              // Clear pending-specific fields if transitioning from pending
              if (currentStatus == 'pending') {
                companion = companion.copyWith(
                  targetConfirmationTime: const drift.Value(null),
                  remainingPendingSeconds: const drift.Value(null),
                );
              }

              await (db.update(
                db.cachedOrders,
              )..where((t) => t.id.equals(orderId))).write(companion);
              await db.close();
            } catch (e) {
              debugPrint('BG_SERVICE: Failed to persist status change: $e');
            }

            // Notify about phase change
            service.invoke('statusChanged', {
              'id': orderId,
              'status': nextStatus,
              'startTime': statusStartTime.toIso8601String(),
            });
          } else {
            completedOrderIds.add(orderId);
          }
        }
      } catch (e) {
        // Report error back to main isolate
        service.invoke('error', {
          'id': orderId,
          'message': 'Technical problem occurred during order tracking.',
        });
        completedOrderIds.add(orderId); // Stop tracking this order
      }
    }

    for (final id in completedOrderIds) {
      trackedOrders.remove(id);
      final activityId = liveActivityIds.remove(id);
      if (activityId != null) {
        await liveActivities.endActivity(activityId);
      }

      // Persist completion to database
      try {
        final db = AppDatabase(AppDatabase.openConnection());
        // For success, we usually delete from local cache as per OrdersNotifier logic
        await (db.delete(db.cachedOrders)..where((t) => t.id.equals(id))).go();
        await (db.delete(
          db.cachedOrderItems,
        )..where((t) => t.orderId.equals(id))).go();
        await db.close();
      } catch (e) {
        debugPrint('BG_SERVICE: Failed to persist completion: $e');
      }

      // Final Success Notification
      await flutterLocalNotificationsPlugin.show(
        id: id.hashCode,
        title: 'Order Delivered! ✅',
        body:
            'Your order #$id has been successfully delivered. Enjoy your meal!',
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            'order_status_channel',
            'Order Status',
            importance: Importance.max,
            priority: Priority.high,
          ),
        ),
      );
    }
  });
}

String _getStatusDisplay(String status) {
  switch (status) {
    case 'pending':
      return 'Cancellation window open... ⏳';
    case 'preparing':
      return 'Cooking your meal... 🍳';
    case 'delivered':
      return 'Order is on the way! 🛵';
    case 'pickup':
      return 'Ready for pickup! 🛍️';
    case 'success':
      return 'Delivered! ✅';
    default:
      return 'Processing...';
  }
}

String? _getNextStatus(String currentStatus) {
  switch (currentStatus) {
    case 'pending':
      return 'preparing';
    case 'preparing':
      return 'delivered';
    case 'delivered':
      return 'pickup';
    case 'pickup':
      return 'success';
    default:
      return null;
  }
}

int _getDurationForStatus(String status) {
  switch (status) {
    case 'pending':
      return 10;
    case 'preparing':
      return 60;
    case 'delivered':
      return 60;
    case 'pickup':
      return 15;
    default:
      return 0;
  }
}

@pragma('vm:entry-point')
Future<bool> onIosBackground(ServiceInstance service) async {
  return true;
}
