import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/card_asset_item.dart';
import '../../models/card_element_style.dart';
import '../../utils/app_colors.dart';
import '../card_asset_library.dart';

class StudioCanvaAssetControls extends StatelessWidget {
  final Map<String, CardElementStyle> elementStyles;
  final String? selectedElementId;
  final String? selectedAssetId;
  final List<CardAssetItem> assets;
  final ValueChanged<String?> onSelectElement;
  final VoidCallback onResetAllElements;
  final ValueChanged<CardAssetItem> onAddAsset;
  final VoidCallback onClearAllAssets;
  final VoidCallback onApplyPreset;
  final ValueChanged<String?> onSelectAsset;
  final ValueChanged<String> onDeleteAsset;
  final void Function(int oldIndex, int newIndex) onReorderAssets;

  const StudioCanvaAssetControls({
    super.key,
    required this.elementStyles,
    required this.selectedElementId,
    required this.selectedAssetId,
    required this.assets,
    required this.onSelectElement,
    required this.onResetAllElements,
    required this.onAddAsset,
    required this.onClearAllAssets,
    required this.onApplyPreset,
    required this.onSelectAsset,
    required this.onDeleteAsset,
    required this.onReorderAssets,
  });

  static String getElementLabel(String id) {
    switch (id) {
      case 'top_badge':
        return 'หัวเรื่องมงคล';
      case 'recipient_name':
        return 'ชื่อลูกดวง';
      case 'meta_chips':
        return 'ป้ายวันเกิด & อายุ';
      case 'separator':
        return 'เส้นคั่นลายมงคล';
      case 'blessing_box':
        return 'กล่องคำอวยพร';
      case 'signature':
        return 'ลายเซ็นอาจารย์';
      case 'footer':
        return 'โลโก้ & เครดิตแอป';
      default:
        return id;
    }
  }

  Widget _buildInternalElementsQuickManager(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: context.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    const Icon(Icons.layers_outlined, size: 18, color: AppColors.caramelBronze),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'ข้อความ & องค์ประกอบภายในการ์ด',
                        style: GoogleFonts.prompt(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: context.textColor,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              TextButton(
                onPressed: onResetAllElements,
                child: const Text('รีเซ็ตทั้งหมด', style: TextStyle(fontSize: 11, color: Color(0xFFEF4444))),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'แตะรายการด้านล่างหรือแตะบนการ์ดโดยตรง เพื่อเลือก ลากย้าย ปรับขนาด หรือเปลี่ยนสี',
            style: TextStyle(fontSize: 11, color: context.subTextColor),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: elementStyles.keys.map((id) {
              final isSelected = selectedElementId == id;
              final style = elementStyles[id]!;
              return InkWell(
                onTap: () {
                  onSelectElement(isSelected ? null : id);
                },
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFFD4AF37).withValues(alpha: 0.18)
                        : (context.isDark ? const Color(0xFF0F172A) : const Color(0xFFF8F6F0)),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isSelected ? const Color(0xFFD4AF37) : context.borderColor,
                      width: isSelected ? 1.5 : 1.0,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isSelected ? Icons.check_circle_rounded : Icons.open_with_rounded,
                        size: 13,
                        color: isSelected ? const Color(0xFFD4AF37) : context.subTextColor,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        getElementLabel(id),
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                          color: isSelected ? const Color(0xFFD4AF37) : context.textColor,
                        ),
                      ),
                      if (style.isModified) ...[
                        const SizedBox(width: 4),
                        Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: Color(0xFFF59E0B),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _renderMiniPreview(CardAssetItem item) {
    switch (item.type) {
      case CardAssetType.emoji:
        return Text(item.text, style: const TextStyle(fontSize: 18));
      case CardAssetType.icon:
        return Icon(item.icon, size: 20, color: item.color ?? AppColors.caramelBronze);
      case CardAssetType.text:
        return const Icon(Icons.title_rounded, size: 18, color: AppColors.caramelBronze);
      case CardAssetType.seal:
        return const Icon(Icons.verified_rounded, size: 18, color: AppColors.caramelBronze);
      case CardAssetType.svg:
        return Icon(Icons.image_rounded, size: 18, color: item.color ?? AppColors.caramelBronze);
    }
  }

  Widget _buildActiveAssetsManager(BuildContext context) {
    if (assets.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: context.isDark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: context.borderColor),
        ),
        child: Column(
          children: [
            const Icon(Icons.touch_app_rounded, size: 28, color: AppColors.caramelBronze),
            const SizedBox(height: 8),
            Text(
              'ยังไม่มีสติกเกอร์หรือตรามงคลเพิ่มเติม',
              style: GoogleFonts.prompt(fontSize: 13, fontWeight: FontWeight.bold, color: context.textColor),
            ),
            const SizedBox(height: 4),
            Text(
              'แตะสติกเกอร์ ตรามงคล หรือพิมพ์ข้อความด้านบนเพื่อเพิ่มลงการ์ด หรือลากย้ายข้อความที่มีอยู่แล้วได้เลย',
              style: TextStyle(fontSize: 11.5, color: context.subTextColor),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: onApplyPreset,
              icon: const Icon(Icons.auto_fix_high_rounded, size: 16),
              label: const Text('ใส่ชุดตกแต่งตัวอย่าง', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: context.goldColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: context.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'รายการของตกแต่งเพิ่มเติม (${assets.length} ชิ้น)',
                  style: GoogleFonts.prompt(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: context.textColor,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'แตะเพื่อเลือก/ย้ายบนการ์ด',
                style: TextStyle(fontSize: 11, color: context.subTextColor),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ReorderableListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: assets.length,
            // ignore: deprecated_member_use
            onReorder: onReorderAssets,
            itemBuilder: (context, index) {
              final item = assets[index];
              final isSelected = item.id == selectedAssetId;
              return Container(
                key: ValueKey(item.id),
                margin: const EdgeInsets.only(bottom: 6),
                decoration: BoxDecoration(
                  color: isSelected
                      ? context.goldColor.withValues(alpha: 0.15)
                      : (context.isDark ? const Color(0xFF0F172A) : const Color(0xFFFAF8F5)),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isSelected ? context.goldColor : context.borderColor,
                    width: isSelected ? 1.5 : 1.0,
                  ),
                ),
                child: ListTile(
                  dense: true,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                  leading: Container(
                    width: 32,
                    height: 32,
                    alignment: Alignment.center,
                    child: _renderMiniPreview(item),
                  ),
                  title: Text(
                    item.type == CardAssetType.seal
                        ? 'ตรา: ${item.text}'
                        : (item.type == CardAssetType.text
                            ? 'ข้อความ: "${item.text}"'
                            : (item.type == CardAssetType.emoji
                                ? 'สติกเกอร์ ${item.text}'
                                : (item.type == CardAssetType.svg
                                    ? 'SVG: ${item.svgAssetKey?.split('/').last ?? "ตกแต่ง"}'
                                    : 'ไอคอนตกแต่ง'))),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                      color: context.textColor,
                    ),
                  ),
                  subtitle: Text(
                    'ขนาด: ${(item.scale * 100).toInt()}% • ตำแหน่ง: (${item.position.dx.toInt()}, ${item.position.dy.toInt()})',
                    style: TextStyle(fontSize: 10, color: context.subTextColor),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.delete_outline_rounded, size: 18, color: Color(0xFFEF4444)),
                        onPressed: () => onDeleteAsset(item.id),
                      ),
                      const Icon(Icons.drag_handle_rounded, size: 18, color: Colors.grey),
                    ],
                  ),
                  onTap: () => onSelectAsset(item.id),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInternalElementsQuickManager(context),
        const SizedBox(height: 16),
        CardAssetLibrary(
          onAddAsset: onAddAsset,
          onClearAll: onClearAllAssets,
          onApplyPreset: onApplyPreset,
          totalAssetsCount: assets.length,
        ),
        const SizedBox(height: 16),
        _buildActiveAssetsManager(context),
      ],
    );
  }
}
