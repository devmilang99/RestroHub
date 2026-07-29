import 'package:logger/logger.dart';

/// A global logger instance for the application.
final logger = Logger(
  printer: PrettyPrinter(
    methodCount: 0,
    errorMethodCount: 5,
    lineLength: 80,
    dateTimeFormat: DateTimeFormat.dateAndTime,
  ),
);

/// Top-level logging functions for convenience.
void logInfo(String message) => logger.i(message);
void logWarning(String message) => logger.w(message);
void logError(String message, [dynamic error, StackTrace? stackTrace]) =>
    logger.e(message, error: error, stackTrace: stackTrace);

/// Extension to easily log messages from any object.
extension LogExtension on Object {
  void logInfo(String message) => logger.i(message);
  void logWarning(String message) => logger.w(message);
  void logError(String message, [dynamic error, StackTrace? stackTrace]) =>
      logger.e(message, error: error, stackTrace: stackTrace);
}
