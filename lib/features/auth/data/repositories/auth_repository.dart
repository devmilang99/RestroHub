import 'package:restro_hub/features/auth/data/models/user_model.dart';

/// Abstract interface for Authentication repository.
/// This defines the contract for any authentication implementation (Domain Layer logic).
abstract class IAuthRepository {
  Future<UserModel?> signUp(String email, String password);
  Future<UserModel?> signIn(String email, String password);
  Future<void> signOut();
  UserModel? get currentUser;
}
