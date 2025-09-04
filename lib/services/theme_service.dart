import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeService {
  static const _themeNameKey = 'themeName';

  // Define your themes here
  static final Map<String, ThemeData> _themes = {
    'Light (Default)': ThemeData.light().copyWith(
      primaryColor: Colors.blue,
      appBarTheme: const AppBarTheme(backgroundColor: Colors.blue, foregroundColor: Colors.white),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(backgroundColor: Colors.blue),
    ),
    'Dark (Default)': ThemeData.dark().copyWith(
      primaryColor: Colors.blueGrey,
      appBarTheme: const AppBarTheme(backgroundColor: Colors.blueGrey, foregroundColor: Colors.white),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(backgroundColor: Colors.blueGrey),
    ),
    'Light (Green)': ThemeData.light().copyWith(
      primaryColor: Colors.lightGreen,
      appBarTheme: const AppBarTheme(backgroundColor: Colors.lightGreen, foregroundColor: Colors.white),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(backgroundColor: Colors.lightGreen),
    ),
    'Dark (Purple)': ThemeData.dark().copyWith(
      primaryColor: Colors.deepPurple,
      appBarTheme: const AppBarTheme(backgroundColor: Colors.deepPurple, foregroundColor: Colors.white),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(backgroundColor: Colors.deepPurple),
    ),
    'Light (Orange)': ThemeData.light().copyWith(
      primaryColor: Colors.orange,
      appBarTheme: const AppBarTheme(backgroundColor: Colors.orange, foregroundColor: Colors.white),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(backgroundColor: Colors.orange),
    ),
    'Dark (Teal)': ThemeData.dark().copyWith(
      primaryColor: Colors.teal,
      appBarTheme: const AppBarTheme(backgroundColor: Colors.teal, foregroundColor: Colors.white),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(backgroundColor: Colors.teal),
    ),
    'Light (Red)': ThemeData.light().copyWith(
      primaryColor: Colors.red,
      appBarTheme: const AppBarTheme(backgroundColor: Colors.red, foregroundColor: Colors.white),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(backgroundColor: Colors.red),
    ),
    'Dark (Indigo)': ThemeData.dark().copyWith(
      primaryColor: Colors.indigo,
      appBarTheme: const AppBarTheme(backgroundColor: Colors.indigo, foregroundColor: Colors.white),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(backgroundColor: Colors.indigo),
    ),
    'Light (Amber)': ThemeData.light().copyWith(
      primaryColor: Colors.amber,
      appBarTheme: const AppBarTheme(backgroundColor: Colors.amber, foregroundColor: Colors.white),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(backgroundColor: Colors.amber),
    ),
    'Dark (Brown)': ThemeData.dark().copyWith(
      primaryColor: Colors.brown,
      appBarTheme: const AppBarTheme(backgroundColor: Colors.brown, foregroundColor: Colors.white),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(backgroundColor: Colors.brown),
    ),
  };

  final ValueNotifier<String> _currentThemeName = ValueNotifier('Light (Default)');

  ValueNotifier<String> get currentThemeName => _currentThemeName;

  ThemeData get currentThemeData => _themes[_currentThemeName.value]!;

  List<String> get availableThemes => _themes.keys.toList();

  ThemeService();

  Future<void> init() async {
    await _loadThemeName();
  }

  Future<void> _loadThemeName() async {
    final prefs = await SharedPreferences.getInstance();
    final themeName = prefs.getString(_themeNameKey);
    if (themeName != null && _themes.containsKey(themeName)) {
      _currentThemeName.value = themeName;
    } else {
      _currentThemeName.value = 'Light (Default)'; // Default theme
    }
  }

  Future<void> setTheme(String themeName) async {
    if (_themes.containsKey(themeName)) {
      final prefs = await SharedPreferences.getInstance();
      _currentThemeName.value = themeName;
      await prefs.setString(_themeNameKey, themeName);
    }
  }
}