import 'package:flutter/material.dart';
import '../services/customer_service.dart';
import '../utils/animation_helper.dart';
import '../utils/app_colors.dart';
import '../widgets/home/home_birthdays_section.dart';
import '../widgets/home/home_sanctuary_header.dart';
import 'notes_view.dart';
import 'stats_view.dart';
import 'settings_view.dart';

/// หน้าแรก โหราเดย์: แท่นบูชาดวงชะตาและศูนย์มงคลประจำวัน (Astrologer Studio Hub & Altar)
/// ออกแบบใหม่ตามแนวคิด "Deep Celestial Sanctuary & Warm Zen Studio"
/// รองรับทั้งโหมดสว่างนวลตา และโหมดมืดลึกมนต์ขลังดวงดาว สลับได้ด้วย 1 สัมผัส
class HomeView extends StatelessWidget {
  final CustomerService customerService;
  final Function(int tabIndex) onNavigateToTab;
  final VoidCallback onAddNewCustomer;

  const HomeView({
    super.key,
    required this.customerService,
    required this.onNavigateToTab,
    required this.onAddNewCustomer,
  });

  void _openNotes(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => NotesView(customerService: customerService),
      ),
    );
  }

  void _openStats(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => StatsView(customerService: customerService),
      ),
    );
  }

  void _openSettings(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => SettingsView(customerService: customerService),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final customersWithNotes = customerService.customersWithNotes;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: MediaQuery.removePadding(
            context: context,
            removeTop: true,
            child: ListView(
              padding: const EdgeInsets.only(bottom: 96),
              physics: const BouncingScrollPhysics(),
              children: [
                // =========================================================
                // 1. Studio Header Sanctuary Canopy
                // =========================================================
                HomeSanctuaryHeader(
                  customerService: customerService,
                  onAddNewCustomer: onAddNewCustomer,
                  onOpenStats: () => _openStats(context),
                  onOpenNotes: () => _openNotes(context),
                  onOpenSettings: () => _openSettings(context),
                  onNavigateToTab: onNavigateToTab,
                ),

                const SizedBox(height: 18),

                // =========================================================
                // 2. Main Content Stream (กระแสข้อมูลวันเกิดและบันทึกดวง)
                // =========================================================
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // All Birthdays Section
                      HomeBirthdaysSection(
                        customerService: customerService,
                        onAddNewCustomer: onAddNewCustomer,
                      ),

                      // Distilled notes entry
                      if (customersWithNotes.isNotEmpty) ...[
                        const SizedBox(height: 28),
                        StaggeredEntrance(
                          index: 4,
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () => _openNotes(context),
                              borderRadius: BorderRadius.circular(14),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 14,
                                ),
                                decoration: BoxDecoration(
                                  color: context.surfaceColor.withValues(
                                    alpha: context.isDark ? 0.8 : 0.55,
                                  ),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: context.borderColor,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.menu_book_outlined,
                                      size: 18,
                                      color: context.goldColor,
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        'บันทึกดวงชะตา ${customersWithNotes.length} ฉบับ',
                                        style: TextStyle(
                                          fontSize: 13.5,
                                          fontWeight: FontWeight.w600,
                                          color: context.textColor,
                                        ),
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () => _openStats(context),
                                      style: TextButton.styleFrom(
                                        minimumSize: const Size(44, 44),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                        ),
                                      ),
                                      child: Text(
                                        'สถิติ',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: context.subTextColor,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                    Icon(
                                      Icons.arrow_forward_ios_rounded,
                                      size: 13,
                                      color: context.mutedTextColor,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
