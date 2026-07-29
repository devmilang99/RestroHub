import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class GoogleAuthService {
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    serverClientId: dotenv.maybeGet('GOOGLE_WEB_CLIENT_ID'),
    scopes: ['email', 'profile'],
  );
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<User?> signIn() async {
    try {
      final clientId = dotenv.maybeGet('GOOGLE_WEB_CLIENT_ID');
      if (clientId == null || clientId.contains('REPLACE_WITH')) {
        debugPrint(
          'ERROR: GOOGLE_WEB_CLIENT_ID is missing or not configured in .env file. '
          'Please provide your Web Client ID from Google Cloud Console.',
        );
        return null;
      }

      // 1. Trigger Google Sign-In flow
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        debugPrint('User Cancelled the Sign-In');
        return null;
      }
      // 2. Get tokens from the login
      final googleAuth = await googleUser.authentication;
      final accessToken = googleAuth.accessToken;
      final idToken = googleAuth.idToken;

      if (idToken == null) {
        debugPrint('No ID Token found.');
        return null;
      }

      // 3. Sign in to Supabase with the tokens
      final response = await _supabase.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: accessToken,
      );

      return response.user;
    } on PlatformException catch (error) {
      if (error.code == 'network_error' ||
          error.message?.contains('7') == true) {
        debugPrint(
          'Supabase Google Sign-In Network Error (7): '
          'This is often caused by missing SHA-1 in Google Cloud Console '
          'or a mismatched Client ID. Error: ${error.message}',
        );
      } else {
        debugPrint(
          'Supabase Google Sign-In Platform Error: ${error.code} - ${error.message}',
        );
      }
      rethrow;
    } on Exception catch (error) {
      debugPrint('Supabase Google Sign-In Error: $error');
      return null;
    }
  }

  Future<User?> signInSilently() async {
    try {
      final googleUser = await _googleSignIn.signInSilently();
      if (googleUser == null) return null;

      final googleAuth = await googleUser.authentication;
      final accessToken = googleAuth.accessToken;
      final idToken = googleAuth.idToken;

      if (idToken == null) return null;

      final response = await _supabase.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: accessToken,
      );

      return response.user;
    } on PlatformException catch (error) {
      debugPrint(
        'Supabase Silent Google Sign-In Platform Error: ${error.code} - ${error.message}',
      );
      return null;
    } on Exception catch (error) {
      debugPrint('Supabase Silent Google Sign-In Error: $error');
      return null;
    }
  }

  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _supabase.auth.signOut();
    } on Exception catch (error) {
      debugPrint('Error during Google Sign-Out: $error');
    }
  }

  Future<bool> isSignedIn() async {
    return _supabase.auth.currentUser != null;
  }
}
