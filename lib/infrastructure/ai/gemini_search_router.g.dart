// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gemini_search_router.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(GeminiSearchRouter)
final geminiSearchRouterProvider = GeminiSearchRouterProvider._();

final class GeminiSearchRouterProvider
    extends $AsyncNotifierProvider<GeminiSearchRouter, void> {
  GeminiSearchRouterProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'geminiSearchRouterProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$geminiSearchRouterHash();

  @$internal
  @override
  GeminiSearchRouter create() => GeminiSearchRouter();
}

String _$geminiSearchRouterHash() =>
    r'32850ec2ec36fbea6c231f12b8b7acd2906167c0';

abstract class _$GeminiSearchRouter extends $AsyncNotifier<void> {
  FutureOr<void> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<void>, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<void>, void>,
              AsyncValue<void>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
