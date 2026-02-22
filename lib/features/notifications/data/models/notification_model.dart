import 'package:flutter/material.dart';

class MockNotification {
  final String title;
  final String message;
  final String icon;
  final DateTime timestamp;
  final Color accentColor;
  final bool isRead;

  MockNotification({
    required this.title,
    required this.message,
    required this.icon,
    required this.timestamp,
    required this.accentColor,
    this.isRead = false,
  });
}
