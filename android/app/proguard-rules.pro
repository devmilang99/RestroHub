# Flutter ProGuard Rules
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Supabase and Dart
-keep class com.google.gson.** { *; }
-keep class com.google.android.gms.signin.** { *; }

# Maintain integrity of Pigeon generated code
-keep class com.portfolio.restrohub.PrinterApi { *; }
-keep class com.portfolio.restrohub.FlutterError { *; }

# General optimizations
-dontwarn io.flutter.embedding.android.FlutterActivity
-dontwarn io.flutter.embedding.android.FlutterFragment
-dontwarn io.flutter.embedding.engine.plugins.FlutterPlugin
-dontwarn io.flutter.plugin.common.MethodChannel
-dontwarn io.flutter.plugin.common.BasicMessageChannel
-dontwarn io.flutter.plugin.common.BinaryMessenger
