import 'package:flutter/material.dart';
import '../../models/customer.dart';
import '../../utils/app_colors.dart';
import '../../utils/line_helper.dart';
import '../../utils/thai_date_helper.dart';
import '../hbd_card_dialog.dart';
import 'birthday_empty_state.dart';
import 'timeline_node_painter.dart';

class BirthdayMeridianTimeline extends StatelessWidget {
  final List<Customer> todayBirthdays;
  final List<Customer> upcomingBirthdays;
  final List<Customer> monthCustomers;
  final DateTime displayedMonth;
  final String activeScope;
  final int? selectedDay;
  final DateTime now;
  final ValueChanged<Customer> onOpenCustomerDetail;
  final VoidCallback onOpenAddCustomer;

  const BirthdayMeridianTimeline({
    super.key,
    required this.todayBirthdays,
    required this.upcomingBirthdays,
    required this.monthCustomers,
    required this.displayedMonth,
    required this.activeScope,
    required this.selectedDay,
    required this.now,
    required this.onOpenCustomerDetail,
    required this.onOpenAddCustomer,
  });

  static String _getDayAbbrev(int weekday) {
    switch (weekday) {
      case 1:
        return 'จ.';
      case 2:
        return 'อ.';
      case 3:
        return 'พ.';
      case 4:
        return 'พฤ.';
      case 5:
        return 'ศ.';
      case 6:
        return 'ส.';
      case 7:
        return 'อา.';
      default:
        return '';
    }
  }

  Widget _buildMeridianTimelineRow(
    BuildContext context,
    Customer customer, {
    required bool isFirst,
    required bool isLast,
    required bool isToday,
  }) {
    final dayColor = AppColors.getDayColor(customer.birthDate.weekday);
    final dayAbbrev = _getDayAbbrev(customer.birthDate.weekday);
    final birthDateStr = ThaiDateHelper.formatShort(customer.birthDate);
    final daysUntil = customer.daysUntilNextBirthday;

    return CustomPaint(
      painter: TimelineNodePainter(
        isFirst: isFirst,
        isLast: isLast,
        isToday: isToday,
        dayColor: dayColor,
        isDark: context.isDark,
      ),
      child: Padding(
        padding: const EdgeInsets.only(left: 36),
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: isToday
                ? (Theme.of(context).brightness == Brightness.dark ? const Color(0xFF282015) : const Color(0xFFFFFBEB))
                : (Theme.of(context).brightness == Brightness.dark ? const Color(0xFF131A29) : const Color(0xFFFBF8F2)),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isToday ? context.goldColor : context.borderColor,
              width: isToday ? 1.4 : 1.0,
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x05000000),
                blurRadius: 6,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(14),
            child: InkWell(
              onTap: () => onOpenCustomerDetail(customer),
              borderRadius: BorderRadius.circular(14),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                          margin: const EdgeInsets.only(right: 8),
                          decoration: BoxDecoration(
                            color: dayColor.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '${customer.birthDate.day} $dayAbbrev',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: dayColor,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            customer.displayName,
                            style: TextStyle(
                              fontSize: 14.5,
                              fontWeight: FontWeight.bold,
                              color: context.textColor,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (isToday)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(
                              color: context.isDark ? const Color(0xFF381519) : const Color(0xFFFEF2F2),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: context.isDark ? const Color(0xFF7F1D1D) : const Color(0xFFFECDD3),
                              ),
                            ),
                            child: Text(
                              'วันนี้!',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: context.isDark ? const Color(0xFFFCA5A5) : const Color(0xFFDC2626),
                              ),
                            ),
                          )
                        else if (daysUntil <= 7)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                            decoration: BoxDecoration(
                              color: AppColors.champagne.withValues(alpha: 0.45),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'อีก $daysUntil วัน',
                              style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: context.goldColor),
                            ),
                          ),
                      ],
                    ),

                    const SizedBox(height: 6),

                    // Subtitle: Age & Horoscope info (Single text widget to prevent overflow)
                    Text(
                      'เกิด $birthDateStr • ครบรอบ ${customer.turningAge} ปี${customer.birthTime != null && customer.birthTime!.isNotEmpty ? ' • เวลา ${customer.birthTime}' : ''}',
                      style: TextStyle(fontSize: 11.5, color: context.subTextColor),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),

                    // Notes Snippet if available
                    if (customer.notes.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1E293B) : const Color(0xFFFAF9F5),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.edit_note, size: 13, color: context.goldColor),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                customer.notes,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 11, color: AppColors.subText),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: 8),

                    // Action Chips Bar — อวยพร primary
                    Row(
                      children: [
                        SizedBox(
                          height: 48,
                          child: ElevatedButton(
                            onPressed: () => HbdCardDialog.show(
                              context,
                              customer: customer,
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.caramelBronze,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.card_giftcard_rounded, size: 16),
                                SizedBox(width: 6),
                                Text(
                                  'อวยพร',
                                  style: TextStyle(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const Spacer(),
                        if (customer.lineId.isNotEmpty) ...[
                          const SizedBox(width: 6),
                          InkWell(
                            onTap: () => LineHelper.openLineChat(
                              context,
                              rawLineId: customer.lineId,
                              customerName: customer.displayName,
                            ),
                            borderRadius: BorderRadius.circular(10),
                            child: Container(
                              constraints: const BoxConstraints(minHeight: 48, minWidth: 48),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: context.isDark
                                    ? const Color(0xFF132B1D)
                                    : const Color(0xFFE8F9EE),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: context.isDark
                                      ? const Color(0xFF166534)
                                      : const Color(0xFF86EFAC),
                                ),
                              ),
                              alignment: Alignment.center,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.chat_bubble_rounded,
                                    size: 14,
                                    color: context.isDark ? const Color(0xFF4ADE80) : const Color(0xFF00B900),
                                  ),
                                  const SizedBox(width: 5),
                                  Text(
                                    'LINE',
                                    style: TextStyle(
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.bold,
                                      color: context.isDark
                                          ? const Color(0xFF4ADE80)
                                          : const Color(0xFF00B900),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Apply scope filter if selected
    List<Customer> displayList = List.from(monthCustomers);
    if (activeScope == 'วันนี้') {
      displayList = displayList.where((c) => c.birthDate.day == now.day && displayedMonth.month == now.month).toList();
    } else if (activeScope == 'สัปดาห์นี้') {
      displayList = displayList.where((c) {
        if (displayedMonth.month != now.month) return false;
        final diff = c.birthDate.day - now.day;
        return diff >= 0 && diff <= 7;
      }).toList();
    } else if (selectedDay != null) {
      displayList = displayList.where((c) => c.birthDate.day == selectedDay).toList();
    }

    if (displayList.isEmpty) {
      return BirthdayEmptyState(
        message: selectedDay != null
            ? 'ไม่มีลูกดวงเกิดในวันที่ $selectedDay ของเดือนนี้'
            : activeScope != 'ทั้งหมด'
                ? 'ไม่มีลูกดวงในระยะ "$activeScope"'
                : 'เดือนนี้ยังไม่มีลูกดวงครบรอบวันเกิด',
        selectedDay: selectedDay,
        onAddBirthday: onOpenAddCustomer,
      );
    }

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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            child: Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 8,
              runSpacing: 4,
              children: [
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 240),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.all_inclusive_rounded, size: 15, color: context.goldColor),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          selectedDay != null
                              ? 'สายธารวันที่ $selectedDay (${displayList.length} ท่าน)'
                              : 'สายธารวันเกิดตามลำดับ (${displayList.length} ท่าน)',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: context.textColor),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  'เรียงตามวันที่ ๑ - ๓๑',
                  style: TextStyle(fontSize: 11, color: context.mutedTextColor),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Meridian Timeline Items with continuous vertical guideline
          Column(
            children: [
              for (int idx = 0; idx < displayList.length; idx++)
                _buildMeridianTimelineRow(
                  context,
                  displayList[idx],
                  isFirst: idx == 0,
                  isLast: idx == displayList.length - 1,
                  isToday: displayList[idx].birthDate.day == now.day && displayedMonth.month == now.month,
                ),
            ],
          ),
        ],
      ),
    );
  }
}
