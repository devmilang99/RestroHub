// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cuisine_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(cuisinesStream)
final cuisinesStreamProvider = CuisinesStreamFamily._();

final class CuisinesStreamProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<MenuItemModel>>,
          List<MenuItemModel>,
          Stream<List<MenuItemModel>>
        >
    with
        $FutureModifier<List<MenuItemModel>>,
        $StreamProvider<List<MenuItemModel>> {
  CuisinesStreamProvider._({
    required CuisinesStreamFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'cuisinesStreamProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$cuisinesStreamHash();

  @override
  String toString() {
    return r'cuisinesStreamProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<List<MenuItemModel>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<MenuItemModel>> create(Ref ref) {
    final argument = this.argument as String;
    return cuisinesStream(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is CuisinesStreamProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$cuisinesStreamHash() => r'2cbd4e1f0c4add0e686ddbbf7e92ce7dcd2392b9';

final class CuisinesStreamFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<MenuItemModel>>, String> {
  CuisinesStreamFamily._()
    : super(
        retry: null,
        name: r'cuisinesStreamProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  CuisinesStreamProvider call(String restaurantId) =>
      CuisinesStreamProvider._(argument: restaurantId, from: this);

  @override
  String toString() => r'cuisinesStreamProvider';
}

@ProviderFor(allCuisinesStream)
final allCuisinesStreamProvider = AllCuisinesStreamProvider._();

final class AllCuisinesStreamProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<MenuItemModel>>,
          List<MenuItemModel>,
          Stream<List<MenuItemModel>>
        >
    with
        $FutureModifier<List<MenuItemModel>>,
        $StreamProvider<List<MenuItemModel>> {
  AllCuisinesStreamProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'allCuisinesStreamProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$allCuisinesStreamHash();

  @$internal
  @override
  $StreamProviderElement<List<MenuItemModel>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<MenuItemModel>> create(Ref ref) {
    return allCuisinesStream(ref);
  }
}

String _$allCuisinesStreamHash() => r'eb226f42cd718562dc3fa383ad280b5c9513bb0b';

@ProviderFor(restaurantIdFromCategory)
final restaurantIdFromCategoryProvider = RestaurantIdFromCategoryFamily._();

final class RestaurantIdFromCategoryProvider
    extends $FunctionalProvider<AsyncValue<String?>, String?, FutureOr<String?>>
    with $FutureModifier<String?>, $FutureProvider<String?> {
  RestaurantIdFromCategoryProvider._({
    required RestaurantIdFromCategoryFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'restaurantIdFromCategoryProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$restaurantIdFromCategoryHash();

  @override
  String toString() {
    return r'restaurantIdFromCategoryProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<String?> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<String?> create(Ref ref) {
    final argument = this.argument as String;
    return restaurantIdFromCategory(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is RestaurantIdFromCategoryProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$restaurantIdFromCategoryHash() =>
    r'60a252878a09b3ddc6c25ac804e26ed53174bd1f';

final class RestaurantIdFromCategoryFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<String?>, String> {
  RestaurantIdFromCategoryFamily._()
    : super(
        retry: null,
        name: r'restaurantIdFromCategoryProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  RestaurantIdFromCategoryProvider call(String categoryId) =>
      RestaurantIdFromCategoryProvider._(argument: categoryId, from: this);

  @override
  String toString() => r'restaurantIdFromCategoryProvider';
}

@ProviderFor(restaurantFromId)
final restaurantFromIdProvider = RestaurantFromIdFamily._();

final class RestaurantFromIdProvider
    extends
        $FunctionalProvider<
          AsyncValue<RestaurantModel?>,
          RestaurantModel?,
          FutureOr<RestaurantModel?>
        >
    with $FutureModifier<RestaurantModel?>, $FutureProvider<RestaurantModel?> {
  RestaurantFromIdProvider._({
    required RestaurantFromIdFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'restaurantFromIdProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$restaurantFromIdHash();

  @override
  String toString() {
    return r'restaurantFromIdProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<RestaurantModel?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<RestaurantModel?> create(Ref ref) {
    final argument = this.argument as String;
    return restaurantFromId(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is RestaurantFromIdProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$restaurantFromIdHash() => r'a2e8e649ba69c588b7b8225dbf75f095350e1bf5';

final class RestaurantFromIdFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<RestaurantModel?>, String> {
  RestaurantFromIdFamily._()
    : super(
        retry: null,
        name: r'restaurantFromIdProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  RestaurantFromIdProvider call(String restaurantId) =>
      RestaurantFromIdProvider._(argument: restaurantId, from: this);

  @override
  String toString() => r'restaurantFromIdProvider';
}
