import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:note_app/core/constants/properties_constant.dart';
import 'package:note_app/core/presentation/components/item_gap.dart';

class FormTextInput extends StatefulWidget {
  final String? label;
  final TextEditingController? controller;
  final String? initialValue;

  final ValueChanged<String>? onChanged;
  final FormFieldValidator<String>? validator;

  final TextInputType keyboardType;
  final TextInputAction? textInputAction;
  final int maxLines;
  final int? maxLength;
  final bool obscureText;
  final bool readOnly;
  final bool enabled;
  final bool showClearButton;
  final bool autofocus;
  final List<TextInputFormatter>? inputFormatters;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final InputDecoration? decoration;
  final bool expands;
  final AutovalidateMode? autovalidateMode;
  final EdgeInsetsGeometry contentPadding;
  final String? hintText;

  const FormTextInput({
    super.key,
    this.label,
    this.controller,
    this.initialValue,
    this.onChanged,
    this.validator,
    this.keyboardType = TextInputType.text,
    this.textInputAction,
    this.maxLines = 1,
    this.maxLength,
    this.obscureText = false,
    this.readOnly = false,
    this.enabled = true,
    this.showClearButton = true,
    this.autofocus = false,
    this.inputFormatters,
    this.prefixIcon,
    this.suffixIcon,
    this.decoration,
    this.expands = false,
    this.autovalidateMode,
    this.contentPadding = AppDimensions.paddingAllSmall,
    this.hintText,
  });

  @override
  State<FormTextInput> createState() => _FormTextInputState();
}

class _FormTextInputState extends State<FormTextInput> {
  late TextEditingController _effectiveController;
  late bool _controllerWasProvided;
  late bool _obscure;

  @override
  void initState() {
    super.initState();
    _controllerWasProvided = widget.controller != null;
    _effectiveController = widget.controller ?? TextEditingController(text: widget.initialValue ?? '');
    _obscure = widget.obscureText;
    _effectiveController.addListener(_onControllerChanged);
  }

  void _onControllerChanged() {
    if (mounted) setState(() {});
  }

  @override
  void didUpdateWidget(covariant FormTextInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller?.removeListener(_onControllerChanged);
      if (!_controllerWasProvided && widget.controller != null) {
        _effectiveController.dispose();
      }
      _controllerWasProvided = widget.controller != null;
      _effectiveController = widget.controller ?? TextEditingController(text: widget.initialValue ?? '');
      _effectiveController.addListener(_onControllerChanged);
    }
    if (oldWidget.obscureText != widget.obscureText) {
      _obscure = widget.obscureText;
    }
  }

  @override
  void dispose() {
    _effectiveController.removeListener(_onControllerChanged);
    if (!_controllerWasProvided) {
      _effectiveController.dispose();
    }
    super.dispose();
  }

  Widget? _buildSuffix(BuildContext context) {
    final theme = Theme.of(context);
    final hasText = _effectiveController.text.isNotEmpty;
    final List<Widget> actions = [];

    if (widget.showClearButton && hasText && !widget.readOnly && widget.enabled) {
      actions.add(IconButton(
        padding: EdgeInsets.all(AppDimensions.spacingXSmall),
        constraints: const BoxConstraints(),
        tooltip: 'Clear',
        icon: Icon(Icons.close, size: AppDimensions.iconSmall, color: theme.iconTheme.color),
        onPressed: () {
          _effectiveController.clear();
          widget.onChanged?.call('');
        },
      ));
    }

    if (widget.obscureText) {
      actions.add(IconButton(
        padding: EdgeInsets.all(AppDimensions.spacingXSmall),
        constraints: const BoxConstraints(),
        tooltip: _obscure ? 'Show' : 'Hide',
        icon: Icon(_obscure ? Icons.visibility : Icons.visibility_off, size: AppDimensions.iconSmall, color: theme.iconTheme.color),
        onPressed: () => setState(() => _obscure = !_obscure),
      ));
    }

    if (widget.suffixIcon != null) actions.add(widget.suffixIcon!);

    if (actions.isEmpty) return null;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: actions,
    );
  }

  InputDecoration _effectiveDecoration(BuildContext context) {
    final theme = Theme.of(context);
    final base = widget.decoration ?? InputDecoration(
      filled: true,
      fillColor: theme.inputDecorationTheme.fillColor,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radius),
        borderSide: BorderSide.none,
      ),
      contentPadding: widget.contentPadding,
    );

    return base.copyWith(
      prefixIcon: widget.prefixIcon != null ? Padding(padding: const EdgeInsets.only(left: 8, right: 8), child: widget.prefixIcon) : null,
      suffixIcon: _buildSuffix(context),
      counterText: widget.maxLength == null ? null : null,
      hintText: widget.hintText,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null) Text(
          widget.label!,
          style: GoogleFonts.poppins(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.w500,
            fontSize: AppDimensions.textMedium,
          ),
        ),
        itemGap(),
        TextFormField(
          controller: _effectiveController,
          onChanged: (v) => widget.onChanged?.call(v),
          validator: widget.validator,
          keyboardType: widget.keyboardType,
          textInputAction: widget.textInputAction,
          maxLines: widget.obscureText ? 1 : widget.maxLines,
          obscureText: _obscure,
          maxLength: widget.maxLength,
          readOnly: widget.readOnly,
          enabled: widget.enabled,
          inputFormatters: widget.inputFormatters,
          expands: widget.expands,
          autofocus: widget.autofocus,
          autovalidateMode: widget.autovalidateMode,
          style: GoogleFonts.poppins(
            color: theme.textTheme.bodyMedium?.color,
          ),
          decoration: _effectiveDecoration(context),
          buildCounter: (
            BuildContext context, {
            required int currentLength,
            required bool isFocused,
            required int? maxLength,
          }) {
            if (maxLength == null) return null;
            return Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                '$currentLength / $maxLength',
                style: theme.textTheme.bodySmall,
              ),
            );
          },
        ),
      ],
    );
  }
}
