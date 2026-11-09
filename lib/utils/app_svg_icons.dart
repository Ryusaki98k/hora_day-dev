import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Centralized SVG vector icons for Hora Day application.
/// Replaces system emojis with crisp, theme-aware vector icons.
class AppSvgIcons {
  // 1. Birthday Cake SVG
  static const String cakeSvg = '''<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
    <path d="M20 21v-8a2 2 0 0 0-2-2H6a2 2 0 0 0-2 2v8"/>
    <path d="M4 16s.5-1 2-1 2.5 2 4 2 2.5-2 4-2 2.5 2 4 2 2-1 2-1"/>
    <path d="M2 21h20"/>
    <path d="M7 8v3"/>
    <path d="M12 8v3"/>
    <path d="M17 8v3"/>
    <path d="M7 4h.01"/>
    <path d="M12 4h.01"/>
    <path d="M17 4h.01"/>
  </svg>''';

  // 2. Hourglass (Pending/Upcoming Days) SVG
  static const String hourglassSvg = '''<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
    <path d="M5 22h14"/>
    <path d="M5 2h14"/>
    <path d="M17 22v-4.172a2 2 0 0 0-.586-1.414L12 12l-4.414 4.414A2 2 0 0 0 7 17.828V22"/>
    <path d="M7 2v4.172a2 2 0 0 0 .586 1.414L12 12l4.414-4.414A2 2 0 0 0 17 6.172V2"/>
  </svg>''';

  // 3. Palette (Studio / Design) SVG
  static const String paletteSvg = '''<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
    <circle cx="13.5" cy="6.5" r=".5" fill="currentColor"/>
    <circle cx="17.5" cy="10.5" r=".5" fill="currentColor"/>
    <circle cx="8.5" cy="7.5" r=".5" fill="currentColor"/>
    <circle cx="6.5" cy="12.5" r=".5" fill="currentColor"/>
    <path d="M12 2C6.5 2 2 6.5 2 12s4.5 10 10 10c.926 0 1.648-.746 1.648-1.688 0-.437-.18-.835-.437-1.125-.29-.289-.438-.652-.438-1.125a1.64 1.64 0 0 1 1.668-1.668h1.996c3.051 0 5.555-2.503 5.555-5.554C21.965 6.012 17.461 2 12 2z"/>
  </svg>''';

  // 4. Sparkle (Stickers / Magic) SVG
  static const String sparkleSvg = '''<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
    <path d="m12 3-1.912 5.813a2 2 0 0 1-1.275 1.275L3 12l5.813 1.912a2 2 0 0 1 1.275 1.275L12 21l1.912-5.813a2 2 0 0 1 1.275-1.275L21 12l-5.813-1.912a2 2 0 0 1-1.275-1.275L12 3Z"/>
    <path d="M5 3v4"/>
    <path d="M19 17v4"/>
    <path d="M3 5h4"/>
    <path d="M17 19h4"/>
  </svg>''';

  // 5. Seal (Auspicious Medal / Badge) SVG
  static const String sealSvg = '''<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
    <circle cx="12" cy="8" r="6"/>
    <path d="M15.477 12.89 17 22l-5-3-5 3 1.523-9.11"/>
  </svg>''';

  // 6. Pen / Typography SVG
  static const String penSvg = '''<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
    <path d="M17 3a2.85 2.83 0 1 1 4 4L7.5 20.5 2 22l1.5-5.5Z"/>
    <path d="m15 5 4 4"/>
  </svg>''';

  // 7. Calendar SVG
  static const String calendarSvg = '''<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
    <path d="M8 2v4"/>
    <path d="M16 2v4"/>
    <rect width="18" height="18" x="3" y="4" rx="2"/>
    <path d="M3 10h18"/>
    <path d="M8 14h.01"/>
    <path d="M12 14h.01"/>
    <path d="M16 14h.01"/>
    <path d="M8 18h.01"/>
    <path d="M12 18h.01"/>
  </svg>''';

  // 8. Celebration / Party Popper SVG
  static const String partySvg = '''<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
    <path d="m5.8 11.3 5.3-5.3a2 2 0 0 1 2.8 0l4.4 4.4a2 2 0 0 1 0 2.8l-5.3 5.3a2 2 0 0 1-2.8 0l-4.4-4.4a2 2 0 0 1 0-2.8Z"/>
    <path d="m2 22 4.2-4.2"/>
    <path d="m18.5 2.5 1.5 1.5"/>
    <path d="M14 2h2"/>
    <path d="M22 6v2"/>
    <path d="m20 12 1.5 1.5"/>
    <path d="M11 20v2"/>
    <path d="m4 15-1.5 1.5"/>
  </svg>''';

  /// Helper builders that produce an SvgPicture with color and dimensions
  static Widget cake({double size = 16, Color? color}) {
    return SvgPicture.string(
      cakeSvg,
      width: size,
      height: size,
      colorFilter: color != null ? ColorFilter.mode(color, BlendMode.srcIn) : null,
    );
  }

  static Widget hourglass({double size = 16, Color? color}) {
    return SvgPicture.string(
      hourglassSvg,
      width: size,
      height: size,
      colorFilter: color != null ? ColorFilter.mode(color, BlendMode.srcIn) : null,
    );
  }

  static Widget palette({double size = 16, Color? color}) {
    return SvgPicture.string(
      paletteSvg,
      width: size,
      height: size,
      colorFilter: color != null ? ColorFilter.mode(color, BlendMode.srcIn) : null,
    );
  }

  static Widget sparkle({double size = 16, Color? color}) {
    return SvgPicture.string(
      sparkleSvg,
      width: size,
      height: size,
      colorFilter: color != null ? ColorFilter.mode(color, BlendMode.srcIn) : null,
    );
  }

  static Widget seal({double size = 16, Color? color}) {
    return SvgPicture.string(
      sealSvg,
      width: size,
      height: size,
      colorFilter: color != null ? ColorFilter.mode(color, BlendMode.srcIn) : null,
    );
  }

  static Widget pen({double size = 16, Color? color}) {
    return SvgPicture.string(
      penSvg,
      width: size,
      height: size,
      colorFilter: color != null ? ColorFilter.mode(color, BlendMode.srcIn) : null,
    );
  }

  static Widget calendar({double size = 16, Color? color}) {
    return SvgPicture.string(
      calendarSvg,
      width: size,
      height: size,
      colorFilter: color != null ? ColorFilter.mode(color, BlendMode.srcIn) : null,
    );
  }

  static Widget party({double size = 16, Color? color}) {
    return SvgPicture.string(
      partySvg,
      width: size,
      height: size,
      colorFilter: color != null ? ColorFilter.mode(color, BlendMode.srcIn) : null,
    );
  }
}
