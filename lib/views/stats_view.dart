import 'package:flutter/material.dart';
import '../services/customer_service.dart';
import '../utils/animation_helper.dart';
import '../utils/app_colors.dart';

/// หน้าจอภาพรวมสถิติดวงชะตาลูกดวง (Astrological Studio Insights)
/// ออกแบบใหม่ตามหลัก Warm Zen & Minimal Studio:
/// เรียบหรู สะอาดตา แสดงสัดส่วนวันเกิด 7 วัน และข้อมูลทางสถิติอย่างชัดเจน
class StatsView extends StatelessWidget {
  final CustomerService customerService;

  const StatsView({super.key, required this.customerService});

  Color _getDayMineralColor(int weekday) {
    return AppColors.getDayColor(weekday);
  }

  @override
  Widget build(BuildContext context) {
    final customers = customerService.customers;
    final total = customers.length;

    final dayNames = [
      'วันจันทร์',
      'วันอังคาร',
      'วันพุธ',
      'วันพฤหัสบดี',
      'วันศุกร์',
      'วันเสาร์',
      'วันอาทิตย์',
    ];

    final dayCounts = List.generate(7, (index) {
      final weekday = index + 1;
      return customers.where((c) => c.birthDate.weekday == weekday).length;
    });

    final maxDayCount = dayCounts.isEmpty ? 1 : dayCounts.reduce((a, b) => a > b ? a : b);

    // Group by province
    final provinceMap = <String, int>{};
    for (final c in customers) {
      final prov = c.province.trim().isNotEmpty ? c.province.trim() : 'ไม่ระบุจังหวัด';
      provinceMap[prov] = (provinceMap[prov] ?? 0) + 1;
    }
    final sortedProvinces = provinceMap.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Scaffold(
      backgroundColor: context.scaffoldBgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        titleSpacing: 16,
        title: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.champagne.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.amberGold.withValues(alpha: 0.6)),
              ),
              child: AnimatedSparkleIcon(icon: Icons.insights_rounded, color: context.goldColor, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'สถิติดวงชะตาลูกดวง',
                    style: TextStyle(
                      fontSize: 17.5,
                      fontWeight: FontWeight.bold,
                      color: context.textColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    'ภาพรวมฐานข้อมูล & สัดส่วนวันเกิด 7 วัน',
                    style: TextStyle(fontSize: 11.5, color: context.subTextColor, fontWeight: FontWeight.w500),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 88),
            physics: const BouncingScrollPhysics(),
            children: [
              // 1. Overview 3-Metric Boxes
              StaggeredEntrance(
                index: 0,
                child: Row(
                  children: [
                    Expanded(
                      child: _buildMetricCard(
                        context: context,
                        label: 'ลูกดวงทั้งหมด',
                        count: total,
                        unit: 'ท่าน',
                        icon: Icons.people_alt_outlined,
                        color: context.goldColor,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildMetricCard(
                        context: context,
                        label: 'มีบันทึกดวง',
                        count: customerService.customersWithNotes.length,
                        unit: 'ท่าน',
                        icon: Icons.menu_book_outlined,
                        color: AppColors.dayWednesday,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildMetricCard(
                        context: context,
                        label: 'เกิดเดือนนี้',
                        count: customerService.thisMonthBirthdayCustomers.length,
                        unit: 'ท่าน',
                        icon: Icons.cake_outlined,
                        color: AppColors.dayMonday,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // 2. 7-Day Planetary Breakdown
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: context.cardColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: context.borderColor),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x05000000),
                      blurRadius: 10,
                      offset: Offset(0, 3),
                    ),
                  ],
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
                              Icon(Icons.pie_chart_outline_rounded, size: 18, color: context.goldColor),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'สัดส่วนลูกดวงตามวันเกิด 7 วัน',
                                  style: TextStyle(
                                    fontSize: 15,
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
                        Text(
                          'รวม $total ท่าน',
                          style: TextStyle(fontSize: 12, color: context.subTextColor, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),

                    // Horizontal Distribution Bars
                    ...List.generate(7, (index) {
                      final weekday = index + 1;
                      final count = dayCounts[index];
                      final pct = total > 0 ? (count / total * 100).toStringAsFixed(1) : '0';
                      final barFactor = maxDayCount > 0 ? (count / maxDayCount).clamp(0.04, 1.0) : 0.04;
                      final mineralColor = _getDayMineralColor(weekday);

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 8,
                                        height: 8,
                                        decoration: BoxDecoration(
                                          color: mineralColor,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          dayNames[index],
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                            color: context.textColor,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '$count ท่าน ($pct%)',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: count > 0 ? FontWeight.bold : FontWeight.normal,
                                    color: count > 0 ? context.textColor : context.mutedTextColor,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            // Animated Smooth Progress Bar
                            AnimatedProgressBar(
                              factor: barFactor,
                              color: mineralColor,
                              height: 8,
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // 3. Province Distribution
              if (sortedProvinces.isNotEmpty) ...[
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: context.cardColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: context.borderColor),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x05000000),
                        blurRadius: 10,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.location_city_rounded, size: 18, color: context.goldColor),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'จังหวัดที่มีลูกดวงมากที่สุด',
                              style: TextStyle(
                                fontSize: 14.5,
                                fontWeight: FontWeight.bold,
                                color: context.textColor,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: sortedProvinces.take(8).map((entry) {
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF161F30) : AppColors.ivory,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: context.borderColor),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  entry.key,
                                  style: TextStyle(fontSize: 12, color: context.textColor, fontWeight: FontWeight.w500),
                                ),
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF282015) : AppColors.warmSand,
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  child: Text(
                                    '${entry.value}',
                                    style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: context.goldColor),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetricCard({
    required BuildContext context,
    required String label,
    required int count,
    required String unit,
    required IconData icon,
    required Color color,
  }) {
    return AnimatedPressable(
      scaleDown: 0.94,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        decoration: BoxDecoration(
          color: context.cardColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: context.borderColor),
          boxShadow: const [
            BoxShadow(
              color: Color(0x05000000),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(8),
              ),
              alignment: Alignment.center,
              child: Icon(icon, size: 17, color: color),
            ),
            const SizedBox(height: 10),
            AnimatedCountText(
              count: count,
              style: TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.bold,
                color: context.textColor,
                height: 1.1,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 11.5,
                color: context.subTextColor,
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
