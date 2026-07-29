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

String _$cuisinesStreamHash() => r'4722569dd2a6a68b971bfa2455a4457e3369388b';

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

String _$allCuisinesStreamHash() => r'ec15bee2359145ffcb7aac5ec7b4653a5a468ff2';
