import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HelperProvider extends ChangeNotifier {
  // Theme Provider functionality
  bool _isDarkMode = false;
  bool get isDarkMode => _isDarkMode;

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
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
