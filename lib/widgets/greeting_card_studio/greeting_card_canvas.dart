import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/card_asset_item.dart';
import '../../models/card_element_style.dart';
import 'card_auspicious_background_painter.dart';
import 'card_theme_config.dart';
import 'studio_canvas_element.dart';

class GreetingCardCanvas extends StatelessWidget {
  final GlobalKey cardRepaintKey;
  final CardThemeConfig themeConfig;
  final Map<String, CardElementStyle> elementStyles;
  final String? selectedElementId;
  final String? selectedAssetId;
  final bool isDownloading;
  final String nickname;
  final String name;
  final String dayName;
  final String age;
  final bool showDayOfWeek;
  final bool showAge;
  final String blessing;
  final String signature;
  final List<CardAssetItem> assets;
  final VoidCallback onTapOutside;
  final ValueChanged<String> onSelectElement;
  final void Function(String id, Offset delta) onPanElement;
  final ValueChanged<String> onSelectAsset;
  final void Function(String id, Offset delta) onPanAsset;
  final ValueChanged<String> onDeleteAsset;
  // New callbacks for scaling and rotating assets
  final void Function(String id, double scale) onScaleAsset;
  final void Function(String id, double rotation) onRotateAsset;

  const GreetingCardCanvas({
    super.key,
    required this.cardRepaintKey,
    required this.themeConfig,
    required this.elementStyles,
    required this.selectedElementId,
    required this.selectedAssetId,
    required this.isDownloading,
    required this.nickname,
    required this.name,
    required this.dayName,
    required this.age,
    required this.showDayOfWeek,
    required this.showAge,
    required this.blessing,
    required this.signature,
    required this.assets,
    required this.onTapOutside,
    required this.onSelectElement,
    required this.onPanElement,
    required this.onSelectAsset,
    required this.onPanAsset,
    required this.onScaleAsset,
    required this.onRotateAsset,
    required this.onDeleteAsset,
  });

  Widget _buildCardTopBadge({Color? colorOverride}) {
    final badgeColor = colorOverride ?? themeConfig.accentColor;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
      decoration: BoxDecoration(
        color: themeConfig.badgeBackgroundColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colorOverride ?? themeConfig.badgeBorderColor, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: themeConfig.accentColor.withValues(alpha: 0.15),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.stars_rounded, size: 14, color: badgeColor),
            const SizedBox(width: 6),
            Text(
              '✦ ศุภวารมงคลสมโภชวันเกิด ✦',
              style: GoogleFonts.prompt(
                fontSize: 11.5,
                fontWeight: FontWeight.bold,
                color: colorOverride ?? themeConfig.titleTextColor,
                letterSpacing: 0.4,
              ),
            ),
            const SizedBox(width: 6),
            Icon(Icons.stars_rounded, size: 14, color: themeConfig.accentColor),
          ],
        ),
      ),
    );
  }

  Widget _buildCardMetaChip({required IconData icon, required String label, Color? colorOverride}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3.5),
      decoration: BoxDecoration(
        color: themeConfig.chipBackgroundColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colorOverride ?? themeConfig.chipBorderColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: colorOverride ?? themeConfig.accentColor),
          const SizedBox(width: 5),
          Flexible(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: colorOverride ?? themeConfig.titleTextColor,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardSeparator({Color? colorOverride}) {
    final sepColor = colorOverride ?? themeConfig.accentColor;
    return Row(
      children: [
        Flexible(
          fit: FlexFit.loose,
          child: Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  sepColor.withValues(alpha: 0.5),
                ],
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Icon(Icons.auto_awesome, size: 13, color: sepColor),
        ),
        Flexible(
          fit: FlexFit.loose,
          child: Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  sepColor.withValues(alpha: 0.5),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: onTapOutside,
      child: RepaintBoundary(
        key: cardRepaintKey,
        child: Container(
          width: double.infinity,
          decoration: themeConfig.boxDecoration.copyWith(
            image: themeConfig.backgroundImageAsset != null
                ? DecorationImage(
                    image: AssetImage(themeConfig.backgroundImageAsset!),
                    fit: BoxFit.cover,
                  )
                : null,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Stack(
              children: [
                // ลายน้ำพื้นหลังมงคล
                Positioned.fill(
                  child: CustomPaint(
                    painter: CardAuspiciousBackgroundPainter(style: themeConfig.style),
                  ),
                ),
                // กรอบทองสองชั้น (Double Inset Border)
                Positioned.fill(
                  child: Container(
                    margin: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: themeConfig.frameBorderColor,
                        width: 1.0,
                      ),
                    ),
                  ),
                ),
                // เนื้อหาภายในการ์ด
                Padding(
                  padding: const EdgeInsets.fromLTRB(26, 30, 26, 28),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // 1. หัวเรื่องสิริมงคล (Canva Movable)
                      MovableCardElement(
                        id: 'top_badge',
                        label: 'หัวเรื่องมงคล',
                        style: elementStyles['top_badge']!,
                        isSelected: selectedElementId == 'top_badge' && !isDownloading,
                        onSelect: () => onSelectElement('top_badge'),
                        onPanUpdate: (delta) => onPanElement('top_badge', delta),
                        child: _buildCardTopBadge(colorOverride: elementStyles['top_badge']?.color),
                      ),

                      const SizedBox(height: 18),

                      // 2. ชื่อลูกดวง (Canva Movable)
                      MovableCardElement(
                        id: 'recipient_name',
                        label: 'ชื่อลูกดวง',
                        style: elementStyles['recipient_name']!,
                        isSelected: selectedElementId == 'recipient_name' && !isDownloading,
                        onSelect: () => onSelectElement('recipient_name'),
                        onPanUpdate: (delta) => onPanElement('recipient_name', delta),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              nickname.isNotEmpty ? 'คุณ$nickname' : 'คุณ$name',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.prompt(
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                                color: elementStyles['recipient_name']?.color ?? themeConfig.titleTextColor,
                                letterSpacing: -0.3,
                                height: 1.2,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (nickname.isNotEmpty && name.isNotEmpty) ...[
                              const SizedBox(height: 2),
                              Text(
                                '($name)',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: (elementStyles['recipient_name']?.color ?? themeConfig.subTextColor).withValues(alpha: 0.85),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ],
                        ),
                      ),

                      const SizedBox(height: 10),

                      // 3. ข้อมูลวันเกิด / อายุ / วันในสัปดาห์ (Canva Movable)
                      if (showDayOfWeek || showAge) ...[
                        MovableCardElement(
                          id: 'meta_chips',
                          label: 'ป้ายวันเกิด & อายุ',
                          style: elementStyles['meta_chips']!,
                          isSelected: selectedElementId == 'meta_chips' && !isDownloading,
                          onSelect: () => onSelectElement('meta_chips'),
                          onPanUpdate: (delta) => onPanElement('meta_chips', delta),
                          child: Wrap(
                            alignment: WrapAlignment.center,
                            spacing: 8,
                            runSpacing: 4,
                            children: [
                              if (showDayOfWeek)
                                _buildCardMetaChip(
                                  icon: Icons.calendar_today_rounded,
                                  label: 'เกิดวัน$dayName',
                                  colorOverride: elementStyles['meta_chips']?.color,
                                ),
                              if (showAge && age.isNotEmpty)
                                _buildCardMetaChip(
                                  icon: Icons.cake_outlined,
                                  label: 'ครบรอบ $age ปี',
                                  colorOverride: elementStyles['meta_chips']?.color,
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],

                      // เส้นคั่นลายมงคลพร้อมดาวประกาย (Canva Movable)
                      MovableCardElement(
                        id: 'separator',
                        label: 'เส้นคั่นลายมงคล',
                        style: elementStyles['separator']!,
                        isSelected: selectedElementId == 'separator' && !isDownloading,
                        onSelect: () => onSelectElement('separator'),
                        onPanUpdate: (delta) => onPanElement('separator', delta),
                        child: _buildCardSeparator(colorOverride: elementStyles['separator']?.color),
                      ),

                      const SizedBox(height: 14),

                      // 4. กล่องข้อความคำอวยพรมงคล (Canva Movable)
                      MovableCardElement(
                        id: 'blessing_box',
                        label: 'กล่องคำอวยพร',
                        style: elementStyles['blessing_box']!,
                        isSelected: selectedElementId == 'blessing_box' && !isDownloading,
                        onSelect: () => onSelectElement('blessing_box'),
                        onPanUpdate: (delta) => onPanElement('blessing_box', delta),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                          decoration: BoxDecoration(
                            color: themeConfig.blessingBoxColor,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: elementStyles['blessing_box']?.color?.withValues(alpha: 0.4) ?? themeConfig.blessingBoxBorderColor,
                              width: elementStyles['blessing_box']?.color != null ? 1.5 : 1.0,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.04),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Text(
                            '“$blessing”',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.sarabun(
                              fontSize: 14,
                              height: 1.65,
                              fontWeight: FontWeight.w500,
                              color: elementStyles['blessing_box']?.color ?? themeConfig.bodyTextColor,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // 5. คำลงท้าย / ลายเซ็นอาจารย์ (Canva Movable)
                      if (signature.isNotEmpty) ...[
                        MovableCardElement(
                          id: 'signature',
                          label: 'ลายเซ็นอาจารย์',
                          style: elementStyles['signature']!,
                          isSelected: selectedElementId == 'signature' && !isDownloading,
                          onSelect: () => onSelectElement('signature'),
                          onPanUpdate: (delta) => onPanElement('signature', delta),
                          child: Text(
                            '— $signature —',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 11.5,
                              fontStyle: FontStyle.italic,
                              color: elementStyles['signature']?.color ?? themeConfig.subTextColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],

                      const SizedBox(height: 10),

                      // โลโก้แอปมงคลและตราประทับ (Canva Movable)
                      MovableCardElement(
                        id: 'footer',
                        label: 'โลโก้ & เครดิตแอป',
                        style: elementStyles['footer']!,
                        isSelected: selectedElementId == 'footer' && !isDownloading,
                        onSelect: () => onSelectElement('footer'),
                        onPanUpdate: (delta) => onPanElement('footer', delta),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.auto_awesome, size: 11, color: elementStyles['footer']?.color ?? themeConfig.accentColor),
                              const SizedBox(width: 5),
                              Text(
                                'HORA DAY • สมุดดวงชะตา & ศูนย์วันเกิดมงคล',
                                style: TextStyle(
                                  fontSize: 9.5,
                                  letterSpacing: 0.8,
                                  fontWeight: FontWeight.w700,
                                  color: elementStyles['footer']?.color ?? themeConfig.subTextColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Canva Draggable Assets Layer
                ...assets.map((asset) => StudioAssetWidget(
                  item: asset,
                  isSelected: selectedAssetId == asset.id && !isDownloading,
                  accentColor: themeConfig.accentColor,
                  bodyTextColor: themeConfig.bodyTextColor,
                  onSelect: () => onSelectAsset(asset.id),
                  onPanUpdate: (delta) => onPanAsset(asset.id, delta),
                  onScaleChanged: (scale) => onScaleAsset(asset.id, scale),
                  onRotationDelta: (rotation) => onRotateAsset(asset.id, rotation),
                  onDelete: () => onDeleteAsset(asset.id),
                )),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
