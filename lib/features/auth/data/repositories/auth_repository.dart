import 'package:firebase_auth/firebase_auth.dart';

/// Abstract interface for Authentication repository.
/// This defines the contract for any authentication implementation (Domain Layer logic).
abstract class IAuthRepository {
  Future<User?> signUp(String email, String password);
  Future<User?> signIn(String email, String password);
  Future<void> signOut();
  User? get currentUser;
}
