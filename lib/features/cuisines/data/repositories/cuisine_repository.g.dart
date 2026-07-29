// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cuisine_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(cuisineRepository)
final cuisineRepositoryProvider = CuisineRepositoryProvider._();

final class CuisineRepositoryProvider
    extends
        $FunctionalProvider<
          ICuisineRepository,
          ICuisineRepository,
          ICuisineRepository
        >
    with $Provider<ICuisineRepository> {
  CuisineRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'cuisineRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$cuisineRepositoryHash();

  @$internal
  @override
  $ProviderElement<ICuisineRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ICuisineRepository create(Ref ref) {
    return cuisineRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ICuisineRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ICuisineRepository>(value),
    );
  }
}

String _$cuisineRepositoryHash() => r'aafdd60da0e1101493813e1daf2170aed00da60d';
