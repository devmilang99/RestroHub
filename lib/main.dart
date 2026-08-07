import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:restro_hub/core/network/network_providers.dart';
import 'package:restro_hub/core/providers/error_service.dart';
import 'package:restro_hub/core/providers/preferences_provider.dart';
import 'package:restro_hub/core/services/notification_service.dart';
import 'package:restro_hub/core/services/security_service.dart';
import 'package:restro_hub/core/theme/app_theme.dart';
import 'package:restro_hub/core/theme/theme_provider.dart';
import 'package:restro_hub/core/utils/logger.dart';
import 'package:restro_hub/core/widgets/connectivity_banner.dart';
import 'package:restro_hub/core/widgets/error_listener_wrapper.dart';
import 'package:restro_hub/infrastructure/supabase/supabase_service.dart';
import 'package:restro_hub/infrastructure/sync/sync_coordinator.dart';
import 'package:restro_hub/l10n/generated/app_localizations.dart';
import 'package:restro_hub/router/router_service.dart';
import 'package:restro_hub/screens/security_violation_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();

  // Set a conservative image cache size to prevent OOM on lower-end devices
  // 100MB is sufficient for smooth scrolling while leaving headroom for sync operations
  PaintingBinding.instance.imageCache.maximumSizeBytes = 100 * 1024 * 1024;
  PaintingBinding.instance.imageCache.maximumSize = 500;

  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  final prefs = await SharedPreferences.getInstance();
  final container = ProviderContainer(
    overrides: [
      sharedPreferencesProvider.overrideWithValue(prefs),
    ],
  );

  // Global error handling
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    container
        .read(errorServiceProvider.notifier)
        .handleException(
          details.exception,
          details.stack,
        );
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    container.read(errorServiceProvider.notifier).handleException(error, stack);
    return true;
  };

  try {
    debugPrint('MAIN: Starting initialization...');

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarDividerColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.light,
        statusBarIconBrightness: Brightness.light,
      ),
    );
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

    debugPrint('MAIN: Loading .env...');
    await dotenv.load();

    debugPrint('MAIN: Performing parallel initialization...');

    // Run independent initialization tasks in parallel to minimize startup time
    final initResults = await Future.wait([
      SecurityService.isDeviceSecure()
          .timeout(const Duration(seconds: 4))
          .catchError((Object e) {
            debugPrint('MAIN: Security check failed/timed out: $e');
            return true; // Fallback to true in case of timeout/error
          }),
      container
          .read(notificationServiceProvider)
          .init()
          .timeout(const Duration(seconds: 3))
          .catchError((Object e) {
            debugPrint('MAIN: Notification service init failed: $e');
            return null;
          }),
      SupabaseService.initialize()
          .timeout(const Duration(seconds: 8))
          .catchError((Object e, StackTrace stack) {
            logError('Supabase initialization warning', e, stack);
            return null;
          }),
    ]);

    final isSecure = (initResults[0] as bool?) ?? true;
    if (!isSecure) {
      debugPrint('MAIN: Device not secure, showing violation screen');
      runApp(const SecurityViolationScreen());
      FlutterNativeSplash.remove();
      return;
    }

    debugPrint('MAIN: Initialization complete. Running app.');
    runApp(
      UncontrolledProviderScope(
        container: container,
        child: const MyApp(),
      ),
    );
  } on Object catch (e, stack) {
    debugPrint('MAIN: FATAL STARTUP ERROR: $e');
    debugPrint(stack.toString());

    // Ensure we at least try to run the app so it doesn't stay on splash forever
    runApp(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: Text('Startup Error: $e\nCheck console logs.'),
          ),
        ),
      ),
    );
    FlutterNativeSplash.remove();
  }
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.read(syncCoordinatorProvider);

    final themeMode = ref.watch(themeProvider);
    final router = ref.watch(goRouterProvider);

    return MaterialApp.router(
      routerConfig: router,
      title: 'Restro Hub',
      themeMode: themeMode,
      builder: (context, child) {
        return ErrorListenerWrapper(
          child: AnnotatedRegion<SystemUiOverlayStyle>(
            value: SystemUiOverlayStyle(
              statusBarColor: Colors.transparent,
              systemNavigationBarColor: Colors.transparent,
              systemNavigationBarDividerColor: Colors.transparent,
              systemNavigationBarIconBrightness: themeMode == ThemeMode.dark
                  ? Brightness.light
                  : Brightness.dark,
              statusBarIconBrightness: themeMode == ThemeMode.dark
                  ? Brightness.light
                  : Brightness.dark,
            ),
            child: Stack(
              children: [
                if (child != null) Positioned.fill(child: child),
                if (!ref.watch(isOnlineProvider))
                  const Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: SafeArea(
                      bottom: false,
                      child: ConnectivityBanner(),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en', '')],
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      debugShowCheckedModeBanner: false,
    );
  }
}
