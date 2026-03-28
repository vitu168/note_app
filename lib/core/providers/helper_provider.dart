import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HelperProvider extends ChangeNotifier {
  bool _isDarkMode = false;
  bool get isDarkMode => _isDarkMode;

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }

  // Custom primary color (persisted)
  static const _kPrimaryColorKey = 'primary_color';
  int _primaryColorValue = Colors.indigo.value;
  Color get primaryColor => Color(_primaryColorValue);

  HelperProvider() {
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
