import 'package:flutter/material.dart'; 
import 'package:note_app/core/constants/color_constant.dart';
import 'package:note_app/core/constants/font_constant.dart';

class DropdownItem extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const DropdownItem({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withValues(alpha: 0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: AppFonts.bodyMedium.copyWith(
            color: isSelected ? AppColors.primary : AppColors.primaryLight,
          ),
        ),
      ),
    );
  }
}
