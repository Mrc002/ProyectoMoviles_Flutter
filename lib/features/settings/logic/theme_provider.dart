import 'package:flutter/material.dart';

class ThemeProvider extends ChangeNotifier {
  // Empezamos con el tema claro por defecto
  ThemeMode _themeMode = ThemeMode.light;

  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _themeMode == ThemeMode.dark;

  void toggleTheme(bool isOn) {
    _themeMode = isOn ? ThemeMode.dark : ThemeMode.light;
    notifyListeners(); // Avisa a toda la app que el tema cambió
  }
}