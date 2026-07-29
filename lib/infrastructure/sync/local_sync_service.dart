import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:bonsoir/bonsoir.dart';
import 'package:restro_hub/core/utils/logger.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_web_socket/shelf_web_socket.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class LocalSyncService {
  static const String _serviceType = '_restro-sync._tcp';
  BonsoirBroadcast? _broadcast;
  BonsoirDiscovery? _discovery;
  HttpServer? _server;

  /// Starts the KDS Server (Kitchen Display side)
  Future<void> startKdsServer() async {
    final handler = webSocketHandler((dynamic webSocket, dynamic protocol) {
      if (webSocket is WebSocketChannel) {
        webSocket.stream.listen((dynamic message) {
          logInfo('KDS Received: $message');
          // Handle incoming order update with conflict resolution logic here
          webSocket.sink.add(
            jsonEncode({
              'status': 'received',
              'timestamp': DateTime.now().toIso8601String(),
            }),
          );
        });
      }
    });

    _server = await io.serve(handler, InternetAddress.anyIPv4, 8080);
    logInfo(
      'KDS Server running on ${_server?.address.address}:${_server?.port}',
    );

    // Broadcast presence via mDNS
    final service = BonsoirService(
      name: 'Restro-KDS-${Platform.localHostname}',
      type: _serviceType,
      port: 8080,
    );
    _broadcast = BonsoirBroadcast(service: service);
    await _broadcast?.start();
  }

  /// Starts discovering KDS servers (POS Tablet side)
  Future<void> discoverKds() async {
    _discovery = BonsoirDiscovery(type: _serviceType);

    _discovery?.eventStream?.listen((event) {
      if (event is BonsoirDiscoveryServiceFoundEvent) {
        logInfo('Found KDS: ${event.service.name}');
        unawaited(event.service.resolve(_discovery!.serviceResolver));
      } else if (event is BonsoirDiscoveryServiceResolvedEvent) {
        final service = event.service;
        logInfo('Resolved KDS: ${service.name}');
        // Bonsoir 7.x: uses hostAddresses instead of host
        final host =
            service.attributes['host'] ??
            (service.toJson()['hostAddresses'] as List<dynamic>?)?.first;
        if (host != null) {
          _connectToKds(host.toString(), service.port);
        }
      }
    });

    await _discovery?.start();
  }

  void _connectToKds(String host, int port) {
    final channel = WebSocketChannel.connect(Uri.parse('ws://$host:$port'));
    channel.sink.add(
      jsonEncode({
        'type': 'order_sync',
        'orderId': '12345',
        'items': ['Burger', 'Coke'],
        'timestamp': DateTime.now().toIso8601String(),
      }),
    );
  }

  Future<void> stop() async {
    await _broadcast?.stop();
    await _discovery?.stop();
    await _server?.close();
  }
}
