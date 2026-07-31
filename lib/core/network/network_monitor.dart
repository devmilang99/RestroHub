import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:restro_hub/core/utils/logger.dart';

enum NetworkStatus { online, offline, weak }

class NetworkMonitor {
  final Connectivity _connectivity = Connectivity();
  final _controller = StreamController<NetworkStatus>.broadcast();

  Stream<NetworkStatus> get statusStream => _controller.stream;

  Future<NetworkStatus> checkStatus() async {
    try {
      final results = await _connectivity.checkConnectivity();
      return _mapConnectivityResult(results);
    } on Exception catch (e) {
      logError('Failed to check connectivity', e);
      return NetworkStatus.offline;
    }
  }

  void initialize() {
    _connectivity.onConnectivityChanged.listen((results) {
      final status = _mapConnectivityResult(results);
      _controller.add(status);
      logInfo('Network status changed to: $status');
    });
  }

  NetworkStatus _mapConnectivityResult(List<ConnectivityResult> results) {
    if (results.isEmpty || results.contains(ConnectivityResult.none)) {
      return NetworkStatus.offline;
    }
    // We consider mobile and wifi as online.
    // In a more complex app, we could check for actual internet reachability.
    return NetworkStatus.online;
  }

  void dispose() {
    unawaited(_controller.close());
  }
}
