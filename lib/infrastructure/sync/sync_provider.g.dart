// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sync_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(KdsSync)
final kdsSyncProvider = KdsSyncProvider._();

final class KdsSyncProvider extends $NotifierProvider<KdsSync, KdsSyncState> {
  KdsSyncProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'kdsSyncProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$kdsSyncHash();

  @$internal
  @override
  KdsSync create() => KdsSync();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(KdsSyncState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<KdsSyncState>(value),
    );
  }
}

String _$kdsSyncHash() => r'9c03842d193ae839a676e21f4dcbbf898c6366f1';

abstract class _$KdsSync extends $Notifier<KdsSyncState> {
  KdsSyncState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<KdsSyncState, KdsSyncState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<KdsSyncState, KdsSyncState>,
              KdsSyncState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
