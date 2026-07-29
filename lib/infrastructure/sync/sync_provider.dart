import 'dart:async';

import 'package:restro_hub/infrastructure/sync/local_sync_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'sync_provider.g.dart';

class KdsSyncState {
  final bool isServerRunning;
  final bool isDiscoveryActive;
  final String? serverAddress;

  KdsSyncState({
    required this.isServerRunning,
    required this.isDiscoveryActive,
    this.serverAddress,
  });

  KdsSyncState copyWith({
    bool? isServerRunning,
    bool? isDiscoveryActive,
    String? serverAddress,
  }) {
    return KdsSyncState(
      isServerRunning: isServerRunning ?? this.isServerRunning,
      isDiscoveryActive: isDiscoveryActive ?? this.isDiscoveryActive,
      serverAddress: serverAddress ?? this.serverAddress,
    );
  }
}

@riverpod
class KdsSync extends _$KdsSync {
  final _service = LocalSyncService();

  @override
  KdsSyncState build() {
    ref.onDispose(_service.stop);
    return KdsSyncState(isServerRunning: false, isDiscoveryActive: false);
  }

  Future<void> toggleKdsServer() async {
    if (state.isServerRunning) {
      unawaited(_service.stop());
      state = state.copyWith(isServerRunning: false);
    } else {
      await _service.startKdsServer();
      state = state.copyWith(
        isServerRunning: true,
        serverAddress: 'Local Network',
      );
    }
  }

  Future<void> toggleDiscovery() async {
    if (state.isDiscoveryActive) {
      state = state.copyWith(isDiscoveryActive: false);
    } else {
      await _service.discoverKds();
      state = state.copyWith(isDiscoveryActive: true);
    }
  }
}
