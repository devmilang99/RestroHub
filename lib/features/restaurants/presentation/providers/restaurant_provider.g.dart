// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'restaurant_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(RestaurantFilter)
final restaurantFilterProvider = RestaurantFilterProvider._();

final class RestaurantFilterProvider
    extends $NotifierProvider<RestaurantFilter, String> {
  RestaurantFilterProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'restaurantFilterProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$restaurantFilterHash();

  @$internal
  @override
  RestaurantFilter create() => RestaurantFilter();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String>(value),
    );
  }
}

String _$restaurantFilterHash() => r'52e059e102b638b01bde21381e3057253065264b';

abstract class _$RestaurantFilter extends $Notifier<String> {
  String build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<String, String>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<String, String>,
              String,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(RestaurantSearch)
final restaurantSearchProvider = RestaurantSearchProvider._();

final class RestaurantSearchProvider
    extends $NotifierProvider<RestaurantSearch, String> {
  RestaurantSearchProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'restaurantSearchProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$restaurantSearchHash();

  @$internal
  @override
  RestaurantSearch create() => RestaurantSearch();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String>(value),
    );
  }
}

String _$restaurantSearchHash() => r'd235caf398dd476fe67bb72f3068c43b9413f467';

abstract class _$RestaurantSearch extends $Notifier<String> {
  String build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<String, String>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<String, String>,
              String,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(initialSync)
final initialSyncProvider = InitialSyncProvider._();

final class InitialSyncProvider
    extends $FunctionalProvider<AsyncValue<void>, void, FutureOr<void>>
    with $FutureModifier<void>, $FutureProvider<void> {
  InitialSyncProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'initialSyncProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$initialSyncHash();

  @$internal
  @override
  $FutureProviderElement<void> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<void> create(Ref ref) {
    return initialSync(ref);
  }
}

String _$initialSyncHash() => r'0f7094208d434849d681569842a2f38620a35fa3';

@ProviderFor(restaurantsStream)
final restaurantsStreamProvider = RestaurantsStreamProvider._();

final class RestaurantsStreamProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<RestaurantModel>>,
          List<RestaurantModel>,
          Stream<List<RestaurantModel>>
        >
    with
        $FutureModifier<List<RestaurantModel>>,
        $StreamProvider<List<RestaurantModel>> {
  RestaurantsStreamProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'restaurantsStreamProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$restaurantsStreamHash();

  @$internal
  @override
  $StreamProviderElement<List<RestaurantModel>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<RestaurantModel>> create(Ref ref) {
    return restaurantsStream(ref);
  }
}

String _$restaurantsStreamHash() => r'962e6ac4df24a205f751379bf4ad6eabacd122eb';

@ProviderFor(FilteredRestaurants)
final filteredRestaurantsProvider = FilteredRestaurantsProvider._();

final class FilteredRestaurantsProvider
    extends $AsyncNotifierProvider<FilteredRestaurants, List<RestaurantModel>> {
  FilteredRestaurantsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'filteredRestaurantsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$filteredRestaurantsHash();

  @$internal
  @override
  FilteredRestaurants create() => FilteredRestaurants();
}

String _$filteredRestaurantsHash() =>
    r'1e32a49584de7a05617f55819664a20442f4d79c';

abstract class _$FilteredRestaurants
    extends $AsyncNotifier<List<RestaurantModel>> {
  FutureOr<List<RestaurantModel>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref
            as $Ref<AsyncValue<List<RestaurantModel>>, List<RestaurantModel>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<List<RestaurantModel>>,
                List<RestaurantModel>
              >,
              AsyncValue<List<RestaurantModel>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
