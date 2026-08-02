# Keep Google Sign-In classes to avoid ClassNotFoundException during unmarshalling
-keep class com.google.android.gms.auth.api.signin.internal.SignInConfiguration { *; }
-keep class com.google.android.gms.auth.api.signin.** { *; }
-keep class com.google.android.gms.auth.api.signin.GoogleSignInAccount { *; }
-keep class com.google.android.gms.auth.api.signin.GoogleSignInOptions { *; }
-keep class com.google.android.gms.auth.api.signin.GoogleSignInResult { *; }
