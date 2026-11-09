import 'package:flutter/material.dart';
import 'app_colors.dart';

/// 1. Tactile Press Wrapper (Zero-animation static pressable)
class AnimatedPressable extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double scaleDown;
  final BorderRadius? borderRadius;

  const AnimatedPressable({
    super.key,
    required this.child,
    this.onTap,
    this.scaleDown = 0.96,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: borderRadius,
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      child: child,
    );
  }
}

/// 2. Staggered Entrance (Static pass-through with no entrance animation delays)
class StaggeredEntrance extends StatelessWidget {
  final Widget child;
  final int index;
  final Duration baseDelay;
  final Duration duration;
  final Offset offset;

  const StaggeredEntrance({
    super.key,
    required this.child,
    this.index = 0,
    this.baseDelay = const Duration(milliseconds: 40),
    this.duration = const Duration(milliseconds: 420),
    this.offset = const Offset(0, 18),
  });

  @override
  Widget build(BuildContext context) {
    return child;
  }
}

/// 3. Tab & Page Switcher Transition (Static pass-through with no page transition)
class AnimatedPageTransition extends StatelessWidget {
  final Widget child;
  final int pageKey;

  const AnimatedPageTransition({
    super.key,
    required this.child,
    required this.pageKey,
  });

  @override
  Widget build(BuildContext context) {
    return child;
  }
}

/// 4. Typing Indicator (Static 3 dots without bouncing animation)
class AnimatedTypingIndicator extends StatelessWidget {
  final Color dotColor;
  final double dotSize;

  const AnimatedTypingIndicator({
    super.key,
    this.dotColor = AppColors.caramelBronze,
    this.dotSize = 6.0,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(
        3,
        (index) => Container(
          width: dotSize,
          height: dotSize,
          margin: const EdgeInsets.symmetric(horizontal: 2),
          decoration: BoxDecoration(
            color: dotColor.withValues(alpha: 0.6),
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}

/// 5. Confetti Burst Overlay (Static pass-through without confetti particles)
class ConfettiBurstOverlay extends StatelessWidget {
  final Widget child;
  final bool trigger;
  final VoidCallback? onComplete;

  const ConfettiBurstOverlay({
    super.key,
    required this.child,
    required this.trigger,
    this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    return child;
  }
}

/// 6. Golden Mesh Background (Static pass-through without background animation loop)
class AnimatedGoldenMeshBackground extends StatelessWidget {
  final Widget child;

  const AnimatedGoldenMeshBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return child;
  }
}

/// 7. Auspicious Glow Badge (Static pass-through without pulsing animation)
class AuspiciousGlowBadge extends StatelessWidget {
  final Widget child;
  final bool enabled;
  final BorderRadius? borderRadius;

  const AuspiciousGlowBadge({
    super.key,
    required this.child,
    this.enabled = true,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return child;
  }
}

/// 8. Rolling Count (Static count display without rolling animation)
class AnimatedCountText extends StatelessWidget {
  final int count;
  final TextStyle? style;
  final Duration duration;
  final String suffix;
  final String prefix;

  const AnimatedCountText({
    super.key,
    required this.count,
    this.style,
    this.duration = const Duration(milliseconds: 650),
    this.suffix = '',
    this.prefix = '',
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      '$prefix$count$suffix',
      style: style,
    );
  }
}

/// 9. Progress Bar (Static progress display without expanding animation)
class AnimatedProgressBar extends StatelessWidget {
  final double factor;
  final Color color;
  final double height;
  final Duration duration;

  const AnimatedProgressBar({
    super.key,
    required this.factor,
    required this.color,
    this.height = 7.0,
    this.duration = const Duration(milliseconds: 750),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.warmSand,
        borderRadius: BorderRadius.circular(height / 2),
      ),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: factor.clamp(0.04, 1.0),
        child: Container(
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(height / 2),
          ),
        ),
      ),
    );
  }
}

/// 10. Sparkle Icon (Static icon without rotating/scaling animation)
class AnimatedSparkleIcon extends StatelessWidget {
  final IconData icon;
  final Color color;
  final double size;

  const AnimatedSparkleIcon({
    super.key,
    this.icon = Icons.auto_awesome,
    this.color = AppColors.amberGold,
    this.size = 18.0,
  });

  @override
  Widget build(BuildContext context) {
    return Icon(
      icon,
      color: color,
      size: size,
    );
  }
}
