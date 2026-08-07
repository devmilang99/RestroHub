// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'error_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// A global service to manage and display error states across the application.

@ProviderFor(ErrorService)
final errorServiceProvider = ErrorServiceProvider._();

/// A global service to manage and display error states across the application.
final class ErrorServiceProvider
    extends $NotifierProvider<ErrorService, ErrorState?> {
  /// A global service to manage and display error states across the application.
  ErrorServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'errorServiceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$errorServiceHash();

  @$internal
  @override
  ErrorService create() => ErrorService();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ErrorState? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ErrorState?>(value),
    );
  }
}

String _$errorServiceHash() => r'644587b6edf06e75e1eb5cad41856b74c02de999';

/// A global service to manage and display error states across the application.

abstract class _$ErrorService extends $Notifier<ErrorState?> {
  ErrorState? build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<ErrorState?, ErrorState?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ErrorState?, ErrorState?>,
              ErrorState?,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
