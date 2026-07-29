import 'dart:async';

import 'package:restro_hub/core/network/network_monitor.dart';
import 'package:restro_hub/core/network/network_providers.dart';
import 'package:restro_hub/core/utils/logger.dart';
import 'package:restro_hub/infrastructure/sync/supabase_sync_manager.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'sync_coordinator.g.dart';

@Riverpod(keepAlive: true)
class SyncCoordinator extends _$SyncCoordinator {
  @override
  bool build() {
    // Watch network status and trigger sync on transition to online
    ref.listen(networkStatusProvider, (previous, next) {
      final status = next.value;
      final prevStatus = previous?.value;

      if (status == NetworkStatus.online &&
          prevStatus == NetworkStatus.offline) {
        logInfo('SYNC COORDINATOR: Network restored. Triggering auto-sync...');
        _triggerSync();
      }
    });

    // Initial check
    _checkInitialStatus();

    return true;
  }

  Future<void> _checkInitialStatus() async {
    final status = await ref.read(networkMonitorProvider).checkStatus();

    if (!ref.mounted) return;

    if (status == NetworkStatus.online) {
      logInfo(
        'SYNC COORDINATOR: Online at startup. Triggering initial sync...',
      );
      _triggerSync();
    }
  }

  void _triggerSync() {
    try {
      if (ref.mounted) {
        ref.read(supabaseSyncManagerProvider.notifier).syncRestaurants();
      }
    } catch (e, stack) {
      logError('SYNC COORDINATOR: Failed to trigger sync', e, stack);
    }
  }
}
