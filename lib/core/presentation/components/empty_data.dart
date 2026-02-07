import 'package:flutter/material.dart';
import 'package:note_app/core/constants/color_constant.dart';
import 'package:note_app/core/constants/font_constant.dart';
import 'package:note_app/core/constants/properties_constant.dart';
import 'package:note_app/core/presentation/components/item_gap.dart';
class EmptyData extends StatelessWidget {
  final String message;

  const EmptyData({super.key, this.message = 'No data available'});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inbox,
            size: AppDimensions.iconLarge * 2,
            color: AppColors.primary.withValues(alpha: 0.5),
          ),
          itemGap(height: 16),
          Text(
            message,
            style: AppFonts.bodyMedium.copyWith(color: AppColors.primary.withValues(alpha:0.5)),
          ),
        ],
      ),
    );
  }
}