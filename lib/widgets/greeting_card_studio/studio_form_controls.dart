import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/card_theme_style.dart';
import '../../models/customer.dart';
import '../../utils/app_colors.dart';

class StudioFormControls extends StatelessWidget {
  final List<Customer> customers;
  final Customer? selectedCustomer;
  final TextEditingController nameController;
  final TextEditingController nicknameController;
  final TextEditingController ageController;
  final TextEditingController blessingController;
  final TextEditingController signatureController;
  final CardThemeStyle selectedTheme;
  final Color dayColor;
  final String dayName;
  final bool showAge;
  final bool showDayOfWeek;
  final int selectedBlessingCategory;
  final List<Map<String, String>> blessingTemplates;
  final ValueChanged<Customer?> onCustomerSelected;
  final ValueChanged<CardThemeStyle> onThemeSelected;
  final ValueChanged<int> onBlessingCategorySelected;
  final ValueChanged<bool> onToggleShowAge;
  final ValueChanged<bool> onToggleShowDayOfWeek;
  final VoidCallback onSwitchToCanvaTab;

  const StudioFormControls({
    super.key,
    required this.customers,
    required this.selectedCustomer,
    required this.nameController,
    required this.nicknameController,
    required this.ageController,
    required this.blessingController,
    required this.signatureController,
    required this.selectedTheme,
    required this.dayColor,
    required this.dayName,
    required this.showAge,
    required this.showDayOfWeek,
    required this.selectedBlessingCategory,
    required this.blessingTemplates,
    required this.onCustomerSelected,
    required this.onThemeSelected,
    required this.onBlessingCategorySelected,
    required this.onToggleShowAge,
    required this.onToggleShowDayOfWeek,
    required this.onSwitchToCanvaTab,
  });

  Widget _buildThemeChip(
    BuildContext context, {
    required CardThemeStyle style,
    required String title,
    required Color color,
    String? thumbnailAsset,
  }) {
    final isSelected = selectedTheme == style;
    return ChoiceChip(
      avatar: thumbnailAsset != null
          ? CircleAvatar(
              radius: 14,
              backgroundColor: Colors.grey.shade200,
              child: ClipOval(
                child: Image.asset(
                  thumbnailAsset,
                  width: 28,
                  height: 28,
                  fit: BoxFit.cover,
                ),
              ),
            )
          : CircleAvatar(backgroundColor: color, radius: 6),
      label: Text(
        title,
        style: TextStyle(
          fontSize: 12,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          color: isSelected ? color : context.textColor,
        ),
      ),
      selected: isSelected,
      selectedColor: color.withValues(alpha: 0.2),
      backgroundColor: context.isDark ? const Color(0xFF1E293B) : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      side: BorderSide(
        color: isSelected ? color : context.borderColor,
        width: isSelected ? 1.5 : 1.0,
      ),
      onSelected: (selected) {
        if (selected) onThemeSelected(style);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. เลือกลูกดวง
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Text(
                '1. ข้อมูลผู้รับคำอวยพร',
                style: GoogleFonts.prompt(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: context.textColor,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (customers.isNotEmpty) ...[
              const SizedBox(width: 8),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 180),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<Customer?>(
                    isExpanded: true,
                    value: selectedCustomer,
                    dropdownColor: context.cardColor,
                    hint: Text('เลือกลูกดวง', style: TextStyle(fontSize: 12, color: context.subTextColor), overflow: TextOverflow.ellipsis),
                    icon: Icon(Icons.arrow_drop_down_rounded, size: 20, color: context.subTextColor),
                    items: [
                      DropdownMenuItem<Customer?>(
                        value: null,
                        child: Text('— กำหนดชื่อเอง —', style: TextStyle(fontSize: 12.5, color: context.textColor), overflow: TextOverflow.ellipsis),
                      ),
                      ...customers.map(
                        (c) => DropdownMenuItem<Customer?>(
                          value: c,
                          child: Text(
                            c.nickname.isNotEmpty ? '${c.fullName} (${c.nickname})' : c.fullName,
                            style: TextStyle(fontSize: 12.5, color: context.textColor),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ],
                    onChanged: onCustomerSelected,
                  ),
                ),
              ),
            ],
          ],
        ),

        const SizedBox(height: 10),

        // TextFields
        Row(
          children: [
            Expanded(
              flex: 3,
              child: TextFormField(
                controller: nameController,
                style: TextStyle(fontSize: 13.5, color: context.textColor),
                decoration: const InputDecoration(
                  labelText: 'ชื่อ-นามสกุล',
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              flex: 2,
              child: TextFormField(
                controller: nicknameController,
                style: TextStyle(fontSize: 13.5, color: context.textColor),
                decoration: const InputDecoration(
                  labelText: 'ชื่อเล่น',
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              width: 72,
              child: TextFormField(
                controller: ageController,
                style: TextStyle(fontSize: 13.5, color: context.textColor),
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'อายุ (ปี)',
                  contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 20),

        // 2. เลือกธีมการ์ด
        Text(
          '2. สไตล์ & โทนสีการ์ดมงคล',
          style: GoogleFonts.prompt(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: context.textColor,
          ),
        ),
        const SizedBox(height: 10),

        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildThemeChip(
              context,
              style: CardThemeStyle.celestialGold,
              title: 'ทองแชมเปญ',
              color: const Color(0xFFD4AF37),
              thumbnailAsset: 'assets/templates/1.png',
            ),
            _buildThemeChip(
              context,
              style: CardThemeStyle.celestialGold2,
              title: 'ทองแชมเปญ 2',
              color: const Color(0xFFD4AF37),
              thumbnailAsset: 'assets/templates/1-1.png',
            ),
            _buildThemeChip(
              context,
              style: CardThemeStyle.celestialGold3,
              title: 'ทองแชมเปญ 3',
              color: const Color(0xFFD4AF37),
              thumbnailAsset: 'assets/templates/1-2.png',
            ),
            _buildThemeChip(
              context,
              style: CardThemeStyle.midnightCosmic,
              title: 'รัตติกาลดวงดาว',
              color: const Color(0xFF1E293B),
              thumbnailAsset: 'assets/templates/2.png',
            ),
            _buildThemeChip(
              context,
              style: CardThemeStyle.midnightCosmic2,
              title: 'รัตติกาล 2',
              color: const Color(0xFF1E293B),
              thumbnailAsset: 'assets/templates/2-1.png',
            ),
            _buildThemeChip(
              context,
              style: CardThemeStyle.midnightCosmic3,
              title: 'รัตติกาล 3',
              color: const Color(0xFF1E293B),
              thumbnailAsset: 'assets/templates/2-2.png',
            ),
            _buildThemeChip(
              context,
              style: CardThemeStyle.birthMineralDay,
              title: 'สีมงคลวันเกิด ($dayName)',
              color: dayColor,
              thumbnailAsset: 'assets/templates/1-3.png',
            ),
            _buildThemeChip(
              context,
              style: CardThemeStyle.rubyFortune,
              title: 'ทับทิมบารมี',
              color: const Color(0xFFB91C1C),
              thumbnailAsset: 'assets/templates/3.png',
            ),
            _buildThemeChip(
              context,
              style: CardThemeStyle.emeraldPeace,
              title: 'มรกตสันติสุข',
              color: const Color(0xFF047857),
              thumbnailAsset: 'assets/templates/3-1 (1).png',
            ),
            _buildThemeChip(
              context,
              style: CardThemeStyle.emeraldPeace2,
              title: 'มรกต 2',
              color: const Color(0xFF047857),
              thumbnailAsset: 'assets/templates/3-1 (2).png',
            ),
            _buildThemeChip(
              context,
              style: CardThemeStyle.emeraldPeace3,
              title: 'มรกต 3',
              color: const Color(0xFF047857),
              thumbnailAsset: 'assets/templates/3-1 (3).png',
            ),
            _buildThemeChip(
              context,
              style: CardThemeStyle.lotusMetta,
              title: 'บัวชมพูเมตตา',
              color: const Color(0xFFDB2777),
              thumbnailAsset: 'assets/templates/2-3.png',
            ),
          ],
        ),

        const SizedBox(height: 22),

        // 3. หมวดหมู่และข้อความคำอวยพร
        Text(
          '3. คำอวยพร & พรสิริมงคล',
          style: GoogleFonts.prompt(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: context.textColor,
          ),
        ),
        const SizedBox(height: 8),

        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: List.generate(blessingTemplates.length, (index) {
              final item = blessingTemplates[index];
              final isSelected = selectedBlessingCategory == index;
              final iconColor = isSelected ? context.goldColor : context.subTextColor;
              return Padding(
                padding: const EdgeInsets.only(right: 6),
                child: ChoiceChip(
                  avatar: SvgPicture.string(
                    item['svg']!,
                    width: 15,
                    height: 15,
                    colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
                  ),
                  label: Text(
                    item['title']!,
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                      color: isSelected ? context.goldColor : context.textColor,
                    ),
                  ),
                  selected: isSelected,
                  selectedColor: context.goldColor.withValues(alpha: 0.18),
                  backgroundColor: context.isDark ? const Color(0xFF1E293B) : Colors.white,
                  side: BorderSide(color: isSelected ? context.goldColor : context.borderColor),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  onSelected: (selected) {
                    if (selected) onBlessingCategorySelected(index);
                  },
                ),
              );
            }),
          ),
        ),

        const SizedBox(height: 10),

        TextFormField(
          controller: blessingController,
          maxLines: 4,
          decoration: InputDecoration(
            hintText: 'พิมพ์แก้ไขข้อความคำอวยพรได้ตามใจชอบ...',
            hintStyle: TextStyle(color: context.mutedTextColor),
            filled: true,
            fillColor: context.isDark ? const Color(0xFF1E293B) : Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          style: TextStyle(fontSize: 13.5, height: 1.5, color: context.textColor),
        ),

        const SizedBox(height: 14),

        // 4. ลายเซ็นคำลงท้าย
        TextFormField(
          controller: signatureController,
          style: TextStyle(fontSize: 13.5, color: context.textColor),
          decoration: const InputDecoration(
            labelText: 'ข้อความลงท้าย / ลายเซ็นอาจารย์',
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          ),
        ),

        const SizedBox(height: 16),

        // 5. สวิตช์แสดงผล
        Row(
          children: [
            Expanded(
              child: SwitchListTile(
                contentPadding: EdgeInsets.zero,
                dense: true,
                title: Text('แสดงอายุ', style: TextStyle(fontSize: 13, color: context.textColor, fontWeight: FontWeight.w500)),
                value: showAge,
                onChanged: onToggleShowAge,
              ),
            ),
            Expanded(
              child: SwitchListTile(
                contentPadding: EdgeInsets.zero,
                dense: true,
                title: Text('แสดงวันเกิด', style: TextStyle(fontSize: 13, color: context.textColor, fontWeight: FontWeight.w500)),
                value: showDayOfWeek,
                onChanged: onToggleShowDayOfWeek,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: context.goldColor.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: context.goldColor.withValues(alpha: 0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.palette_outlined, color: AppColors.caramelBronze, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'ต้องการตกแต่งการ์ดเพิ่มเติมหรือจัดระเบียบเลเยอร์? สลับไปที่แท็บ "2. คลังตกแต่ง Canva" ด้านบน',
                      style: TextStyle(
                        fontSize: 12,
                        color: context.textColor,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: onSwitchToCanvaTab,
                  icon: const Icon(Icons.arrow_forward_rounded, size: 14),
                  label: const Text('ไปที่คลังตกแต่ง', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
