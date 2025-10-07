import 'dart:ui';
import 'package:flutter/material.dart';
import '../../constants/color_constant.dart';

/// A beautiful, friendly animated cycle line loading widget
/// Uses app primary/secondary colors and smooth animation
class LoadingAnimation extends StatefulWidget {
  final double size;
  final double lineWidth;
  final Color? color;
  final Color? backgroundColor;
  final Duration duration;

  const LoadingAnimation({
    Key? key,
    this.size = 48.0,
    this.lineWidth = 4.0,
    this.color,
    this.backgroundColor,
    this.duration = const Duration(milliseconds: 1200),
  }) : super(key: key);

  @override
  State<LoadingAnimation> createState() => _LoadingAnimationState();
}

class _LoadingAnimationState extends State<LoadingAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.color ?? AppColors.primary;
    final bgColor =
        widget.backgroundColor ?? AppColors.primaryLight.withOpacity(0.12);
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return CustomPaint(
            painter: _CycleLinePainter(
              progress: _controller.value,
              color: color,
              backgroundColor: bgColor,
              lineWidth: widget.lineWidth,
            ),
          );
        },
      ),
    );
  }
}

class _CycleLinePainter extends CustomPainter {
  final double progress;
  final Color color;
  final Color backgroundColor;
  final double lineWidth;

  _CycleLinePainter({
    required this.progress,
    required this.color,
    required this.backgroundColor,
    required this.lineWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - lineWidth) / 2;

    // Draw background circle
    final bgPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = lineWidth;
    canvas.drawCircle(center, radius, bgPaint);

    // Draw animated arc
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = lineWidth;

    // Animate arc sweep and start angle for a friendly effect
    final sweep = lerpDouble(
            0.25, 0.85, (progress < 0.5 ? progress * 2 : (1 - progress) * 2))! *
        2 *
        3.1415926;
    final startAngle = 2 * 3.1415926 * progress;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweep,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _CycleLinePainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.color != color ||
        oldDelegate.backgroundColor != backgroundColor ||
        oldDelegate.lineWidth != lineWidth;
  }
}
