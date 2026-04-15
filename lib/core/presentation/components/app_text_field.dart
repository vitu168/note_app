import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:note_app/core/theme/app_context_ext.dart';

/// A minimal, customisable text field with clean spacing.
///
/// Features:
/// - Borderless, clean aesthetic
/// - Subtle internal padding
/// - Optional label
/// - No background container — pure text input
///
/// Example:
/// ```dart
/// AppTextField(
///   controller: _titleController,
///   hint: 'Note title',
///   fontSize: 22,
///   fontWeight: FontWeight.w700,
///   maxLines: null,
/// )
/// ```
class AppTextField extends StatelessWidget {
  /// Optional small label displayed above the field.
  final String? label;

  /// Placeholder text shown when the field is empty.
  final String hint;

  final TextEditingController? controller;
  final FocusNode? focusNode;

  // ── Text style ────────────────────────────────────────────────────────────
  final double fontSize;
  final FontWeight fontWeight;
  final Color? color;
  final Color? hintColor;
  final double lineHeight;

  // ── Behaviour ─────────────────────────────────────────────────────────────
  final int? maxLines;
  final int? minLines;
  final TextInputType keyboardType;
  final TextInputAction? textInputAction;
  final TextCapitalization textCapitalization;
  final List<TextInputFormatter>? inputFormatters;
  final bool autofocus;
  final bool readOnly;
  final bool enabled;
  final bool obscureText;

  // ── Decorations ───────────────────────────────────────────────────────────
  final Widget? prefixIcon;
  final Widget? suffixIcon;

  /// Internal padding. Defaults to 0.
  final EdgeInsetsGeometry contentPadding;

  // ── Callbacks ─────────────────────────────────────────────────────────────
  final ValueChanged<String>? onChanged;
  final VoidCallback? onTap;
  final VoidCallback? onEditingComplete;

  const AppTextField({
    super.key,
    required this.hint,
    this.label,
    this.controller,
    this.focusNode,
    this.fontSize = 15,
    this.fontWeight = FontWeight.w400,
    this.color,
    this.hintColor,
    this.lineHeight = 1.6,
    this.maxLines = 1,
    this.minLines,
    this.keyboardType = TextInputType.text,
    this.textInputAction,
    this.textCapitalization = TextCapitalization.sentences,
    this.inputFormatters,
    this.autofocus = false,
    this.readOnly = false,
    this.enabled = true,
    this.obscureText = false,
    this.prefixIcon,
    this.suffixIcon,
    this.contentPadding = EdgeInsets.zero,
    this.onChanged,
    this.onTap,
    this.onEditingComplete,
  });

  @override
  Widget build(BuildContext context) {
    final t = context.appTheme;
    final resolvedColor = color ?? t.bodyText;
    final resolvedHint = hintColor ?? t.hintText.withValues(alpha: 0.45);

    final textStyle = GoogleFonts.poppins(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: resolvedColor,
      height: lineHeight,
    );

    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(
        color: t.divider.withValues(alpha: 0.35),
        width: 1,
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: GoogleFonts.poppins(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
              color: t.hintText,
            ),
          ),
          const SizedBox(height: 8),
        ],
        TextField(
          controller: controller,
          focusNode: focusNode,
          style: textStyle,
          maxLines: maxLines,
          minLines: minLines,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          textCapitalization: textCapitalization,
          inputFormatters: inputFormatters,
          autofocus: autofocus,
          readOnly: readOnly,
          enabled: enabled,
          obscureText: obscureText,
          onChanged: onChanged,
          onTap: onTap,
          onEditingComplete: onEditingComplete,
          decoration: InputDecoration(
            filled: true,
            fillColor: t.surface,
            border: border,
            enabledBorder: border,
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: t.primary.withValues(alpha: 0.45), width: 1.5),
            ),
            errorBorder: border,
            disabledBorder: border,
            hintText: hint,
            hintStyle: textStyle.copyWith(color: resolvedHint),
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            prefixIcon: prefixIcon,
            prefixIconConstraints:
                prefixIcon != null ? const BoxConstraints() : null,
            suffixIcon: suffixIcon,
            suffixIconConstraints:
                suffixIcon != null ? const BoxConstraints() : null,
          ),
        ),
      ],
    );
  }
}
