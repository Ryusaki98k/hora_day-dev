import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/customer_service.dart';
import '../../utils/animation_helper.dart';
import '../../utils/app_colors.dart';
import '../../views/greeting_card_studio_view.dart';
import '../celestial_starfield.dart';
import 'home_pulse_card.dart';

class HomeSanctuaryHeader extends StatelessWidget {
  final CustomerService customerService;
  final VoidCallback onAddNewCustomer;
  final VoidCallback onOpenStats;
  final VoidCallback onOpenNotes;
  final VoidCallback onOpenSettings;
  final Function(int tabIndex) onNavigateToTab;

  const HomeSanctuaryHeader({
    super.key,
    required this.customerService,
    required this.onAddNewCustomer,
    required this.onOpenStats,
    required this.onOpenNotes,
    required this.onOpenSettings,
    required this.onNavigateToTab,
  });

  @override
  Widget build(BuildContext context) {
    final upcomingCustomers = customerService.upcomingBirthdayCustomers;
    final customersWithNotes = customerService.customersWithNotes;
    final totalCustomers = customerService.customers.length;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: context.isDark
              ? const [
                  Color(0xFF131B2F),
                  Color(0xFF0F172A),
                  Color(0xFF090D18),
                ]
              : const [
                  Color(0xFFF7F1E6),
                  Color(0xFFF3ECE0),
                  Color(0xFFEDE4D4),
                ],
          stops: const [0.0, 0.6, 1.0],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
        border: Border(
          bottom: BorderSide(
            color: context.isDark
                ? AppColors.celestialBorder.withValues(alpha: 0.8)
                : AppColors.warmBorder.withValues(alpha: 0.9),
            width: 1.0,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: context.isDark
                ? const Color(0x33000000)
                : const Color(0xFF78350F).withValues(alpha: 0.05),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
        child: Stack(
          children: [
            // Auspicious Celestial Starfield & Shooting Stars Watermark
            Positioned.fill(
              child: CelestialStarfield(
                isDark: context.isDark,
              ),
            ),
            SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Brand Header Bar
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final isCompact = constraints.maxWidth < 410;
                        final isVeryCompact = constraints.maxWidth < 350;

                        return Row(
                          children: [
                            Container(
                              width: isVeryCompact ? 34 : 40,
                              height: isVeryCompact ? 34 : 40,
                              decoration: BoxDecoration(
                                color: context.cardColor,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: context.isDark
                                      ? AppColors.starGold.withValues(alpha: 0.5)
                                      : AppColors.amberGold.withValues(alpha: 0.5),
                                ),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Color(0x08000000),
                                    blurRadius: 6,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              alignment: Alignment.center,
                              child: AnimatedSparkleIcon(
                                color: context.goldColor,
                                size: isVeryCompact ? 18 : 22,
                              ),
                            ),
                            SizedBox(width: isVeryCompact ? 8 : 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Hora Day',
                                    style: GoogleFonts.prompt(
                                      fontSize: isVeryCompact ? 17 : 19,
                                      fontWeight: FontWeight.w800,
                                      color: context.textColor,
                                      letterSpacing: -0.3,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    'สมุดดวงชะตา & ศูนย์วันเกิดมงคล',
                                    style: GoogleFonts.sarabun(
                                      fontSize: isVeryCompact ? 11 : 12,
                                      color: context.subTextColor,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 6),
                            // Quick Add Action (+ เพิ่ม)
                            AnimatedPressable(
                              onTap: onAddNewCustomer,
                              borderRadius: BorderRadius.circular(10),
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: isCompact ? 10 : 13,
                                  vertical: 7,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.caramelBronze,
                                  borderRadius: BorderRadius.circular(10),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Color(0x18000000),
                                      blurRadius: 4,
                                      offset: Offset(0, 1),
                                    ),
                                  ],
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.person_add_rounded,
                                      size: 16,
                                      color: Colors.white,
                                    ),
                                    SizedBox(width: 5),
                                    Text(
                                      'เพิ่ม',
                                      style: TextStyle(
                                        fontSize: 12.5,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            // Stats Overview Shortcut
                            AnimatedPressable(
                              onTap: onOpenStats,
                              borderRadius: BorderRadius.circular(10),
                              child: Container(
                                padding: const EdgeInsets.all(7),
                                decoration: BoxDecoration(
                                  color: context.isDark
                                      ? AppColors.astralSurface
                                      : Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: context.borderColor,
                                  ),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Color(0x06000000),
                                      blurRadius: 4,
                                      offset: Offset(0, 1),
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  Icons.insights_rounded,
                                  size: 16,
                                  color: context.goldColor,
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            const AppThemeToggleButton(compact: true),
                            const SizedBox(width: 6),
                            // Settings shortcut
                            AnimatedPressable(
                              onTap: onOpenSettings,
                              borderRadius: BorderRadius.circular(10),
                              child: Container(
                                padding: const EdgeInsets.all(7),
                                decoration: BoxDecoration(
                                  color: context.isDark
                                      ? AppColors.astralSurface
                                      : Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: context.borderColor,
                                  ),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Color(0x06000000),
                                      blurRadius: 4,
                                      offset: Offset(0, 1),
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  Icons.settings_rounded,
                                  size: 16,
                                  color: context.goldColor,
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),

                    const SizedBox(height: 16),

                    // Clean 3-Metric Pulse Container (Unified Background Card)
                    StaggeredEntrance(
                      index: 0,
                      child: Container(
                        decoration: BoxDecoration(
                          color: context.cardColor,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: context.borderColor,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: context.isDark
                                  ? const Color(0x33000000)
                                  : const Color(0x05000000),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                child: HomePulseCard(
                                  icon: Icons.cake_outlined,
                                  label: 'วันเกิดใกล้ถึง',
                                  count: upcomingCustomers.length,
                                  unit: 'ท่าน',
                                  color: upcomingCustomers.isNotEmpty
                                      ? const Color(0xFFDC2626)
                                      : context.goldColor,
                                  onTap: () {},
                                ),
                              ),
                              Container(
                                width: 1,
                                height: 44,
                                color: context.borderColor,
                              ),
                              Expanded(
                                child: HomePulseCard(
                                  icon: Icons.people_alt_outlined,
                                  label: 'ลูกดวงทั้งหมด',
                                  count: totalCustomers,
                                  unit: 'ท่าน',
                                  color: context.goldColor,
                                  onTap: () => onNavigateToTab(1),
                                ),
                              ),
                              Container(
                                width: 1,
                                height: 44,
                                color: context.borderColor,
                              ),
                              Expanded(
                                child: HomePulseCard(
                                  icon: Icons.menu_book_outlined,
                                  label: 'มีบันทึกดวง',
                                  count: customersWithNotes.length,
                                  unit: 'ท่าน',
                                  color: const Color(0xFF059669),
                                  onTap: onOpenNotes,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Auspicious Greeting Card Studio Shortcut
                    StaggeredEntrance(
                      index: 1,
                      child: AnimatedPressable(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => GreetingCardStudioView(
                                customerService: customerService,
                              ),
                            ),
                          );
                        },
                        borderRadius: BorderRadius.circular(14),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                          decoration: BoxDecoration(
                            color: context.cardColor,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: context.isDark
                                  ? AppColors.starGold.withValues(alpha: 0.35)
                                  : AppColors.amberGold.withValues(alpha: 0.45),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: context.isDark
                                    ? const Color(0x33000000)
                                    : const Color(0x0A78350F),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [AppColors.caramelBronze, AppColors.amberGold],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: AppColors.goldGlow,
                                      blurRadius: 6,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.card_giftcard_rounded,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'การ์ดอวยพรวันเกิดมงคล',
                                      style: GoogleFonts.prompt(
                                        fontSize: 13.5,
                                        fontWeight: FontWeight.bold,
                                        color: context.textColor,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'เลือกแบบการ์ด • ใส่ชื่อ & คำอวยพร',
                                      style: GoogleFonts.sarabun(
                                        fontSize: 11,
                                        color: context.subTextColor,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: context.goldColor,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.palette_outlined,
                                      size: 13,
                                      color: context.isDark ? AppColors.celestialVoid : Colors.white,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'สร้างการ์ด',
                                      style: TextStyle(
                                        fontSize: 11.5,
                                        fontWeight: FontWeight.bold,
                                        color: context.isDark ? AppColors.celestialVoid : Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
