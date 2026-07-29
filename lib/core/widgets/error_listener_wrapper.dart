import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:restro_hub/core/providers/error_service.dart';

class ErrorListenerWrapper extends ConsumerWidget {
  final Widget child;

  const ErrorListenerWrapper({required this.child, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(errorServiceProvider, (previous, next) {
      if (next != null) {
        _showErrorSnackBar(context, next, ref);
      }
    });

    return child;
  }

  void _showErrorSnackBar(
    BuildContext context,
    ErrorState error,
    WidgetRef ref,
  ) {
    final scaffoldMessenger = ScaffoldMessenger.maybeOf(context);
    if (scaffoldMessenger == null) return;

    scaffoldMessenger
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(
                _getIconForType(error.type),
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  error.message,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
          backgroundColor: _getBgColorForType(error.type),
          behavior: SnackBarBehavior.floating,
          action: SnackBarAction(
            label: 'DISMISS',
            textColor: Colors.white,
            onPressed: () {
              ref.read(errorServiceProvider.notifier).clearError();
            },
          ),
        ),
      );
  }

  IconData _getIconForType(ErrorType type) {
    switch (type) {
      case ErrorType.network:
        return Icons.wifi_off_rounded;
      case ErrorType.auth:
        return Icons.lock_outline;
      case ErrorType.database:
        return Icons.storage_rounded;
      case ErrorType.unknown:
        return Icons.error_outline_rounded;
    }
  }

  Color _getBgColorForType(ErrorType type) {
    switch (type) {
      case ErrorType.auth:
        return Colors.orange.shade800;
      case ErrorType.network:
      case ErrorType.database:
      case ErrorType.unknown:
        return Colors.red.shade700;
    }
  }
}
