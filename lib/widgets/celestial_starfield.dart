import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

/// ข้อมูลพิกัดและคุณสมบัติของดวงดาวบนฟากฟ้า
class _StarPoint {
  final double x; // 0.0 .. 1.0
  final double y; // 0.0 .. 1.0
  final double size;
  final double frequency;
  final double phase;
  final bool isSparkle;

  const _StarPoint(
    this.x,
    this.y,
    this.size,
    this.frequency,
    this.phase, {
    this.isSparkle = false,
  });
}

/// วิดเจ็ตพื้นหลังท้องฟ้าจักรราศีและดวงดาวระยิบระยับ พร้อมแอนิเมชันดาวตก (Shooting Stars)
/// ออกแบบมาเพื่อสร้างบรรยากาศอันน่าอัศจรรย์และสงบงาม สไตล์ Warm Zen & Deep Celestial Sanctuary
class CelestialStarfield extends StatefulWidget {
  final bool isDark;
  final Widget? child;

  const CelestialStarfield({
    super.key,
    required this.isDark,
    this.child,
  });

  @override
  State<CelestialStarfield> createState() => _CelestialStarfieldState();
}

class _CelestialStarfieldState extends State<CelestialStarfield>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late final AnimationController _controller;

  // ตำแหน่งกลุ่มดวงดาวมงคลบนท้องฟ้า (24 ดวง พร้อมดาวประกาย 4 แฉก)
  static const List<_StarPoint> _stars = [
    // ดวงดาวประกาย 4 แฉก (Sparkle Stars)
    _StarPoint(0.12, 0.24, 3.4, 1.2, 0.0, isSparkle: true),
    _StarPoint(0.52, 0.16, 2.8, 1.5, 1.8, isSparkle: true),
    _StarPoint(0.84, 0.30, 3.6, 1.1, 3.2, isSparkle: true),
    _StarPoint(0.70, 0.76, 2.6, 1.4, 4.5, isSparkle: true),

    // ดวงดาวระยิบระยับแบบกลมมน (Twinkling Points)
    _StarPoint(0.06, 0.48, 1.4, 2.2, 0.6),
    _StarPoint(0.18, 0.65, 1.8, 1.7, 2.1),
    _StarPoint(0.24, 0.14, 1.2, 2.8, 4.0),
    _StarPoint(0.32, 0.40, 1.6, 1.5, 1.2),
    _StarPoint(0.38, 0.84, 1.3, 2.4, 5.1),
    _StarPoint(0.44, 0.32, 1.4, 1.9, 3.4),
    _StarPoint(0.60, 0.22, 1.7, 2.2, 0.8),
    _StarPoint(0.66, 0.54, 1.2, 2.6, 2.7),
    _StarPoint(0.78, 0.15, 2.0, 1.3, 4.8),
    _StarPoint(0.82, 0.66, 1.4, 2.0, 1.6),
    _StarPoint(0.92, 0.22, 1.6, 1.8, 3.9),
    _StarPoint(0.94, 0.60, 1.3, 2.5, 0.3),
    _StarPoint(0.15, 0.88, 1.2, 1.6, 2.9),
    _StarPoint(0.28, 0.72, 1.5, 2.3, 4.4),
    _StarPoint(0.36, 0.20, 1.3, 2.0, 1.9),
    _StarPoint(0.54, 0.78, 1.5, 2.1, 5.6),
    _StarPoint(0.64, 0.92, 1.2, 1.8, 3.1),
    _StarPoint(0.88, 0.82, 1.5, 2.7, 0.9),
    _StarPoint(0.04, 0.75, 1.1, 1.9, 2.4),
    _StarPoint(0.76, 0.42, 1.3, 2.2, 4.2),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // ลูปแอนิเมชันความยาว 8 วินาที วนซ้ำอย่างราบรื่น
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      if (!_controller.isAnimating) {
        _controller.repeat();
      }
    } else if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.hidden) {
      if (_controller.isAnimating) {
        _controller.stop(canceled: false);
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final disableAnimations = MediaQuery.of(context).disableAnimations;

    final painter = RepaintBoundary(
      child: CustomPaint(
        painter: _CelestialStarfieldPainter(
          animation: _controller,
          isDark: widget.isDark,
          stars: _stars,
          disableAnimations: disableAnimations,
        ),
        child: widget.child,
      ),
    );

    return painter;
  }
}

class _CelestialStarfieldPainter extends CustomPainter {
  final Animation<double> animation;
  final bool isDark;
  final List<_StarPoint> stars;
  final bool disableAnimations;

  _CelestialStarfieldPainter({
    required this.animation,
    required this.isDark,
    required this.stars,
    required this.disableAnimations,
  }) : super(repaint: disableAnimations ? null : animation);

  @override
  void paint(Canvas canvas, Size size) {
    final t = disableAnimations ? 0.25 : animation.value;

    // 1. Soft Warm Amber / Astral Gold Glow at top-right
    _drawAmbientGlow(canvas, size);

    // 2. Celestial Astrolabe Meridian Arcs (วงโคจรดวงดาวและเส้นเมอริเดียนดวงชะตา)
    _drawAstrolabeMeridians(canvas, size);

    // 3. Twinkling & Sparkling Stars (ดวงดาวระยิบระยับ)
    _drawStars(canvas, size, t);

    // 4. Shooting Stars / Meteors (แอนิเมชันดาวตก)
    if (!disableAnimations) {
      _drawShootingStars(canvas, size, t);
    }
  }

  void _drawAmbientGlow(Canvas canvas, Size size) {
    final glowCenter = Offset(size.width * 0.82, size.height * 0.22);
    final glowRadius = size.width * 0.52;

    final glowPaint = Paint()
      ..shader = RadialGradient(
        colors: isDark
            ? [
                AppColors.starGold.withValues(alpha: 0.18),
                AppColors.celestialAmber.withValues(alpha: 0.08),
                Colors.transparent,
              ]
            : [
                AppColors.amberGold.withValues(alpha: 0.10),
                AppColors.champagne.withValues(alpha: 0.04),
                Colors.transparent,
              ],
        stops: const [0.0, 0.55, 1.0],
      ).createShader(
        Rect.fromCircle(center: glowCenter, radius: glowRadius),
      );

    canvas.drawCircle(glowCenter, glowRadius, glowPaint);
  }

  void _drawAstrolabeMeridians(Canvas canvas, Size size) {
    final arcPaint = Paint()
      ..color = isDark
          ? AppColors.starGold.withValues(alpha: 0.18)
          : AppColors.amberGold.withValues(alpha: 0.08)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final centerArc = Offset(size.width * 0.96, -size.height * 0.15);
    canvas.drawCircle(centerArc, size.width * 0.45, arcPaint);
    canvas.drawCircle(centerArc, size.width * 0.68, arcPaint);
    canvas.drawCircle(centerArc, size.width * 0.92, arcPaint);
  }

  void _drawStars(Canvas canvas, Size size, double t) {
    final primaryStarColor = isDark ? AppColors.starGold : AppColors.caramelBronze;
    final brightStarColor = isDark ? const Color(0xFFFFFBEB) : AppColors.amberGold;

    for (final star in stars) {
      final center = Offset(star.x * size.width, star.y * size.height);

      // คำนวณความสว่างระยิบระยับด้วย sine wave แต่ละดวงมี phase & frequency ต่างกัน
      final wave = math.sin((t * 2 * math.pi * star.frequency) + star.phase);
      final normalizedWave = (wave * 0.5) + 0.5; // 0.0 .. 1.0
      final alpha = (0.20 + (0.75 * normalizedWave)).clamp(0.0, 1.0);

      if (star.isSparkle) {
        // ดาวประกาย 4 แฉก (Sparkle Star ✦)
        final sparkleScale = 0.75 + (0.45 * normalizedWave);
        final currentSize = star.size * sparkleScale;

        // รัศมีแสงเรืองรอง (Aura Glow แบบ Alpha Concurrency สำหรับ GPU Mobile)
        final outerHaloPaint = Paint()
          ..color = primaryStarColor.withValues(alpha: 0.14 * alpha)
          ..style = PaintingStyle.fill;
        canvas.drawCircle(center, currentSize * 1.8, outerHaloPaint);

        final innerHaloPaint = Paint()
          ..color = primaryStarColor.withValues(alpha: 0.28 * alpha)
          ..style = PaintingStyle.fill;
        canvas.drawCircle(center, currentSize * 1.25, innerHaloPaint);

        // วาดตัวดาว 4 แฉกแบบโค้งรับแสง
        final starPaint = Paint()
          ..color = brightStarColor.withValues(alpha: alpha)
          ..style = PaintingStyle.fill;

        final path = Path();
        path.moveTo(center.dx, center.dy - currentSize);
        path.quadraticBezierTo(center.dx, center.dy, center.dx + currentSize, center.dy);
        path.quadraticBezierTo(center.dx, center.dy, center.dx, center.dy + currentSize);
        path.quadraticBezierTo(center.dx, center.dy, center.dx - currentSize, center.dy);
        path.quadraticBezierTo(center.dx, center.dy, center.dx, center.dy - currentSize);
        path.close();

        canvas.drawPath(path, starPaint);

        // แกนแสงจุดศูนย์กลางสีขาวสว่าง
        canvas.drawCircle(
          center,
          currentSize * 0.25,
          Paint()..color = Colors.white.withValues(alpha: 0.9 * alpha),
        );
      } else {
        // ดวงดาวกลมมนปกติ (Twinkling Dot)
        final currentRadius = star.size * (0.80 + (0.25 * normalizedWave));

        if (normalizedWave > 0.65) {
          final glowPaint = Paint()
            ..color = primaryStarColor.withValues(alpha: 0.16 * alpha)
            ..style = PaintingStyle.fill;
          canvas.drawCircle(center, currentRadius * 1.8, glowPaint);
        }

        final dotPaint = Paint()
          ..color = (normalizedWave > 0.75 ? brightStarColor : primaryStarColor)
              .withValues(alpha: alpha)
          ..style = PaintingStyle.fill;

        canvas.drawCircle(center, currentRadius, dotPaint);
      }
    }
  }

  void _drawShootingStars(Canvas canvas, Size size, double t) {
    // -------------------------------------------------------------------------
    // ดาวตกดวงที่ 1 (Primary Meteor): พุ่งจากมุมขวาบนลงซ้ายล่าง ช่วงเวลา t = 0.08 .. 0.26
    // -------------------------------------------------------------------------
    const m1Start = 0.08;
    const m1End = 0.26;
    if (t >= m1Start && t <= m1End) {
      final progress = (t - m1Start) / (m1End - m1Start); // 0.0 .. 1.0

      final startPos = Offset(size.width * 1.04, size.height * -0.04);
      final endPos = Offset(size.width * 0.18, size.height * 0.88);

      final headPos = Offset.lerp(startPos, endPos, progress)!;
      final angle = math.atan2(endPos.dy - startPos.dy, endPos.dx - startPos.dx);
      final tailLength = size.width * 0.28;

      // การเฟดเข้า-ออก เพื่อให้การพุ่งดูเป็นธรรมชาติ
      final opacity = _calculateMeteorOpacity(progress);

      _paintMeteor(
        canvas: canvas,
        headPos: headPos,
        angle: angle,
        tailLength: tailLength,
        opacity: opacity,
        headRadius: 2.2,
      );
    }

    // -------------------------------------------------------------------------
    // ดาวตกดวงที่ 2 (Secondary Meteor): พุ่งพริ้วผ่านฝั่งซ้ายบน ช่วงเวลา t = 0.56 .. 0.72
    // -------------------------------------------------------------------------
    const m2Start = 0.56;
    const m2End = 0.72;
    if (t >= m2Start && t <= m2End) {
      final progress = (t - m2Start) / (m2End - m2Start); // 0.0 .. 1.0

      final startPos = Offset(size.width * 0.60, size.height * -0.05);
      final endPos = Offset(size.width * -0.06, size.height * 0.62);

      final headPos = Offset.lerp(startPos, endPos, progress)!;
      final angle = math.atan2(endPos.dy - startPos.dy, endPos.dx - startPos.dx);
      final tailLength = size.width * 0.22;

      final opacity = _calculateMeteorOpacity(progress);

      _paintMeteor(
        canvas: canvas,
        headPos: headPos,
        angle: angle,
        tailLength: tailLength,
        opacity: opacity * 0.85,
        headRadius: 1.8,
      );
    }
  }

  double _calculateMeteorOpacity(double progress) {
    if (progress < 0.18) {
      return progress / 0.18;
    } else if (progress > 0.75) {
      return (1.0 - progress) / 0.25;
    }
    return 1.0;
  }

  void _paintMeteor({
    required Canvas canvas,
    required Offset headPos,
    required double angle,
    required double tailLength,
    required double opacity,
    required double headRadius,
  }) {
    final tailEnd = Offset(
      headPos.dx - math.cos(angle) * tailLength,
      headPos.dy - math.sin(angle) * tailLength,
    );

    final trailBaseColor = isDark ? AppColors.starGold : AppColors.caramelBronze;
    final headGlowColor = isDark ? const Color(0xFFFDE047) : AppColors.amberGold;

    // 1. หางแสงฟุ้งบางเบาชั้นนอก (Outer Trail Glow)
    final outerTrailPaint = Paint()
      ..shader = ui.Gradient.linear(
        tailEnd,
        headPos,
        [
          Colors.transparent,
          trailBaseColor.withValues(alpha: 0.08 * opacity),
          headGlowColor.withValues(alpha: 0.35 * opacity),
        ],
        const [0.0, 0.6, 1.0],
      )
      ..strokeWidth = 4.5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    canvas.drawLine(tailEnd, headPos, outerTrailPaint);

    // 2. ลำแสงหางดาวตกคมชัดตรงกลาง (Core Trail Stream)
    final coreTrailPaint = Paint()
      ..shader = ui.Gradient.linear(
        tailEnd,
        headPos,
        [
          Colors.transparent,
          trailBaseColor.withValues(alpha: 0.25 * opacity),
          Colors.white.withValues(alpha: 0.90 * opacity),
        ],
        const [0.0, 0.5, 1.0],
      )
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    canvas.drawLine(tailEnd, headPos, coreTrailPaint);

    // 3. รัศมีแสงเรืองรองที่หัวดาวตก (Meteor Head Halo - smooth concentric)
    final outerHaloPaint = Paint()
      ..color = headGlowColor.withValues(alpha: 0.20 * opacity)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(headPos, headRadius * 3.0, outerHaloPaint);

    final innerHaloPaint = Paint()
      ..color = headGlowColor.withValues(alpha: 0.45 * opacity)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(headPos, headRadius * 1.8, innerHaloPaint);

    // 4. จุดประกายแสงจ้าใจกลางหัวดาวตก (Bright Star Core)
    final corePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.95 * opacity)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(headPos, headRadius, corePaint);
  }

  @override
  bool shouldRepaint(covariant _CelestialStarfieldPainter oldDelegate) {
    if (disableAnimations) {
      return oldDelegate.isDark != isDark;
    }
    return oldDelegate.animation.value != animation.value ||
        oldDelegate.isDark != isDark ||
        oldDelegate.disableAnimations != disableAnimations;
  }
}
