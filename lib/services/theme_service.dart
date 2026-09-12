import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Central service for managing and persisting the application's theme mode.
/// Supports three states:
/// 1. System Default (ThemeMode.system)
/// 2. Light (ThemeMode.light)
/// 3. Dark (ThemeMode.dark)
class ThemeService {
  ThemeService._();
  static final ThemeService instance = ThemeService._();

  static const String _themePrefKey = 'app_theme_mode';

  final ValueNotifier<ThemeMode> themeModeNotifier =
      ValueNotifier<ThemeMode>(ThemeMode.system);

  ThemeMode get themeMode => themeModeNotifier.value;

  /// Loads saved theme preference from local storage.
  /// Defaults to [ThemeMode.system] for new users.
  Future<void> initialize() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedMode = prefs.getString(_themePrefKey);

      switch (savedMode) {
        case 'light':
          themeModeNotifier.value = ThemeMode.light;
          break;
        case 'dark':
          themeModeNotifier.value = ThemeMode.dark;
          break;
        case 'system':
        default:
          themeModeNotifier.value = ThemeMode.system;
          break;
      }
    } catch (e) {
      debugPrint('ThemeService initialization error: $e');
      themeModeNotifier.value = ThemeMode.system;
    }
  }

  /// Updates the theme mode and persists the choice to local storage.
  Future<void> setThemeMode(ThemeMode mode) async {
    if (themeModeNotifier.value == mode) return;

    themeModeNotifier.value = mode;

    try {
      final prefs = await SharedPreferences.getInstance();
      switch (mode) {
        case ThemeMode.light:
          await prefs.setString(_themePrefKey, 'light');
          break;
        case ThemeMode.dark:
          await prefs.setString(_themePrefKey, 'dark');
          break;
        case ThemeMode.system:
          await prefs.setString(_themePrefKey, 'system');
          break;
      }
    } catch (e) {
      debugPrint('Error saving theme mode: $e');
    }
  }

  /// Human-readable label for a given or current [ThemeMode].
  String getThemeModeLabel([ThemeMode? mode]) {
    final targetMode = mode ?? themeMode;
    switch (targetMode) {
      case ThemeMode.system:
        return 'System Default';
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
    }
  }

  /// Icon corresponding to a given or current [ThemeMode].
  IconData getThemeModeIcon([ThemeMode? mode]) {
    final targetMode = mode ?? themeMode;
    switch (targetMode) {
      case ThemeMode.system:
        return Icons.brightness_auto_rounded;
      case ThemeMode.light:
        return Icons.light_mode_rounded;
      case ThemeMode.dark:
        return Icons.dark_mode_rounded;
    }
  }
}
