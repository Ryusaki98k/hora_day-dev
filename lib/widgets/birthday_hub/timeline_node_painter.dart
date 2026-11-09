import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';

/// High-performance timeline connector that eliminates IntrinsicHeight double-layout passes
class TimelineNodePainter extends CustomPainter {
  final bool isFirst;
  final bool isLast;
  final bool isToday;
  final Color dayColor;
  final bool isDark;

  const TimelineNodePainter({
    required this.isFirst,
    required this.isLast,
    required this.isToday,
    required this.dayColor,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const centerX = 18.0;
    const nodeY = 21.0;
    const nodeRadius = 7.0;

    final linePaint = Paint()
      ..color = isToday
          ? AppColors.amberGold
          : (isDark ? const Color(0xFF334155) : const Color(0xFFEBE5DC))
      ..strokeWidth = 2.0;

    if (!isFirst) {
      canvas.drawLine(const Offset(centerX, 0), const Offset(centerX, nodeY), linePaint);
    }
    if (!isLast) {
      canvas.drawLine(const Offset(centerX, nodeY), Offset(centerX, size.height), linePaint);
    }

    final glowPaint = Paint()
      ..color = (isToday ? const Color(0xFFDC2626) : dayColor).withValues(alpha: 0.35);
    canvas.drawCircle(const Offset(centerX, nodeY), nodeRadius + 2.0, glowPaint);

    final nodePaint = Paint()
      ..color = isToday ? const Color(0xFFDC2626) : dayColor
      ..style = PaintingStyle.fill;
    canvas.drawCircle(const Offset(centerX, nodeY), nodeRadius, nodePaint);

    final borderPaint = Paint()
      ..color = isDark ? const Color(0xFF0F172A) : Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;
    canvas.drawCircle(const Offset(centerX, nodeY), nodeRadius, borderPaint);
  }

  @override
  bool shouldRepaint(covariant TimelineNodePainter oldDelegate) =>
      oldDelegate.isFirst != isFirst ||
      oldDelegate.isLast != isLast ||
      oldDelegate.isToday != isToday ||
      oldDelegate.dayColor != dayColor ||
      oldDelegate.isDark != isDark;
}
