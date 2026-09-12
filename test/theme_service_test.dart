import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectify/services/theme_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('New user defaults to ThemeMode.system', () async {
    final themeService = ThemeService.instance;
    await themeService.initialize();

    expect(themeService.themeMode, ThemeMode.system);
    expect(themeService.getThemeModeLabel(), 'System Default');
  });

  test('Switching to Light theme persists and updates state', () async {
    final themeService = ThemeService.instance;
    await themeService.initialize();

    await themeService.setThemeMode(ThemeMode.light);
    expect(themeService.themeMode, ThemeMode.light);
    expect(themeService.getThemeModeLabel(), 'Light');

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('app_theme_mode'), 'light');
  });

  test('Switching to Dark theme persists and updates state', () async {
    final themeService = ThemeService.instance;
    await themeService.initialize();

    await themeService.setThemeMode(ThemeMode.dark);
    expect(themeService.themeMode, ThemeMode.dark);
    expect(themeService.getThemeModeLabel(), 'Dark');

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('app_theme_mode'), 'dark');
  });

  test('Switching back to System Default persists and updates state', () async {
    final themeService = ThemeService.instance;
    await themeService.initialize();

    await themeService.setThemeMode(ThemeMode.dark);
    expect(themeService.themeMode, ThemeMode.dark);

    await themeService.setThemeMode(ThemeMode.system);
    expect(themeService.themeMode, ThemeMode.system);
    expect(themeService.getThemeModeLabel(), 'System Default');

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('app_theme_mode'), 'system');
  });

  test('Persistent state is restored upon re-initialization', () async {
    SharedPreferences.setMockInitialValues({'app_theme_mode': 'dark'});

    final themeService = ThemeService.instance;
    await themeService.initialize();

    expect(themeService.themeMode, ThemeMode.dark);
    expect(themeService.getThemeModeLabel(), 'Dark');
  });
}
