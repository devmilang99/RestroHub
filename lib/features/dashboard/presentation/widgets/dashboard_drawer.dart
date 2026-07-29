import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:restro_hub/features/auth/data/models/user_model.dart';
import 'package:restro_hub/features/auth/presentation/providers/auth_provider.dart';
import 'package:restro_hub/infrastructure/sync/models/sync_status.dart';
import 'package:restro_hub/infrastructure/sync/supabase_sync_manager.dart';
import 'package:restro_hub/infrastructure/sync/sync_monitor_provider.dart';

class DashboardDrawer extends ConsumerWidget {
  const DashboardDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authRepositoryProvider).currentUser;

    return Drawer(
      child: Column(
        children: [
          PremiumDrawerHeader(user: user),
          ListTile(
            leading: const Icon(Icons.home_outlined),
            title: const Text('Home'),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: const Icon(Icons.person_outline),
            title: const Text('Profile'),
            onTap: () {
              Navigator.pop(context);
              unawaited(context.pushNamed('profileScreen', extra: user));
            },
          ),
          ListTile(
            leading: const Icon(Icons.contact_support_outlined),
            title: const Text('Contact Us'),
            onTap: () {
              Navigator.pop(context);
              unawaited(context.pushNamed('contactUsScreen'));
            },
          ),
          const Divider(),
          const SyncStatusSection(),
          const Spacer(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Logout', style: TextStyle(color: Colors.red)),
            onTap: () async {
              Navigator.pop(context);
              await ref.read(authRepositoryProvider).signOut();
              if (context.mounted) {
                context.goNamed('splash');
              }
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class SyncStatusSection extends ConsumerWidget {
  const SyncStatusSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final syncState = ref.watch(globalSyncStatusProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Data Synchronization',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade600,
                ),
              ),
              const Spacer(),
              if (syncState.status == SyncStatus.syncing)
                const SizedBox(
                  width: 12,
                  height: 12,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
            ],
          ),
          const SizedBox(height: 8),
          _buildStatusRow(syncState),
          if (syncState.lastSync != null)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                'Last synced: ${DateFormat('MMM d, HH:mm').format(syncState.lastSync!)}',
                style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
              ),
            ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: syncState.status == SyncStatus.syncing
                  ? null
                  : () => ref
                        .read(supabaseSyncManagerProvider.notifier)
                        .syncRestaurants(force: true),
              icon: const Icon(Icons.sync, size: 16),
              label: const Text('Sync Now', style: TextStyle(fontSize: 12)),
              style: OutlinedButton.styleFrom(
                visualDensity: VisualDensity.compact,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusRow(SyncState state) {
    final IconData icon;
    final Color color;
    final String text;

    switch (state.status) {
      case SyncStatus.idle:
        icon = Icons.cloud_done_outlined;
        color = Colors.grey;
        text = 'Ready';
      case SyncStatus.syncing:
        icon = Icons.sync;
        color = Colors.blue;
        text = 'Syncing...';
      case SyncStatus.success:
        icon = Icons.check_circle_outline;
        color = Colors.green;
        text = 'Up to date';
      case SyncStatus.error:
        icon = Icons.error_outline;
        color = Colors.red;
        text = 'Sync failed';
    }

    return Row(
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            fontSize: 12,
            color: color,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class PremiumDrawerHeader extends StatelessWidget {
  final UserModel? user;
  const PremiumDrawerHeader({required this.user, super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 60, bottom: 20, left: 20, right: 20),
      decoration: BoxDecoration(
        color: colorScheme.primary,
        borderRadius: const BorderRadius.only(
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 35,
            backgroundColor: Colors.white24,
            child: Text(
              (user?.email ?? 'U')[0].toUpperCase(),
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 15),
          Text(
            user?.email ?? 'Guest User',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            'Premium Member',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

class PointsGraph extends StatefulWidget {
  final double collected;
  final double total;
  const PointsGraph({required this.collected, required this.total, super.key});

  @override
  State<PointsGraph> createState() => _PointsGraphState();
}

class _PointsGraphState extends State<PointsGraph>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _animation = Tween<double>(
      begin: 0,
      end: widget.collected / widget.total,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    unawaited(_controller.forward());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return CustomPaint(
            size: const Size(80, 45),
            painter: HalfArcPainter(
              progress: _animation.value,
              backgroundColor: Colors.white.withValues(alpha: 0.2),
            ),
          );
        },
      ),
    );
  }
}

class HalfArcPainter extends CustomPainter {
  final double progress;
  final Color backgroundColor;

  HalfArcPainter({
    required this.progress,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height);
    final radius = size.width / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    final bgPaint = Paint()
      ..color = backgroundColor
      ..strokeWidth = 8
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final progressPaint = Paint()
      ..color = Colors.amber
      ..strokeWidth = 8
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(rect, math.pi, math.pi, false, bgPaint);
    if (progress > 0) {
      canvas.drawArc(rect, math.pi, math.pi * progress, false, progressPaint);
    }
  }

  @override
  bool shouldRepaint(covariant HalfArcPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
