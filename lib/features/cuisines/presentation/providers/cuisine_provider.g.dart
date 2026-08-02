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

String _$allCuisinesStreamHash() => r'9c1b002e48b6fc06df264d6ca806119850226fce';

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
    r'52cec679e2801c0ce6b59f9867bcd3f32d580d5b';

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

String _$restaurantFromIdHash() => r'22290a2ea3d5e6ed3ba24a5e05f2e754d671737f';

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

@ProviderFor(restaurantFromCategoryId)
final restaurantFromCategoryIdProvider = RestaurantFromCategoryIdFamily._();

final class RestaurantFromCategoryIdProvider
    extends
        $FunctionalProvider<
          AsyncValue<RestaurantModel?>,
          RestaurantModel?,
          FutureOr<RestaurantModel?>
        >
    with $FutureModifier<RestaurantModel?>, $FutureProvider<RestaurantModel?> {
  RestaurantFromCategoryIdProvider._({
    required RestaurantFromCategoryIdFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'restaurantFromCategoryIdProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$restaurantFromCategoryIdHash();

  @override
  String toString() {
    return r'restaurantFromCategoryIdProvider'
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
    return restaurantFromCategoryId(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is RestaurantFromCategoryIdProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$restaurantFromCategoryIdHash() =>
    r'2c7b747e4a562d865ba029e61127b79ed1178d42';

final class RestaurantFromCategoryIdFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<RestaurantModel?>, String> {
  RestaurantFromCategoryIdFamily._()
    : super(
        retry: null,
        name: r'restaurantFromCategoryIdProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  RestaurantFromCategoryIdProvider call(String categoryId) =>
      RestaurantFromCategoryIdProvider._(argument: categoryId, from: this);

  @override
  String toString() => r'restaurantFromCategoryIdProvider';
}

@ProviderFor(FilteredCuisines)
final filteredCuisinesProvider = FilteredCuisinesProvider._();

final class FilteredCuisinesProvider
    extends $AsyncNotifierProvider<FilteredCuisines, List<MenuItemModel>> {
  FilteredCuisinesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'filteredCuisinesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$filteredCuisinesHash();

  @$internal
  @override
  FilteredCuisines create() => FilteredCuisines();
}

String _$filteredCuisinesHash() => r'7b339b59cf9cd4030832ff104102b2cbf17b7d8a';

abstract class _$FilteredCuisines extends $AsyncNotifier<List<MenuItemModel>> {
  FutureOr<List<MenuItemModel>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<List<MenuItemModel>>, List<MenuItemModel>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<MenuItemModel>>, List<MenuItemModel>>,
              AsyncValue<List<MenuItemModel>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
