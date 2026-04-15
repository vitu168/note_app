import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_theme_extension.dart';

/// Central theme factory.
///
/// Both [lightThemeFor] and [darkThemeFor] embed an [AppThemeExtension] so
/// every widget can access semantic tokens via `context.appTheme`.
class AppTheme {
  AppTheme._();

  // ── Light ──────────────────────────────────────────────────────────────────
  static ThemeData lightThemeFor(Color primary) {
    final ext = AppThemeExtension.light(primary);
    return ThemeData(
      useMaterial3: false,
      primaryColor: primary,
      scaffoldBackgroundColor: ext.surfaceElevated,
      colorScheme: ColorScheme.light(
        primary: primary,
        surface: ext.surface,
        onSurface: ext.titleText,
        error: ext.danger,
      ),
      textTheme: GoogleFonts.poppinsTextTheme(),
      // Cards
      cardTheme: CardThemeData(
        elevation: 0,
        color: ext.surface,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      // Dividers
      dividerTheme: DividerThemeData(
        color: ext.divider,
        space: 1,
        thickness: 1,
      ),
      // List tiles
      listTileTheme: const ListTileThemeData(
        minLeadingWidth: 0,
        contentPadding: EdgeInsets.symmetric(horizontal: 16),
      ),
      // App bar
      appBarTheme: AppBarTheme(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
      // Buttons
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primary,
          side: BorderSide(color: primary, width: 1.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primary,
          textStyle: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500),
        ),
      ),
      // FAB
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: const CircleBorder(),
      ),
      // Dialogs
      dialogTheme: DialogThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 8,
        backgroundColor: ext.surface,
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 17,
          fontWeight: FontWeight.w600,
          color: ext.titleText,
        ),
        contentTextStyle: GoogleFonts.poppins(
          fontSize: 14,
          color: ext.bodyText,
        ),
      ),
      // Snackbars
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: ext.titleText,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        contentTextStyle: GoogleFonts.poppins(color: Colors.white, fontSize: 13),
      ),
      // Inputs
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: ext.surfaceElevated,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: ext.divider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: ext.danger),
        ),
        hintStyle: GoogleFonts.poppins(color: ext.hintText, fontSize: 14),
        labelStyle: GoogleFonts.poppins(color: ext.bodyText, fontSize: 14),
      ),
      extensions: [ext],
    );
  }

  // ── Dark ───────────────────────────────────────────────────────────────────
  static ThemeData darkThemeFor(Color primary) {
    final ext = AppThemeExtension.dark(primary);
    return ThemeData(
      useMaterial3: false,
      primaryColor: primary,
      scaffoldBackgroundColor: ext.surfaceElevated,
      colorScheme: ColorScheme.dark(
        primary: primary,
        surface: ext.surface,
        onSurface: ext.titleText,
        error: ext.danger,
      ),
      textTheme: GoogleFonts.poppinsTextTheme().apply(
        bodyColor: ext.bodyText,
        displayColor: ext.titleText,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: ext.surface,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      dividerTheme: DividerThemeData(
        color: ext.divider,
        space: 1,
        thickness: 1,
      ),
      listTileTheme: const ListTileThemeData(
        minLeadingWidth: 0,
        contentPadding: EdgeInsets.symmetric(horizontal: 16),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: ext.surface,
        foregroundColor: ext.titleText,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: ext.titleText,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primary,
          side: BorderSide(color: primary, width: 1.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primary,
          textStyle: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: const CircleBorder(),
      ),
      dialogTheme: DialogThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 8,
        backgroundColor: ext.surface,
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 17,
          fontWeight: FontWeight.w600,
          color: ext.titleText,
        ),
        contentTextStyle: GoogleFonts.poppins(
          fontSize: 14,
          color: ext.bodyText,
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: ext.surfaceHighest,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        contentTextStyle: GoogleFonts.poppins(color: ext.titleText, fontSize: 13),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: ext.surfaceHighest,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: ext.divider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: ext.danger),
        ),
        hintStyle: GoogleFonts.poppins(color: ext.hintText, fontSize: 14),
        labelStyle: GoogleFonts.poppins(color: ext.bodyText, fontSize: 14),
      ),
      extensions: [ext],
    );
  }
}
