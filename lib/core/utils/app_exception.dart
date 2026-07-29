import 'package:equatable/equatable.dart';

/// Base class for all application-specific exceptions.
abstract class AppException extends Equatable implements Exception {
  final String message;
  final String? code;

  const AppException(this.message, [this.code]);

  @override
  List<Object?> get props => [message, code];

  @override
  String toString() => 'AppException: [$code] $message';
}

class NetworkException extends AppException {
  const NetworkException([
    super.message = 'Please check your internet connection and try again.',
    super.code,
  ]);
}

class ServerException extends AppException {
  const ServerException([
    super.message = 'Our server is having trouble. Please try again later.',
    super.code,
  ]);
}

class ValidationException extends AppException {
  const ValidationException(super.message, [super.code]);
}

class UnauthorizedException extends AppException {
  const UnauthorizedException([
    super.message = 'Session expired. Please log in again.',
    super.code,
  ]);
}
