import 'dart:async';

import 'package:restro_hub/core/data/database/app_database.dart';
import 'package:restro_hub/core/utils/logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'database_provider.g.dart';

@Riverpod(keepAlive: true)
Future<AppDatabase> appDatabase(Ref ref) async {
  logInfo('Initializing AppDatabase provider...');
  try {
    final executor = AppDatabase.openConnection();
    final db = AppDatabase(executor);

    logInfo('AppDatabase initialized successfully.');

    if (ref.mounted) {
      ref.onDispose(() {
        logInfo('Disposing AppDatabase provider...');
        unawaited(db.close());
      });
    } else {
      logWarning(
        'AppDatabase provider disposed while connecting. Closing connection.',
      );
      db.close().ignore();
    }

    return db;
  } catch (e, stack) {
    logError('Failed to initialize AppDatabase', e, stack);
    rethrow;
  }
}
