import 'package:flutter/widgets.dart';
import 'package:note_app/core/constants/properties_constant.dart';
class ItemGap extends StatelessWidget {
  final double? height;
  final double? width;

  const ItemGap({Key? key, this.height, this.width}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height ?? (width == null ? AppDimensions.spacing : null),
      width: width ?? (height == null ? AppDimensions.spacing : null),
    );
  }
}

Widget itemGap({double? height, double? width}) => ItemGap(height: height, width: width);
