import 'package:flutter/material.dart';

/// ชุดสี Warm Zen & Minimal Studio (นวลครีมงาช้าง โมเดิร์น คลีน สบายตา มินิมอลเรียบหรู)
/// สอดคล้องตามหลักสรีรศาสตร์สายตา และความคมชัดระดับ WCAG AA / AAA
class AppColors {
  // 1. Warm Zen Canvas & Neutral Surfaces
  static const Color ivory = Color(0xFFFAF8F5);          // พื้นหลังหลัก: นวลครีมงาช้าง สว่าง สะอาดตา อ่อนโยน
  static const Color warmSand = Color(0xFFF3EFE6);       // สีพื้นผิวรอง: ทรายนวลอบอุ่น สำหรับการ์ดหรือแผงควบคุม
  static const Color warmCard = Color(0xFFFFFFFF);       // สีพื้นการ์ด: ขาวบริสุทธิ์เพื่อมิติที่คมชัดและสบายตา
  static const Color warmSurfaceHover = Color(0xFFF6F2E9);// สีไฮไลต์เมื่อ Hover หรือแตะสัมผัส
  static const Color warmBorder = Color(0xFFEBE5DC);     // เส้นขอบบางเฉียบ (Hairline): ละมุน ไม่แย่งสายตา

  // 2. Auspicious Refined Gold & Bronze Accents (ใช้ด้วยความประณีต สุภาพ มินิมอล)
  static const Color caramelBronze = Color(0xFFA87532);  // สีทองบรอนซ์คาราเมลละมุน: ปุ่มหลัก และจุดเน้นสำคัญ
  static const Color amberGold = Color(0xFFD4A359);      // สีทองอำพันประกายสงบ: เส้นเน้นและไอคอนมงคล
  static const Color champagne = Color(0xFFF5EEDB);      // สีแชมเปญนวล: พื้นหลังชิปและป้ายข้อความย่อย
  static const Color deepGoldText = Color(0xFF78450A);   // สีทองเข้มสำหรับข้อความ: คมชัดสูงพิเศษ (>7:1 WCAG AAA)
  static const Color goldGlow = Color(0x1AA87532);       // เงาฟุ้งทองบางเบา นุ่มนวล ไม่ฟุ้งกระจายจนรกตา

  // 3. Ink & Typographic Hierarchy (หมึกชาร์โคลอบอุ่น สบายตา นุ่มนวลกว่าสีดำสนิท)
  static const Color darkText = Color(0xFF141311);       // ข้อความหลัก: ชาร์โคลอุ่น คมชัดสูงสุด (>15:1 AAA)
  static const Color subText = Color(0xFF423C34);        // ข้อความรอง: คมชัดระดับ WCAG AAA (>8:1 AAA)
  static const Color mutedText = Color(0xFF5A534A);      // ข้อความบอกใบ้: คมชัดระดับ WCAG AA (>5.5:1 AA)
  static const Color deepSlate = Color(0xFF1E293B);      // หินชนวนเข้มลึกสำหรับแถบส่วนหัวและการเน้นเข้ม

  // 4. Auspicious Mineral Day Colors (แร่ธาตุมงคลประจำวันเกิด 7 วัน โทนสงบ ไม่ฉูดฉาด)
  static const Color daySunday = Color(0xFFDC2626);      // อาทิตย์ - ทับทิมมงคล (Ruby Crimson)
  static const Color dayMonday = Color(0xFFD97706);      // จันทร์ - บุษราคัมอำพัน (Amber Ochre)
  static const Color dayTuesday = Color(0xFFDB2777);     // อังคาร - กลีบบัวมงคล (Lotus Rose)
  static const Color dayWednesday = Color(0xFF059669);   // พุธ - หยกมรกต (Jade Mineral)
  static const Color dayThursday = Color(0xFFEA580C);    // พฤหัสบดี - คุรุสุวรรณ (Terracotta Gold)
  static const Color dayFriday = Color(0xFF0284C7);      // ศุกร์ - ไพลินสงบ (Cerulean Slate)
  static const Color daySaturday = Color(0xFF7C3AED);    // เสาร์ - นิลกาฬอเมทิสต์ (Deep Amethyst)

  /// คืนค่าสีประจำวันเกิดตามมาตรฐานแร่ธาตุมงคล (1=จันทร์ .. 7=อาทิตย์)
  static Color getDayColor(int weekday) {
    switch (weekday) {
      case 1:
        return dayMonday;
      case 2:
        return dayTuesday;
      case 3:
        return dayWednesday;
      case 4:
        return dayThursday;
      case 5:
        return dayFriday;
      case 6:
        return daySaturday;
      case 7:
        return daySunday;
      default:
        return caramelBronze;
    }
  }

  // 5. Semantic Accents
  static const Color royalIndigo = Color(0xFF4338CA);    // สีครามราชสำนัก
  static const Color successGreen = Color(0xFF059669);   // สีเขียวสำเร็จเรียบร้อย

  // 6. Deep Celestial Sanctuary Canvas & Surfaces (Mood Mode / รัตติกาลมืดมนต์ขลัง)
  static const Color celestialVoid = Color(0xFF090C15);         // พื้นหลังลึกสุด: รัตติกาลออบซิเดียน ไม่สะท้อนตา
  static const Color midnightSlate = Color(0xFF111728);        // พื้นหลังการ์ดลึก: หินชนวนรัตติกาล มีมิติ
  static const Color astralSurface = Color(0xFF182238);        // พื้นผิวรอง: เนบิวลาน้ำเงินลึก สำหรับชิป/คอนเทนเนอร์
  static const Color astralSurfaceHover = Color(0xFF222E4A);   // ไฮไลต์เมื่อสัมผัสในโหมดมืด
  static const Color celestialBorder = Color(0xFF23304B);      // เส้นขอบบางเฉียบประกายอวกาศ
  static const Color celestialBorderGlow = Color(0x33FBBF24);  // ขอบเรืองรองทองคำดาว

  // 7. Celestial Divine Golds & Accents (ทองประกายดาวในห้วงรัตติกาล)
  static const Color starGold = Color(0xFFFBBF24);             // ทองประกายดาว: จุดโฟกัสและไอคอนนำโชค
  static const Color starGoldHover = Color(0xFFF59E0B);        // ทองเข้มขึ้นเมื่อแตะสัมผัส
  static const Color celestialAmber = Color(0xFFD97706);       // อำพันสุริยะเรืองรอง
  static const Color celestialChampagne = Color(0xFF282315);   // แชมเปญเข้มสำหรับพื้นหลังชิปในโหมดมืด
  static const Color celestialGoldText = Color(0xFFFDE047);    // ข้อความสีทองสว่าง: คมชัดสูงสุดบนพื้นมืด (>13:1 AAA)
  static const Color moonGlow = Color(0x24FBBF24);             // ออร่าแสงจันทร์ทองเรืองรอง

  // 8. Starlight Typographic Hierarchy (ตัวอักษรประกายดาว คมชัดตามเกณฑ์ WCAG AAA)
  static const Color starlightText = Color(0xFFF8FAFC);        // ข้อความหลัก: ขาวสว่างประกายดาว (>15:1 AAA)
  static const Color celestialSubText = Color(0xFFCBD5E1);     // ข้อความรอง: หินชนวนประกายดาว (>10:1 AAA)
  static const Color celestialMutedText = Color(0xFFA6B7D4);   // ข้อความบอกใบ้: คมชัดบนพื้นมืด (>6.5:1 AA)

  // 9. Dynamic Adaptive Theme Color Helpers
  static Color canvas(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? celestialVoid : ivory;

  static Color card(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? midnightSlate : warmCard;

  static Color surface(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? astralSurface : warmSand;

  static Color border(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? celestialBorder : warmBorder;

  static Color text(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? starlightText : darkText;

  static Color sub(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? celestialSubText : subText;

  static Color muted(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? celestialMutedText : mutedText;

  static Color gold(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? celestialGoldText : deepGoldText;

  static Color chipBg(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? celestialChampagne : champagne;

  static Color chipText(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? celestialGoldText : deepGoldText;
}

/// Extension สำหรับเรียกใช้ชุดสีตามธีมได้อย่างสะดวกผ่าน context
extension AppThemeContext on BuildContext {
  bool get isDark => Theme.of(this).brightness == Brightness.dark;
  Color get canvasColor => AppColors.canvas(this);
  Color get scaffoldBgColor => AppColors.canvas(this);
  Color get cardColor => AppColors.card(this);
  Color get surfaceColor => AppColors.surface(this);
  Color get borderColor => AppColors.border(this);
  Color get textColor => AppColors.text(this);
  Color get subTextColor => AppColors.sub(this);
  Color get mutedTextColor => AppColors.muted(this);
  Color get goldColor => AppColors.gold(this);
  Color get chipBgColor => AppColors.chipBg(this);
  Color get chipTextColor => AppColors.chipText(this);
}

/// ตัวจัดการสถานะและเปลี่ยนโหมดธีม (Light / Dark Mode Controller)
class AppThemeController {
  static final ValueNotifier<ThemeMode> themeModeNotifier =
      ValueNotifier<ThemeMode>(ThemeMode.light);

  static bool get isDark => themeModeNotifier.value == ThemeMode.dark;

  static void toggleTheme() {
    themeModeNotifier.value =
        themeModeNotifier.value == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
  }

  static void setDarkMode(bool dark) {
    themeModeNotifier.value = dark ? ThemeMode.dark : ThemeMode.light;
  }
}

/// ปุ่มสลับโหมด Light / Dark Mode สำเร็จรูป แสดงไอคอนพระอาทิตย์ / พระจันทร์
class AppThemeToggleButton extends StatelessWidget {
  final bool compact;
  final Color? color;

  const AppThemeToggleButton({
    super.key,
    this.compact = false,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: AppThemeController.themeModeNotifier,
      builder: (context, mode, _) {
        final isDark = mode == ThemeMode.dark;
        return Tooltip(
          message: isDark ? 'เปลี่ยนเป็นโหมดสว่าง (Light Mode)' : 'เปลี่ยนเป็นโหมดมืด (Dark Mode)',
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: AppThemeController.toggleTheme,
              borderRadius: BorderRadius.circular(10),
              child: Container(
                padding: EdgeInsets.all(compact ? 6 : 8),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF182238)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isDark
                        ? AppColors.celestialBorder
                        : const Color(0xFFEBE5DC),
                    width: 1,
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x06000000),
                      blurRadius: 4,
                      offset: Offset(0, 1),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                      size: compact ? 16 : 18,
                      color: color ?? (isDark ? AppColors.starGold : AppColors.amberGold),
                    ),
                    if (!compact) ...[
                      const SizedBox(width: 5),
                      Text(
                        isDark ? 'โหมดมืด' : 'โหมดสว่าง',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: isDark ? const Color(0xFFF8FAFC) : AppColors.darkText,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
