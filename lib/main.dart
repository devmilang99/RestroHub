import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:restro_hub/core/providers/preferences_provider.dart';
import 'package:restro_hub/core/services/notification_service.dart';
import 'package:restro_hub/core/theme/app_theme.dart';
import 'package:restro_hub/core/theme/theme_provider.dart';
import 'package:restro_hub/core/widgets/connectivity_banner.dart';
import 'package:restro_hub/core/widgets/error_listener_wrapper.dart';
import 'package:restro_hub/infrastructure/supabase/supabase_service.dart';
import 'package:restro_hub/infrastructure/sync/sync_coordinator.dart';
import 'package:restro_hub/l10n/generated/app_localizations.dart';
import 'package:restro_hub/router/router_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  await dotenv.load();

  final SharedPreferences prefs = await SharedPreferences.getInstance();

  final container = ProviderContainer(
    overrides: [
      sharedPreferencesProvider.overrideWithValue(prefs),
    ],
  );

  final service = container.read(notificationServiceProvider);
  await service.init();
  await service.requestPermissions();

  try {
    await SupabaseService.initialize();
  } on Object catch (e) {
    debugPrint(
      'Supabase initialization failed: $e. App will continue in offline mode.',
    );
  }

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.read(syncCoordinatorProvider);

    final themeMode = ref.watch(themeProvider);
    final router = ref.watch(goRouterProvider);

    return ErrorListenerWrapper(
      child: MaterialApp.router(
        routerConfig: router,
        title: 'Restro Hub',
        themeMode: themeMode,
        builder: (context, child) {
          return Column(
            children: [
              const ConnectivityBanner(),
              if (child != null) Expanded(child: child),
            ],
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
      ),
    );
  }
}
