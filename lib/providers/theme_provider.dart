import 'package:flutter/material.dart';

class ThemeProvider with ChangeNotifier {
  bool _isDark = false;

  bool get isDark => _isDark;

  ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      useMaterial3: true,
      colorSchemeSeed: Colors.deepOrange,
      scaffoldBackgroundColor: Colors.white,
      appBarTheme: const AppBarTheme(
        centerTitle: false,
      ),
    );
  }

  ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      useMaterial3: true,
      colorSchemeSeed: Colors.deepOrange,
      appBarTheme: const AppBarTheme(
        centerTitle: false,
      ),
    );
  }

  // Enhancement 3:
  // Toggles between dark mode and light mode.
  void toggleTheme() {
    _isDark = !_isDark;
    notifyListeners();
  }
}