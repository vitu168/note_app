import 'package:flutter/material.dart';
import '../../constants/color_constant.dart';
import '../../constants/font_constant.dart';
import '../../constants/enum_constant.dart';

class DynamicButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final DynamicButtonType type;
  final DynamicButtonSize size;
  final bool isLoading;
  final bool isDisabled;
  final IconData? icon;
  final bool iconOnly;
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry? padding;

  const DynamicButton({
    Key? key,
    required this.label,
    this.onPressed,
    this.type = DynamicButtonType.primary,
    this.size = DynamicButtonSize.medium,
    this.isLoading = false,
    this.isDisabled = false,
    this.icon,
    this.iconOnly = false,
    this.width,
    this.height,
    this.borderRadius,
    this.padding,
  }) : super(key: key);

  @override
  State<DynamicButton> createState() => _DynamicButtonState();
}

class _DynamicButtonState extends State<DynamicButton>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    if (!widget.isDisabled && !widget.isLoading) {
      _animationController.forward();
    }
  }

  void _onTapUp(TapUpDetails details) {
    if (!widget.isDisabled && !widget.isLoading) {
      _animationController.reverse();
    }
  }

  void _onTapCancel() {
    if (!widget.isDisabled && !widget.isLoading) {
      _animationController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isEnabled =
        !widget.isDisabled && !widget.isLoading && widget.onPressed != null;

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: GestureDetector(
            onTapDown: _onTapDown,
            onTapUp: _onTapUp,
            onTapCancel: _onTapCancel,
            onTap: isEnabled ? widget.onPressed : null,
            child: Container(
              width: widget.width ?? _getButtonWidth(),
              height: widget.height ?? _getButtonHeight(),
              decoration: _getButtonDecoration(isDark, isEnabled),
              child: _buildButtonContent(isDark, isEnabled),
            ),
          ),
        );
      },
    );
  }

  double? _getButtonWidth() {
    if (widget.iconOnly) {
      return _getButtonHeight();
    }
    return null; // Let content determine width
  }

  double _getButtonHeight() {
    switch (widget.size) {
      case DynamicButtonSize.small:
        return 36.0;
      case DynamicButtonSize.medium:
        return 48.0;
      case DynamicButtonSize.large:
        return 56.0;
    }
  }

  EdgeInsetsGeometry _getButtonPadding() {
    if (widget.padding != null) return widget.padding!;

    if (widget.iconOnly) {
      return const EdgeInsets.all(12.0);
    }

    switch (widget.size) {
      case DynamicButtonSize.small:
        return const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0);
      case DynamicButtonSize.medium:
        return const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0);
      case DynamicButtonSize.large:
        return const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0);
    }
  }

  BorderRadius _getBorderRadius() {
    if (widget.borderRadius != null) return widget.borderRadius!;
    return BorderRadius.circular(24.0); // Round as per guidelines
  }

  BoxDecoration _getButtonDecoration(bool isDark, bool isEnabled) {
    final baseDecoration = BoxDecoration(
      borderRadius: _getBorderRadius(),
      boxShadow: isEnabled ? _getButtonShadow(isDark) : null,
    );

    switch (widget.type) {
      case DynamicButtonType.primary:
        return baseDecoration.copyWith(
          gradient: LinearGradient(
            colors: isEnabled
                ? [AppColors.primary, AppColors.primaryLight]
                : [AppColors.textSecondaryLight, AppColors.textSecondaryLight],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        );

      case DynamicButtonType.secondary:
        return baseDecoration.copyWith(
          color: Colors.transparent,
          border: Border.all(
            color: isEnabled ? AppColors.primary : AppColors.textSecondaryLight,
            width: 1.0,
          ),
        );

      case DynamicButtonType.text:
        return baseDecoration.copyWith(
          color: Colors.transparent,
        );

      case DynamicButtonType.danger:
        return baseDecoration.copyWith(
          gradient: LinearGradient(
            colors: isEnabled
                ? [AppColors.error, AppColors.errorLight]
                : [AppColors.textSecondaryLight, AppColors.textSecondaryLight],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        );

      case DynamicButtonType.success:
        return baseDecoration.copyWith(
          gradient: LinearGradient(
            colors: isEnabled
                ? [AppColors.success, AppColors.successLight]
                : [AppColors.textSecondaryLight, AppColors.textSecondaryLight],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        );
    }
  }

  List<BoxShadow> _getButtonShadow(bool isDark) {
    return [
      BoxShadow(
        color: isDark ? AppColors.shadowDark : AppColors.shadowLight,
        offset: const Offset(0, 2),
        blurRadius: 4.0,
        spreadRadius: 0.0,
      ),
    ];
  }

  Widget _buildButtonContent(bool isDark, bool isEnabled) {
    final textColor = _getTextColor(isDark, isEnabled);
    final textStyle = _getTextStyle().copyWith(color: textColor);

    return Padding(
      padding: _getButtonPadding(),
      child: widget.isLoading
          ? _buildLoadingIndicator(textColor)
          : Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (widget.icon != null && !widget.iconOnly) ...[
                  Icon(
                    widget.icon,
                    color: textColor,
                    size: _getIconSize(),
                  ),
                  const SizedBox(width: 8.0),
                ],
                if (!widget.iconOnly)
                  Text(
                    widget.label,
                    style: textStyle,
                    textAlign: TextAlign.center,
                  ),
                if (widget.icon != null && widget.iconOnly)
                  Icon(
                    widget.icon,
                    color: textColor,
                    size: _getIconSize(),
                  ),
              ],
            ),
    );
  }

  Widget _buildLoadingIndicator(Color color) {
    return SizedBox(
      width: _getIconSize(),
      height: _getIconSize(),
      child: CircularProgressIndicator(
        strokeWidth: 2.0,
        valueColor: AlwaysStoppedAnimation<Color>(color),
      ),
    );
  }

  double _getIconSize() {
    switch (widget.size) {
      case DynamicButtonSize.small:
        return 16.0;
      case DynamicButtonSize.medium:
        return 20.0;
      case DynamicButtonSize.large:
        return 24.0;
    }
  }

  Color _getTextColor(bool isDark, bool isEnabled) {
    if (!isEnabled) {
      return isDark
          ? AppColors.textSecondaryDark
          : AppColors.textSecondaryLight;
    }

    switch (widget.type) {
      case DynamicButtonType.primary:
      case DynamicButtonType.danger:
      case DynamicButtonType.success:
        return Colors.white;
      case DynamicButtonType.secondary:
      case DynamicButtonType.text:
        return AppColors.primary;
    }
  }

  TextStyle _getTextStyle() {
    switch (widget.size) {
      case DynamicButtonSize.small:
        return AppFonts.labelSmall;
      case DynamicButtonSize.medium:
        return AppFonts.labelMedium;
      case DynamicButtonSize.large:
        return AppFonts.labelLarge;
    }
  }
}
