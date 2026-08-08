// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ai_search_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(AiSearchNotifier)
final aiSearchProvider = AiSearchNotifierProvider._();

final class AiSearchNotifierProvider
    extends $AsyncNotifierProvider<AiSearchNotifier, AiSearchState> {
  AiSearchNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'aiSearchProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$aiSearchNotifierHash();

  @$internal
  @override
  AiSearchNotifier create() => AiSearchNotifier();
}

String _$aiSearchNotifierHash() => r'56ae337cc39dc70148bf3bdbecd238b281eca714';

abstract class _$AiSearchNotifier extends $AsyncNotifier<AiSearchState> {
  FutureOr<AiSearchState> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<AiSearchState>, AiSearchState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<AiSearchState>, AiSearchState>,
              AsyncValue<AiSearchState>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
