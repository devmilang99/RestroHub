import 'package:restro_hub/features/auth/data/models/user_model.dart';
import 'package:restro_hub/features/auth/data/repositories/auth_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseAuthRepositoryImpl implements IAuthRepository {
  final SupabaseClient _client;

  SupabaseAuthRepositoryImpl(this._client);

  @override
  Future<UserModel?> signUp(String email, String password) async {
    final response = await _client.auth.signUp(
      email: email,
      password: password,
    );
    return _mapUser(response.user);
  }

  @override
  Future<UserModel?> signIn(String email, String password) async {
    final response = await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
    return _mapUser(response.user);
  }

  @override
  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  @override
  UserModel? get currentUser => _mapUser(_client.auth.currentUser);

  UserModel? _mapUser(User? user) {
    if (user == null) return null;
    return UserModel(
      id: user.id,
      email: user.email ?? '',
      fullName: user.userMetadata?['full_name'] as String?,
      avatarUrl: user.userMetadata?['avatar_url'] as String?,
      phone: user.userMetadata?['phone'] as String?,
    );
  }
}
