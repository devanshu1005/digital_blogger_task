import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  bool _isDarkMode = false;
  bool _isInitialized = false;

  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _isDarkMode;
  bool get isInitialized => _isInitialized;

  ThemeProvider() {
    _loadThemePreference();
  }

  ThemeData get lightTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primarySwatch: Colors.blue,
    primaryColor: Colors.blue,
    scaffoldBackgroundColor: Colors.grey[50],
    cardColor: Colors.white,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      foregroundColor: Colors.black87,
      elevation: 1,
      systemOverlayStyle: SystemUiOverlayStyle.dark,
    ),
    cardTheme: CardTheme(
      color: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    textTheme: const TextTheme(
      headlineSmall: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
      bodyLarge: TextStyle(color: Colors.black87),
      bodyMedium: TextStyle(color: Colors.black54),
    ),
    iconTheme: const IconThemeData(color: Colors.black87),
  );

  ThemeData get darkTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    primarySwatch: Colors.blue,
    primaryColor: Colors.blue,
    scaffoldBackgroundColor: const Color(0xFF121212),
    cardColor: const Color(0xFF1E1E1E),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF1E1E1E),
      foregroundColor: Colors.white,
      elevation: 1,
      systemOverlayStyle: SystemUiOverlayStyle.light,
    ),
    cardTheme: CardTheme(
      color: const Color(0xFF1E1E1E),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    textTheme: const TextTheme(
      headlineSmall: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      bodyLarge: TextStyle(color: Colors.white),
      bodyMedium: TextStyle(color: Colors.white70),
    ),
    iconTheme: const IconThemeData(color: Colors.white),
  );

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    _themeMode = _isDarkMode ? ThemeMode.dark : ThemeMode.light;
    _saveThemePreference();
    notifyListeners();
  }

  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    _isDarkMode = mode == ThemeMode.dark;
    _saveThemePreference();
    notifyListeners();
  }

  Future<void> _loadThemePreference() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _isDarkMode = prefs.getBool('isDarkMode') ?? false;
      _themeMode = _isDarkMode ? ThemeMode.dark : ThemeMode.light;
      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading theme preference: $e');
      _isInitialized = true;
      notifyListeners();
    }
  }

  Future<void> _saveThemePreference() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isDarkMode', _isDarkMode);
    } catch (e) {
      debugPrint('Error saving theme preference: $e');
    }
  }
}