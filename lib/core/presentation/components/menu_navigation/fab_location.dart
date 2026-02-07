import 'package:flutter/material.dart';
import 'package:note_app/core/constants/properties_constant.dart';

/// FloatingActionButtonLocation that positions FAB above the bottom navigation bar
/// on the right side with consistent spacing.
class AboveBottomNavigationBar extends FloatingActionButtonLocation {
  const AboveBottomNavigationBar();

  @override
  Offset getOffset(ScaffoldPrelayoutGeometry scaffoldGeometry) {
    final double fabHeight = scaffoldGeometry.floatingActionButtonSize.height;
    final double navbarHeight = scaffoldGeometry.scaffoldSize.height - scaffoldGeometry.contentBottom;
    final double x = scaffoldGeometry.scaffoldSize.width - scaffoldGeometry.floatingActionButtonSize.width - AppDimensions.spacingMedium;
    final double y = scaffoldGeometry.scaffoldSize.height - navbarHeight - fabHeight - AppDimensions.spacingMedium;
    return Offset(x, y);
  }
}
