import 'package:flutter/material.dart';
import 'package:note_app/core/presentation/components/toast.dart';

void showToast(BuildContext context, String message, {Duration duration = const Duration(seconds: 3), ToastType type = ToastType.info, Color? backgroundColor, Color? textColor, IconData? icon, bool withHaptic = true}) {
  Toast.show(
    context,
    message,
    type: type,
    duration: duration,
    backgroundColor: backgroundColor,
    textColor: textColor,
    icon: icon,
    withHaptic: withHaptic,
  );
}
