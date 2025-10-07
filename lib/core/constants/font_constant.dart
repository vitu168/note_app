import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppFonts {
  // Font Families
  static const String primaryFont = 'Poppins';
  static const String secondaryFont = 'Inter';
  static const String monospaceFont = 'JetBrains Mono';

  // Font Sizes
  static const double fontSizeXS = 10.0;
  static const double fontSizeSM = 12.0;
  static const double fontSizeMD = 14.0;
  static const double fontSizeLG = 16.0;
  static const double fontSizeXL = 18.0;
  static const double fontSizeXXL = 20.0;
  static const double fontSizeXXXL = 24.0;
  static const double fontSizeXXXXL = 28.0;
  static const double fontSizeXXXXXL = 32.0;

  // Font Weights
  static const FontWeight fontWeightLight = FontWeight.w300;
  static const FontWeight fontWeightRegular = FontWeight.w400;
  static const FontWeight fontWeightMedium = FontWeight.w500;
  static const FontWeight fontWeightSemiBold = FontWeight.w600;
  static const FontWeight fontWeightBold = FontWeight.w700;
  static const FontWeight fontWeightExtraBold = FontWeight.w800;

  // Line Heights
  static const double lineHeightTight = 1.2;
  static const double lineHeightNormal = 1.4;
  static const double lineHeightRelaxed = 1.6;
  static const double lineHeightLoose = 1.8;

  // Letter Spacing
  static const double letterSpacingTight = -0.5;
  static const double letterSpacingNormal = 0.0;
  static const double letterSpacingWide = 0.5;
  static const double letterSpacingExtraWide = 1.0;

  // Text Styles for Headings
  static TextStyle get heading1 => GoogleFonts.poppins(
        fontSize: fontSizeXXXXXL,
        fontWeight: fontWeightBold,
        height: lineHeightTight,
        letterSpacing: letterSpacingTight,
      );

  static TextStyle get heading2 => GoogleFonts.poppins(
        fontSize: fontSizeXXXXL,
        fontWeight: fontWeightBold,
        height: lineHeightTight,
        letterSpacing: letterSpacingTight,
      );

  static TextStyle get heading3 => GoogleFonts.poppins(
        fontSize: fontSizeXXXL,
        fontWeight: fontWeightSemiBold,
        height: lineHeightTight,
        letterSpacing: letterSpacingNormal,
      );

  static TextStyle get heading4 => GoogleFonts.poppins(
        fontSize: fontSizeXXL,
        fontWeight: fontWeightSemiBold,
        height: lineHeightNormal,
        letterSpacing: letterSpacingNormal,
      );

  static TextStyle get heading5 => GoogleFonts.poppins(
        fontSize: fontSizeXL,
        fontWeight: fontWeightMedium,
        height: lineHeightNormal,
        letterSpacing: letterSpacingNormal,
      );

  static TextStyle get heading6 => GoogleFonts.poppins(
        fontSize: fontSizeLG,
        fontWeight: fontWeightMedium,
        height: lineHeightNormal,
        letterSpacing: letterSpacingNormal,
      );

  // Text Styles for Body Text
  static TextStyle get bodyLarge => GoogleFonts.inter(
        fontSize: fontSizeLG,
        fontWeight: fontWeightRegular,
        height: lineHeightRelaxed,
        letterSpacing: letterSpacingNormal,
      );

  static TextStyle get bodyMedium => GoogleFonts.inter(
        fontSize: fontSizeMD,
        fontWeight: fontWeightRegular,
        height: lineHeightRelaxed,
        letterSpacing: letterSpacingNormal,
      );

  static TextStyle get bodySmall => GoogleFonts.inter(
        fontSize: fontSizeSM,
        fontWeight: fontWeightRegular,
        height: lineHeightRelaxed,
        letterSpacing: letterSpacingNormal,
      );

  // Text Styles for Labels and Buttons
  static TextStyle get labelLarge => GoogleFonts.inter(
        fontSize: fontSizeLG,
        fontWeight: fontWeightMedium,
        height: lineHeightNormal,
        letterSpacing: letterSpacingWide,
      );

  static TextStyle get labelMedium => GoogleFonts.inter(
        fontSize: fontSizeMD,
        fontWeight: fontWeightMedium,
        height: lineHeightNormal,
        letterSpacing: letterSpacingWide,
      );

  static TextStyle get labelSmall => GoogleFonts.inter(
        fontSize: fontSizeSM,
        fontWeight: fontWeightMedium,
        height: lineHeightNormal,
        letterSpacing: letterSpacingWide,
      );

  // Text Styles for Display
  static TextStyle get displayLarge => GoogleFonts.poppins(
        fontSize: fontSizeXXXXXL,
        fontWeight: fontWeightLight,
        height: lineHeightTight,
        letterSpacing: letterSpacingTight,
      );

  static TextStyle get displayMedium => GoogleFonts.poppins(
        fontSize: fontSizeXXXXL,
        fontWeight: fontWeightLight,
        height: lineHeightTight,
        letterSpacing: letterSpacingTight,
      );

  static TextStyle get displaySmall => GoogleFonts.poppins(
        fontSize: fontSizeXXXL,
        fontWeight: fontWeightRegular,
        height: lineHeightTight,
        letterSpacing: letterSpacingTight,
      );

  // Monospace font for code
  static TextStyle get code => GoogleFonts.jetBrainsMono(
        fontSize: fontSizeSM,
        fontWeight: fontWeightRegular,
        height: lineHeightNormal,
        letterSpacing: letterSpacingNormal,
      );

  // Custom text styles with colors
  static TextStyle heading1WithColor(Color color) =>
      heading1.copyWith(color: color);
  static TextStyle heading2WithColor(Color color) =>
      heading2.copyWith(color: color);
  static TextStyle heading3WithColor(Color color) =>
      heading3.copyWith(color: color);
  static TextStyle bodyLargeWithColor(Color color) =>
      bodyLarge.copyWith(color: color);
  static TextStyle bodyMediumWithColor(Color color) =>
      bodyMedium.copyWith(color: color);
  static TextStyle labelLargeWithColor(Color color) =>
      labelLarge.copyWith(color: color);

  // Text styles with different weights
  static TextStyle get bodyLargeBold =>
      bodyLarge.copyWith(fontWeight: fontWeightBold);
  static TextStyle get bodyMediumBold =>
      bodyMedium.copyWith(fontWeight: fontWeightBold);
  static TextStyle get labelLargeBold =>
      labelLarge.copyWith(fontWeight: fontWeightBold);

  // Text styles with different sizes for specific use cases
  static TextStyle get noteTitle => GoogleFonts.poppins(
        fontSize: fontSizeXL,
        fontWeight: fontWeightSemiBold,
        height: lineHeightNormal,
        letterSpacing: letterSpacingNormal,
      );

  static TextStyle get noteContent => GoogleFonts.inter(
        fontSize: fontSizeMD,
        fontWeight: fontWeightRegular,
        height: lineHeightRelaxed,
        letterSpacing: letterSpacingNormal,
      );

  static TextStyle get buttonText => GoogleFonts.inter(
        fontSize: fontSizeMD,
        fontWeight: fontWeightMedium,
        height: lineHeightNormal,
        letterSpacing: letterSpacingWide,
      );

  static TextStyle get caption => GoogleFonts.inter(
        fontSize: fontSizeXS,
        fontWeight: fontWeightRegular,
        height: lineHeightNormal,
        letterSpacing: letterSpacingNormal,
      );

  static TextStyle get overline => GoogleFonts.inter(
        fontSize: fontSizeXS,
        fontWeight: fontWeightMedium,
        height: lineHeightNormal,
        letterSpacing: letterSpacingExtraWide,
        textBaseline: TextBaseline.alphabetic,
      ).copyWith(
        decoration: TextDecoration.underline,
        decorationStyle: TextDecorationStyle.solid,
      );
}
