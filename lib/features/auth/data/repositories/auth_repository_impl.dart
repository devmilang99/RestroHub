import 'package:firebase_auth/firebase_auth.dart';
import '../datasources/firebase_auth_datasource.dart';
import 'auth_repository.dart';

/// Implementation of [IAuthRepository] using Firebase as the data source.
/// This acts as a bridge between the data source and the presentation layer.
class AuthRepositoryImpl implements IAuthRepository {
  final FirebaseAuthService _firebaseAuthService;

  AuthRepositoryImpl(this._firebaseAuthService);

  @override
  Future<User?> signUp(String email, String password) {
    return _firebaseAuthService.signUpWithEmailAndPassword(email, password);
  }

  @override
  Future<User?> signIn(String email, String password) {
    return _firebaseAuthService.signInWithEmailAndPassword(email, password);
  }

  @override
  Future<void> signOut() {
    return _firebaseAuthService.signOut();
  }

  @override
  User? get currentUser => _firebaseAuthService.currentUser;
}
