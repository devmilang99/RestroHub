import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../data/datasources/firebase_auth_datasource.dart';

/// Provider for the [FirebaseAuthService] data source.
final firebaseAuthServiceProvider = Provider<FirebaseAuthService>((ref) {
  return FirebaseAuthService();
});

/// Provider for the [IAuthRepository] implementation.
final authRepositoryProvider = Provider<IAuthRepository>((ref) {
  final firebaseAuth = ref.watch(firebaseAuthServiceProvider);
  return AuthRepositoryImpl(firebaseAuth);
});

/// StateNotifier or other view models would go here to manage Auth UI state.
