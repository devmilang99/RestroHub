import 'package:restro_hub/infrastructure/sync/models/sync_status.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'sync_monitor_provider.g.dart';

@Riverpod(keepAlive: true)
class GlobalSyncStatus extends _$GlobalSyncStatus {
  @override
  SyncState build() {
    return SyncState(status: SyncStatus.idle);
  }

  void startSync() {
    state = state.copyWith(status: SyncStatus.syncing);
  }

  void completeSync() {
    state = state.copyWith(
      status: SyncStatus.success,
      lastSync: DateTime.now(),
    );
  }

  void failSync(String error) {
    state = state.copyWith(status: SyncStatus.error, errorMessage: error);
  }

  void reset() {
    state = state.copyWith(status: SyncStatus.idle);
  }
}
