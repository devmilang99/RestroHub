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
    state = state.copyWith(status: SyncStatus.syncing, progress: 0.0);
  }

  void updateProgress(double progress) {
    if (state.status == SyncStatus.syncing) {
      state = state.copyWith(progress: progress.clamp(0.0, 1.0));
    }
  }

  void completeSync() {
    state = state.copyWith(
      status: SyncStatus.success,
      lastSync: DateTime.now(),
      progress: 1.0,
    );
  }

  void failSync(String error) {
    state = state.copyWith(
      status: SyncStatus.error,
      errorMessage: error,
      progress: 0.0,
    );
  }

  void reset() {
    state = state.copyWith(status: SyncStatus.idle, progress: 0.0);
  }
}
