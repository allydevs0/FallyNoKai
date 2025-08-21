import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeService {
  static const _themeModeKey = 'themeMode';

  final ValueNotifier<ThemeMode> _themeMode = ValueNotifier(ThemeMode.system);

  ValueNotifier<ThemeMode> get themeMode => _themeMode;

  ThemeService();

  Future<void> init() async {
    await _loadThemeMode();
  }

  Future<void> _loadThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final themeModeString = prefs.getString(_themeModeKey);
    if (themeModeString == 'light') {
      _themeMode.value = ThemeMode.light;
    } else if (themeModeString == 'dark') {
      _themeMode.value = ThemeMode.dark;
    } else {
      _themeMode.value = ThemeMode.system;
    }
  }

  Future<void> toggleTheme() async {
    final prefs = await SharedPreferences.getInstance();
    if (_themeMode.value == ThemeMode.light) {
      _themeMode.value = ThemeMode.dark;
      await prefs.setString(_themeModeKey, 'dark');
    } else {
      _themeMode.value = ThemeMode.light;
      await prefs.setString(_themeModeKey, 'light');
    }
  }

  Future<void> setTheme(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    _themeMode.value = mode;
    await prefs.setString(_themeModeKey, mode.toString().split('.').last);
  }
}
