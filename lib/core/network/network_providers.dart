import 'package:restro_hub/core/network/network_monitor.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'network_providers.g.dart';

@riverpod
NetworkMonitor networkMonitor(Ref ref) {
  final monitor = NetworkMonitor();
  monitor.initialize();
  ref.onDispose(monitor.dispose);
  return monitor;
}

@riverpod
Stream<NetworkStatus> networkStatus(Ref ref) {
  return ref.watch(networkMonitorProvider).statusStream;
}

@riverpod
Future<NetworkStatus> initialNetworkStatus(Ref ref) {
  return ref.watch(networkMonitorProvider).checkStatus();
}

@riverpod
bool isOnline(Ref ref) {
  final asyncStatus = ref.watch(networkStatusProvider);

  return asyncStatus.when(
    data: (status) => status == NetworkStatus.online,
    loading: () {
      final initial = ref.read(initialNetworkStatusProvider);
      return initial.asData?.value == null ||
          initial.asData?.value == NetworkStatus.online;
    },
    error: (_, _) => false,
  );
}
