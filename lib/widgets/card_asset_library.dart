import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/card_asset_item.dart';
import '../utils/app_colors.dart';
import '../utils/app_svg_icons.dart';

/// คลัง Asset ตกแต่งการ์ดสไตล์ Canva สำหรับสตูดิโอการ์ดอวยพรวันเกิด
class CardAssetLibrary extends StatefulWidget {
  final Function(CardAssetItem item) onAddAsset;
  final VoidCallback onClearAll;
  final VoidCallback onApplyPreset;
  final int totalAssetsCount;

  const CardAssetLibrary({
    super.key,
    required this.onAddAsset,
    required this.onClearAll,
    required this.onApplyPreset,
    required this.totalAssetsCount,
  });

  @override
  State<CardAssetLibrary> createState() => _CardAssetLibraryState();
}

class _CardAssetLibraryState extends State<CardAssetLibrary> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _customTextController = TextEditingController();
  final TextEditingController _customSvgController = TextEditingController();

  final List<String> _auspiciousEmojis = [
    '✨', '🌟', '🕉️', '🪷', '💰', '🪙', '🧧', '💎',
    '🔮', '📜', '🍀', '🪔', '🕊️', '👑', '☀️', '🌙',
    '📿', '🧿', '🌸', '💐', '🕯️', '🥂', '🎀', '💖'
  ];

  final List<String> _birthdayEmojis = [
    '🎂', '🎁', '🎈', '🎉', '🥳', '🧁', '🍰', '🍫',
    '🍭', '🥂', '🍾', '🎊', '🎇', '🎆', '🎠', '🧸'
  ];

  final List<Map<String, dynamic>> _auspiciousIcons = [
    {'name': 'ประกายทิพย์', 'icon': Icons.auto_awesome_rounded},
    {'name': 'ดารามงคล', 'icon': Icons.stars_rounded},
    {'name': 'ดอกบัวสงบ', 'icon': Icons.spa_rounded},
    {'name': 'มณีนำโชค', 'icon': Icons.diamond_rounded},
    {'name': 'สุริยเทพ', 'icon': Icons.wb_sunny_rounded},
    {'name': 'ศศิธร', 'icon': Icons.nightlight_round},
    {'name': 'เค้กมงคล', 'icon': Icons.cake_rounded},
    {'name': 'กล่องของขวัญ', 'icon': Icons.card_giftcard_rounded},
    {'name': 'เฉลิมฉลอง', 'icon': Icons.celebration_rounded},
    {'name': 'เมตตาจิต', 'icon': Icons.favorite_rounded},
    {'name': 'มงกุฎเกียรติ', 'icon': Icons.military_tech_rounded},
    {'name': 'ประทีปธรรม', 'icon': Icons.local_fire_department_rounded},
    {'name': 'ความสำเร็จ', 'icon': Icons.emoji_events_rounded},
    {'name': 'คุ้มครองภัย', 'icon': Icons.shield_rounded},
  ];

  final List<Map<String, dynamic>> _auspiciousSeals = [
    {
      'title': 'มั่งคั่ง ร่ำรวย',
      'subtitle': 'เงินทองไหลมาเทมา',
      'icon': Icons.monetization_on_rounded,
      'color': Color(0xFFD4AF37),
    },
    {
      'title': 'ดวงดี ตลอดปี',
      'subtitle': 'ชะตารุ่งโรจน์โชติช่วง',
      'icon': Icons.auto_awesome_rounded,
      'color': Color(0xFFEAB308),
    },
    {
      'title': 'อายุยืน สุขภาพดี',
      'subtitle': 'ปราศจากโรคาพาธ',
      'icon': Icons.spa_rounded,
      'color': Color(0xFF10B981),
    },
    {
      'title': 'เมตตา มหานิยม',
      'subtitle': 'เป็นที่รักใคร่เอ็นดู',
      'icon': Icons.favorite_rounded,
      'color': Color(0xFFEC4899),
    },
    {
      'title': 'แคล้วคลาด ปลอดภัย',
      'subtitle': 'สิ่งศักดิ์สิทธิ์คุ้มครอง',
      'icon': Icons.shield_rounded,
      'color': Color(0xFF38BDF8),
    },
    {
      'title': 'รับทรัพย์ มหาศาล',
      'subtitle': 'ค้าขายคล่องตัว',
      'icon': Icons.savings_rounded,
      'color': Color(0xFFF59E0B),
    },
  ];

  final List<String> _textTemplates = [
    '✨ Happy Birthday ✨',
    'ร่ำรวย มั่งคั่ง สุขภาพแข็งแรง',
    'ขอให้ปีนี้เป็นปีทองของคุณ',
    'เฮงๆ รวยๆ ปังๆ ตลอดทั้งปี',
    'ด้วยรักและความเคารพ',
    'สุขกาย สบายใจ สมหวังทุกประการ',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _customTextController.dispose();
    _customSvgController.dispose();
    super.dispose();
  }

  void _addEmoji(String emoji) {
    widget.onAddAsset(
      CardAssetItem(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        type: CardAssetType.emoji,
        position: const Offset(160, 240),
        text: emoji,
        fontSize: 34.0,
      ),
    );
  }

  void _addIcon(IconData icon) {
    widget.onAddAsset(
      CardAssetItem(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        type: CardAssetType.icon,
        position: const Offset(160, 240),
        icon: icon,
        scale: 1.2,
        color: const Color(0xFFD4AF37),
      ),
    );
  }

  void _addSeal(Map<String, dynamic> seal) {
    widget.onAddAsset(
      CardAssetItem(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        type: CardAssetType.seal,
        position: const Offset(130, 220),
        text: seal['title'],
        subtitle: seal['subtitle'],
        sealIcon: seal['icon'],
        color: seal['color'],
        scale: 1.0,
      ),
    );
  }

  void _addText(String text) {
    if (text.trim().isEmpty) return;
    widget.onAddAsset(
      CardAssetItem(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        type: CardAssetType.text,
        position: const Offset(110, 260),
        text: text.trim(),
        fontSize: 15.0,
        isBold: true,
        color: const Color(0xFF78450A),
      ),
    );
  }

  void _addSvg(String svgContent) {
    widget.onAddAsset(
      CardAssetItem(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        type: CardAssetType.svg,
        position: const Offset(120, 230),
        svgContent: svgContent,
        scale: 1.0,
        color: const Color(0xFFD4AF37),
      ),
    );
  }

  void _addSvgFromAsset(String assetKey) {
    widget.onAddAsset(
      CardAssetItem(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        type: CardAssetType.svg,
        position: const Offset(120, 230),
        svgAssetKey: assetKey,
        scale: 1.0,
        color: const Color(0xFFD4AF37),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : const Color(0xFFFAF8F5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFEBE5DC),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isCompact = constraints.maxWidth < 450;
                final titleSection = Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppColors.caramelBronze.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.palette_rounded,
                        size: 18,
                        color: AppColors.caramelBronze,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'คลังของตกแต่งการ์ด (Canva Asset)',
                            style: GoogleFonts.prompt(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : AppColors.darkText,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            'แตะเพื่อเพิ่มลงการ์ด • ลากย้ายตำแหน่งได้อิสระ',
                            style: TextStyle(
                              fontSize: 11,
                              color: isDark ? const Color(0xFF94A3B8) : AppColors.subText,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                );

                final actionSection = Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextButton.icon(
                      onPressed: widget.onApplyPreset,
                      icon: const Icon(Icons.auto_fix_high_rounded, size: 14),
                      label: const Text('จัดเซ็ตสวยงาม', style: TextStyle(fontSize: 11.5)),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.caramelBronze,
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                    if (widget.totalAssetsCount > 0) ...[
                      const SizedBox(width: 6),
                      TextButton.icon(
                        onPressed: widget.onClearAll,
                        icon: const Icon(Icons.delete_sweep_rounded, size: 14),
                        label: Text(
                          'ล้าง (${widget.totalAssetsCount})',
                          style: const TextStyle(fontSize: 11.5, color: Color(0xFFEF4444)),
                        ),
                        style: TextButton.styleFrom(
                          foregroundColor: const Color(0xFFEF4444),
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                      ),
                    ],
                  ],
                );

                if (isCompact) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      titleSection,
                      const SizedBox(height: 6),
                      Align(
                        alignment: Alignment.centerRight,
                        child: actionSection,
                      ),
                    ],
                  );
                }

                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(child: titleSection),
                    actionSection,
                  ],
                );
              },
            ),
          ),

          // Tabs
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1EBE1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: TabBar(
              controller: _tabController,
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.transparent,
              labelPadding: const EdgeInsets.symmetric(horizontal: 4),
              indicator: BoxDecoration(
                color: isDark ? const Color(0xFF334155) : Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 4,
                  ),
                ],
              ),
              labelColor: isDark ? AppColors.starGold : AppColors.caramelBronze,
              unselectedLabelColor: isDark ? const Color(0xFF94A3B8) : AppColors.subText,
              labelStyle: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold),
              tabs: [
                Tab(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AppSvgIcons.sparkle(size: 13, color: isDark ? AppColors.starGold : AppColors.caramelBronze),
                        const SizedBox(width: 4),
                        const Text('สติกเกอร์'),
                      ],
                    ),
                  ),
                ),
                Tab(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AppSvgIcons.cake(size: 13, color: isDark ? AppColors.starGold : AppColors.caramelBronze),
                        const SizedBox(width: 4),
                        const Text('วันเกิด'),
                      ],
                    ),
                  ),
                ),
                Tab(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AppSvgIcons.seal(size: 13, color: isDark ? AppColors.starGold : AppColors.caramelBronze),
                        const SizedBox(width: 4),
                        const Text('ตรามงคล'),
                      ],
                    ),
                  ),
                ),
                Tab(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AppSvgIcons.pen(size: 13, color: isDark ? AppColors.starGold : AppColors.caramelBronze),
                        const SizedBox(width: 4),
                        const Text('ข้อความ'),
                      ],
                    ),
                  ),
                ),
                Tab(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AppSvgIcons.palette(size: 13, color: isDark ? AppColors.starGold : AppColors.caramelBronze),
                        const SizedBox(width: 4),
                        const Text('SVG มงคล'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // Tab Content
          SizedBox(
            height: 165,
            child: TabBarView(
              controller: _tabController,
              children: [
                // 1. สติกเกอร์ & ไอคอนมงคล
                _buildAuspiciousStickersGrid(isDark),

                // 2. วันเกิด & ปาร์ตี้
                _buildBirthdayStickersGrid(isDark),

                // 3. ตราประทับมงคล
                _buildSealsList(isDark),

                // 4. ข้อความอิสระ
                _buildCustomTextTab(isDark),

                // 5. SVG Assets จาก assets/icons/
                _buildSvgAssetsTab(isDark),
              ],
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildAuspiciousStickersGrid(bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Emoji stickers
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _auspiciousEmojis.map((emoji) {
              return InkWell(
                onTap: () => _addEmoji(emoji),
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  width: 38,
                  height: 38,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF0F172A) : Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isDark ? const Color(0xFF334155) : const Color(0xFFE5DECE),
                    ),
                  ),
                  child: Text(emoji, style: const TextStyle(fontSize: 20)),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 10),
          // Auspicious Vector Icons
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _auspiciousIcons.map((item) {
              return InkWell(
                onTap: () => _addIcon(item['icon'] as IconData),
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF0F172A) : Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isDark ? const Color(0xFF334155) : const Color(0xFFE5DECE),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(item['icon'] as IconData, size: 16, color: const Color(0xFFD4AF37)),
                      const SizedBox(width: 4),
                      Text(
                        item['name'] as String,
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark ? Colors.white70 : AppColors.darkText,
                        ),
                      ),
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

  Widget _buildBirthdayStickersGrid(bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        children: _birthdayEmojis.map((emoji) {
          return InkWell(
            onTap: () => _addEmoji(emoji),
            borderRadius: BorderRadius.circular(10),
            child: Container(
              width: 44,
              height: 44,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF0F172A) : Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isDark ? const Color(0xFF334155) : const Color(0xFFE5DECE),
                ),
              ),
              child: Text(emoji, style: const TextStyle(fontSize: 24)),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSealsList(bool isDark) {
    return ListView.separated(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      itemCount: _auspiciousSeals.length,
      separatorBuilder: (_, index) => const SizedBox(width: 10),
      itemBuilder: (context, index) {
        final seal = _auspiciousSeals[index];
        final Color sealColor = seal['color'];

        return InkWell(
          onTap: () => _addSeal(seal),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: 140,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF0F172A) : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: sealColor.withValues(alpha: 0.6), width: 1.4),
              boxShadow: [
                BoxShadow(
                  color: sealColor.withValues(alpha: 0.12),
                  blurRadius: 8,
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: sealColor.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(seal['icon'] as IconData, size: 22, color: sealColor),
                ),
                const SizedBox(height: 6),
                Text(
                  seal['title'] as String,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.prompt(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : AppColors.darkText,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  seal['subtitle'] as String,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 9.5,
                    color: isDark ? const Color(0xFF94A3B8) : AppColors.subText,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSvgAssetsTab(bool isDark) {
    // SVG assets จาก assets/icons/ — อ่านจากไฟล์จริงใน runtime
    final svgAssets = [
      {'name': ' blessing', 'assetKey': 'assets/icons/blessing.svg'},
      {'name': 'ดวงอาทิตย์', 'assetKey': 'assets/icons/sun.svg'},
      {'name': 'โหรา', 'assetKey': 'assets/icons/โหรา.svg'},
      {'name': 'โหรา 2', 'assetKey': 'assets/icons/โหรา2.svg'},
      {'name': 'ลูกแก้ว', 'assetKey': 'assets/icons/ลูกแก้ว.svg'},
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            ' SVG มงคลจาก assets — แตะเพื่อเพิ่มลงการ์ด',
            style: TextStyle(fontSize: 11, color: isDark ? const Color(0xFF94A3B8) : AppColors.subText),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: svgAssets.map((asset) {
              return InkWell(
                onTap: () => _addSvgFromAsset(asset['assetKey'] as String),
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  width: 90,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF0F172A) : Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isDark ? const Color(0xFF334155) : const Color(0xFFE5DECE),
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SvgPicture.asset(
                        asset['assetKey'] as String,
                        width: 40,
                        height: 40,
                        colorFilter: ColorFilter.mode(
                          isDark ? AppColors.starGold : AppColors.caramelBronze,
                          BlendMode.srcIn,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        asset['name'] as String,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white70 : AppColors.darkText,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 14),
          // เพิ่ม SVG เองจาก string
          Text(
            'SVG กำหนดเอง (ใส่ SVG string)',
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: isDark ? Colors.white70 : AppColors.subText),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _customSvgController,
                  style: TextStyle(fontSize: 12, color: isDark ? Colors.white : AppColors.darkText),
                  decoration: InputDecoration(
                    hintText: 'วาง SVG string...',
                    hintStyle: TextStyle(fontSize: 11, color: isDark ? Colors.white38 : AppColors.mutedText),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  maxLines: 2,
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: () {
                  final svg = _customSvgController.text.trim();
                  if (svg.isNotEmpty) {
                    _addSvg(svg);
                    _customSvgController.clear();
                  }
                },
                icon: const Icon(Icons.add_rounded, size: 16),
                label: const Text('เพิ่ม', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.caramelBronze,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCustomTextTab(bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 38,
                  child: TextField(
                    controller: _customTextController,
                    style: TextStyle(fontSize: 12.5, color: isDark ? Colors.white : AppColors.darkText),
                    decoration: InputDecoration(
                      hintText: 'พิมพ์ข้อความอิสระ เช่น HBD, มั่งมีศรีสุข...',
                      hintStyle: TextStyle(fontSize: 11.5, color: isDark ? Colors.white38 : AppColors.mutedText),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onSubmitted: (val) {
                      _addText(val);
                      _customTextController.clear();
                    },
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: () {
                  _addText(_customTextController.text);
                  _customTextController.clear();
                },
                icon: const Icon(Icons.add_rounded, size: 16),
                label: const Text('เพิ่ม', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.caramelBronze,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'ข้อความสำเร็จรูปแนะนำ (แตะเพื่อเพิ่ม):',
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: isDark ? Colors.white70 : AppColors.subText),
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: _textTemplates.map((template) {
              return ActionChip(
                label: Text(template, style: const TextStyle(fontSize: 11)),
                onPressed: () => _addText(template),
                backgroundColor: isDark ? const Color(0xFF0F172A) : Colors.white,
                side: BorderSide(color: isDark ? const Color(0xFF334155) : const Color(0xFFE5DECE)),
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
