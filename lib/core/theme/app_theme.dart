import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static ThemeData lightThemeFor(Color primary) {
    return ThemeData(
      primaryColor: primary,
      scaffoldBackgroundColor: const Color(0xFFF5F7FA),
      colorScheme: ColorScheme.light(
        primary: primary,
        surface: const Color(0xFFF5F7FA),
        onSurface: Colors.black87,
      ),
      textTheme: GoogleFonts.poppinsTextTheme(),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      appBarTheme: AppBarTheme(backgroundColor: primary, foregroundColor: Colors.white),
      floatingActionButtonTheme: FloatingActionButtonThemeData(backgroundColor: primary),
    );
  }

  static ThemeData darkThemeFor(Color primary) {
    return ThemeData(
      primaryColor: primary,
      scaffoldBackgroundColor: const Color(0xFF212121),
      colorScheme: ColorScheme.dark(
        primary: primary,
        surface: const Color(0xFF212121),
        onSurface: Colors.white70,
      ),
      textTheme: GoogleFonts.poppinsTextTheme().apply(bodyColor: Colors.white70),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      appBarTheme: AppBarTheme(backgroundColor: primary, foregroundColor: Colors.white),
      floatingActionButtonTheme: FloatingActionButtonThemeData(backgroundColor: primary),
    );
  }
}
