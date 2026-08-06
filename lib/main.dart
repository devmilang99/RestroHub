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

    // Security Check
    debugPrint('MAIN: Performing security check...');
    try {
      final isSecure = await SecurityService.isDeviceSecure().timeout(
        const Duration(seconds: 5),
      );
      if (!isSecure) {
        debugPrint('MAIN: Device not secure, showing violation screen');
        runApp(const SecurityViolationScreen());
        FlutterNativeSplash.remove();
        return;
      }
    } catch (e) {
      debugPrint('MAIN: Security check timed out or failed: $e');
      // Continue anyway in debug/dev to avoid soft lock if safe_device hangs
    }

    debugPrint('MAIN: Initializing SharedPreferences...');
    // Prefs already initialized for global error handling

    debugPrint('MAIN: Initializing Notification Service...');
    try {
      final service = container.read(notificationServiceProvider);
      await service.init().timeout(const Duration(seconds: 3));
    } catch (e) {
      debugPrint('MAIN: Notification service init failed: $e');
    }

    debugPrint('MAIN: Initializing Supabase...');
    try {
      await SupabaseService.initialize().timeout(const Duration(seconds: 10));
    } catch (e, stack) {
      logError(
        'Supabase initialization warning (Safe to continue if session expired)',
        e,
        stack,
      );
      // We don't rethrow here because the app can still run and
      // let the user log in even if session recovery fails.
    }

    debugPrint('MAIN: Initialization complete. Running app.');
    runApp(
      UncontrolledProviderScope(
        container: container,
        child: const MyApp(),
      ),
    );
  } catch (e, stack) {
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
