// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sync_monitor_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(GlobalSyncStatus)
final globalSyncStatusProvider = GlobalSyncStatusProvider._();

final class GlobalSyncStatusProvider
    extends $NotifierProvider<GlobalSyncStatus, SyncState> {
  GlobalSyncStatusProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'globalSyncStatusProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$globalSyncStatusHash();

  @$internal
  @override
  GlobalSyncStatus create() => GlobalSyncStatus();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SyncState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SyncState>(value),
    );
  }
}

String _$globalSyncStatusHash() => r'ff3f3bea9bbf498c12532cda0337d3ab33b6f758';

abstract class _$GlobalSyncStatus extends $Notifier<SyncState> {
  SyncState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<SyncState, SyncState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<SyncState, SyncState>,
              SyncState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
