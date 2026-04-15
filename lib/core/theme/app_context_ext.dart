import 'package:flutter/material.dart';
import 'app_theme_extension.dart';

/// Shortcut extensions on [BuildContext] for easy theme token access.
///
/// Example:
///   ```dart
///   final t = context.appTheme;
///   Container(color: t.surface, child: Text('Hello', style: TextStyle(color: t.titleText)));
///   ```
extension AppThemeContext on BuildContext {
  /// Semantic design tokens for the current theme.
  AppThemeExtension get appTheme =>
      Theme.of(this).extension<AppThemeExtension>()!;

  /// Whether the current resolved brightness is [Brightness.dark].
  bool get isDark => Theme.of(this).brightness == Brightness.dark;

  /// The current resolved primary color (convenience shortcut).
  Color get primaryColor => Theme.of(this).colorScheme.primary;
}
