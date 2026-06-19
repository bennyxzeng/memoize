import 'package:flutter/material.dart';

// Manages the app state's theme
// Uses a change notifier so widgets can listen for changes and rebuild
class ThemeProvider extends ChangeNotifier {
  // By default the theme is set to light mode when app starts.
  ThemeMode _themeMode = ThemeMode.light;
  // Returns the current theme
  ThemeMode get themeMode => _themeMode;
  // Returns true if current theme is dark mode
  bool get isDark => _themeMode == ThemeMode.dark;

  // Toggles between light mode and dark mode
  void toggleTheme() {
    //Shorthand for if currently darkmode to switch to light mode on press vice versa for light mode switch to dark
    _themeMode = isDark ? ThemeMode.light : ThemeMode.dark;
    notifyListeners();
  }
}