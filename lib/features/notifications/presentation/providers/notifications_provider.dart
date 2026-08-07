import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:restro_hub/features/notifications/data/models/notification_model.dart';

class NotificationsNotifier extends Notifier<List<MockNotification>> {
  final List<MockNotification> _mockNotifications = [
    MockNotification(
      title: '🎉 Special Offer!',
      message: 'Get 50% OFF on your next order at Italian Bistro',
      icon: '🎁',
      timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
      accentColor: const Color(0xFFFF6B6B),
    ),
    MockNotification(
      title: '✅ Order Confirmed',
      message: 'Your order #12345 has been confirmed. Est. delivery: 35 mins',
      icon: '🍜',
      timestamp: DateTime.now().subtract(const Duration(minutes: 15)),
      accentColor: const Color(0xFF51CF66),
    ),
    MockNotification(
      title: '🚗 Order Out for Delivery',
      message: 'Your food is on its way! Track your order with live GPS',
      icon: '🛵',
      timestamp: DateTime.now().subtract(const Duration(minutes: 25)),
      accentColor: const Color(0xFFFFA94D),
      isRead: true,
    ),
    MockNotification(
      title: '⭐ Rate Your Order',
      message: 'Please rate your recent order to help us improve',
      icon: '⭐',
      timestamp: DateTime.now().subtract(const Duration(hours: 1)),
      accentColor: const Color(0xFFFFD93D),
      isRead: true,
    ),
    MockNotification(
      title: '💳 Wallet Credited',
      message: 'Rs. 100 cashback credited to your wallet',
      icon: '💰',
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      accentColor: const Color(0xFF6C5CE7),
      isRead: true,
    ),
    MockNotification(
      title: '🎊 Loyalty Points Earned',
      message: 'You earned 250 loyalty points from your last order',
      icon: '🏆',
      timestamp: DateTime.now().subtract(const Duration(hours: 3)),
      accentColor: const Color(0xFF00B4DB),
      isRead: true,
    ),
  ];

  @override
  List<MockNotification> build() {
    return List.from(_mockNotifications);
  }

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
