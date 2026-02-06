import 'package:flutter/material.dart';

/// App-wide dimension and property constants.
///
/// Use `AppDimensions` for named spacing and size constants, and
/// `Responsive` helpers for context-aware sizes.
class AppDimensions {
  AppDimensions._(); // no instances

  // --- Spacing (generic) ---
  static const double spacingXSmall = 4.0;
  static const double spacingSmall = 8.0;
  static const double spacing = 12.0;
  static const double spacingMedium = 16.0;
  static const double spacingLarge = 24.0;
  static const double spacingXLarge = 32.0;
  static const double spacingXXLarge = 48.0;

  // --- Common paddings ---
  static const EdgeInsets paddingAllSmall = EdgeInsets.all(spacingSmall);
  static const EdgeInsets paddingAll = EdgeInsets.all(spacing);
  static const EdgeInsets paddingAllLarge = EdgeInsets.all(spacingLarge);
  static const EdgeInsets paddingHorizontal = EdgeInsets.symmetric(horizontal: spacingMedium);
  static const EdgeInsets paddingVertical = EdgeInsets.symmetric(vertical: spacingMedium);

  // --- Icon and touch sizes ---
  static const double iconSmall = 16.0;
  static const double icon = 24.0;
  static const double iconLarge = 32.0;

  static const double touchTargetSmall = 40.0;
  static const double touchTarget = 48.0; // recommended minimum

  // --- Heights ---
  static const double inputHeight = 48.0;
  static const double buttonHeight = 48.0;
  static const double appBarHeight = kToolbarHeight;

  // --- Radii and borders ---
  static const double radiusSmall = 6.0;
  static const double radius = 8.0;
  static const double radiusLarge = 12.0;
  static const BorderRadius borderRadius = BorderRadius.all(Radius.circular(radius));

  // --- Elevation & shadows ---
  static const double elevationLow = 1.0;
  static const double elevation = 4.0;
  static const double elevationHigh = 8.0;

  // --- Animation durations ---
  static const Duration durationShort = Duration(milliseconds: 150);
  static const Duration duration = Duration(milliseconds: 300);
  static const Duration durationLong = Duration(milliseconds: 600);

  // --- Text sizes ---
  static const double textSmall = 12.0;
  static const double text = 14.0;
  static const double textMedium = 16.0;
  static const double textLarge = 20.0;
  static const double textXLarge = 24.0;

  // --- Responsive breakpoints (useful for web/layout decisions) ---
  static const double breakpointSmall = 600.0; // phone
  static const double breakpointMedium = 1024.0; // tablet
  static const double breakpointLarge = 1440.0; // desktop

  // --- Max widths for content ---
  static const double maxContentWidth = 1100.0;
}

/// Responsive helpers for size adjustments based on the current context.
class Responsive {
  Responsive._();

  static bool isSmall(BuildContext context) => MediaQuery.of(context).size.width <= AppDimensions.breakpointSmall;
  static bool isMedium(BuildContext context) => MediaQuery.of(context).size.width > AppDimensions.breakpointSmall && MediaQuery.of(context).size.width <= AppDimensions.breakpointMedium;
  static bool isLarge(BuildContext context) => MediaQuery.of(context).size.width > AppDimensions.breakpointMedium;

  /// Returns a scaled size factor based on width. Useful for font scaling or padding.
  static double widthScale(BuildContext context, {double min = 0.9, double max = 1.25}) {
    final width = MediaQuery.of(context).size.width;
    if (width <= AppDimensions.breakpointSmall) return min;
    if (width >= AppDimensions.breakpointLarge) return max;

    // a simple linear interpolation between min and max across medium sizes
    final t = (width - AppDimensions.breakpointSmall) / (AppDimensions.breakpointLarge - AppDimensions.breakpointSmall);
    return min + (max - min) * t.clamp(0.0, 1.0);
  }

  /// Convenience: returns spacing that scales a bit by screen width.
  static double scaledSpacing(BuildContext context, {double base = AppDimensions.spacing}) {
    return base * widthScale(context);
  }
}

// --- Shorthands for common paddings used in UI code ---
extension PaddingHelpers on Widget {
  Widget withPaddingAll([EdgeInsets? padding]) => Padding(padding: padding ?? AppDimensions.paddingAll, child: this);
  Widget withPaddingSymmetric({double horizontal = AppDimensions.spacingMedium, double vertical = 0}) => Padding(padding: EdgeInsets.symmetric(horizontal: horizontal, vertical: vertical), child: this);
}
