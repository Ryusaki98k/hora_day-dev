import 'package:flutter/material.dart';
import '../models/customer.dart';
import '../services/customer_service.dart';
import '../utils/app_colors.dart';
import '../utils/thai_date_helper.dart';
import 'customer_detail_dialog.dart';

/// ป๊อปอัปปฏิทินวันเกิดมงคล (Birthday Calendar Popup Dialog)
/// เปิดขึ้นด้วยแอนิเมชันพลิกปฏิทิน 3D พร้อมผังวันเกิดและรายชื่อผู้เกิดในเดือนนี้
class CalendarPopupDialog extends StatefulWidget {
  final CustomerService customerService;
  final VoidCallback onOpenFullHub;

  const CalendarPopupDialog({
    super.key,
    required this.customerService,
    required this.onOpenFullHub,
  });

  static Future<void> show(
    BuildContext context, {
    required CustomerService customerService,
    required VoidCallback onOpenFullHub,
  }) {
    return showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.45),
      builder: (context) {
        return CalendarPopupDialog(
          customerService: customerService,
          onOpenFullHub: onOpenFullHub,
        );
      },
    );
  }

  @override
  State<CalendarPopupDialog> createState() => _CalendarPopupDialogState();
}

class _CalendarPopupDialogState extends State<CalendarPopupDialog> {
  late DateTime _currentMonth;
  int? _selectedDay;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _currentMonth = DateTime(now.year, now.month, 1);
    _selectedDay = now.day;
  }

  Color _getWeekdayColor(int weekday) {
    switch (weekday) {
      case 1:
        return const Color(0xFFF59E0B); // จันทร์
      case 2:
        return const Color(0xFFEC4899); // อังคาร
      case 3:
        return const Color(0xFF10B981); // พุธ
      case 4:
        return const Color(0xFFF97316); // พฤหัส
      case 5:
        return const Color(0xFF06B6D4); // ศุกร์
      case 6:
        return const Color(0xFF8B5CF6); // เสาร์
      case 7:
        return const Color(0xFFEF4444); // อาทิตย์
      default:
        return AppColors.caramelBronze;
    }
  }


  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final isCurrentMonth = _currentMonth.year == now.year && _currentMonth.month == now.month;
    final monthName = ThaiDateHelper.monthName(_currentMonth.month);
    final thaiYear = _currentMonth.year + 543;

    final daysInMonth = DateTime(_currentMonth.year, _currentMonth.month + 1, 0).day;
    final firstWeekday = DateTime(_currentMonth.year, _currentMonth.month, 1).weekday; // 1=Mon..7=Sun

    // ลูกดวงที่เกิดในเดือนนี้
    final monthCustomers = widget.customerService.customers.where((c) {
      return c.birthDate.month == _currentMonth.month;
    }).toList();

    // ลูกดวงในวันที่เลือก
    final selectedDayCustomers = _selectedDay != null
        ? monthCustomers.where((c) => c.birthDate.day == _selectedDay).toList()
        : <Customer>[];

    final isMobile = MediaQuery.of(context).size.width < 640;

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: isMobile ? MediaQuery.of(context).size.width * 0.94 : 520,
          maxHeight: MediaQuery.of(context).size.height * 0.88,
        ),
        child: Material(
          color: Colors.transparent,
          child: Container(
            decoration: BoxDecoration(
              color: context.cardColor,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: context.borderColor),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x28000000),
                  blurRadius: 32,
                  offset: Offset(0, 12),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 1. Calendar Header (สันเกลียวปฏิทิน + สรุปดวงดาว)
                  Container(
                    padding: const EdgeInsets.fromLTRB(18, 14, 14, 12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: context.isDark
                            ? const [Color(0xFF1E2538), Color(0xFF131A29)]
                            : const [Color(0xFFFEF3C7), Color(0xFFFDE68A)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      border: Border(
                        bottom: BorderSide(color: context.borderColor, width: 1),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: context.isDark ? const Color(0xFF1E293B) : Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: const [
                              BoxShadow(color: Color(0x10000000), blurRadius: 4, offset: Offset(0, 2)),
                            ],
                          ),
                          alignment: Alignment.center,
                          child: Icon(
                            Icons.calendar_month_rounded,
                            color: context.goldColor,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Flexible(
                                    child: Text(
                                      '$monthName $thaiYear',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: context.textColor,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  if (isCurrentMonth) ...[
                                    const SizedBox(width: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                                      decoration: BoxDecoration(
                                        color: context.goldColor,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        'ปัจจุบัน',
                                        style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold, color: context.isDark ? AppColors.celestialVoid : Colors.white),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                              Text(
                                'มีลูกดวงเกิดเดือนนี้ ${monthCustomers.length} ท่าน',
                                style: TextStyle(fontSize: 11.5, color: context.goldColor, fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ),

                        // Month navigation buttons
                        IconButton(
                          icon: Icon(Icons.chevron_left_rounded, size: 22, color: context.goldColor),
                          onPressed: () {
                            setState(() {
                              _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1, 1);
                              _selectedDay = null;
                            });
                          },
                          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                          padding: EdgeInsets.zero,
                          tooltip: 'เดือนก่อนหน้า',
                        ),
                        IconButton(
                          icon: Icon(Icons.chevron_right_rounded, size: 22, color: context.goldColor),
                          onPressed: () {
                            setState(() {
                              _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1, 1);
                              _selectedDay = null;
                            });
                          },
                          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                          padding: EdgeInsets.zero,
                          tooltip: 'เดือนถัดไป',
                        ),
                        const SizedBox(width: 4),

                        // Close Button
                        IconButton(
                          icon: Icon(Icons.close_rounded, size: 20, color: context.textColor),
                          onPressed: () => Navigator.of(context).pop(),
                          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                          padding: EdgeInsets.zero,
                        ),
                      ],
                    ),
                  ),

                  // 2. Calendar Grid Area
                  Flexible(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Weekday Headers (อาทิตย์ - เสาร์)
                          Row(
                            children: [
                              _buildWeekdayHeader('อา', const Color(0xFFEF4444)),
                              _buildWeekdayHeader('จ', const Color(0xFFF59E0B)),
                              _buildWeekdayHeader('อ', const Color(0xFFEC4899)),
                              _buildWeekdayHeader('พ', const Color(0xFF10B981)),
                              _buildWeekdayHeader('พฤ', const Color(0xFFF97316)),
                              _buildWeekdayHeader('ศ', const Color(0xFF06B6D4)),
                              _buildWeekdayHeader('ส', const Color(0xFF8B5CF6)),
                            ],
                          ),
                          const SizedBox(height: 6),

                          // Days Matrix
                          _buildMonthDaysGrid(
                            firstWeekday: firstWeekday,
                            daysInMonth: daysInMonth,
                            isCurrentMonth: isCurrentMonth,
                            today: now.day,
                            monthCustomers: monthCustomers,
                          ),

                          const SizedBox(height: 14),

                          // 3. Selected Day Celebrants Section
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: context.isDark ? const Color(0xFF1E2538) : const Color(0xFFFBF8F2),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: context.borderColor),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(Icons.stars_rounded, size: 16, color: context.goldColor),
                                        const SizedBox(width: 6),
                                        Text(
                                          _selectedDay != null
                                              ? 'ลูกดวงเกิดวันที่ $_selectedDay $monthName'
                                              : 'แตะวันที่บนปฏิทินเพื่อดูลูกดวง',
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold,
                                            color: context.textColor,
                                          ),
                                        ),
                                      ],
                                    ),
                                    if (selectedDayCustomers.isNotEmpty)
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 1.5),
                                        decoration: BoxDecoration(
                                          color: context.goldColor,
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          '${selectedDayCustomers.length} ท่าน',
                                          style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: context.isDark ? AppColors.celestialVoid : Colors.white),
                                        ),
                                      ),
                                  ],
                                ),

                                const SizedBox(height: 8),

                                if (_selectedDay == null || selectedDayCustomers.isEmpty)
                                  Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 8),
                                    child: Center(
                                      child: Text(
                                        _selectedDay == null
                                            ? 'แตะเลือกวันที่มีจุดมงคลสีทองเพื่อดูรายชื่อ'
                                            : 'ไม่มีลูกดวงเกิดในวันที่ $_selectedDay $monthName',
                                        style: TextStyle(fontSize: 12, color: context.subTextColor),
                                      ),
                                    ),
                                  )
                                else
                                  ...selectedDayCustomers.map((customer) {
                                    final isToday = customer.daysUntilNextBirthday == 0;
                                    return Container(
                                      margin: const EdgeInsets.only(bottom: 6),
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: context.cardColor,
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(
                                          color: isToday ? context.goldColor : context.borderColor,
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 32,
                                            height: 32,
                                            decoration: BoxDecoration(
                                              color: _getWeekdayColor(customer.birthDate.weekday).withValues(alpha: 0.15),
                                              shape: BoxShape.circle,
                                              border: Border.all(color: _getWeekdayColor(customer.birthDate.weekday)),
                                            ),
                                            alignment: Alignment.center,
                                            child: Text(
                                              customer.initialLetter,
                                              style: TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.bold,
                                                color: _getWeekdayColor(customer.birthDate.weekday),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  customer.displayName,
                                                  style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold, color: context.textColor),
                                                ),
                                                Text(
                                                  '${customer.thaiDayOfWeek} • อายุย่าง ${customer.turningAge} ปี',
                                                  style: TextStyle(fontSize: 11, color: context.mutedTextColor),
                                                ),
                                              ],
                                            ),
                                          ),
                                          IconButton(
                                            icon: Icon(Icons.arrow_forward_ios_rounded, size: 13, color: context.subTextColor),
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                              CustomerDetailDialog.show(
                                                context,
                                                customer: customer,
                                                onUpdate: (updated) => widget.customerService.updateCustomer(updated),
                                                onDelete: () => widget.customerService.deleteCustomer(customer.id),
                                              );
                                            },
                                            constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                                            padding: EdgeInsets.zero,
                                          ),
                                        ],
                                      ),
                                    );
                                  }),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // 4. Footer Action (เปิดปฏิทินเต็มจอ)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: context.isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                      border: Border(top: BorderSide(color: context.borderColor)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton.icon(
                          onPressed: () {
                            setState(() {
                              _currentMonth = DateTime(now.year, now.month, 1);
                              _selectedDay = now.day;
                            });
                          },
                          icon: Icon(Icons.today_rounded, size: 16, color: context.goldColor),
                          label: Text('กลับสู่วันนี้', style: TextStyle(fontSize: 12, color: context.goldColor, fontWeight: FontWeight.bold)),
                        ),
                        ElevatedButton.icon(
                          onPressed: () {
                            Navigator.of(context).pop();
                            widget.onOpenFullHub();
                          },
                          icon: const Icon(Icons.open_in_full_rounded, size: 15),
                          label: const Text('ศูนย์วันเกิดเต็มจอ'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: context.goldColor,
                            foregroundColor: context.isDark ? AppColors.celestialVoid : Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            elevation: 0,
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
      ),
    );
  }

  Widget _buildWeekdayHeader(String label, Color color) {
    return Expanded(
      child: Center(
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ),
    );
  }

  Widget _buildMonthDaysGrid({
    required int firstWeekday,
    required int daysInMonth,
    required bool isCurrentMonth,
    required int today,
    required List<Customer> monthCustomers,
  }) {
    // อาทิตย์ = 7 ใน DateTime.weekday, แปลงให้อาทิตย์เป็นคอลัมน์แรก (0)
    final startOffset = firstWeekday == 7 ? 0 : firstWeekday;
    final totalCells = ((startOffset + daysInMonth) / 7).ceil() * 7;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        childAspectRatio: 1.15,
        crossAxisSpacing: 3,
        mainAxisSpacing: 3,
      ),
      itemCount: totalCells,
      itemBuilder: (context, index) {
        final dayNum = index - startOffset + 1;
        if (dayNum < 1 || dayNum > daysInMonth) {
          return const SizedBox.shrink();
        }

        final isToday = isCurrentMonth && dayNum == today;
        final isSelected = _selectedDay == dayNum;

        // นับจำนวนลูกดวงในวันนี้
        final celebrants = monthCustomers.where((c) => c.birthDate.day == dayNum).toList();
        final hasCelebrants = celebrants.isNotEmpty;

        return InkWell(
          onTap: () {
            setState(() {
              _selectedDay = dayNum;
            });
          },
          borderRadius: BorderRadius.circular(8),
          child: Container(
            decoration: BoxDecoration(
              color: isSelected
                  ? context.goldColor
                  : isToday
                      ? (context.isDark ? const Color(0xFF332A15) : AppColors.champagne.withValues(alpha: 0.6))
                      : hasCelebrants
                          ? (context.isDark ? const Color(0xFF1E293B) : const Color(0xFFFFFBEB))
                          : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isSelected
                    ? context.goldColor
                    : isToday
                        ? context.goldColor
                        : hasCelebrants
                            ? (context.isDark ? const Color(0xFFFDE047).withValues(alpha: 0.6) : AppColors.amberGold.withValues(alpha: 0.6))
                            : Colors.transparent,
                width: isToday || isSelected ? 1.5 : 0.8,
              ),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Text(
                  '$dayNum',
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: isToday || isSelected || hasCelebrants ? FontWeight.bold : FontWeight.w500,
                    color: isSelected
                        ? (context.isDark ? AppColors.celestialVoid : Colors.white)
                        : isToday
                            ? context.goldColor
                            : context.textColor,
                  ),
                ),
                if (hasCelebrants)
                  Positioned(
                    bottom: 2,
                    child: Container(
                      width: 5,
                      height: 5,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? (context.isDark ? AppColors.celestialVoid : Colors.white)
                            : (context.isDark ? const Color(0xFFFDE047) : AppColors.amberGold),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
