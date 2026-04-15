import 'package:flutter/material.dart';

/// Semantic design tokens stored as a [ThemeExtension] so they flow through
/// Flutter's [ThemeData] and are accessible anywhere via [BuildContext].
///
/// Usage:
///   final t = Theme.of(context).extension<AppThemeExtension>()!;
///   // or with the shortcut from app_context_ext.dart:
///   final t = context.appTheme;
class AppThemeExtension extends ThemeExtension<AppThemeExtension> {
  const AppThemeExtension._({
    required this.primary,
    required this.onPrimary,
    required this.primaryMuted,
    required this.surface,
    required this.surfaceElevated,
    required this.surfaceHighest,
    required this.titleText,
    required this.bodyText,
    required this.hintText,
    required this.divider,
    required this.danger,
    required this.dangerMuted,
    required this.success,
    required this.warning,
    // Semantic icon badge colours
    required this.iconBlue,
    required this.iconGreen,
    required this.iconOrange,
    required this.iconTeal,
    required this.iconRed,
    required this.iconPurple,
  });

  // ── Brand ──────────────────────────────────────────────────────────────────
  final Color primary;
  final Color onPrimary;

  /// primary at ~10 % opacity — for chip/badge backgrounds
  final Color primaryMuted;

  // ── Surfaces ───────────────────────────────────────────────────────────────
  /// Card / sheet colour (white in light, dark panel in dark)
  final Color surface;

  /// Page scaffold background (slightly off-white or deeper dark)
  final Color surfaceElevated;

  /// Divider-level surface; slightly lighter than the card.
  final Color surfaceHighest;

  // ── Text ───────────────────────────────────────────────────────────────────
  final Color titleText;
  final Color bodyText;
  final Color hintText;

  // ── Utility ────────────────────────────────────────────────────────────────
  final Color divider;
  final Color danger;

  /// danger at ~10 % opacity — for destructive backgrounds
  final Color dangerMuted;
  final Color success;
  final Color warning;

  // ── Icon badge colours ─────────────────────────────────────────────────────
  final Color iconBlue;
  final Color iconGreen;
  final Color iconOrange;
  final Color iconTeal;
  final Color iconRed;
  final Color iconPurple;

  // ── Factories ──────────────────────────────────────────────────────────────

  factory AppThemeExtension.light(Color primary) => AppThemeExtension._(
        primary: primary,
        onPrimary: Colors.white,
        primaryMuted: primary.withValues(alpha: 0.10),
        surface: const Color(0xFFFFFFFF),
        surfaceElevated: const Color(0xFFF2F4F8),
        surfaceHighest: const Color(0xFFE8EAF0),
        titleText: const Color(0xFF16162A),
        bodyText: const Color(0xFF52528A),
        hintText: const Color(0xFF9E9EBE),
        divider: const Color(0xFFEBECF2),
        danger: const Color(0xFFEF4444),
        dangerMuted: const Color(0x1AEF4444),
        success: const Color(0xFF22C55E),
        warning: const Color(0xFFF59E0B),
        iconBlue: const Color(0xFF42A5F5),
        iconGreen: const Color(0xFF66BB6A),
        iconOrange: const Color(0xFFFF9800),
        iconTeal: const Color(0xFF26A69A),
        iconRed: const Color(0xFFEF5350),
        iconPurple: const Color(0xFFAB47BC),
      );

  factory AppThemeExtension.dark(Color primary) => AppThemeExtension._(
        primary: primary,
        onPrimary: Colors.white,
        primaryMuted: primary.withValues(alpha: 0.18),
        surface: const Color(0xFF1E1E2E),
        surfaceElevated: const Color(0xFF12121E),
        surfaceHighest: const Color(0xFF2A2A3E),
        titleText: const Color(0xFFE8E8F8),
        bodyText: const Color(0xFF8A8AAA),
        hintText: const Color(0xFF5A5A7A),
        divider: const Color(0xFF2C2C44),
        danger: const Color(0xFFFF6B6B),
        dangerMuted: const Color(0x1AFF6B6B),
        success: const Color(0xFF4ADE80),
        warning: const Color(0xFFFBBF24),
        iconBlue: const Color(0xFF1E88E5),
        iconGreen: const Color(0xFF43A047),
        iconOrange: const Color(0xFFFB8C00),
        iconTeal: const Color(0xFF00897B),
        iconRed: const Color(0xFFE53935),
        iconPurple: const Color(0xFF9C27B0),
      );

  // ── ThemeExtension boilerplate ─────────────────────────────────────────────

  @override
  AppThemeExtension copyWith({
    Color? primary,
    Color? onPrimary,
    Color? primaryMuted,
    Color? surface,
    Color? surfaceElevated,
    Color? surfaceHighest,
    Color? titleText,
    Color? bodyText,
    Color? hintText,
    Color? divider,
    Color? danger,
    Color? dangerMuted,
    Color? success,
    Color? warning,
    Color? iconBlue,
    Color? iconGreen,
    Color? iconOrange,
    Color? iconTeal,
    Color? iconRed,
    Color? iconPurple,
  }) =>
      AppThemeExtension._(
        primary: primary ?? this.primary,
        onPrimary: onPrimary ?? this.onPrimary,
        primaryMuted: primaryMuted ?? this.primaryMuted,
        surface: surface ?? this.surface,
        surfaceElevated: surfaceElevated ?? this.surfaceElevated,
        surfaceHighest: surfaceHighest ?? this.surfaceHighest,
        titleText: titleText ?? this.titleText,
        bodyText: bodyText ?? this.bodyText,
        hintText: hintText ?? this.hintText,
        divider: divider ?? this.divider,
        danger: danger ?? this.danger,
        dangerMuted: dangerMuted ?? this.dangerMuted,
        success: success ?? this.success,
        warning: warning ?? this.warning,
        iconBlue: iconBlue ?? this.iconBlue,
        iconGreen: iconGreen ?? this.iconGreen,
        iconOrange: iconOrange ?? this.iconOrange,
        iconTeal: iconTeal ?? this.iconTeal,
        iconRed: iconRed ?? this.iconRed,
        iconPurple: iconPurple ?? this.iconPurple,
      );

  @override
  AppThemeExtension lerp(
    covariant ThemeExtension<AppThemeExtension>? other,
    double t,
  ) {
    if (other is! AppThemeExtension) return this;
    Color c(Color a, Color b) => Color.lerp(a, b, t)!;
    return AppThemeExtension._(
      primary: c(primary, other.primary),
      onPrimary: c(onPrimary, other.onPrimary),
      primaryMuted: c(primaryMuted, other.primaryMuted),
      surface: c(surface, other.surface),
      surfaceElevated: c(surfaceElevated, other.surfaceElevated),
      surfaceHighest: c(surfaceHighest, other.surfaceHighest),
      titleText: c(titleText, other.titleText),
      bodyText: c(bodyText, other.bodyText),
      hintText: c(hintText, other.hintText),
      divider: c(divider, other.divider),
      danger: c(danger, other.danger),
      dangerMuted: c(dangerMuted, other.dangerMuted),
      success: c(success, other.success),
      warning: c(warning, other.warning),
      iconBlue: c(iconBlue, other.iconBlue),
      iconGreen: c(iconGreen, other.iconGreen),
      iconOrange: c(iconOrange, other.iconOrange),
      iconTeal: c(iconTeal, other.iconTeal),
      iconRed: c(iconRed, other.iconRed),
      iconPurple: c(iconPurple, other.iconPurple),
    );
  }
}
