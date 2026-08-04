import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:restro_hub/core/data/database/database_provider.dart';
import 'package:restro_hub/features/auth/data/models/user_model.dart';
import 'package:restro_hub/features/auth/data/repositories/auth_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseAuthRepositoryImpl implements IAuthRepository {
  final SupabaseClient _client;
  final Ref _ref;

  SupabaseAuthRepositoryImpl(this._client, this._ref) {
    _initAuthListener();
  }

  void _initAuthListener() {
    _client.auth.onAuthStateChange.listen((data) async {
      final event = data.event;
      if (event == AuthChangeEvent.signedIn ||
          event == AuthChangeEvent.tokenRefreshed) {
        // Double check if user still exists in DB
        await verifySession();
      }
    });
  }

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
  Future<void> signOut({bool clearData = true}) async {
    // 1. Sync necessary data (Profile)
    // Could call sync manager here if needed

    // 2. Clear local data
    if (clearData) {
      try {
        final db = await _ref.read(appDatabaseProvider.future);
        await db.clearAllUserData();
      } catch (_) {
        // Database might not be initialized, ignore
      }
    }

    // 3. Sign out from Google (if applicable)
    try {
      final googleSignIn = GoogleSignIn();
      if (await googleSignIn.isSignedIn()) {
        await googleSignIn.signOut();
      }
    } catch (_) {
      // Ignore google sign out errors
    }

    // 4. Sign out from Supabase
    await _client.auth.signOut();
  }

  @override
  UserModel? get currentUser => _mapUser(_client.auth.currentUser);

  @override
  Future<bool> verifySession() async {
    try {
      final response = await _client.auth.getUser();
      return response.user != null;
    } on AuthException catch (e) {
      // If user was deleted or session is invalid, getUser() throws AuthException
      // Code '404' or specific messages usually indicate user not found
      await signOut(clearData: true);
      return false;
    } catch (e) {
      // For network errors, we might want to return true to allow offline usage
      // assuming the local session is still technically valid.
      return _client.auth.currentUser != null;
    }
  }

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
