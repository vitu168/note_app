import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors
  static const Color primary = Color(0xFF1976D2);
  static const Color primaryLight = Color(0xFF42A5F5);
  static const Color primaryDark = Color(0xFF1565C0);

  // Secondary Colors
  static const Color secondary = Color(0xFFDC143C);
  static const Color secondaryLight = Color(0xFFFF6B6B);
  static const Color secondaryDark = Color(0xFFC62828);

  // Accent Colors
  static const Color accent = Color(0xFFFFC107);
  static const Color accentLight = Color(0xFFFFF350);
  static const Color accentDark = Color(0xFFFF8F00);

  // Background Colors
  static const Color backgroundLight = Color(0xFFFAFAFA);
  static const Color backgroundDark = Color(0xFF121212);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFF1E1E1E);

  // Text Colors
  static const Color textPrimaryLight = Color(0xFF212121);
  static const Color textSecondaryLight = Color(0xFF757575);
  static const Color textHintLight = Color(0xFFBDBDBD);

  static const Color textPrimaryDark = Color(0xFFFFFFFF);
  static const Color textSecondaryDark = Color(0xFFBDBDBD);
  static const Color textHintDark = Color(0xFF757575);

  // Error Colors
  static const Color error = Color(0xFFD32F2F);
  static const Color errorLight = Color(0xFFEF5350);
  static const Color errorDark = Color(0xFFC62828);

  // Success Colors
  static const Color success = Color(0xFF388E3C);
  static const Color successLight = Color(0xFF4CAF50);
  static const Color successDark = Color(0xFF2E7D32);

  // Warning Colors
  static const Color warning = Color(0xFFF57C00);
  static const Color warningLight = Color(0xFFFF9800);
  static const Color warningDark = Color(0xFFE65100);

  // Note Colors (for different note categories)
  static const Color noteBlue = Color(0xFFE3F2FD);
  static const Color noteGreen = Color(0xFFE8F5E8);
  static const Color noteYellow = Color(0xFFFFF8E1);
  static const Color notePink = Color(0xFFFCE4EC);
  static const Color notePurple = Color(0xFFF3E5F5);
  static const Color noteOrange = Color(0xFFFFF3E0);

  // Border Colors
  static const Color borderLight = Color(0xFFE0E0E0);
  static const Color borderDark = Color(0xFF424242);

  // Shadow Colors
  static const Color shadowLight = Color(0x1F000000);
  static const Color shadowDark = Color(0x3F000000);

  // Transparent Colors
  static const Color transparent = Colors.transparent;
  static const Color overlayLight = Color(0x80FFFFFF);
  static const Color overlayDark = Color(0x80000000);

  // Get colors based on theme
  static Color getTextPrimary(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light
        ? textPrimaryLight
        : textPrimaryDark;
  }

  static Color getTextSecondary(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light
        ? textSecondaryLight
        : textSecondaryDark;
  }

  static Color getBackground(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light
        ? backgroundLight
        : backgroundDark;
  }

  static Color getSurface(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light
        ? surfaceLight
        : surfaceDark;
  }

  static Color getBorder(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light
        ? borderLight
        : borderDark;
  }

  // Note color palette
  static const List<Color> noteColors = [
    noteBlue,
    noteGreen,
    noteYellow,
    notePink,
    notePurple,
    noteOrange,
  ];

  // Get random note color
  static Color getRandomNoteColor() {
    return noteColors[
        DateTime.now().millisecondsSinceEpoch % noteColors.length];
  }
}
