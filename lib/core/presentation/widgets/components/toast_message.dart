import 'package:flutter/material.dart';
import 'package:note_app/core/constants/color_constant.dart';
import 'package:note_app/core/constants/font_constant.dart';
import 'package:note_app/core/constants/properties_constant.dart';

class ToastMessage extends StatelessWidget{
  final String message;
  final Color backgroundColor;
  final Color textColor;

  const ToastMessage({
    super.key,
    required this.message,
    this.backgroundColor = AppColors.primary,
    this.textColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppDimensions.paddingAll,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(AppDimensions.radius),
      ),
      child: Text(
        message,
        style: AppFonts.bodyMedium.copyWith(color: textColor),
        textAlign: TextAlign.center,
      ),
    );
  }
}