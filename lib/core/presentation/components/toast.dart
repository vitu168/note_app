import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:note_app/core/constants/properties_constant.dart';
import 'package:note_app/core/constants/color_constant.dart';
import 'package:note_app/core/constants/font_constant.dart';
class Toast {
  Toast._();

  static final _queue = <_ToastEntry>[];
  static bool _showing = false;
  static void show(
    BuildContext context,
    String message, {
    ToastType type = ToastType.info,
    Duration duration = const Duration(milliseconds: 2500),
    Color? backgroundColor,
    Color? textColor,
    IconData? icon,
    bool withHaptic = true,
  }) {
    final entry = _ToastEntry(
      context: context,
      message: message,
      type: type,
      duration: duration,
      backgroundColor: backgroundColor,
      textColor: textColor,
      icon: icon,
      withHaptic: withHaptic,
    );

    _queue.add(entry);
    if (!_showing) _showNext();
  }

  static void _showNext() async {
    if (_queue.isEmpty) {
      _showing = false;
      return;
    }
    _showing = true;
    final entry = _queue.removeAt(0);
    await entry._show();
    await Future.delayed(const Duration(milliseconds: 150));
    _showNext();
  }
}

enum ToastType { success, error, info, warning }

class _ToastEntry {
  final BuildContext context;
  final String message;
  final ToastType type;
  final Duration duration;
  final Color? backgroundColor;
  final Color? textColor;
  final IconData? icon;
  final bool withHaptic;

  _ToastEntry({
    required this.context,
    required this.message,
    required this.type,
    required this.duration,
    this.backgroundColor,
    this.textColor,
    this.icon,
    this.withHaptic = true,
  });

  Future<void> _show() async {
    final overlay = Overlay.of(context);

    final theme = Theme.of(context);
    final Color bg = backgroundColor ?? _defaultBackgroundColor(theme, type);
    final Color txt = textColor ?? AppColors.surfaceLight;
    final IconData ic = icon ?? _defaultIcon(type);

    final overlayEntry = OverlayEntry(
      builder: (context) => _ToastWidget(
        message: message,
        backgroundColor: bg,
        textColor: txt,
        icon: ic,
      ),
    );

    overlay.insert(overlayEntry);

    if (withHaptic && !kIsWeb) {
      try {
        if (type == ToastType.error) HapticFeedback.heavyImpact();
        else HapticFeedback.lightImpact();
      } catch (_) {}
    }

    await Future.delayed(duration);

    overlayEntry.remove();
  }

  Color _defaultBackgroundColor(ThemeData theme, ToastType type) {
    switch (type) {
      case ToastType.success:
        return AppColors.success;
      case ToastType.error:
        return AppColors.error;
      case ToastType.warning:
        return AppColors.warning;
      case ToastType.info:
        return AppColors.primary;
    }
  }

  IconData _defaultIcon(ToastType type) {
    switch (type) {
      case ToastType.success:
        return Icons.check_circle_outline;
      case ToastType.error:
        return Icons.error_outline;
      case ToastType.warning:
        return Icons.warning_amber_outlined;
      case ToastType.info:
        return Icons.info_outline;
    }
  }
}

class _ToastWidget extends StatefulWidget {
  final String message;
  final Color backgroundColor;
  final Color textColor;
  final IconData icon;

  const _ToastWidget({
    Key? key,
    required this.message,
    required this.backgroundColor,
    required this.textColor,
    required this.icon,
  }) : super(key: key);

  @override
  State<_ToastWidget> createState() => _ToastWidgetState();
}

class _ToastWidgetState extends State<_ToastWidget> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _offsetAnim;
  late final Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 250));
    _offsetAnim = Tween<Offset>(begin: const Offset(0, -0.15), end: Offset.zero).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _fadeAnim = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final topPadding = mq.padding.top + AppDimensions.spacing; // respect status bar

    return Positioned(
      top: topPadding,
      left: AppDimensions.spacingMedium,
      right: AppDimensions.spacingMedium,
      child: SlideTransition(
        position: _offsetAnim,
        child: FadeTransition(
          opacity: _fadeAnim,
          child: Material(
            color: Colors.transparent,
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(minWidth: 100, maxWidth: AppDimensions.maxContentWidth),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  decoration: BoxDecoration(
                    color: widget.backgroundColor,
                    borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
                    boxShadow: [
                      BoxShadow(color: AppColors.shadowLight, blurRadius: 8, offset: const Offset(0, 4)),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(widget.icon, color: widget.textColor, size: AppDimensions.icon),
                      const SizedBox(width: 12),
                      Flexible(
                        child: Text(
                          widget.message,
                          style: AppFonts.bodyMediumWithColor(widget.textColor),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
