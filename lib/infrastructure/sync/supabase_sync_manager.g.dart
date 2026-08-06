// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'supabase_sync_manager.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(SupabaseSyncManager)
final supabaseSyncManagerProvider = SupabaseSyncManagerProvider._();

final class SupabaseSyncManagerProvider
    extends $NotifierProvider<SupabaseSyncManager, void> {
  SupabaseSyncManagerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'supabaseSyncManagerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$supabaseSyncManagerHash();

  @$internal
  @override
  SupabaseSyncManager create() => SupabaseSyncManager();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$supabaseSyncManagerHash() =>
    r'a22ae73988c3a3077c942f998ac23f843b4311b8';

abstract class _$SupabaseSyncManager extends $Notifier<void> {
  void build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<void, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<void, void>,
              void,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
