import 'package:flutter/material.dart';
import 'package:note_app/core/constants/color_constant.dart';
import 'package:note_app/core/constants/font_constant.dart';
import 'package:note_app/core/presentation/components/item_gap.dart';
import 'package:note_app/core/presentation/components/form_text_input.dart';

class DropdownItemSearch extends StatelessWidget{
  final String? label;
  final TextEditingController? controller;
  final String? hintText;
  final ValueChanged<String>? onChanged;

  const DropdownItemSearch({
    super.key,
    this.label,
    this.controller,
    this.hintText,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: AppFonts.bodyMedium.copyWith(color: AppColors.primary),
          ),
          itemGap(height: 8),
        ],
        FormTextInput(
          controller: controller,
          onChanged: onChanged,
          hintText: hintText,
          prefixIcon: const Icon(Icons.search, size: 20),
        ),
      ],
    );
  }
}

      