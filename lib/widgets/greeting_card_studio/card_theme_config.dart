import 'package:flutter/material.dart';
import '../../models/card_theme_style.dart';

class CardThemeConfig {
  final CardThemeStyle style;
  final Color dayColor;

  const CardThemeConfig({
    required this.style,
    required this.dayColor,
  });

  String? get backgroundImageAsset {
    switch (style) {
      case CardThemeStyle.celestialGold:
        return 'assets/templates/1.png';
      case CardThemeStyle.celestialGold2:
        return 'assets/templates/1-1.png';
      case CardThemeStyle.celestialGold3:
        return 'assets/templates/1-2.png';
      case CardThemeStyle.midnightCosmic:
        return 'assets/templates/2.png';
      case CardThemeStyle.midnightCosmic2:
        return 'assets/templates/2-1.png';
      case CardThemeStyle.midnightCosmic3:
        return 'assets/templates/2-2.png';
      case CardThemeStyle.rubyFortune:
        return 'assets/templates/3.png';
      case CardThemeStyle.emeraldPeace:
        return 'assets/templates/3-1 (1).png';
      case CardThemeStyle.emeraldPeace2:
        return 'assets/templates/3-1 (2).png';
      case CardThemeStyle.emeraldPeace3:
        return 'assets/templates/3-1 (3).png';
      case CardThemeStyle.lotusMetta:
        return 'assets/templates/2-3.png';
      case CardThemeStyle.birthMineralDay:
        return 'assets/templates/1-3.png';
    }
  }

  BoxDecoration get boxDecoration {
    switch (style) {
      case CardThemeStyle.celestialGold:
      case CardThemeStyle.celestialGold2:
      case CardThemeStyle.celestialGold3:
        return BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFFFFBF2),
              Color(0xFFF7EED8),
              Color(0xFFEDE0C4),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFD4AF37).withValues(alpha: 0.25),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
          border: Border.all(color: const Color(0xFFD4AF37), width: 1.4),
        );

      case CardThemeStyle.midnightCosmic:
      case CardThemeStyle.midnightCosmic2:
      case CardThemeStyle.midnightCosmic3:
        return BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF131B2F),
              Color(0xFF0F172A),
              Color(0xFF070B14),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF38BDF8).withValues(alpha: 0.2),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
          border: Border.all(color: const Color(0xFFF59E0B), width: 1.4),
        );

      case CardThemeStyle.rubyFortune:
        return BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF7F1D1D),
              Color(0xFF991B1B),
              Color(0xFF450A0A),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFDC2626).withValues(alpha: 0.3),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
          border: Border.all(color: const Color(0xFFFCD34D), width: 1.4),
        );

      case CardThemeStyle.emeraldPeace:
      case CardThemeStyle.emeraldPeace2:
      case CardThemeStyle.emeraldPeace3:
        return BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF064E3B),
              Color(0xFF065F46),
              Color(0xFF022C22),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF10B981).withValues(alpha: 0.3),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
          border: Border.all(color: const Color(0xFF6EE7B7), width: 1.4),
        );

      case CardThemeStyle.lotusMetta:
        return BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFFDF2F8),
              Color(0xFFFCE7F3),
              Color(0xFFFBCFE8),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFEC4899).withValues(alpha: 0.2),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
          border: Border.all(color: const Color(0xFFF472B6), width: 1.4),
        );

      case CardThemeStyle.birthMineralDay:
        return BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              dayColor.withValues(alpha: 0.25),
              dayColor.withValues(alpha: 0.15),
              Colors.white,
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: dayColor.withValues(alpha: 0.25),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
          border: Border.all(color: dayColor, width: 1.4),
        );
    }
  }

  Color get titleTextColor {
    switch (style) {
      case CardThemeStyle.midnightCosmic:
      case CardThemeStyle.midnightCosmic2:
      case CardThemeStyle.midnightCosmic3:
      case CardThemeStyle.rubyFortune:
      case CardThemeStyle.emeraldPeace:
      case CardThemeStyle.emeraldPeace2:
      case CardThemeStyle.emeraldPeace3:
        return Colors.white;
      default:
        return const Color(0xFF14100C);
    }
  }

  Color get subTextColor {
    switch (style) {
      case CardThemeStyle.midnightCosmic:
        return const Color(0xFFCBD5E1);
      case CardThemeStyle.midnightCosmic2:
        return const Color(0xFFCBD5E1);
      case CardThemeStyle.midnightCosmic3:
        return const Color(0xFFCBD5E1);
      case CardThemeStyle.rubyFortune:
        return const Color(0xFFFECACA);
      case CardThemeStyle.emeraldPeace:
        return const Color(0xFFA7F3D0);
      case CardThemeStyle.emeraldPeace2:
        return const Color(0xFFA7F3D0);
      case CardThemeStyle.emeraldPeace3:
        return const Color(0xFFA7F3D0);
      default:
        return const Color(0xFF4A3B2C);
    }
  }

  Color get bodyTextColor {
    switch (style) {
      case CardThemeStyle.midnightCosmic:
      case CardThemeStyle.midnightCosmic2:
      case CardThemeStyle.midnightCosmic3:
      case CardThemeStyle.rubyFortune:
      case CardThemeStyle.emeraldPeace:
      case CardThemeStyle.emeraldPeace2:
      case CardThemeStyle.emeraldPeace3:
        return const Color(0xFFF8FAFC);
      default:
        return const Color(0xFF1C150E);
    }
  }

  Color get accentColor {
    switch (style) {
      case CardThemeStyle.celestialGold:
        return const Color(0xFFB45309);
      case CardThemeStyle.celestialGold2:
        return const Color(0xFFB45309);
      case CardThemeStyle.celestialGold3:
        return const Color(0xFFB45309);
      case CardThemeStyle.midnightCosmic:
        return const Color(0xFFF59E0B);
      case CardThemeStyle.midnightCosmic2:
        return const Color(0xFFF59E0B);
      case CardThemeStyle.midnightCosmic3:
        return const Color(0xFFF59E0B);
      case CardThemeStyle.rubyFortune:
        return const Color(0xFFFDE047);
      case CardThemeStyle.emeraldPeace:
        return const Color(0xFF6EE7B7);
      case CardThemeStyle.emeraldPeace2:
        return const Color(0xFF6EE7B7);
      case CardThemeStyle.emeraldPeace3:
        return const Color(0xFF6EE7B7);
      case CardThemeStyle.lotusMetta:
        return const Color(0xFFBE185D);
      case CardThemeStyle.birthMineralDay:
        return dayColor;
    }
  }

  Color get frameBorderColor {
    switch (style) {
      case CardThemeStyle.midnightCosmic:
      case CardThemeStyle.midnightCosmic2:
      case CardThemeStyle.midnightCosmic3:
      case CardThemeStyle.rubyFortune:
      case CardThemeStyle.emeraldPeace:
      case CardThemeStyle.emeraldPeace2:
      case CardThemeStyle.emeraldPeace3:
        return Colors.white.withValues(alpha: 0.18);
      default:
        return const Color(0xFFD4AF37).withValues(alpha: 0.35);
    }
  }

  Color get badgeBackgroundColor {
    switch (style) {
      case CardThemeStyle.midnightCosmic:
      case CardThemeStyle.midnightCosmic2:
      case CardThemeStyle.midnightCosmic3:
      case CardThemeStyle.rubyFortune:
      case CardThemeStyle.emeraldPeace:
      case CardThemeStyle.emeraldPeace2:
      case CardThemeStyle.emeraldPeace3:
        return Colors.white.withValues(alpha: 0.12);
      default:
        return Colors.white.withValues(alpha: 0.85);
    }
  }

  Color get badgeBorderColor {
    switch (style) {
      case CardThemeStyle.midnightCosmic:
        return const Color(0xFFF59E0B).withValues(alpha: 0.4);
      case CardThemeStyle.midnightCosmic2:
        return const Color(0xFFF59E0B).withValues(alpha: 0.4);
      case CardThemeStyle.midnightCosmic3:
        return const Color(0xFFF59E0B).withValues(alpha: 0.4);
      case CardThemeStyle.rubyFortune:
        return const Color(0xFFFDE047).withValues(alpha: 0.5);
      case CardThemeStyle.emeraldPeace:
        return const Color(0xFF6EE7B7).withValues(alpha: 0.5);
      case CardThemeStyle.emeraldPeace2:
        return const Color(0xFF6EE7B7).withValues(alpha: 0.5);
      case CardThemeStyle.emeraldPeace3:
        return const Color(0xFF6EE7B7).withValues(alpha: 0.5);
      default:
        return const Color(0xFFD4AF37).withValues(alpha: 0.5);
    }
  }

  Color get chipBackgroundColor {
    switch (style) {
      case CardThemeStyle.midnightCosmic:
      case CardThemeStyle.midnightCosmic2:
      case CardThemeStyle.midnightCosmic3:
      case CardThemeStyle.rubyFortune:
      case CardThemeStyle.emeraldPeace:
      case CardThemeStyle.emeraldPeace2:
      case CardThemeStyle.emeraldPeace3:
        return Colors.white.withValues(alpha: 0.10);
      default:
        return Colors.white.withValues(alpha: 0.7);
    }
  }

  Color get chipBorderColor {
    switch (style) {
      case CardThemeStyle.midnightCosmic:
      case CardThemeStyle.midnightCosmic2:
      case CardThemeStyle.midnightCosmic3:
      case CardThemeStyle.rubyFortune:
      case CardThemeStyle.emeraldPeace:
      case CardThemeStyle.emeraldPeace2:
      case CardThemeStyle.emeraldPeace3:
        return Colors.white.withValues(alpha: 0.2);
      default:
        return const Color(0xFFE2D6C0);
    }
  }

  Color get blessingBoxColor {
    switch (style) {
      case CardThemeStyle.midnightCosmic:
        return const Color(0xFF0F172A).withValues(alpha: 0.85);
      case CardThemeStyle.midnightCosmic2:
        return const Color(0xFF0F172A).withValues(alpha: 0.85);
      case CardThemeStyle.midnightCosmic3:
        return const Color(0xFF0F172A).withValues(alpha: 0.85);
      case CardThemeStyle.rubyFortune:
        return const Color(0xFF450A0A).withValues(alpha: 0.75);
      case CardThemeStyle.emeraldPeace:
        return const Color(0xFF022C22).withValues(alpha: 0.75);
      case CardThemeStyle.emeraldPeace2:
        return const Color(0xFF022C22).withValues(alpha: 0.75);
      case CardThemeStyle.emeraldPeace3:
        return const Color(0xFF022C22).withValues(alpha: 0.75);
      default:
        return Colors.white.withValues(alpha: 0.82);
    }
  }

  Color get blessingBoxBorderColor {
    switch (style) {
      case CardThemeStyle.midnightCosmic:
        return const Color(0xFF334155);
      case CardThemeStyle.midnightCosmic2:
        return const Color(0xFF334155);
      case CardThemeStyle.midnightCosmic3:
        return const Color(0xFF334155);
      case CardThemeStyle.rubyFortune:
        return const Color(0xFFB91C1C);
      case CardThemeStyle.emeraldPeace:
        return const Color(0xFF065F46);
      case CardThemeStyle.emeraldPeace2:
        return const Color(0xFF065F46);
      case CardThemeStyle.emeraldPeace3:
        return const Color(0xFF065F46);
      default:
        return const Color(0xFFEAD8BA);
    }
  }
}
