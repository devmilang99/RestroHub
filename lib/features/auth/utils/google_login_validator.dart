import 'package:restro_hub/features/auth/data/models/google_user_model.dart';

class GoogleLoginValidator {
  /// Validates if the Google user data is complete and meets application requirements.
  static String? validate(GoogleUserModel? user) {
    if (user == null) {
      return 'Sign-in failed or was cancelled.';
    }

    if (user.email.isEmpty) {
      return 'Email address is missing.';
    }

    if (!user.email.contains('@')) {
      return 'Invalid email address format.';
    }

    // Example of domain validation if needed
    // if (!user.email.endsWith('@company.com')) {
    //   return 'Only company emails are allowed.';
    // }

    return null; // No errors
  }
}
