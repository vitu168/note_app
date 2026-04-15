import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HelperProvider extends ChangeNotifier {
  // Three-state theme mode (system / light / dark)
  static const _kThemeModeKey = 'theme_mode';
  ThemeMode _themeMode = ThemeMode.system;
  ThemeMode get themeMode => _themeMode;

  // Backward-compat computed getter
  bool get isDarkMode => _themeMode == ThemeMode.dark;

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      final s = mode == ThemeMode.light
          ? 'light'
          : mode == ThemeMode.dark
              ? 'dark'
              : 'system';
      await prefs.setString(_kThemeModeKey, s);
    } catch (_) {}
  }

  void toggleTheme() {
    setThemeMode(_themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark);
  }

  Future<void> _loadThemeMode() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final s = prefs.getString(_kThemeModeKey);
      final mode = s == 'light'
          ? ThemeMode.light
          : s == 'dark'
              ? ThemeMode.dark
              : ThemeMode.system;
      if (mode != _themeMode) {
        _themeMode = mode;
        notifyListeners();
      }
    } catch (_) {}
  }

  // Custom primary color (persisted)
  static const _kPrimaryColorKey = 'primary_color';
  int _primaryColorValue = Colors.indigo.value;
  Color get primaryColor => Color(_primaryColorValue);

  HelperProvider() {
    _loadThemeMode();
    _loadPrimaryColor();
  }

  Future<void> _loadPrimaryColor() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final v = prefs.getInt(_kPrimaryColorKey);
      if (v != null && v != _primaryColorValue) {
        _primaryColorValue = v;
        notifyListeners();
      }
    } catch (_) {}
  }

  Future<void> setPrimaryColor(Color color) async {
    _primaryColorValue = color.value;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_kPrimaryColorKey, color.value);
    } catch (_) {}
  }

  // Locale/Language Provider functionality
  Locale _locale = const Locale('en');
  Locale get locale => _locale;

  void setLocale(Locale locale) {
    if (!['en', 'km'].contains(locale.languageCode)) return;
    _locale = locale;
    notifyListeners();
  }

  // Service Provider functionality (can be extended)
  // Add any service-related state and methods here

  // Combined provider for easy access
  static HelperProvider of(BuildContext context) {
    return Provider.of<HelperProvider>(context, listen: false);
  }
}

class L10n {
  static const all = [
    Locale('en'),
    Locale('km'),
    // Add more supported locales here
  ];
}
