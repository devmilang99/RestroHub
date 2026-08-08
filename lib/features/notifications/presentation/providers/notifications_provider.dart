import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:restro_hub/features/notifications/data/models/notification_model.dart';

import 'package:restro_hub/features/auth/presentation/providers/auth_provider.dart';

class NotificationsNotifier extends Notifier<List<MockNotification>> {
  @override
  List<MockNotification> build() {
    // Watch user to clear notifications on logout
    final user = ref.watch(currentUserProvider).value;
    if (user == null) {
      return [];
    }

    return List.from(_mockNotifications);
  }

  final List<MockNotification> _mockNotifications = [];

  int getUnreadCount() {
    return state.where((n) => !n.isRead).length;
  }

  void markAsRead(int index) {
    if (index >= 0 && index < state.length) {
      final notification = state[index];
      state = [
        ...state.sublist(0, index),
        MockNotification(
          title: notification.title,
          message: notification.message,
          icon: notification.icon,
          timestamp: notification.timestamp,
          accentColor: notification.accentColor,
          isRead: true,
        ),
        ...state.sublist(index + 1),
      ];
    }
  }

  void markAllAsRead() {
    state = state
        .map(
          (n) => MockNotification(
            title: n.title,
            message: n.message,
            icon: n.icon,
            timestamp: n.timestamp,
            accentColor: n.accentColor,
            isRead: true,
          ),
        )
        .toList();
  }

  void clearAll() {
    state = [];
  }

  void deleteNotification(int index) {
    if (index >= 0 && index < state.length) {
      state = [...state.sublist(0, index), ...state.sublist(index + 1)];
    }
  }

  void addNotification(MockNotification notification) {
    state = [notification, ...state];
  }
}

final notificationsProvider =
    NotifierProvider<NotificationsNotifier, List<MockNotification>>(() {
      return NotificationsNotifier();
    });
