import 'package:restro_hub/core/utils/app_exception.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'error_service.g.dart';

enum ErrorType {
  network,
  database,
  auth,
  unknown,
}

class ErrorState {
  final String message;
  final ErrorType type;
  final DateTime timestamp;

  ErrorState({
    required this.message,
    this.type = ErrorType.unknown,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
}

/// A global service to manage and display error states across the application.
@riverpod
class ErrorService extends _$ErrorService {
  @override
  ErrorState? build() => null;

  void showError({
    required String message,
    ErrorType type = ErrorType.unknown,
  }) {
    // Delay state update to avoid "Tried to modify a provider while the widget tree was building"
    Future.microtask(() {
      state = ErrorState(message: message, type: type);
    });
  }

  void clearError() {
    Future.microtask(() {
      state = null;
    });
  }

  void handleException(dynamic e, [StackTrace? stack]) {
    var message = 'Something went wrong. Please try again.';
    var type = ErrorType.unknown;

    if (e is AuthException) {
      type = ErrorType.auth;
      message = _mapAuthException(e);
    } else if (e is PostgrestException) {
      type = ErrorType.database;
      message = _mapPostgrestException(e);
    } else if (e is AppException) {
      message = e.message;
      if (e is NetworkException) type = ErrorType.network;
      if (e is UnauthorizedException) type = ErrorType.auth;
    } else {
      final errorStr = e.toString().toLowerCase();
      if (errorStr.contains('network') ||
          errorStr.contains('socket') ||
          errorStr.contains('connection')) {
        type = ErrorType.network;
        message = 'Please check your internet connection.';
      }
    }

    showError(message: message, type: type);
  }

  String _mapAuthException(AuthException e) {
    final message = e.message.toLowerCase();

    if (message.contains('invalid login credentials')) {
      return 'Invalid email or password. Please try again.';
    }
    if (message.contains('user already registered') ||
        message.contains('already exists')) {
      return 'This email is already in use. Try logging in instead.';
    }
    if (message.contains('email not confirmed')) {
      return 'Please verify your email address before logging in.';
    }
    if (message.contains('password should be') || message.contains('weak')) {
      return 'Password is too weak. Please use at least 6 characters.';
    }
    if (message.contains('too many requests')) {
      return 'Too many attempts. Please try again later.';
    }
    if (message.contains('refresh_token_not_found') ||
        message.contains('invalid refresh token')) {
      return 'Session expired. Please log in again.';
    }

    return e.message;
  }

  String _mapPostgrestException(PostgrestException e) {
    if (e.code == '23505') {
      return 'This record already exists.';
    }
    return 'Database error occurred. Please try again.';
  }
}
