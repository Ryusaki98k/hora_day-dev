import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/card_element_style.dart';
import '../../utils/app_colors.dart';

/// การ์ดคำแนะนำเมื่อยังไม่มีการเลือกวัตถุ (ความสูงคงที่เท่ากับแถบเครื่องมือ เพื่อไม่ให้การ์ดขยับ)
class StudioIdleToolbarHint extends StatelessWidget {
  const StudioIdleToolbarHint({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: context.isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: context.borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.auto_awesome_rounded, size: 16, color: Color(0xFFD4AF37)),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  'โหมดจัดวางอิสระ (Canva Studio)',
                  style: GoogleFonts.prompt(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: context.textColor,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'แตะที่ข้อความหรือของตกแต่งบนการ์ด เพื่อลากย้าย หมุน ปรับขนาด หรือเปลี่ยนสีได้ทันที',
            style: TextStyle(
              fontSize: 11.5,
              color: context.subTextColor,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// แถบเครื่องมือปรับแต่งสำหรับข้อความและองค์ประกอบภายในการ์ด (Canva Internal Element Toolbar)
class StudioInternalPropertyBar extends StatelessWidget {
  final String elementId;
  final CardElementStyle style;
  final String label;
  final VoidCallback onReset;
  final VoidCallback onDone;
  final ValueChanged<double> onScaleChanged;
  final ValueChanged<double> onRotationDelta;
  final ValueChanged<Color?> onColorChanged;

  const StudioInternalPropertyBar({
    super.key,
    required this.elementId,
    required this.style,
    required this.label,
    required this.onReset,
    required this.onDone,
    required this.onScaleChanged,
    required this.onRotationDelta,
    required this.onColorChanged,
  });

  static const List<Color> _paletteColors = [
    Color(0xFFD4AF37), // Celestial Gold
    Color(0xFFF59E0B), // Amber
    Color(0xFFDC2626), // Ruby Red
    Color(0xFF059669), // Emerald
    Color(0xFFDB2777), // Lotus Pink
    Color(0xFF0284C7), // Sky Blue
    Color(0xFF1E293B), // Dark Slate
    Color(0xFFFFFFFF), // White
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: context.isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFFD4AF37),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const Icon(Icons.open_with_rounded, size: 16, color: AppColors.caramelBronze),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'ปรับแต่ง: $label (แตะแล้วลากย้ายบนการ์ดได้ทันที)',
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.bold,
                    color: context.textColor,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (style.isModified)
                TextButton.icon(
                  onPressed: onReset,
                  icon: const Icon(Icons.restore_rounded, size: 14),
                  label: const Text('รีเซ็ต', style: TextStyle(fontSize: 11)),
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFFEF4444),
                    visualDensity: VisualDensity.compact,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                ),
              IconButton(
                tooltip: 'เสร็จสิ้น',
                icon: const Icon(Icons.check_circle_rounded, size: 20, color: Color(0xFF059669)),
                onPressed: onDone,
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Text('ขนาด: ${(style.scale * 100).toInt()}%', style: TextStyle(fontSize: 11, color: context.subTextColor)),
              Expanded(
                child: Slider(
                  value: style.scale,
                  min: 0.6,
                  max: 2.0,
                  divisions: 28,
                  activeColor: context.goldColor,
                  onChanged: onScaleChanged,
                ),
              ),
              IconButton(
                tooltip: 'หมุนทวนเข็ม -15°',
                icon: const Icon(Icons.rotate_left_rounded, size: 18),
                onPressed: () => onRotationDelta(-15 * 3.141592653589793 / 180),
                visualDensity: VisualDensity.compact,
              ),
              IconButton(
                tooltip: 'หมุนตามเข็ม +15°',
                icon: const Icon(Icons.rotate_right_rounded, size: 18),
                onPressed: () => onRotationDelta(15 * 3.141592653589793 / 180),
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
          const SizedBox(height: 4),
          // แถบเลือกสี
          Row(
            children: [
              Text('สี:', style: TextStyle(fontSize: 11, color: context.subTextColor)),
              const SizedBox(width: 8),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => onColorChanged(null),
                        child: Container(
                          margin: const EdgeInsets.only(right: 6),
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: style.color == null ? context.goldColor : context.borderColor,
                              width: style.color == null ? 1.5 : 1.0,
                            ),
                            borderRadius: BorderRadius.circular(6),
                            color: style.color == null ? context.goldColor.withValues(alpha: 0.15) : Colors.transparent,
                          ),
                          child: const Text('สีธีมเดิม', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                        ),
                      ),
                      ..._paletteColors.map((c) {
                        final isChosen = style.color == c;
                        return GestureDetector(
                          onTap: () => onColorChanged(c),
                          child: Container(
                            width: 22,
                            height: 22,
                            margin: const EdgeInsets.only(right: 6),
                            decoration: BoxDecoration(
                              color: c,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isChosen ? const Color(0xFFD4AF37) : Colors.black26,
                                width: isChosen ? 2.5 : 1.0,
                              ),
                              boxShadow: isChosen
                                  ? [BoxShadow(color: c.withValues(alpha: 0.5), blurRadius: 4)]
                                  : null,
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
