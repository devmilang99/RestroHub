import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'preferences_provider.g.dart';

@Riverpod(keepAlive: true)
class PreferencesService extends _$PreferencesService {
  late SharedPreferences _prefs;

  @override
  FutureOr<void> build() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static const _onboardingCompletedKey = 'onboarding_completed';
  static const _themeModeKey = 'theme_mode';

  bool get isOnboardingCompleted =>
      _prefs.getBool(_onboardingCompletedKey) ?? false;

  Future<void> setOnboardingCompleted(bool completed) async {
    await _prefs.setBool(_onboardingCompletedKey, completed);
    ref.invalidateSelf();
  }

  ThemeMode get themeMode {
    final mode = _prefs.getString(_themeModeKey);
    if (mode == 'dark') return ThemeMode.dark;
    if (mode == 'light') return ThemeMode.light;
    return ThemeMode.system;
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    await _prefs.setString(_themeModeKey, mode.name);
    ref.invalidateSelf();
  }
}
