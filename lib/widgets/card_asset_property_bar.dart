import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/card_asset_item.dart';
import '../utils/app_colors.dart';

/// แถบเครื่องมือปรับแต่ง Asset ที่เลือกอยู่ (สไตล์ Canva Quick Toolbar)
class CardAssetPropertyBar extends StatelessWidget {
  final CardAssetItem selectedItem;
  final Function(CardAssetItem updated) onUpdateItem;
  final VoidCallback onDelete;
  final VoidCallback onDuplicate;
  final VoidCallback onBringToFront;
  final VoidCallback onDeselect;

  const CardAssetPropertyBar({
    super.key,
    required this.selectedItem,
    required this.onUpdateItem,
    required this.onDelete,
    required this.onDuplicate,
    required this.onBringToFront,
    required this.onDeselect,
  });

  static const List<Color> _paletteColors = [
    Color(0xFFD4AF37), // Celestial Gold
    Color(0xFFF59E0B), // Amber
    Color(0xFFDC2626), // Ruby Red
    Color(0xFF059669), // Emerald
    Color(0xFFDB2777), // Lotus Pink
    Color(0xFF0284C7), // Sky Blue
    Color(0xFF1E293B), // Dark Slate
    Color(0xFFFFFFFF), // Pure White
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? AppColors.starGold.withValues(alpha: 0.5) : AppColors.caramelBronze.withValues(alpha: 0.5),
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
          // Row 1: Item Label, Quick Buttons & Deselect
          Row(
            children: [
              Icon(
                selectedItem.type == CardAssetType.emoji
                    ? Icons.emoji_emotions_rounded
                    : (selectedItem.type == CardAssetType.seal
                        ? Icons.verified_rounded
                        : (selectedItem.type == CardAssetType.text
                            ? Icons.title_rounded
                            : (selectedItem.type == CardAssetType.svg
                                ? Icons.image_rounded
                                : Icons.auto_awesome_rounded))),
                size: 16,
                color: AppColors.caramelBronze,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  selectedItem.type == CardAssetType.seal
                      ? 'ตรามงคล: ${selectedItem.text}'
                      : (selectedItem.type == CardAssetType.text
                          ? 'ข้อความ: "${selectedItem.text}"'
                          : (selectedItem.type == CardAssetType.emoji
                              ? 'สติกเกอร์: ${selectedItem.text}'
                              : (selectedItem.type == CardAssetType.svg
                                  ? 'SVG'
                                  : (selectedItem.type == CardAssetType.icon
                                      ? 'ไอคอนตกแต่ง'
                                      : 'ไอคอนตกแต่ง')))),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : AppColors.darkText,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              // Bring to Front
              IconButton(
                tooltip: 'ย้ายมาหน้าสุด',
                icon: const Icon(Icons.flip_to_front_rounded, size: 18),
                onPressed: onBringToFront,
                visualDensity: VisualDensity.compact,
              ),
              // Duplicate
              IconButton(
                tooltip: 'ทำซ้ำ',
                icon: const Icon(Icons.copy_rounded, size: 18),
                onPressed: onDuplicate,
                visualDensity: VisualDensity.compact,
              ),
              // Delete
              IconButton(
                tooltip: 'ลบ',
                icon: const Icon(Icons.delete_outline_rounded, size: 18, color: Color(0xFFEF4444)),
                onPressed: onDelete,
                visualDensity: VisualDensity.compact,
              ),
              // Done
              IconButton(
                tooltip: 'เสร็จสิ้น',
                icon: const Icon(Icons.check_rounded, size: 18, color: Color(0xFF059669)),
                onPressed: onDeselect,
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),

          const Divider(height: 10, thickness: 0.8),

          // Row 2: Controls (Scale Slider & Rotate & Color Palette)
          Row(
            children: [
              // Scale Controls
              const Icon(Icons.format_size_rounded, size: 15, color: Colors.grey),
              const SizedBox(width: 4),
              Expanded(
                flex: 3,
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    trackHeight: 3,
                    thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                    overlayShape: const RoundSliderOverlayShape(overlayRadius: 10),
                    activeTrackColor: AppColors.caramelBronze,
                    thumbColor: AppColors.caramelBronze,
                  ),
                  child: Slider(
                    value: selectedItem.scale.clamp(0.5, 2.5),
                    min: 0.5,
                    max: 2.5,
                    onChanged: (val) {
                      onUpdateItem(selectedItem.copyWith(scale: val));
                    },
                  ),
                ),
              ),
              Text(
                '${(selectedItem.scale * 100).toInt()}%',
                style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold),
              ),

              const SizedBox(width: 10),

              // Rotate -15° and +15°
              IconButton(
                tooltip: 'หมุนทวนเข็ม 15°',
                icon: const Icon(Icons.rotate_left_rounded, size: 18),
                visualDensity: VisualDensity.compact,
                onPressed: () {
                  final newRotation = selectedItem.rotation - (15 * math.pi / 180);
                  onUpdateItem(selectedItem.copyWith(rotation: newRotation));
                },
              ),
              IconButton(
                tooltip: 'หมุนตามเข็ม 15°',
                icon: const Icon(Icons.rotate_right_rounded, size: 18),
                visualDensity: VisualDensity.compact,
                onPressed: () {
                  final newRotation = selectedItem.rotation + (15 * math.pi / 180);
                  onUpdateItem(selectedItem.copyWith(rotation: newRotation));
                },
              ),
            ],
          ),

          // Row 3: Colors (if icon or text or svg)
          if (selectedItem.type == CardAssetType.icon ||
              selectedItem.type == CardAssetType.text ||
              selectedItem.type == CardAssetType.seal ||
              selectedItem.type == CardAssetType.svg) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                const Text(
                  'สี:',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.grey),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _paletteColors.map((color) {
                        final isSelected = selectedItem.color == color;
                        return GestureDetector(
                          onTap: () {
                            onUpdateItem(selectedItem.copyWith(color: color));
                          },
                          child: Container(
                            margin: const EdgeInsets.only(right: 6),
                            width: 22,
                            height: 22,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isSelected ? AppColors.caramelBronze : Colors.black26,
                                width: isSelected ? 2.5 : 1.0,
                              ),
                            ),
                            child: isSelected
                                ? Icon(
                                    Icons.check,
                                    size: 13,
                                    color: color.computeLuminance() > 0.5 ? Colors.black : Colors.white,
                                  )
                                : null,
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
