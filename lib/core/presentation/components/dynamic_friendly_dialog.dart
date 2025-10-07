import 'package:flutter/material.dart';
import '../../constants/color_constant.dart';
import '../../constants/font_constant.dart';
import '../../constants/enum_constant.dart';
import 'dynamic_buttom.dart';

/// A comprehensive, mobile-friendly dialog component that follows the app's design system.
/// Supports various dialog types, sizes, and powerful customization options.
///
/// Usage Examples:
/// ```dart
/// // Simple info dialog
/// showDialog(
///   context: context,
///   builder: (context) => DynamicFriendlyDialog(
///     type: DialogType.info,
///     title: 'Information',
///     message: 'This is an informational message.',
///     onConfirm: () => Navigator.pop(context),
///   ),
/// );
///
/// // Confirmation dialog with custom actions
/// showDialog(
///   context: context,
///   builder: (context) => DynamicFriendlyDialog(
///     type: DialogType.confirmation,
///     title: 'Delete Note',
///     message: 'Are you sure you want to delete this note?',
///     confirmText: 'Delete',
///     cancelText: 'Cancel',
///     onConfirm: () => _deleteNote(),
///     onCancel: () => Navigator.pop(context),
///   ),
/// );
///
/// // Success dialog with loading
/// showDialog(
///   context: context,
///   builder: (context) => DynamicFriendlyDialog(
///     type: DialogType.success,
///     title: 'Note Saved',
///     message: 'Your note has been saved successfully.',
///     isLoading: false,
///     onConfirm: () => Navigator.pop(context),
///   ),
/// );
/// ```
class DynamicFriendlyDialog extends StatefulWidget {
  final DialogType type;
  final DialogSize size;
  final String? title;
  final String message;
  final Widget? customIcon;
  final String? confirmText;
  final String? cancelText;
  final String? neutralText;
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;
  final VoidCallback? onNeutral;
  final bool isLoading;
  final bool barrierDismissible;
  final Color? backgroundColor;
  final Color? textColor;
  final EdgeInsetsGeometry? contentPadding;
  final double? maxWidth;
  final double? maxHeight;
  final bool showCloseButton;
  final Widget? customContent;

  const DynamicFriendlyDialog({
    Key? key,
    this.type = DialogType.info,
    this.size = DialogSize.medium,
    this.title,
    required this.message,
    this.customIcon,
    this.confirmText,
    this.cancelText,
    this.neutralText,
    this.onConfirm,
    this.onCancel,
    this.onNeutral,
    this.isLoading = false,
    this.barrierDismissible = true,
    this.backgroundColor,
    this.textColor,
    this.contentPadding,
    this.maxWidth,
    this.maxHeight,
    this.showCloseButton = false,
    this.customContent,
  }) : super(key: key);

  @override
  State<DynamicFriendlyDialog> createState() => _DynamicFriendlyDialogState();

  /// Static method to show the dialog
  static Future<T?> show<T>({
    required BuildContext context,
    required String message,
    DialogType type = DialogType.info,
    DialogSize size = DialogSize.medium,
    String? title,
    Widget? customIcon,
    String? confirmText,
    String? cancelText,
    String? neutralText,
    VoidCallback? onConfirm,
    VoidCallback? onCancel,
    VoidCallback? onNeutral,
    bool isLoading = false,
    bool barrierDismissible = true,
    Color? backgroundColor,
    Color? textColor,
    EdgeInsetsGeometry? contentPadding,
    double? maxWidth,
    double? maxHeight,
    bool showCloseButton = false,
    Widget? customContent,
  }) {
    return showDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (context) => DynamicFriendlyDialog(
        type: type,
        size: size,
        title: title,
        message: message,
        customIcon: customIcon,
        confirmText: confirmText,
        cancelText: cancelText,
        neutralText: neutralText,
        onConfirm: onConfirm,
        onCancel: onCancel,
        onNeutral: onNeutral,
        isLoading: isLoading,
        barrierDismissible: barrierDismissible,
        backgroundColor: backgroundColor,
        textColor: textColor,
        contentPadding: contentPadding,
        maxWidth: maxWidth,
        maxHeight: maxHeight,
        showCloseButton: showCloseButton,
        customContent: customContent,
      ),
    );
  }
}

class _DynamicFriendlyDialogState extends State<DynamicFriendlyDialog>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Dialog(
              backgroundColor: Colors.transparent,
              elevation: 0,
              insetPadding: _getInsetPadding(),
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: widget.maxWidth ?? _getMaxWidth(),
                  maxHeight: widget.maxHeight ?? _getMaxHeight(),
                ),
                decoration: BoxDecoration(
                  color: widget.backgroundColor ??
                      (isDark ? AppColors.surfaceDark : AppColors.surfaceLight),
                  borderRadius: BorderRadius.circular(16.0),
                  boxShadow: [
                    BoxShadow(
                      color:
                          isDark ? AppColors.shadowDark : AppColors.shadowLight,
                      offset: const Offset(0, 8),
                      blurRadius: 16.0,
                      spreadRadius: 0.0,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (widget.showCloseButton) _buildCloseButton(),
                    Flexible(
                      child: SingleChildScrollView(
                        padding:
                            widget.contentPadding ?? const EdgeInsets.all(24.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _buildIcon(),
                            const SizedBox(height: 16.0),
                            if (widget.title != null) _buildTitle(isDark),
                            if (widget.title != null)
                              const SizedBox(height: 8.0),
                            _buildMessage(isDark),
                            if (widget.customContent != null) ...[
                              const SizedBox(height: 16.0),
                              widget.customContent!,
                            ],
                            const SizedBox(height: 24.0),
                            _buildActions(isDark),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  EdgeInsets _getInsetPadding() {
    switch (widget.size) {
      case DialogSize.small:
        return const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24.0);
      case DialogSize.medium:
        return const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0);
      case DialogSize.large:
        return const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0);
      case DialogSize.fullscreen:
        return EdgeInsets.zero;
    }
  }

  double _getMaxWidth() {
    switch (widget.size) {
      case DialogSize.small:
        return 280.0;
      case DialogSize.medium:
        return 360.0;
      case DialogSize.large:
        return 480.0;
      case DialogSize.fullscreen:
        return double.infinity;
    }
  }

  double _getMaxHeight() {
    switch (widget.size) {
      case DialogSize.small:
        return 200.0;
      case DialogSize.medium:
        return 300.0;
      case DialogSize.large:
        return 500.0;
      case DialogSize.fullscreen:
        return double.infinity;
    }
  }

  Widget _buildCloseButton() {
    return Align(
      alignment: Alignment.topRight,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: Icon(
            Icons.close,
            color: AppColors.textSecondaryLight,
            size: 20.0,
          ),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
      ),
    );
  }

  Widget _buildIcon() {
    if (widget.customIcon != null) {
      return widget.customIcon!;
    }

    final iconData = _getIconForType();
    final iconColor = _getIconColor();

    return Container(
      width: 64.0,
      height: 64.0,
      decoration: BoxDecoration(
        color: iconColor.withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(
        iconData,
        color: iconColor,
        size: 32.0,
      ),
    );
  }

  IconData _getIconForType() {
    switch (widget.type) {
      case DialogType.info:
        return Icons.info_outline;
      case DialogType.success:
        return Icons.check_circle_outline;
      case DialogType.warning:
        return Icons.warning_amber_outlined;
      case DialogType.error:
        return Icons.error_outline;
      case DialogType.confirmation:
        return Icons.help_outline;
      case DialogType.custom:
        return Icons.info_outline;
    }
  }

  Color _getIconColor() {
    switch (widget.type) {
      case DialogType.info:
        return AppColors.primary;
      case DialogType.success:
        return AppColors.success;
      case DialogType.warning:
        return AppColors.warning;
      case DialogType.error:
        return AppColors.error;
      case DialogType.confirmation:
        return AppColors.accent;
      case DialogType.custom:
        return AppColors.primary;
    }
  }

  Widget _buildTitle(bool isDark) {
    return Text(
      widget.title!,
      style: AppFonts.heading4.copyWith(
        color: widget.textColor ??
            (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight),
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildMessage(bool isDark) {
    return Text(
      widget.message,
      style: AppFonts.bodyMedium.copyWith(
        color: widget.textColor ??
            (isDark
                ? AppColors.textSecondaryDark
                : AppColors.textSecondaryLight),
        height: 1.5,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildActions(bool isDark) {
    final actions = <Widget>[];

    // Neutral button (usually on the left)
    if (widget.neutralText != null && widget.onNeutral != null) {
      actions.add(
        Expanded(
          child: DynamicButton(
            label: widget.neutralText!,
            type: DynamicButtonType.text,
            onPressed: widget.onNeutral,
          ),
        ),
      );
      actions.add(const SizedBox(width: 8.0));
    }

    // Cancel button
    if (widget.cancelText != null && widget.onCancel != null) {
      actions.add(
        Expanded(
          child: DynamicButton(
            label: widget.cancelText!,
            type: DynamicButtonType.secondary,
            onPressed: widget.onCancel,
          ),
        ),
      );
      actions.add(const SizedBox(width: 8.0));
    }

    // Confirm button (usually on the right, primary action)
    if (widget.confirmText != null && widget.onConfirm != null) {
      final buttonType = widget.type == DialogType.error
          ? DynamicButtonType.danger
          : widget.type == DialogType.success
              ? DynamicButtonType.success
              : DynamicButtonType.primary;

      actions.add(
        Expanded(
          child: DynamicButton(
            label: widget.confirmText!,
            type: buttonType,
            isLoading: widget.isLoading,
            onPressed: widget.onConfirm,
          ),
        ),
      );
    }

    // If no custom buttons provided, show default "OK" button
    if (actions.isEmpty && widget.onConfirm == null) {
      actions.add(
        SizedBox(
          width: double.infinity,
          child: DynamicButton(
            label: 'OK',
            type: DynamicButtonType.primary,
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: actions,
    );
  }
}
