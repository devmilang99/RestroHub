import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'preferences_provider.g.dart';

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError();
});

@Riverpod(keepAlive: true)
class PreferencesService extends _$PreferencesService {
  SharedPreferences get _prefs => ref.read(sharedPreferencesProvider);

  @override
  PreferencesService build() => this;

  static const _onboardingCompletedKey = 'onboarding_completed';
  static const _themeModeKey = 'theme_mode';

  bool get isOnboardingCompleted =>
      _prefs.getBool(_onboardingCompletedKey) ?? false;

  Future<void> setOnboardingCompleted(bool completed) async {
    await _prefs.setBool(_onboardingCompletedKey, completed);
    state = this;
  }

  ThemeMode get themeMode {
    final mode = _prefs.getString(_themeModeKey);
    if (mode == 'dark') return ThemeMode.dark;
    if (mode == 'light') return ThemeMode.light;
    return ThemeMode.system;
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    await _prefs.setString(_themeModeKey, mode.name);
    state = this;
  }
}
