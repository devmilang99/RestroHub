import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:restro_hub/features/auth/data/repositories/auth_repository.dart';
import 'package:restro_hub/features/auth/data/repositories/supabase_auth_repository_impl.dart';
import 'package:restro_hub/infrastructure/supabase/supabase_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Provider for the [IAuthRepository] implementation.
final authRepositoryProvider = Provider<IAuthRepository>((ref) {
  final supabase = ref.watch(supabaseClientProvider);
  return SupabaseAuthRepositoryImpl(supabase, ref);
});

/// A provider that exposes the current Supabase user and updates when the auth state changes.
final currentUserProvider = StreamProvider<User?>((ref) async* {
  final supabase = ref.watch(supabaseClientProvider);

  // Yield initial state
  yield supabase.auth.currentUser;

  // Yield subsequent changes
  yield* supabase.auth.onAuthStateChange.map((data) => data.session?.user);
});

/// A provider that exposes a [Listenable] that notifies when the auth state changes.
/// Useful for GoRouter's refreshListenable.
final authListenableProvider = Provider<Listenable>((ref) {
  final listenable = ValueNotifier<User?>(null);
  ref.listen(currentUserProvider, (previous, next) {
    listenable.value = next.value;
  });
  return listenable;
});
