import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:restro_hub/core/providers/preferences_provider.dart';

// Using the newer Notifier API which is cleaner
class ThemeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() {
    return ref.watch(preferencesServiceProvider).themeMode;
  }

  void toggleTheme({required bool isDark}) {
    final newMode = isDark ? ThemeMode.dark : ThemeMode.light;
    state = newMode;
    ref.read(preferencesServiceProvider).setThemeMode(newMode);
  }
}

final themeProvider = NotifierProvider<ThemeNotifier, ThemeMode>(() {
  return ThemeNotifier();
});
