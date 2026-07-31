// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'restaurant_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(restaurantRepository)
final restaurantRepositoryProvider = RestaurantRepositoryProvider._();

final class RestaurantRepositoryProvider
    extends
        $FunctionalProvider<
          IRestaurantRepository,
          IRestaurantRepository,
          IRestaurantRepository
        >
    with $Provider<IRestaurantRepository> {
  RestaurantRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'restaurantRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$restaurantRepositoryHash();

  @$internal
  @override
  $ProviderElement<IRestaurantRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  IRestaurantRepository create(Ref ref) {
    return restaurantRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(IRestaurantRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<IRestaurantRepository>(value),
    );
  }
}

String _$restaurantRepositoryHash() =>
    r'b2102967fbc82ec49b94e43cd5c8160b7784969e';
