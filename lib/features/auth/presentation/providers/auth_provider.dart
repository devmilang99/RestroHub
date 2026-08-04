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

/// A listenable provider that notifies when auth state changes.
final authListenableProvider = Provider<ValueNotifier<User?>>((ref) {
  final supabase = ref.watch(supabaseClientProvider);
  final notifier = ValueNotifier<User?>(supabase.auth.currentUser);

  final subscription = supabase.auth.onAuthStateChange.listen((data) {
    notifier.value = data.session?.user;
  });

  ref.onDispose(() {
    subscription.cancel();
    notifier.dispose();
  });

  return notifier;
});
