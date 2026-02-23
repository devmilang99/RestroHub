import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'firebase_options.dart' show DefaultFirebaseOptions;
import 'package:restro_hub/router/routerService.dart' show RouterService;
import 'package:restro_hub/core/theme/theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);

    return MaterialApp.router(
      routerConfig: RouterService.goRouter,
      title: 'Restro Hub',
      themeMode: themeMode,
      theme: ThemeData(
        useMaterial3: true,
        // colorScheme: ColorScheme.fromSeed(
        //   seedColor: const Color(0xFFFFD700), // Premium Gold
        //   primary: const Color(0xFFD4AF37), // Metallic Gold
        //   secondary: const Color(0xFFC5A028),
        //   brightness: Brightness.light,
        // ),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 23, 161, 30),
          brightness: Brightness.light,
        ),
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          titleTextStyle: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
        ),
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}
