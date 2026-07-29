import 'dart:isolate';
import 'package:flutter/foundation.dart';

/// A utility to handle heavy computations and long-running background tasks.
class BackgroundWorker {
  /// Executes a one-off heavy task in a separate isolate using [compute].
  /// Suitable for tasks like heavy JSON parsing or complex image processing.
  static Future<R> runHeavyTask<Q, R>(
    ComputeCallback<Q, R> callback,
    Q message,
  ) async {
    return compute(callback, message);
  }

  /// Starts a long-running background worker with a dedicated [ReceivePort].
  /// Useful for continuous data syncing or background listening.
  static Future<SendPort> startLongRunningTask(
    void Function(SendPort) entryPoint,
  ) async {
    final receivePort = ReceivePort();
    await Isolate.spawn(entryPoint, receivePort.sendPort);
    return await receivePort.first as SendPort;
  }
}
