import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:restro_hub/core/extensions/context_extension.dart';
import 'package:restro_hub/features/notifications/presentation/providers/notifications_provider.dart';

// Notification model is defined in data layer

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() =>
      _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }

  void _markAsRead(int index) {
    ref.read(notificationsProvider.notifier).markAsRead(index);
  }

  void _deleteNotification(int index) {
    ref.read(notificationsProvider.notifier).deleteNotification(index);
  }

  void _clearAll() {
    ref.read(notificationsProvider.notifier).clearAll();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final notifications = ref.watch(notificationsProvider);
    final unreadCount = notifications.where((n) => !n.isRead).length;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: colorScheme.surface,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: colorScheme.onSurface,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Notifications',
              style: GoogleFonts.playfairDisplay(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (unreadCount > 0)
              Text(
                '$unreadCount new notifications',
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  color: colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
          ],
        ),
        actions: [
          if (notifications.isNotEmpty)
            TextButton(
              onPressed: () {
                ref.read(notificationsProvider.notifier).markAllAsRead();
              },
              child: Text(
                'Mark all read',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          if (notifications.isNotEmpty)
            TextButton(
              onPressed: () async {
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Clear all notifications?'),
                    content: const Text('This will remove all notifications.'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text('Clear'),
                      ),
                    ],
                  ),
                );
                if (confirmed == true) {
                  _clearAll();
                }
              },
              child: Text(
                'Clear all',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.redAccent,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
      body: notifications.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.notifications_none_rounded,
                    size: 64,
                    color: colorScheme.onSurface.withValues(alpha: 0.2),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No notifications yet',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: colorScheme.onSurface.withValues(alpha: 0.5),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final notification = notifications[index];
                return Dismissible(
                  key: ValueKey(
                    notification.timestamp.toIso8601String() + index.toString(),
                  ),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    decoration: BoxDecoration(
                      color: Colors.redAccent.withValues(alpha: 0.95),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.delete_forever,
                      color: Colors.white,
                    ),
                  ),
                  onDismissed: (_) => _deleteNotification(index),
                  child: GestureDetector(
                    onTap: () => _markAsRead(index),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.only(bottom: 10),
                      decoration: BoxDecoration(
                        color: notification.isRead
                            ? colorScheme.surface
                            : isDark
                            ? colorScheme.primaryContainer.withValues(
                                alpha: 0.15,
                              )
                            : notification.accentColor.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: notification.isRead
                              ? colorScheme.outlineVariant.withValues(
                                  alpha: 0.3,
                                )
                              : notification.accentColor.withValues(alpha: 0.3),
                          width: 1,
                        ),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => _markAsRead(index),
                          borderRadius: BorderRadius.circular(16),
                          child: Padding(
                            padding: const EdgeInsets.all(14),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Icon bubble
                                Container(
                                  width: 56,
                                  height: 56,
                                  decoration: BoxDecoration(
                                    color: notification.accentColor.withValues(
                                      alpha: 0.15,
                                    ),
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(
                                      color: notification.accentColor
                                          .withValues(alpha: 0.3),
                                      width: 1.5,
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      notification.icon,
                                      style: const TextStyle(fontSize: 24),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                // Content
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              notification.title,
                                              style: GoogleFonts.poppins(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w700,
                                                color: colorScheme.onSurface,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          if (!notification.isRead)
                                            Container(
                                              width: 8,
                                              height: 8,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: notification.accentColor,
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: notification
                                                        .accentColor
                                                        .withValues(alpha: 0.5),
                                                    blurRadius: 4,
                                                  ),
                                                ],
                                              ),
                                            ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        notification.message,
                                        style: GoogleFonts.poppins(
                                          fontSize: 12,
                                          color: colorScheme.onSurface
                                              .withValues(alpha: 0.6),
                                          height: 1.4,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        _formatTime(notification.timestamp),
                                        style: GoogleFonts.poppins(
                                          fontSize: 10,
                                          color: colorScheme.onSurface
                                              .withValues(alpha: 0.4),
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                // Action icon
                                PopupMenuButton<String>(
                                  onSelected: (value) {
                                    if (value == 'delete') {
                                      _deleteNotification(index);
                                    }
                                  },
                                  itemBuilder: (_) => [
                                    const PopupMenuItem(
                                      value: 'delete',
                                      child: Text('Delete'),
                                    ),
                                  ],
                                  child: Icon(
                                    Icons.more_vert_rounded,
                                    size: 18,
                                    color: colorScheme.onSurface.withValues(
                                      alpha: 0.3,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
