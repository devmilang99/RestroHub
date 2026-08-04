// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recommended_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(recommendedItems)
final recommendedItemsProvider = RecommendedItemsProvider._();

final class RecommendedItemsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<dynamic>>,
          List<dynamic>,
          FutureOr<List<dynamic>>
        >
    with $FutureModifier<List<dynamic>>, $FutureProvider<List<dynamic>> {
  RecommendedItemsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'recommendedItemsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$recommendedItemsHash();

  @$internal
  @override
  $FutureProviderElement<List<dynamic>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<dynamic>> create(Ref ref) {
    return recommendedItems(ref);
  }
}

String _$recommendedItemsHash() => r'4e41205fcf6e06a8ef40f5fb38af29a6907a77ae';
