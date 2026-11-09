import 'package:flutter/material.dart';
import '../../models/customer.dart';
import '../../utils/app_colors.dart';
import '../../utils/thai_date_helper.dart';
import '../hbd_card_dialog.dart';

class BirthdayAstrolabeGrid extends StatelessWidget {
  final int totalDaysInMonth;
  final int firstWeekday;
  final bool isCurrentMonth;
  final DateTime now;
  final DateTime displayedMonth;
  final List<Customer> monthCustomers;
  final int? selectedDay;
  final ValueChanged<int?> onSelectDay;
  final ValueChanged<Customer> onOpenCustomerDetail;

  const BirthdayAstrolabeGrid({
    super.key,
    required this.totalDaysInMonth,
    required this.firstWeekday,
    required this.isCurrentMonth,
    required this.now,
    required this.displayedMonth,
    required this.monthCustomers,
    required this.selectedDay,
    required this.onSelectDay,
    required this.onOpenCustomerDetail,
  });

  Widget _buildAstrolabeCustomerCard(BuildContext context, Customer customer) {
    final dayColor = AppColors.getDayColor(customer.birthDate.weekday);
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF131A29) : const Color(0xFFFAF9F5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.borderColor),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: dayColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: dayColor, width: 1.2),
            ),
            alignment: Alignment.center,
            child: Text(
              customer.initialLetter,
              style: TextStyle(fontWeight: FontWeight.bold, color: dayColor, fontSize: 16),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  customer.displayName,
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: context.textColor),
                ),
                Text(
                  '${customer.thaiDayOfWeek} • ครบรอบ ${customer.turningAge} ปี',
                  style: TextStyle(fontSize: 11.5, color: context.subTextColor),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => HbdCardDialog.show(context, customer: customer),
            constraints: const BoxConstraints(minWidth: 42, minHeight: 42),
            icon: Icon(
              Icons.auto_awesome,
              size: 18,
              color: context.goldColor,
            ),
            tooltip: 'อวยพร',
          ),
          IconButton(
            onPressed: () => onOpenCustomerDetail(customer),
            constraints: const BoxConstraints(minWidth: 42, minHeight: 42),
            icon: Icon(
              Icons.arrow_forward_ios_rounded,
              size: 14,
              color: context.subTextColor,
            ),
            tooltip: 'ดูรายละเอียด',
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Pre-index month customers by day-of-month into a hash map O(N) -> O(1) cell lookup
    final Map<int, List<Customer>> customersByDay = {};
    for (final customer in monthCustomers) {
      customersByDay.putIfAbsent(customer.birthDate.day, () => []).add(customer);
    }

    final weekdayLabels = [
      {'name': 'อา.', 'fullName': 'วันอาทิตย์', 'color': AppColors.daySunday},
      {'name': 'จ.', 'fullName': 'วันจันทร์', 'color': AppColors.dayMonday},
      {'name': 'อ.', 'fullName': 'วันอังคาร', 'color': AppColors.dayTuesday},
      {'name': 'พ.', 'fullName': 'วันพุธ', 'color': AppColors.dayWednesday},
      {'name': 'พฤ.', 'fullName': 'วันพฤหัสบดี', 'color': AppColors.dayThursday},
      {'name': 'ศ.', 'fullName': 'วันศุกร์', 'color': AppColors.dayFriday},
      {'name': 'ส.', 'fullName': 'วันเสาร์', 'color': AppColors.daySaturday},
    ];

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.borderColor),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          // 7-Mineral Weekday Column Headers
          Row(
            children: weekdayLabels.map((item) {
              final color = item['color'] as Color;
              final name = item['name'] as String;
              final fullName = item['fullName'] as String;
              return Expanded(
                child: Center(
                  child: Semantics(
                    header: true,
                    label: fullName,
                    excludeSemantics: true,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Text(
                        name,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          Divider(height: 14, color: context.borderColor),

          // Planetary Month Grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 0.88,
              mainAxisSpacing: 5,
              crossAxisSpacing: 5,
            ),
            itemCount: firstWeekday + totalDaysInMonth,
            itemBuilder: (context, index) {
              if (index < firstWeekday) {
                return const SizedBox.shrink();
              }
              final dayNumber = index - firstWeekday + 1;
              final isTodayCell = isCurrentMonth && dayNumber == now.day;
              final isSelectedCell = selectedDay == dayNumber;
              final dayCustomers = customersByDay[dayNumber] ?? const <Customer>[];
              final hasBirthdays = dayCustomers.isNotEmpty;

              final dayDate = DateTime(displayedMonth.year, displayedMonth.month, dayNumber);
              final thaiDayName = ThaiDateHelper.dayOfWeekName(dayDate.weekday);
              final buffer = StringBuffer('วันที่ $dayNumber $thaiDayName');
              if (isTodayCell) buffer.write(', วันนี้');
              if (hasBirthdays) {
                buffer.write(', มีวันเกิด ${dayCustomers.length} ท่าน');
                final names = dayCustomers.map((c) => c.nickname.isNotEmpty ? c.nickname : c.fullName).join(', ');
                buffer.write(': $names');
              } else {
                buffer.write(', ไม่มีวันเกิด');
              }
              final semanticLabel = buffer.toString();

              return Semantics(
                label: semanticLabel,
                button: true,
                selected: isSelectedCell,
                excludeSemantics: true,
                child: Tooltip(
                  message: 'วันที่ $dayNumber: ${hasBirthdays ? '${dayCustomers.length} ท่าน' : 'ไม่มีวันเกิด'}',
                  child: InkWell(
                    onTap: () {
                      if (selectedDay == dayNumber) {
                        onSelectDay(null);
                      } else {
                        onSelectDay(dayNumber);
                      }
                    },
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      decoration: BoxDecoration(
                        color: isSelectedCell
                            ? (Theme.of(context).brightness == Brightness.dark ? const Color(0xFF282015) : AppColors.warmSand)
                            : isTodayCell
                                ? (Theme.of(context).brightness == Brightness.dark ? const Color(0xFF381519) : const Color(0xFFFFFDF5))
                                : hasBirthdays
                                    ? (Theme.of(context).brightness == Brightness.dark ? const Color(0xFF231F1A) : AppColors.champagne.withValues(alpha: 0.35))
                                    : context.cardColor,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isSelectedCell
                              ? context.goldColor
                              : isTodayCell
                                  ? (Theme.of(context).brightness == Brightness.dark ? const Color(0xFFEF4444) : AppColors.amberGold)
                                  : hasBirthdays
                                      ? (Theme.of(context).brightness == Brightness.dark ? const Color(0xFFB45309) : AppColors.amberGold.withValues(alpha: 0.8))
                                      : context.borderColor,
                          width: isSelectedCell || isTodayCell ? 1.5 : 1.0,
                        ),
                        boxShadow: isSelectedCell
                            ? const [
                                BoxShadow(
                                  color: AppColors.goldGlow,
                                  blurRadius: 6,
                                  offset: Offset(0, 2),
                                ),
                              ]
                            : null,
                      ),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '$dayNumber',
                              style: TextStyle(
                                fontSize: 12.5,
                                fontWeight: isTodayCell || isSelectedCell || hasBirthdays ? FontWeight.bold : FontWeight.w500,
                                color: isSelectedCell
                                    ? context.goldColor
                                    : isTodayCell
                                        ? const Color(0xFFDC2626)
                                        : hasBirthdays
                                            ? context.goldColor
                                            : context.textColor,
                              ),
                            ),
                            const SizedBox(height: 2),
                            if (hasBirthdays)
                              // Celebrant Mini Pill with count
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                decoration: BoxDecoration(
                                  color: isTodayCell ? const Color(0xFFDC2626) : context.goldColor,
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                child: Text(
                                  '${dayCustomers.length}',
                                  style: const TextStyle(
                                    fontSize: 8.5,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              )
                            else if (isTodayCell)
                              Container(
                                width: 4,
                                height: 4,
                                decoration: const BoxDecoration(
                                  color: Color(0xFFDC2626),
                                  shape: BoxShape.circle,
                                ),
                              )
                            else
                              const SizedBox(height: 12),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),

          // Day Constellation Panel (แผ่นจารึกดวงชะตาประจำวัน)
          if (selectedDay != null) ...[
            () {
              final selectedDayCustomers = customersByDay[selectedDay!] ?? const <Customer>[];
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Divider(height: 24, thickness: 0.8, color: context.borderColor),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'ลูกดวงที่เกิดวันที่ $selectedDay (${selectedDayCustomers.length} ท่าน)',
                        style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold, color: context.textColor),
                      ),
                      TextButton(
                        onPressed: () => onSelectDay(null),
                        child: Text('ดูทั้งเดือน', style: TextStyle(fontSize: 12, color: context.goldColor)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ...selectedDayCustomers.map((c) => _buildAstrolabeCustomerCard(context, c)),
                  if (selectedDayCustomers.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Text('ไม่มีลูกดวงเกิดในวันที่เลือก', style: TextStyle(fontSize: 12.5, color: AppColors.mutedText)),
                    ),
                ],
              );
            }(),
          ],
        ],
      ),
    );
  }
}
