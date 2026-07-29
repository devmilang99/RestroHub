import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:restro_hub/features/auth/data/repositories/auth_repository.dart';
import 'package:restro_hub/features/auth/data/repositories/supabase_auth_repository_impl.dart';
import 'package:restro_hub/infrastructure/supabase/supabase_service.dart';

/// Provider for the [IAuthRepository] implementation.
final authRepositoryProvider = Provider<IAuthRepository>((ref) {
  final supabase = ref.watch(supabaseClientProvider);
  return SupabaseAuthRepositoryImpl(supabase);
});

/// StateNotifier or other view models would go here to manage Auth UI state.
