// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'network_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(networkMonitor)
final networkMonitorProvider = NetworkMonitorProvider._();

final class NetworkMonitorProvider
    extends $FunctionalProvider<NetworkMonitor, NetworkMonitor, NetworkMonitor>
    with $Provider<NetworkMonitor> {
  NetworkMonitorProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'networkMonitorProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$networkMonitorHash();

  @$internal
  @override
  $ProviderElement<NetworkMonitor> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  NetworkMonitor create(Ref ref) {
    return networkMonitor(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(NetworkMonitor value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<NetworkMonitor>(value),
    );
  }
}

String _$networkMonitorHash() => r'4e2f494eacd7b43213f4d1f1f4d31ba292ea5238';

@ProviderFor(networkStatus)
final networkStatusProvider = NetworkStatusProvider._();

final class NetworkStatusProvider
    extends
        $FunctionalProvider<
          AsyncValue<NetworkStatus>,
          NetworkStatus,
          Stream<NetworkStatus>
        >
    with $FutureModifier<NetworkStatus>, $StreamProvider<NetworkStatus> {
  NetworkStatusProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'networkStatusProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$networkStatusHash();

  @$internal
  @override
  $StreamProviderElement<NetworkStatus> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<NetworkStatus> create(Ref ref) {
    return networkStatus(ref);
  }
}

String _$networkStatusHash() => r'230c24aa1362f548489f08876fa7218fdaab0b76';

@ProviderFor(initialNetworkStatus)
final initialNetworkStatusProvider = InitialNetworkStatusProvider._();

final class InitialNetworkStatusProvider
    extends
        $FunctionalProvider<
          AsyncValue<NetworkStatus>,
          NetworkStatus,
          FutureOr<NetworkStatus>
        >
    with $FutureModifier<NetworkStatus>, $FutureProvider<NetworkStatus> {
  InitialNetworkStatusProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'initialNetworkStatusProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$initialNetworkStatusHash();

  @$internal
  @override
  $FutureProviderElement<NetworkStatus> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<NetworkStatus> create(Ref ref) {
    return initialNetworkStatus(ref);
  }
}

String _$initialNetworkStatusHash() =>
    r'46c881f26c9471d5d5181cd9c294a3aa0c83c7c5';

@ProviderFor(isOnline)
final isOnlineProvider = IsOnlineProvider._();

final class IsOnlineProvider extends $FunctionalProvider<bool, bool, bool>
    with $Provider<bool> {
  IsOnlineProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'isOnlineProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$isOnlineHash();

  @$internal
  @override
  $ProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  bool create(Ref ref) {
    return isOnline(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$isOnlineHash() => r'3a2d170c4d7784933fc70cfa96b65869a2d82b7a';
