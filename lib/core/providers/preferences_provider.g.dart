// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'preferences_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(PreferencesService)
final preferencesServiceProvider = PreferencesServiceProvider._();

final class PreferencesServiceProvider
    extends $NotifierProvider<PreferencesService, PreferencesService> {
  PreferencesServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'preferencesServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$preferencesServiceHash();

  @$internal
  @override
  PreferencesService create() => PreferencesService();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PreferencesService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PreferencesService>(value),
    );
  }
}

String _$preferencesServiceHash() =>
    r'f62b4e30067f58e4f02c94fa0f9e68949bfafaf1';

abstract class _$PreferencesService extends $Notifier<PreferencesService> {
  PreferencesService build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<PreferencesService, PreferencesService>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<PreferencesService, PreferencesService>,
              PreferencesService,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
