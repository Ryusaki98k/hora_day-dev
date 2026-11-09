import 'package:flutter/material.dart';
import '../../models/card_theme_style.dart';

/// ลายน้ำมงคลพื้นหลังการ์ด
class CardAuspiciousBackgroundPainter extends CustomPainter {
  final CardThemeStyle style;

  CardAuspiciousBackgroundPainter({required this.style});

  @override
  void paint(Canvas canvas, Size size) {
    final isDarkStyle = style == CardThemeStyle.midnightCosmic ||
        style == CardThemeStyle.midnightCosmic2 ||
        style == CardThemeStyle.midnightCosmic3 ||
        style == CardThemeStyle.rubyFortune ||
        style == CardThemeStyle.emeraldPeace ||
        style == CardThemeStyle.emeraldPeace2 ||
        style == CardThemeStyle.emeraldPeace3;

    final arcPaint = Paint()
      ..color = isDarkStyle
          ? Colors.white.withValues(alpha: 0.05)
          : const Color(0xFFB45309).withValues(alpha: 0.05)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    // เส้นวงโคจรดวงดาวมงคล
    canvas.drawCircle(Offset(size.width * 0.5, size.height * 0.15), size.width * 0.45, arcPaint);
    canvas.drawCircle(Offset(size.width * 0.5, size.height * 0.15), size.width * 0.65, arcPaint);
    canvas.drawCircle(Offset(size.width * 0.5, size.height * 0.85), size.width * 0.5, arcPaint);

    // ประกายดาว 4 มุม
    final starPaint = Paint()
      ..color = isDarkStyle
          ? Colors.white.withValues(alpha: 0.15)
          : const Color(0xFFD4AF37).withValues(alpha: 0.3)
      ..style = PaintingStyle.fill;

    _drawTinyStar(canvas, const Offset(24, 24), starPaint);
    _drawTinyStar(canvas, Offset(size.width - 24, 24), starPaint);
    _drawTinyStar(canvas, Offset(24, size.height - 24), starPaint);
    _drawTinyStar(canvas, Offset(size.width - 24, size.height - 24), starPaint);
  }

  void _drawTinyStar(Canvas canvas, Offset center, Paint paint) {
    canvas.drawCircle(center, 1.8, paint);
  }

  @override
  bool shouldRepaint(covariant CardAuspiciousBackgroundPainter oldDelegate) =>
      oldDelegate.style != style;
}
