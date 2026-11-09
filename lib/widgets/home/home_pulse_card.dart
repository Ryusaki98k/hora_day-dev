import 'package:flutter/material.dart';
import '../../utils/animation_helper.dart';
import '../../utils/app_colors.dart';

class HomePulseCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final int count;
  final String unit;
  final Color color;
  final VoidCallback onTap;

  const HomePulseCard({
    super.key,
    required this.icon,
    required this.label,
    required this.count,
    required this.unit,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        splashColor: color.withValues(alpha: 0.12),
        highlightColor: color.withValues(alpha: 0.05),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 13),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: color.withValues(
                        alpha: context.isDark ? 0.22 : 0.12,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    alignment: Alignment.center,
                    child: Icon(icon, size: 16, color: color),
                  ),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 10,
                    color: context.mutedTextColor,
                  ),
                ],
              ),
              const SizedBox(height: 10),
              AnimatedCountText(
                count: count,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: context.textColor,
                  height: 1.1,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11.5,
                  color: context.subTextColor,
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
