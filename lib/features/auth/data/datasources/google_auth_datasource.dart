import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class GoogleAuthService {
  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email', 'profile']);
  final fb.FirebaseAuth _auth = fb.FirebaseAuth.instance;

  Future<fb.User?> signIn() async {
    try {
      // 1. Trigger Google Sign-In flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        debugPrint('User Cancelled the Sign-In');
        return null;
      }
      // 2. Get tokens from the login
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // 3. Create a credential for Firebase
      final fb.AuthCredential credential = fb.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // 4. Sign in to Firebase with the tokens
      final fb.UserCredential userCredential = await _auth.signInWithCredential(
        credential,
      );
      return userCredential.user;
    } catch (error) {
      print('Firebase Google Sign-In Error: $error');
      return null;
    }
  }

  Future<fb.User?> signInSilently() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn
          .signInSilently();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final fb.AuthCredential credential = fb.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final fb.UserCredential userCredential = await _auth.signInWithCredential(
        credential,
      );
      return userCredential.user;
    } catch (error) {
      print('Firebase Silent Google Sign-In Error: $error');
      return null;
    }
  }

  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _auth.signOut();
    } catch (error) {
      print('Error during Google Sign-Out: $error');
    }
  }

  Future<bool> isSignedIn() async {
    return _auth.currentUser != null;
  }
}
